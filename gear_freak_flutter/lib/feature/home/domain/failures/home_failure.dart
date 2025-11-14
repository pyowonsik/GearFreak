import '../../../../core/domain/failure/failure.dart';

/// 홈 실패 추상 클래스
abstract class HomeFailure extends Failure {
  /// HomeFailure 생성자
  const HomeFailure(super.message, {super.exception, super.stackTrace});

  @override
  String toString() => 'HomeFailure: $message';
}

/// 상품 목록 조회 실패
class GetProductsFailure extends HomeFailure {
  /// GetProductsFailure 생성자
  const GetProductsFailure(super.message, {super.exception, super.stackTrace});

  @override
  String toString() => 'GetProductsFailure: $message';
}

/// 카테고리 조회 실패
class GetCategoriesFailure extends HomeFailure {
  /// GetCategoriesFailure 생성자
  const GetCategoriesFailure(super.message,
      {super.exception, super.stackTrace});

  @override
  String toString() => 'GetCategoriesFailure: $message';
}
