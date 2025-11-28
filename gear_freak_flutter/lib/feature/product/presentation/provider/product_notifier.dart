import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import 'package:gear_freak_flutter/feature/product/di/product_providers.dart';
import 'package:gear_freak_flutter/feature/product/domain/usecase/get_paginated_products_usecase.dart';
import 'package:gear_freak_flutter/feature/product/domain/usecase/get_product_detail_usecase.dart';
import 'package:gear_freak_flutter/feature/product/presentation/provider/product_state.dart';

/// 상품 Notifier
class ProductNotifier extends StateNotifier<ProductState> {
  /// ProductNotifier 생성자
  ///
  /// [ref]는 Riverpod의 Ref 인스턴스입니다.
  /// [getPaginatedProductsUseCase]는 페이지네이션된 상품 목록 조회 UseCase 인스턴스입니다.
  /// [getProductDetailUseCase]는 상품 상세 조회 UseCase 인스턴스입니다.
  ProductNotifier(
    this.ref,
    this.getPaginatedProductsUseCase,
    this.getProductDetailUseCase,
  ) : super(const ProductInitial()) {
    debugPrint('🔵 [ProductNotifier] 생성됨');

    // 삭제 이벤트 감지하여 자동으로 목록에서 제거
    ref
      ..listen<int?>(deletedProductIdProvider, (previous, next) {
        if (next != null) {
          _removeProduct(next);
        }
      })

      // 수정 이벤트 감지하여 자동으로 목록에서 업데이트
      ..listen<pod.Product?>(updatedProductProvider, (previous, next) {
        if (next != null) {
          _updateProduct(next);
        }
      });
  }

  @override
  void dispose() {
    debugPrint('🔴 [ProductNotifier] dispose됨');
    super.dispose();
  }

  /// Riverpod Ref 인스턴스
  final Ref ref;

  /// 페이지네이션된 상품 목록 조회 UseCase 인스턴스
  final GetPaginatedProductsUseCase getPaginatedProductsUseCase;

  /// 상품 상세 조회 UseCase 인스턴스
  final GetProductDetailUseCase getProductDetailUseCase;

  /// 랜덤 상품 로드 (5개) - 홈 화면용
  Future<void> loadRandomProducts() async {
    await loadPaginatedProducts(limit: 5, random: true);
  }

  /// 페이지네이션된 상품 로드 (첫 페이지)
  Future<void> loadPaginatedProducts({
    int page = 1,
    int limit = 10,
    bool random = false,
    pod.ProductSortBy? sortBy,
  }) async {
    state = const ProductLoading();

    final pagination = pod.PaginationDto(
      page: page,
      limit: limit,
      random: random,
      sortBy: sortBy,
    );
    debugPrint('🔄 [ProductNotifier] 페이지네이션 요청: '
        'page=$page, limit=$limit, '
        'random=$random, sortBy=${sortBy?.name ?? "없음"}');
    final result = await getPaginatedProductsUseCase(pagination);

    result.fold(
      (failure) {
        debugPrint('❌ [ProductNotifier] 페이지네이션 실패: ${failure.message}');
        state = ProductError(failure.message);
      },
      (response) {
        debugPrint('✅ [ProductNotifier] 페이지네이션 성공: '
            'page=${response.pagination.page}, '
            'totalCount=${response.pagination.totalCount}, '
            'hasMore=${response.pagination.hasMore}, '
            'products=${response.products.length}개');
        state = ProductPaginatedLoaded(
          products: response.products,
          pagination: response.pagination,
          sortBy: sortBy,
        );
      },
    );
  }

  /// 카테고리별 페이지네이션된 상품 로드 (첫 페이지)
  Future<void> loadPaginatedProductsByCategory({
    required pod.ProductCategory category,
    int page = 1,
    int limit = 20,
    pod.ProductSortBy? sortBy,
  }) async {
    state = const ProductLoading();

    final pagination = pod.PaginationDto(
      page: page,
      limit: limit,
      category: category, // enum을 직접 전달
      sortBy: sortBy,
    );
    debugPrint(
        '🔄 [ProductNotifier] 카테고리 페이지네이션 요청: category=${category.name}, '
        'page=$page, limit=$limit, '
        'sortBy=${sortBy?.name ?? "없음"}');
    final result = await getPaginatedProductsUseCase(pagination);

    result.fold(
      (failure) {
        debugPrint('❌ [ProductNotifier] 카테고리 페이지네이션 실패: ${failure.message}');
        state = ProductError(failure.message);
      },
      (response) {
        debugPrint('✅ [ProductNotifier] 카테고리 페이지네이션 성공: '
            'page=${response.pagination.page}, '
            'totalCount=${response.pagination.totalCount}, '
            'hasMore=${response.pagination.hasMore}, '
            'products=${response.products.length}개');
        state = ProductPaginatedLoaded(
          products: response.products,
          pagination: response.pagination,
          category: category, // 카테고리 정보 저장
          sortBy: sortBy,
        );
      },
    );
  }

  /// 페이지네이션된 상품 추가 로드 (다음 페이지)
  Future<void> loadMoreProducts() async {
    final currentState = state;

    // 현재 상태가 페이지네이션된 상태가 아니면 반환
    if (currentState is! ProductPaginatedLoaded) {
      debugPrint('⚠️ [ProductNotifier] loadMoreProducts: '
          '현재 상태가 ProductPaginatedLoaded가 아닙니다. '
          '(${currentState.runtimeType})');
      return;
    }

    final currentPagination = currentState.pagination;

    // 더 이상 데이터가 없으면 반환
    if (currentPagination.hasMore != true) {
      debugPrint('⚠️ [ProductNotifier] loadMoreProducts: 더 이상 불러올 데이터가 없습니다.');
      return;
    }

    // 이미 로딩 중이면 반환
    if (state is ProductPaginatedLoadingMore) {
      debugPrint('⚠️ [ProductNotifier] loadMoreProducts: 이미 로딩 중입니다.');
      return;
    }

    // 다음 페이지 요청
    final nextPage = currentPagination.page + 1;
    debugPrint('🔄 [ProductNotifier] 다음 페이지 로드: page=$nextPage '
        '(현재: ${currentPagination.page}, '
        '전체: ${currentPagination.totalCount})');

    // 로딩 상태로 변경 (기존 데이터 유지)
    state = ProductPaginatedLoadingMore(
      products: currentState.products,
      pagination: currentPagination,
      category: currentState.category, // 카테고리 정보 유지
      sortBy: currentState.sortBy, // 정렬 기준 유지
    );

    // 저장된 카테고리 및 정렬 정보 사용
    final pagination = pod.PaginationDto(
      page: nextPage,
      limit: currentPagination.limit,
      category: currentState.category, // 저장된 카테고리 정보 사용
      sortBy: currentState.sortBy, // 저장된 정렬 기준 사용
    );

    final result = await getPaginatedProductsUseCase(pagination);

    result.fold(
      (failure) {
        debugPrint('❌ [ProductNotifier] 다음 페이지 로드 실패: ${failure.message}');
        // 에러 발생 시 이전 상태로 복구
        state = currentState;
      },
      (response) {
        // 기존 데이터에 새 데이터 추가
        final updatedProducts = [
          ...currentState.products,
          ...response.products,
        ];

        debugPrint('✅ [ProductNotifier] 다음 페이지 로드 성공: '
            'page=${response.pagination.page}, '
            '추가된 상품=${response.products.length}개, '
            '총 상품=${updatedProducts.length}개, '
            'hasMore=${response.pagination.hasMore}');

        state = ProductPaginatedLoaded(
          products: updatedProducts,
          pagination: response.pagination,
          category: currentState.category, // 카테고리 정보 유지
          sortBy: currentState.sortBy, // 정렬 기준 유지
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

  /// 목록에서 상품 제거 (삭제 이벤트에 의해 자동 호출)
  void _removeProduct(int productId) {
    final currentState = state;
    if (currentState is ProductPaginatedLoaded) {
      final updatedProducts = currentState.products
          .where((product) => product.id != productId)
          .toList();

      // 상품이 실제로 제거되었는지 확인
      if (updatedProducts.length < currentState.products.length) {
        debugPrint('🗑️ [ProductNotifier] 상품 제거: productId=$productId '
            '(${currentState.products.length}개 → ${updatedProducts.length}개)');

        // totalCount도 감소
        final updatedTotalCount = (currentState.pagination.totalCount ?? 0) - 1;

        state = ProductPaginatedLoaded(
          products: updatedProducts,
          pagination: currentState.pagination.copyWith(
            totalCount: updatedTotalCount.clamp(0, double.infinity).toInt(),
            hasMore: updatedProducts.length < updatedTotalCount,
          ),
          category: currentState.category,
          sortBy: currentState.sortBy,
        );
      }
    } else if (currentState is ProductPaginatedLoadingMore) {
      // 로딩 중 상태에서도 제거 처리
      final updatedProducts = currentState.products
          .where((product) => product.id != productId)
          .toList();

      if (updatedProducts.length < currentState.products.length) {
        debugPrint('🗑️ [ProductNotifier] 상품 제거 (로딩 중): productId=$productId '
            '(${currentState.products.length}개 → ${updatedProducts.length}개)');

        final updatedTotalCount = (currentState.pagination.totalCount ?? 0) - 1;

        state = ProductPaginatedLoadingMore(
          products: updatedProducts,
          pagination: currentState.pagination.copyWith(
            totalCount: updatedTotalCount.clamp(0, double.infinity).toInt(),
            hasMore: updatedProducts.length < updatedTotalCount,
          ),
          category: currentState.category,
          sortBy: currentState.sortBy,
        );
      }
    }
  }

  /// 목록에서 상품 수정 (수정 이벤트에 의해 자동 호출)
  void _updateProduct(pod.Product updatedProduct) {
    final currentState = state;

    if (currentState is ProductPaginatedLoaded) {
      final updatedProducts = currentState.products.map((product) {
        // 같은 ID면 새 데이터로 교체
        return product.id == updatedProduct.id ? updatedProduct : product;
      }).toList();

      // 실제로 변경이 있었는지 확인
      final hasChanges =
          currentState.products.any((p) => p.id == updatedProduct.id);

      if (hasChanges) {
        debugPrint(
            '✏️ [ProductNotifier] 상품 수정: productId=${updatedProduct.id}');

        state = ProductPaginatedLoaded(
          products: updatedProducts,
          pagination: currentState.pagination,
          category: currentState.category,
          sortBy: currentState.sortBy,
        );
      }
    } else if (currentState is ProductPaginatedLoadingMore) {
      // 로딩 중 상태에서도 수정 처리
      final updatedProducts = currentState.products.map((product) {
        return product.id == updatedProduct.id ? updatedProduct : product;
      }).toList();

      final hasChanges =
          currentState.products.any((p) => p.id == updatedProduct.id);

      if (hasChanges) {
        debugPrint(
            '✏️ [ProductNotifier] 상품 수정 (로딩 중): productId=${updatedProduct.id}');

        state = ProductPaginatedLoadingMore(
          products: updatedProducts,
          pagination: currentState.pagination,
          category: currentState.category,
          sortBy: currentState.sortBy,
        );
      }
    }
  }
}
