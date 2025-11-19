import 'package:gear_freak_client/gear_freak_client.dart' as pod;

/// 상품 상세 상태 (Sealed Class 방식)
sealed class ProductDetailState {
  const ProductDetailState();
}

/// 초기 상태
class ProductDetailInitial extends ProductDetailState {
  const ProductDetailInitial();
}

/// 로딩 중 상태
class ProductDetailLoading extends ProductDetailState {
  const ProductDetailLoading();
}

/// 상품 상세 로드 성공 상태
class ProductDetailLoaded extends ProductDetailState {
  final pod.Product product;
  final pod.User? seller;

  const ProductDetailLoaded({
    required this.product,
    this.seller,
  });
}

/// 상품 상세 로드 실패 상태
class ProductDetailError extends ProductDetailState {
  final String message;

  const ProductDetailError(this.message);
}

