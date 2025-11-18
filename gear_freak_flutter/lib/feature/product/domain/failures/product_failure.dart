import '../../../../common/domain/failure/failure.dart';

/// 상품 실패 추상 클래스
abstract class ProductFailure extends Failure {
  /// ProductFailure 생성자
  const ProductFailure(super.message, {super.exception, super.stackTrace});

  @override
  String toString() => 'ProductFailure: $message';
}

/// 상품 목록 조회 실패
class GetProductsFailure extends ProductFailure {
  /// GetProductsFailure 생성자
  const GetProductsFailure(super.message, {super.exception, super.stackTrace});

  @override
  String toString() => 'GetProductsFailure: $message';
}

/// 상품 상세 조회 실패
class GetProductDetailFailure extends ProductFailure {
  /// GetProductDetailFailure 생성자
  const GetProductDetailFailure(super.message,
      {super.exception, super.stackTrace});

  @override
  String toString() => 'GetProductDetailFailure: $message';
}

