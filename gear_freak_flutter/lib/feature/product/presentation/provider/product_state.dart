import 'package:gear_freak_client/gear_freak_client.dart' as pod;

/// 상품 상태 (Sealed Class 방식)
sealed class ProductState {
  const ProductState();
}

/// 초기 상태
class ProductInitial extends ProductState {
  const ProductInitial();
}

/// 로딩 중 상태
class ProductLoading extends ProductState {
  const ProductLoading();
}

/// 상품 로드 성공 상태
class ProductLoaded extends ProductState {
  final List<pod.Product> products;

  const ProductLoaded(this.products);
}

/// 상품 로드 실패 상태
class ProductError extends ProductState {
  final String message;

  const ProductError(this.message);
}
