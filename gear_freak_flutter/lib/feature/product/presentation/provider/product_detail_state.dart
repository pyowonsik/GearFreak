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
  final bool isFavorite;

  const ProductDetailLoaded({
    required this.product,
    this.seller,
    this.isFavorite = false,
  });

  ProductDetailLoaded copyWith({
    pod.Product? product,
    pod.User? seller,
    bool? isFavorite,
  }) {
    return ProductDetailLoaded(
      product: product ?? this.product,
      seller: seller ?? this.seller,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}

/// 상품 상세 로드 실패 상태
class ProductDetailError extends ProductDetailState {
  final String message;

  const ProductDetailError(this.message);
}
