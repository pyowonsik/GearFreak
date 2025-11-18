import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import '../../domain/usecase/get_recent_products_usecase.dart';
import '../../domain/usecase/get_all_products_usecase.dart';
import '../../domain/usecase/get_product_detail_usecase.dart';
import 'product_state.dart';

/// 상품 Notifier
class ProductNotifier extends StateNotifier<ProductState> {
  final GetRecentProductsUseCase getRecentProductsUseCase;
  final GetAllProductsUseCase getAllProductsUseCase;
  final GetProductDetailUseCase getProductDetailUseCase;

  ProductNotifier(
    this.getRecentProductsUseCase,
    this.getAllProductsUseCase,
    this.getProductDetailUseCase,
  ) : super(const ProductInitial());

  /// 최근 등록 상품 로드 (5개)
  Future<void> loadRecentProducts() async {
    state = const ProductLoading();

    final productsResult = await getRecentProductsUseCase(null);

    productsResult.fold(
      (failure) {
        state = ProductError(failure.message);
      },
      (products) {
        state = ProductLoaded(products);
      },
    );
  }

  /// 전체 상품 로드
  Future<void> loadAllProducts() async {
    state = const ProductLoading();

    final productsResult = await getAllProductsUseCase(null);

    productsResult.fold(
      (failure) {
        state = ProductError(failure.message);
      },
      (products) {
        state = ProductLoaded(products);
      },
    );
  }

  /// 상품 상세 조회
  Future<pod.Product?> getProductDetail(int id) async {
    final result = await getProductDetailUseCase(id);
    return result.fold(
      (failure) {
        // 에러 발생 시 null 반환
        return null;
      },
      (product) => product,
    );
  }
}
