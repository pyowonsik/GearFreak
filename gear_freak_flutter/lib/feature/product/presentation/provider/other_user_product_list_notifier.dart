import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import 'package:gear_freak_flutter/feature/product/domain/usecase/get_products_by_user_id_usecase.dart';
import 'package:gear_freak_flutter/feature/product/presentation/presentation.dart';

/// 다른 사용자의 상품 목록 Notifier
class OtherUserProductListNotifier extends StateNotifier<ProductState> {
  /// OtherUserProductListNotifier 생성자
  OtherUserProductListNotifier(
    this.getProductsByUserIdUseCase,
    this.userId,
  ) : super(const ProductInitial());

  /// 다른 사용자의 상품 목록 조회 UseCase
  final GetProductsByUserIdUseCase getProductsByUserIdUseCase;

  /// 조회할 사용자 ID
  final int userId;

  /// 상품 목록 로드
  Future<void> loadProducts({
    int page = 1,
    int limit = 20,
    pod.ProductStatus? status,
  }) async {
    state = const ProductLoading();

    final result = await getProductsByUserIdUseCase(
      GetProductsByUserIdParams(
        userId: userId,
        pagination: pod.PaginationDto(
          page: page,
          limit: limit,
          status: status ??
              pod.ProductStatus.selling, // 판매중인 상품만 (selling + reserved 포함)
        ),
      ),
    );

    result.fold(
      (failure) {
        debugPrint(
          '❌ [OtherUserProductListNotifier] 상품 목록 로드 실패: ${failure.message}',
        );
        state = ProductError(failure.message);
      },
      (response) {
        debugPrint('✅ [OtherUserProductListNotifier] 상품 목록 로드 성공: '
            'page=${response.pagination.page}, '
            'totalCount=${response.pagination.totalCount}, '
            'hasMore=${response.pagination.hasMore}, '
            'products=${response.products.length}개');
        state = ProductPaginatedLoaded(
          products: response.products,
          pagination: response.pagination,
        );
      },
    );
  }

  /// 더 많은 상품 불러오기
  Future<void> loadMoreProducts() async {
    final currentState = state;

    if (currentState is! ProductPaginatedLoaded) {
      debugPrint('⚠️ [OtherUserProductListNotifier] loadMoreProducts: '
          '현재 상태가 ProductPaginatedLoaded가 아닙니다. '
          '(${currentState.runtimeType})');
      return;
    }

    final currentPagination = currentState.pagination;

    if (currentPagination.hasMore != true) {
      debugPrint('⚠️ [OtherUserProductListNotifier] loadMoreProducts:'
          ' 더 이상 불러올 데이터가 없습니다.');
      return;
    }

    if (state is ProductPaginatedLoadingMore) {
      debugPrint('⚠️ [OtherUserProductListNotifier] loadMoreProducts:'
          ' 이미 로딩 중입니다.');
      return;
    }

    final nextPage = currentPagination.page + 1;
    debugPrint('🔄 [OtherUserProductListNotifier] 다음 페이지 로드: page=$nextPage '
        '(현재: ${currentPagination.page}, '
        '전체: ${currentPagination.totalCount})');

    state = ProductPaginatedLoadingMore(
      products: currentState.products,
      pagination: currentPagination,
    );

    final result = await getProductsByUserIdUseCase(
      GetProductsByUserIdParams(
        userId: userId,
        pagination: pod.PaginationDto(
          page: nextPage,
          limit: currentPagination.limit,
          status: pod.ProductStatus.selling, // 판매중인 상품만
        ),
      ),
    );

    result.fold(
      (failure) {
        debugPrint('❌ [OtherUserProductListNotifier] 다음 페이지 로드 실패:'
            ' ${failure.message}');
        state = currentState;
      },
      (response) {
        final updatedProducts = [
          ...currentState.products,
          ...response.products,
        ];

        debugPrint('✅ [OtherUserProductListNotifier] 다음 페이지 로드 성공: '
            'page=${response.pagination.page}, '
            '추가된 상품=${response.products.length}개, '
            '총 상품=${updatedProducts.length}개, '
            'hasMore=${response.pagination.hasMore}');

        state = currentState.copyWith(
          products: updatedProducts,
          pagination: response.pagination,
        );
      },
    );
  }
}
