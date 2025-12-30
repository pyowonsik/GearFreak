import 'package:dartz/dartz.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import 'package:gear_freak_flutter/feature/search/domain/domain.dart';
import 'package:gear_freak_flutter/shared/domain/usecase/usecase.dart';

/// 상품 검색 UseCase
class SearchProductsUseCase
    implements
        UseCase<pod.PaginatedProductsResponseDto, SearchProductsParams,
            SearchRepository> {
  /// SearchProductsUseCase 생성자
  ///
  /// [repository]는 검색 Repository 인스턴스입니다.
  const SearchProductsUseCase(this.repository);

  /// 검색 Repository 인스턴스
  final SearchRepository repository;

  @override
  SearchRepository get repo => repository;

  @override
  Future<Either<Failure, pod.PaginatedProductsResponseDto>> call(
    SearchProductsParams param,
  ) async {
    try {
      final result = await repository.searchProducts(
        query: param.query,
        page: param.page,
        limit: param.limit,
        sortBy: param.sortBy, // ⭐ sortBy 전달 추가
      );
      return Right(result);
    } on Exception catch (e) {
      return Left(
        SearchProductsFailure(
          '검색 결과를 불러올 수 없습니다.',
          exception: e,
        ),
      );
    }
  }
}

/// 검색 파라미터
class SearchProductsParams {
  /// SearchProductsParams 생성자
  ///
  /// [query]는 검색 쿼리입니다.
  /// [page]는 페이지 번호입니다.
  /// [limit]는 페이지당 아이템 수입니다.
  /// [sortBy]는 정렬 기준입니다.
  const SearchProductsParams({
    required this.query,
    this.page = 1,
    this.limit = 20,
    this.sortBy,
  });

  /// 검색 쿼리
  final String query;

  /// 페이지 번호
  final int page;

  /// 페이지당 아이템 수
  final int limit;

  /// 정렬 기준
  final pod.ProductSortBy? sortBy;
}
