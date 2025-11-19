import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import '../../domain/usecase/get_product_detail_usecase.dart';
import '../../domain/usecase/toggle_favorite_usecase.dart';
import '../../domain/usecase/is_favorite_usecase.dart';
import '../../../profile/domain/usecase/get_user_by_id_usecase.dart';
import 'product_detail_state.dart';

/// 상품 상세 Notifier
class ProductDetailNotifier extends StateNotifier<ProductDetailState> {
  final GetProductDetailUseCase getProductDetailUseCase;
  final ToggleFavoriteUseCase toggleFavoriteUseCase;
  final IsFavoriteUseCase isFavoriteUseCase;
  final GetUserByIdUseCase getUserByIdUseCase;

  ProductDetailNotifier(
    this.getProductDetailUseCase,
    this.toggleFavoriteUseCase,
    this.isFavoriteUseCase,
    this.getUserByIdUseCase,
  ) : super(const ProductDetailInitial());

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
        pod.User? sellerData = product.seller;
        if (sellerData == null) {
          final sellerResult = await getUserByIdUseCase(product.sellerId);
          sellerResult.fold(
            (failure) {
              // seller 정보를 가져오지 못해도 상품 정보는 표시
              print('판매자 정보를 불러오는데 실패했습니다: ${failure.message}');
            },
            (user) {
              sellerData = user;
            },
          );
        }

        // 찜 상태 조회
        bool isFavorite = false;
        if (product.id != null) {
          final favoriteResult = await isFavoriteUseCase(product.id!);
          favoriteResult.fold(
            (failure) {
              print('찜 상태를 불러오는데 실패했습니다: ${failure.message}');
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

    result.fold(
      (failure) {
        // 실패 시 이전 상태로 복원
        state = currentState.copyWith(isFavorite: previousIsFavorite);
        print('찜 상태 변경 실패: ${failure.message}');
      },
      (isFavorite) async {
        // 성공 시 상품 정보도 업데이트 (favoriteCount 변경)
        final productResult = await getProductDetailUseCase(productId);
        productResult.fold(
          (failure) {
            // 상품 정보 업데이트 실패해도 찜 상태는 유지
            print('상품 정보를 불러오는데 실패했습니다: ${failure.message}');
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
}
