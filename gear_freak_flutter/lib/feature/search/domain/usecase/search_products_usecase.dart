import 'package:dartz/dartz.dart';
import '../../../../core/domain/usecase/usecase.dart';
import '../domain.dart';

/// 검색 파라미터
class SearchProductsParams {
  final String query;
  final int page;
  final int limit;

  const SearchProductsParams({
    required this.query,
    this.page = 1,
    this.limit = 20,
  });
}

/// 상품 검색 UseCase
class SearchProductsUseCase
    implements UseCase<SearchResult, SearchProductsParams, SearchRepository> {
  final SearchRepository repository;

  const SearchProductsUseCase(this.repository);

  @override
  SearchRepository get repo => repository;

  @override
  Future<Either<Failure, SearchResult>> call(SearchProductsParams param) async {
    try {
      final result = await repository.searchProducts(
        query: param.query,
        page: param.page,
        limit: param.limit,
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

