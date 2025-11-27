import 'package:gear_freak_flutter/common/domain/failure/failure.dart';

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
  const GetProductDetailFailure(
    super.message, {
    super.exception,
    super.stackTrace,
  });

  @override
  String toString() => 'GetProductDetailFailure: $message';
}

/// 찜 토글 실패
class ToggleFavoriteFailure extends ProductFailure {
  /// ToggleFavoriteFailure 생성자
  const ToggleFavoriteFailure(
    super.message, {
    super.exception,
    super.stackTrace,
  });

  @override
  String toString() => 'ToggleFavoriteFailure: $message';
}

/// 찜 상태 조회 실패
class IsFavoriteFailure extends ProductFailure {
  /// IsFavoriteFailure 생성자
  const IsFavoriteFailure(super.message, {super.exception, super.stackTrace});

  @override
  String toString() => 'IsFavoriteFailure: $message';
}

/// 상품 생성 실패
class CreateProductFailure extends ProductFailure {
  /// CreateProductFailure 생성자
  const CreateProductFailure(super.message,
      {super.exception, super.stackTrace});

  @override
  String toString() => 'CreateProductFailure: $message';
}

/// 상품 수정 실패
class UpdateProductFailure extends ProductFailure {
  /// UpdateProductFailure 생성자
  const UpdateProductFailure(super.message,
      {super.exception, super.stackTrace});

  @override
  String toString() => 'UpdateProductFailure: $message';
}

/// 상품 삭제 실패
class DeleteProductFailure extends ProductFailure {
  /// DeleteProductFailure 생성자
  const DeleteProductFailure(super.message,
      {super.exception, super.stackTrace});

  @override
  String toString() => 'DeleteProductFailure: $message';
}
