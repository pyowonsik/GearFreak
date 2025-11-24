import 'package:gear_freak_client/gear_freak_client.dart' as pod;

/// 상품 상세 상태 (Sealed Class 방식)
sealed class ProductDetailState {
  const ProductDetailState();
}

/// 초기 상태
class ProductDetailInitial extends ProductDetailState {
  /// ProductDetailInitial 생성자
  const ProductDetailInitial();
}

/// 로딩 중 상태
class ProductDetailLoading extends ProductDetailState {
  /// ProductDetailLoading 생성자
  const ProductDetailLoading();
}

/// 상품 상세 로드 성공 상태
class ProductDetailLoaded extends ProductDetailState {
  /// ProductDetailLoaded 생성자
  ///
  /// [product]는 상품 정보입니다.
  /// [seller]는 판매자 정보입니다.
  /// [isFavorite]는 찜 상태입니다.
  const ProductDetailLoaded({
    required this.product,
    this.seller,
    this.isFavorite = false,
  });

  /// 상품 정보
  final pod.Product product;

  /// 판매자 정보
  final pod.User? seller;

  /// 찜 상태
  final bool isFavorite;

  /// ProductDetailLoaded 복사
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
  /// ProductDetailError 생성자
  ///
  /// [message]는 에러 메시지입니다.
  const ProductDetailError(this.message);

  /// 에러 메시지
  final String message;
}
