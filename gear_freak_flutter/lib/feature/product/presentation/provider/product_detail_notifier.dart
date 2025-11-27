import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gear_freak_flutter/feature/product/di/product_providers.dart';
import 'package:gear_freak_flutter/feature/product/domain/usecase/delete_product_usecase.dart';
import 'package:gear_freak_flutter/feature/product/domain/usecase/get_product_detail_usecase.dart';
import 'package:gear_freak_flutter/feature/product/domain/usecase/is_favorite_usecase.dart';
import 'package:gear_freak_flutter/feature/product/domain/usecase/toggle_favorite_usecase.dart';
import 'package:gear_freak_flutter/feature/product/presentation/provider/product_detail_state.dart';
import 'package:gear_freak_flutter/feature/profile/domain/usecase/get_user_by_id_usecase.dart';

/// 상품 상세 Notifier
class ProductDetailNotifier extends StateNotifier<ProductDetailState> {
  /// ProductDetailNotifier 생성자
  ///
  /// [ref]는 Riverpod의 Ref 인스턴스입니다.
  /// [getProductDetailUseCase]는 상품 상세 조회 UseCase 인스턴스입니다.
  /// [toggleFavoriteUseCase]는 찜 토글 UseCase 인스턴스입니다.
  /// [isFavoriteUseCase]는 찜 상태 조회 UseCase 인스턴스입니다.
  /// [getUserByIdUseCase]는 사용자 ID로 사용자 정보 조회 UseCase 인스턴스입니다.
  /// [deleteProductUseCase]는 상품 삭제 UseCase 인스턴스입니다.
  ProductDetailNotifier(
    this.ref,
    this.getProductDetailUseCase,
    this.toggleFavoriteUseCase,
    this.isFavoriteUseCase,
    this.getUserByIdUseCase,
    this.deleteProductUseCase,
  ) : super(const ProductDetailInitial());

  /// Riverpod Ref 인스턴스
  final Ref ref;

  /// 상품 상세 조회 UseCase 인스턴스
  final GetProductDetailUseCase getProductDetailUseCase;

  /// 찜 토글 UseCase 인스턴스
  final ToggleFavoriteUseCase toggleFavoriteUseCase;

  /// 찜 상태 조회 UseCase 인스턴스
  final IsFavoriteUseCase isFavoriteUseCase;

  /// 사용자 ID로 사용자 정보 조회 UseCase 인스턴스
  final GetUserByIdUseCase getUserByIdUseCase;

  /// 상품 삭제 UseCase 인스턴스
  final DeleteProductUseCase deleteProductUseCase;

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
}
