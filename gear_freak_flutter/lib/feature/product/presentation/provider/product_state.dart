import 'package:gear_freak_client/gear_freak_client.dart' as pod;

/// 상품 상태 (Sealed Class 방식)
sealed class ProductState {
  const ProductState();
}

/// 초기 상태
class ProductInitial extends ProductState {
  /// ProductInitial 생성자
  const ProductInitial();
}

/// 로딩 중 상태
class ProductLoading extends ProductState {
  /// ProductLoading 생성자
  const ProductLoading();
}

/// 상품 로드 실패 상태
class ProductError extends ProductState {
  /// ProductError 생성자
  ///
  /// [message]는 에러 메시지입니다.
  const ProductError(this.message);

  /// 에러 메시지
  final String message;
}

/// 페이지네이션된 상품 로드 성공 상태
class ProductPaginatedLoaded extends ProductState {
  /// ProductPaginatedLoaded 생성자
  ///
  /// [products]는 상품 목록입니다.
  /// [pagination]는 페이지네이션 정보입니다.
  /// [category]는 카테고리 정보입니다.
  /// [sortBy]는 정렬 기준입니다.
  /// [profileType]는 프로필 화면 타입입니다. "myProducts" 또는 "myFavorite" (선택적)
  const ProductPaginatedLoaded({
    required this.products,
    required this.pagination,
    this.category,
    this.sortBy,
    this.profileType,
  });

  /// 상품 목록
  final List<pod.Product> products;

  /// 페이지네이션 정보
  final pod.PaginationDto pagination;

  /// 카테고리 정보
  final pod.ProductCategory? category; // 원래 요청 시 사용한 카테고리 (필터링용)

  /// 정렬 기준
  final pod.ProductSortBy? sortBy; // 원래 요청 시 사용한 정렬 기준

  /// 프로필 화면 타입
  final String? profileType; // "myProducts" 또는 "myFavorite"
}

/// 페이지네이션 추가 로딩 중 상태 (기존 데이터 유지)
class ProductPaginatedLoadingMore extends ProductState {
  /// ProductPaginatedLoadingMore 생성자
  ///
  /// [products]는 상품 목록입니다.
  /// [pagination]는 페이지네이션 정보입니다.
  /// [category]는 카테고리 정보입니다.
  /// [sortBy]는 정렬 기준입니다.
  /// [profileType]는 프로필 화면 타입입니다. "myProducts" 또는 "myFavorite" (선택적)
  const ProductPaginatedLoadingMore({
    required this.products,
    required this.pagination,
    this.category,
    this.sortBy,
    this.profileType,
  });

  /// 상품 목록
  final List<pod.Product> products;

  /// 페이지네이션 정보
  final pod.PaginationDto pagination;

  /// 카테고리 정보
  final pod.ProductCategory? category; // 원래 요청 시 사용한 카테고리 (필터링용)

  /// 정렬 기준
  final pod.ProductSortBy? sortBy; // 원래 요청 시 사용한 정렬 기준

  /// 프로필 화면 타입
  final String? profileType; // "myProducts" 또는 "myFavorite"
}
