import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import 'package:gear_freak_flutter/feature/product/di/product_providers.dart';
import 'package:gear_freak_flutter/feature/product/domain/usecase/delete_product_usecase.dart';
import 'package:gear_freak_flutter/feature/product/domain/usecase/get_product_detail_usecase.dart';
import 'package:gear_freak_flutter/feature/product/domain/usecase/increment_view_count_usecase.dart';
import 'package:gear_freak_flutter/feature/product/domain/usecase/is_favorite_usecase.dart';
import 'package:gear_freak_flutter/feature/product/domain/usecase/toggle_favorite_usecase.dart';
import 'package:gear_freak_flutter/feature/product/domain/usecase/update_product_status_usecase.dart';
import 'package:gear_freak_flutter/feature/product/presentation/provider/product_detail_state.dart';
import 'package:gear_freak_flutter/feature/profile/domain/usecase/get_user_by_id_usecase.dart';
import 'package:gear_freak_flutter/feature/review/di/review_providers.dart';
import 'package:gear_freak_flutter/feature/review/domain/usecase/delete_reviews_by_product_id_usecase.dart';

/// 상품 상세 Notifier
class ProductDetailNotifier extends StateNotifier<ProductDetailState> {
  /// ProductDetailNotifier 생성자
  ///
  /// [ref]는 Riverpod의 Ref 인스턴스입니다.
  /// [getProductDetailUseCase]는 상품 상세 조회 UseCase 인스턴스입니다.
  /// [toggleFavoriteUseCase]는 찜 토글 UseCase 인스턴스입니다.
  /// [isFavoriteUseCase]는 찜 상태 조회 UseCase 인스턴스입니다.
  /// [incrementViewCountUseCase]는 조회수 증가 UseCase 인스턴스입니다.
  /// [getUserByIdUseCase]는 사용자 ID로 사용자 정보 조회 UseCase 인스턴스입니다.
  /// [deleteProductUseCase]는 상품 삭제 UseCase 인스턴스입니다.
  /// [updateProductStatusUseCase]는 상품 상태 변경 UseCase 인스턴스입니다.
  ProductDetailNotifier(
    this.ref,
    this.getProductDetailUseCase,
    this.toggleFavoriteUseCase,
    this.isFavoriteUseCase,
    this.incrementViewCountUseCase,
    this.getUserByIdUseCase,
    this.deleteProductUseCase,
    this.updateProductStatusUseCase,
  ) : super(const ProductDetailInitial());

  /// Riverpod Ref 인스턴스
  final Ref ref;

  /// 상품 상세 조회 UseCase 인스턴스
  final GetProductDetailUseCase getProductDetailUseCase;

  /// 찜 토글 UseCase 인스턴스
  final ToggleFavoriteUseCase toggleFavoriteUseCase;

  /// 찜 상태 조회 UseCase 인스턴스
  final IsFavoriteUseCase isFavoriteUseCase;

  /// 조회수 증가 UseCase 인스턴스
  final IncrementViewCountUseCase incrementViewCountUseCase;

  /// 사용자 ID로 사용자 정보 조회 UseCase 인스턴스
  final GetUserByIdUseCase getUserByIdUseCase;

  /// 상품 삭제 UseCase 인스턴스
  final DeleteProductUseCase deleteProductUseCase;

  /// 상품 상태 변경 UseCase 인스턴스
  final UpdateProductStatusUseCase updateProductStatusUseCase;

  /// 상품 ID로 후기 삭제 UseCase 인스턴스
  DeleteReviewsByProductIdUseCase get _deleteReviewsByProductIdUseCase =>
      ref.read(deleteReviewsByProductIdUseCaseProvider);

  // ==================== Public Methods (UseCase 호출) ====================

  /// 상품 상세 조회
  Future<void> loadProductDetail(int id) async {
    state = const ProductDetailLoading();

    final result = await getProductDetailUseCase(id);

    await result.fold(
      (failure) async {
        state = ProductDetailError(failure.message);
      },
      (product) async {
        // seller 정보가 없으면 getUserByIdUseCase를 통해 가져오기
        var sellerData = product.seller;
        if (sellerData == null) {
          final sellerResult = await getUserByIdUseCase(product.sellerId);
          sellerResult.fold(
            (failure) {
              // seller 정보를 가져오지 못해도 상품 정보는 표시
              debugPrint('판매자 정보를 불러오는데 실패했습니다: ${failure.message}');
            },
            (user) {
              sellerData = user;
            },
          );
        }

        // 찜 상태 조회
        var isFavorite = false;
        if (product.id != null) {
          final favoriteResult = await isFavoriteUseCase(product.id!);
          favoriteResult.fold(
            (failure) {
              debugPrint('찜 상태를 불러오는데 실패했습니다: ${failure.message}');
            },
            (favorite) {
              isFavorite = favorite;
            },
          );
        }

        state = ProductDetailLoaded(
          product: product,
          seller: sellerData,
          isFavorite: isFavorite,
        );

        // 조회수 증가 (비동기, 실패해도 상품 정보는 표시)
        if (product.id != null) {
          unawaited(incrementViewCount(product.id!));
        }
      },
    );
  }

  /// 조회수 증가 (계정당 1회)
  /// 반환값: true = 조회수 증가됨, false = 이미 조회함 (증가 안 됨)
  Future<bool> incrementViewCount(int productId) async {
    final result = await incrementViewCountUseCase(productId);
    return result.fold(
      (failure) {
        debugPrint('조회수 증가 실패: ${failure.message}');
        return false;
      },
      (incremented) {
        // 조회수가 증가한 경우 상품 정보 업데이트
        if (incremented) {
          final currentState = state;
          if (currentState is ProductDetailLoaded) {
            final productResult = getProductDetailUseCase(productId);
            productResult.then((result) {
              result.fold(
                (failure) {
                  debugPrint('상품 정보를 불러오는데 실패했습니다: ${failure.message}');
                },
                (updatedProduct) {
                  final updatedState = state;
                  if (updatedState is ProductDetailLoaded) {
                    state = updatedState.copyWith(product: updatedProduct);
                    // 조회수 증가 성공 시 이벤트 발행 (목록 Provider가 갱신)
                    ref.read(updatedProductProvider.notifier).state =
                        updatedProduct;
                    // 이벤트 처리 후 초기화 (다음 업데이트를 위해)
                    Future.microtask(() {
                      ref.read(updatedProductProvider.notifier).state = null;
                    });
                  }
                },
              );
            });
          }
        }
        return incremented;
      },
    );
  }

  /// 찜 토글
  Future<void> toggleFavorite(int productId) async {
    final currentState = state;
    if (currentState is! ProductDetailLoaded) return;

    // 낙관적 업데이트 -> 업데이트가 될것이라 확신하고 UI를 먼저 업데이트.
    final previousIsFavorite = currentState.isFavorite;
    state = currentState.copyWith(
      isFavorite: !previousIsFavorite,
    );

    final result = await toggleFavoriteUseCase(productId);

    await result.fold(
      (failure) {
        // 실패 시 이전 상태로 복원
        state = currentState.copyWith(isFavorite: previousIsFavorite);
        debugPrint('찜 상태 변경 실패: ${failure.message}');
      },
      (isFavorite) async {
        // 성공 시 상품 정보도 업데이트 (favoriteCount 변경)
        final productResult = await getProductDetailUseCase(productId);
        productResult.fold(
          (failure) {
            // 상품 정보 업데이트 실패해도 찜 상태는 유지
            debugPrint('상품 정보를 불러오는데 실패했습니다: ${failure.message}');
          },
          (updatedProduct) {
            state = currentState.copyWith(
              product: updatedProduct,
              isFavorite: isFavorite,
            );
            // 찜 토글 성공 시 이벤트 발행 (ProfileNotifier가 stats 갱신)
            ref.read(updatedProductProvider.notifier).state = updatedProduct;
            // 이벤트 처리 후 초기화 (다음 업데이트를 위해)
            Future.microtask(() {
              ref.read(updatedProductProvider.notifier).state = null;
            });
          },
        );
      },
    );
  }

  /// 상품 삭제
  /// 반환값: true = 삭제 성공, false = 삭제 실패
  Future<bool> deleteProduct(int productId) async {
    final result = await deleteProductUseCase(productId);

    return result.fold(
      (failure) {
        debugPrint('상품 삭제 실패: ${failure.message}');
        return false;
      },
      (_) {
        debugPrint('상품 삭제 성공: $productId');
        // 삭제 성공 시 이벤트 발행 (모든 목록 Provider가 자동으로 반응)
        ref.read(deletedProductIdProvider.notifier).state = productId;
        // 이벤트 처리 후 초기화 (다음 삭제를 위해)
        Future.microtask(() {
          ref.read(deletedProductIdProvider.notifier).state = null;
        });
        return true;
      },
    );
  }

  /// 상품 상태 변경
  Future<bool> updateProductStatus(
    int productId,
    pod.ProductStatus status,
  ) async {
    final currentState = state;
    if (currentState is! ProductDetailLoaded) return false;

    final currentStatus =
        currentState.product.status ?? pod.ProductStatus.selling;

    // 판매완료에서 판매중/예약중으로 변경하는 경우 후기 삭제
    if (currentStatus == pod.ProductStatus.sold &&
        (status == pod.ProductStatus.selling ||
            status == pod.ProductStatus.reserved)) {
      debugPrint('🔄 상품 상태 변경: 판매완료 -> ${status.name}, 후기 삭제 시작');
      final deleteResult = await _deleteReviewsByProductIdUseCase(
        DeleteReviewsByProductIdParams(productId: productId),
      );
      deleteResult.fold(
        (failure) {
          debugPrint('⚠️ 후기 삭제 실패 (상태 변경은 계속 진행): ${failure.message}');
        },
        (deletedCount) {
          debugPrint('✅ 후기 삭제 완료: $deletedCount개 삭제됨');
        },
      );
    }

    // 낙관적 업데이트
    final updatedProduct = pod.Product(
      id: currentState.product.id,
      sellerId: currentState.product.sellerId,
      title: currentState.product.title,
      category: currentState.product.category,
      price: currentState.product.price,
      condition: currentState.product.condition,
      description: currentState.product.description,
      tradeMethod: currentState.product.tradeMethod,
      baseAddress: currentState.product.baseAddress,
      detailAddress: currentState.product.detailAddress,
      imageUrls: currentState.product.imageUrls,
      status: status,
      viewCount: currentState.product.viewCount,
      favoriteCount: currentState.product.favoriteCount,
      chatCount: currentState.product.chatCount,
      createdAt: currentState.product.createdAt,
      updatedAt: currentState.product.updatedAt,
      seller: currentState.product.seller,
    );
    state = currentState.copyWith(product: updatedProduct);

    final request = pod.UpdateProductStatusRequestDto(
      productId: productId,
      status: status,
    );

    final result = await updateProductStatusUseCase(request);

    return result.fold(
      (failure) {
        // 실패 시 이전 상태로 복원
        state = currentState;
        debugPrint('상품 상태 변경 실패: ${failure.message}');
        return false;
      },
      (updatedProduct) {
        // 성공 시 상품 정보 업데이트
        state = currentState.copyWith(product: updatedProduct);
        debugPrint('상품 상태 변경 성공: $productId -> ${status.name}');
        // 상태 변경 이벤트 발행 (모든 목록 Provider와 ProfileNotifier가 자동으로 반응)
        ref.read(updatedProductProvider.notifier).state = updatedProduct;
        // 이벤트 처리 후 초기화 (다음 업데이트를 위해)
        Future.microtask(() {
          ref.read(updatedProductProvider.notifier).state = null;
        });
        return true;
      },
    );
  }

  // ==================== Public Methods (Service 호출) ====================

  // ==================== Private Helper Methods ====================
}
