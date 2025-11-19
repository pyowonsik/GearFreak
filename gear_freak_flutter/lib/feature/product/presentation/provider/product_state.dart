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

/// 상품 로드 실패 상태
class ProductError extends ProductState {
  final String message;

  const ProductError(this.message);
}

/// 페이지네이션된 상품 로드 성공 상태
class ProductPaginatedLoaded extends ProductState {
  final List<pod.Product> products;
  final pod.PaginationDto pagination;
  final pod.ProductCategory? category; // 원래 요청 시 사용한 카테고리 (필터링용)
  final pod.ProductSortBy? sortBy; // 원래 요청 시 사용한 정렬 기준

  const ProductPaginatedLoaded({
    required this.products,
    required this.pagination,
    this.category,
    this.sortBy,
  });
}

/// 페이지네이션 추가 로딩 중 상태 (기존 데이터 유지)
class ProductPaginatedLoadingMore extends ProductState {
  final List<pod.Product> products;
  final pod.PaginationDto pagination;
  final pod.ProductCategory? category; // 원래 요청 시 사용한 카테고리 (필터링용)
  final pod.ProductSortBy? sortBy; // 원래 요청 시 사용한 정렬 기준

  const ProductPaginatedLoadingMore({
    required this.products,
    required this.pagination,
    this.category,
    this.sortBy,
  });
}
