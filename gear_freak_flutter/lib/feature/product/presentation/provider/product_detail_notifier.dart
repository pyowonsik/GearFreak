import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import '../../domain/usecase/get_product_detail_usecase.dart';
import '../../../profile/domain/usecase/get_user_by_id_usecase.dart';
import 'product_detail_state.dart';

/// 상품 상세 Notifier
class ProductDetailNotifier extends StateNotifier<ProductDetailState> {
  final GetProductDetailUseCase getProductDetailUseCase;
  final GetUserByIdUseCase getUserByIdUseCase;

  ProductDetailNotifier(
    this.getProductDetailUseCase,
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

        state = ProductDetailLoaded(
          product: product,
          seller: sellerData,
        );
      },
    );
  }
}
