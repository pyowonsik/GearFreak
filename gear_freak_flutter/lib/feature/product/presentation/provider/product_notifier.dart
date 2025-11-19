import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import '../../domain/usecase/get_paginated_products_usecase.dart';
import '../../domain/usecase/get_product_detail_usecase.dart';
import 'product_state.dart';

/// 상품 Notifier
class ProductNotifier extends StateNotifier<ProductState> {
  final GetPaginatedProductsUseCase getPaginatedProductsUseCase;
  final GetProductDetailUseCase getProductDetailUseCase;

  ProductNotifier(
    this.getPaginatedProductsUseCase,
    this.getProductDetailUseCase,
  ) : super(const ProductInitial());

  /// 랜덤 상품 로드 (5개) - 홈 화면용
  Future<void> loadRandomProducts() async {
    await loadPaginatedProducts(page: 1, limit: 5, random: true);
  }

  /// 페이지네이션된 상품 로드 (첫 페이지)
  Future<void> loadPaginatedProducts({
    int page = 1,
    int limit = 10,
    bool random = false,
  }) async {
    state = const ProductLoading();

    final pagination = pod.PaginationDto(
      page: page,
      limit: limit,
      random: random,
    );
    print(
        '🔄 [ProductNotifier] 페이지네이션 요청: page=$page, limit=$limit, random=$random');
    final result = await getPaginatedProductsUseCase(pagination);

    result.fold(
      (failure) {
        print('❌ [ProductNotifier] 페이지네이션 실패: ${failure.message}');
        state = ProductError(failure.message);
      },
      (response) {
        print(
            '✅ [ProductNotifier] 페이지네이션 성공: page=${response.pagination.page}, totalCount=${response.pagination.totalCount}, hasMore=${response.pagination.hasMore}, products=${response.products.length}개');
        state = ProductPaginatedLoaded(
          products: response.products,
          pagination: response.pagination,
        );
      },
    );
  }

  /// 페이지네이션된 상품 추가 로드 (다음 페이지)
  Future<void> loadMoreProducts() async {
    final currentState = state;

    // 현재 상태가 페이지네이션된 상태가 아니면 반환
    if (currentState is! ProductPaginatedLoaded) {
      print(
          '⚠️ [ProductNotifier] loadMoreProducts: 현재 상태가 ProductPaginatedLoaded가 아닙니다. (${currentState.runtimeType})');
      return;
    }

    final currentPagination = currentState.pagination;

    // 더 이상 데이터가 없으면 반환
    if (currentPagination.hasMore != true) {
      print('⚠️ [ProductNotifier] loadMoreProducts: 더 이상 불러올 데이터가 없습니다.');
      return;
    }

    // 이미 로딩 중이면 반환
    if (state is ProductPaginatedLoadingMore) {
      print('⚠️ [ProductNotifier] loadMoreProducts: 이미 로딩 중입니다.');
      return;
    }

    // 다음 페이지 요청
    final nextPage = currentPagination.page + 1;
    print(
        '🔄 [ProductNotifier] 다음 페이지 로드: page=$nextPage (현재: ${currentPagination.page}, 전체: ${currentPagination.totalCount})');

    // 로딩 상태로 변경 (기존 데이터 유지)
    state = ProductPaginatedLoadingMore(
      products: currentState.products,
      pagination: currentPagination,
    );

    final pagination = pod.PaginationDto(
      page: nextPage,
      limit: currentPagination.limit,
    );

    final result = await getPaginatedProductsUseCase(pagination);

    result.fold(
      (failure) {
        print('❌ [ProductNotifier] 다음 페이지 로드 실패: ${failure.message}');
        // 에러 발생 시 이전 상태로 복구
        state = currentState;
      },
      (response) {
        // 기존 데이터에 새 데이터 추가
        final updatedProducts = [
          ...currentState.products,
          ...response.products,
        ];

        print(
            '✅ [ProductNotifier] 다음 페이지 로드 성공: page=${response.pagination.page}, 추가된 상품=${response.products.length}개, 총 상품=${updatedProducts.length}개, hasMore=${response.pagination.hasMore}');

        state = ProductPaginatedLoaded(
          products: updatedProducts,
          pagination: response.pagination,
        );
      },
    );
  }

  /// 상품 상세 조회
  Future<pod.Product?> getProductDetail(int id) async {
    final result = await getProductDetailUseCase(id);
    return result.fold(
      (failure) {
        // 에러 발생 시 null 반환
        return null;
      },
      (product) => product,
    );
  }
}
