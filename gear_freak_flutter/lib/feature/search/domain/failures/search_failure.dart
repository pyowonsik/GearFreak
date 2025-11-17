import '../../../../common/domain/failure/failure.dart';

/// 검색 실패 추상 클래스
abstract class SearchFailure extends Failure {
  /// SearchFailure 생성자
  const SearchFailure(super.message, {super.exception, super.stackTrace});

  @override
  String toString() => 'SearchFailure: $message';
}

/// 상품 검색 실패
class SearchProductsFailure extends SearchFailure {
  /// SearchProductsFailure 생성자
  const SearchProductsFailure(super.message,
      {super.exception, super.stackTrace});

  @override
  String toString() => 'SearchProductsFailure: $message';
}
