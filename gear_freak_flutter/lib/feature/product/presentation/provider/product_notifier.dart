import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import 'package:gear_freak_flutter/feature/product/di/product_providers.dart';
import 'package:gear_freak_flutter/feature/product/domain/usecase/get_my_favorite_products_usecase.dart';
import 'package:gear_freak_flutter/feature/product/domain/usecase/get_my_products_usecase.dart';
import 'package:gear_freak_flutter/feature/product/domain/usecase/get_paginated_products_usecase.dart';
import 'package:gear_freak_flutter/feature/product/domain/usecase/get_product_detail_usecase.dart';
import 'package:gear_freak_flutter/feature/product/presentation/provider/product_state.dart';
import 'package:gear_freak_flutter/feature/product/presentation/utils/product_enum_helper.dart';

/// 상품 Notifier
class ProductNotifier extends StateNotifier<ProductState> {
  /// ProductNotifier 생성자
  ///
  /// [ref]는 Riverpod의 Ref 인스턴스입니다.
  /// [getPaginatedProductsUseCase]는 페이지네이션된 상품 목록 조회 UseCase 인스턴스입니다.
  /// [getProductDetailUseCase]는 상품 상세 조회 UseCase 인스턴스입니다.
  /// [getMyProductsUseCase]는 내 상품 목록 조회 UseCase 인스턴스입니다. (선택적)
  /// [getMyFavoriteProductsUseCase]는 찜 목록 조회 UseCase 인스턴스입니다. (선택적)
  ProductNotifier(
    this.ref,
    this.getPaginatedProductsUseCase,
    this.getProductDetailUseCase, {
    this.getMyProductsUseCase,
    this.getMyFavoriteProductsUseCase,
  }) : super(const ProductInitial()) {
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

  /// 내 상품 목록 조회 UseCase 인스턴스 (선택적)
  final GetMyProductsUseCase? getMyProductsUseCase;

  /// 찜 목록 조회 UseCase 인스턴스 (선택적)
  final GetMyFavoriteProductsUseCase? getMyFavoriteProductsUseCase;

  /// 페이지네이션된 상품 로드 (첫 페이지)
  Future<void> loadPaginatedProducts({
    int page = 1,
    int limit = 10,
    pod.ProductSortBy? sortBy,
  }) async {
    state = const ProductLoading();

    final pagination = pod.PaginationDto(
      page: page,
      limit: limit,
      sortBy: sortBy,
    );
    debugPrint('🔄 [ProductNotifier] 페이지네이션 요청: '
        'page=$page, limit=$limit, '
        'sortBy=${sortBy?.name ?? "없음"}');
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
      profileType: currentState.profileType, // 프로필 타입 유지
    );

    // 저장된 카테고리 및 정렬 정보 사용
    final pagination = pod.PaginationDto(
      page: nextPage,
      limit: currentPagination.limit,
      category: currentState.category, // 저장된 카테고리 정보 사용
      sortBy: currentState.sortBy, // 저장된 정렬 기준 사용
      status: currentState.profileType == 'mySoldProducts'
          ? pod.ProductStatus.sold
          : null, // 거래완료인 경우 status 추가
    );

    // 프로필 타입에 따라 적절한 UseCase 사용
    final result = currentState.profileType == 'myProducts' ||
            currentState.profileType == 'mySoldProducts'
        ? (getMyProductsUseCase != null
            ? await getMyProductsUseCase!(pagination)
            : await getPaginatedProductsUseCase(pagination))
        : currentState.profileType == 'myFavorite'
            ? (getMyFavoriteProductsUseCase != null
                ? await getMyFavoriteProductsUseCase!(pagination)
                : await getPaginatedProductsUseCase(pagination))
            : await getPaginatedProductsUseCase(pagination);

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
          profileType: currentState.profileType, // 프로필 타입 유지
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
      _removeProductFromLoaded(productId, currentState);
    } else if (currentState is ProductPaginatedLoadingMore) {
      _removeProductFromLoadingMore(productId, currentState);
    }
  }

  /// ProductPaginatedLoaded 상태에서 상품 제거
  void _removeProductFromLoaded(
    int productId,
    ProductPaginatedLoaded currentState,
  ) {
    final updatedProducts = currentState.products
        .where((product) => product.id != productId)
        .toList();

    if (updatedProducts.length < currentState.products.length) {
      debugPrint(
        '🗑️ [ProductNotifier] 상품 제거: productId=$productId '
        '(${currentState.products.length}개 → ${updatedProducts.length}개)',
      );

      final updatedTotalCount = (currentState.pagination.totalCount ?? 0) - 1;
      final updatedPagination = currentState.pagination.copyWith(
        totalCount: updatedTotalCount.clamp(0, double.infinity).toInt(),
        hasMore: updatedProducts.length < updatedTotalCount,
      );

      state = ProductPaginatedLoaded(
        products: updatedProducts,
        pagination: updatedPagination,
        category: currentState.category,
        sortBy: currentState.sortBy,
        profileType: currentState.profileType,
      );
    }
  }

  /// ProductPaginatedLoadingMore 상태에서 상품 제거
  void _removeProductFromLoadingMore(
    int productId,
    ProductPaginatedLoadingMore currentState,
  ) {
    final updatedProducts = currentState.products
        .where((product) => product.id != productId)
        .toList();

    if (updatedProducts.length < currentState.products.length) {
      debugPrint(
        '🗑️ [ProductNotifier] 상품 제거 (로딩 중): productId=$productId '
        '(${currentState.products.length}개 → ${updatedProducts.length}개)',
      );

      final updatedTotalCount = (currentState.pagination.totalCount ?? 0) - 1;
      final updatedPagination = currentState.pagination.copyWith(
        totalCount: updatedTotalCount.clamp(0, double.infinity).toInt(),
        hasMore: updatedProducts.length < updatedTotalCount,
      );

      state = ProductPaginatedLoadingMore(
        products: updatedProducts,
        pagination: updatedPagination,
        category: currentState.category,
        sortBy: currentState.sortBy,
        profileType: currentState.profileType,
      );
    }
  }

  /// 목록에서 상품 수정 (수정 이벤트에 의해 자동 호출)
  void _updateProduct(pod.Product updatedProduct) {
    final currentState = state;

    if (currentState is ProductPaginatedLoaded) {
      _updateProductInLoaded(updatedProduct, currentState);
    } else if (currentState is ProductPaginatedLoadingMore) {
      _updateProductInLoadingMore(updatedProduct, currentState);
    }
  }

  /// 상품이 목록에서 제거되어야 하는지 확인
  bool _shouldRemoveProduct(
    pod.Product updatedProduct,
    String? profileType,
  ) {
    // 판매완료로 변경된 경우: 거래완료 목록이 아니면 무조건 제거
    if (updatedProduct.status == pod.ProductStatus.sold &&
        profileType != 'mySoldProducts') {
      return true;
    }

    // 판매중/예약중으로 변경된 경우: 판매중 목록이 아니면 제거
    final expectedStatus = getExpectedStatusForProfileType(profileType);
    if (expectedStatus != null &&
        !isStatusMatching(expectedStatus, updatedProduct.status)) {
      return true;
    }

    return false;
  }

  /// ProductPaginatedLoaded 상태에서 상품 수정
  void _updateProductInLoaded(
    pod.Product updatedProduct,
    ProductPaginatedLoaded currentState,
  ) {
    // 제거 조건 확인
    if (_shouldRemoveProduct(updatedProduct, currentState.profileType)) {
      _removeProductFromLoaded(updatedProduct.id!, currentState);
      return;
    }

    // 필터 조건에 맞으면 상품 정보 업데이트
    final updatedProducts = currentState.products.map((product) {
      return product.id == updatedProduct.id ? updatedProduct : product;
    }).toList();

    final hasChanges =
        currentState.products.any((p) => p.id == updatedProduct.id);

    if (hasChanges) {
      debugPrint(
        '✏️ [ProductNotifier] 상품 수정: productId=${updatedProduct.id}',
      );

      state = ProductPaginatedLoaded(
        products: updatedProducts,
        pagination: currentState.pagination,
        category: currentState.category,
        sortBy: currentState.sortBy,
        profileType: currentState.profileType,
      );
    }
  }

  /// ProductPaginatedLoadingMore 상태에서 상품 수정
  void _updateProductInLoadingMore(
    pod.Product updatedProduct,
    ProductPaginatedLoadingMore currentState,
  ) {
    // 제거 조건 확인
    if (_shouldRemoveProduct(updatedProduct, currentState.profileType)) {
      _removeProductFromLoadingMore(updatedProduct.id!, currentState);
      return;
    }

    // 필터 조건에 맞으면 상품 정보 업데이트
    final updatedProducts = currentState.products.map((product) {
      return product.id == updatedProduct.id ? updatedProduct : product;
    }).toList();

    final hasChanges =
        currentState.products.any((p) => p.id == updatedProduct.id);

    if (hasChanges) {
      debugPrint(
        '✏️ [ProductNotifier] 상품 수정 (로딩 중): productId=${updatedProduct.id}',
      );

      state = ProductPaginatedLoadingMore(
        products: updatedProducts,
        pagination: currentState.pagination,
        category: currentState.category,
        sortBy: currentState.sortBy,
        profileType: currentState.profileType,
      );
    }
  }

  /// 내가 등록한 상품 목록 로드 (프로필 화면용)
  Future<void> loadMyProducts({
    int page = 1,
    int limit = 20,
    pod.ProductStatus? status,
  }) async {
    if (getMyProductsUseCase == null) {
      debugPrint('⚠️ [ProductNotifier] getMyProductsUseCase가 주입되지 않았습니다.');
      state = const ProductError('내 상품 목록을 불러올 수 없습니다.');
      return;
    }

    state = const ProductLoading();
    debugPrint(
        '🔄 [ProductNotifier] 내 상품 목록 로드: page=$page, limit=$limit, status=$status');

    final pagination = pod.PaginationDto(
      page: page,
      limit: limit,
      status: status,
    );

    final result = await getMyProductsUseCase!(pagination);

    result.fold(
      (failure) {
        debugPrint('❌ [ProductNotifier] 내 상품 목록 로드 실패: ${failure.message}');
        state = ProductError(failure.message);
      },
      (response) {
        debugPrint('✅ [ProductNotifier] 내 상품 목록 로드 성공: '
            'page=${response.pagination.page}, '
            'totalCount=${response.pagination.totalCount}, '
            'hasMore=${response.pagination.hasMore}, '
            'products=${response.products.length}개');
        state = ProductPaginatedLoaded(
          products: response.products,
          pagination: response.pagination,
          sortBy: null,
          profileType: status == pod.ProductStatus.sold
              ? 'mySoldProducts'
              : status == pod.ProductStatus.selling
                  ? 'myProducts'
                  : 'myProducts',
        );
      },
    );
  }

  /// 내가 관심목록한 상품 목록 로드 (프로필 화면용)
  Future<void> loadMyFavoriteProducts({
    int page = 1,
    int limit = 20,
  }) async {
    if (getMyFavoriteProductsUseCase == null) {
      debugPrint(
          '⚠️ [ProductNotifier] getMyFavoriteProductsUseCase가 주입되지 않았습니다.');
      state = const ProductError('찜 목록을 불러올 수 없습니다.');
      return;
    }

    state = const ProductLoading();
    debugPrint('🔄 [ProductNotifier] 찜 목록 로드: page=$page, limit=$limit');

    final pagination = pod.PaginationDto(
      page: page,
      limit: limit,
    );

    final result = await getMyFavoriteProductsUseCase!(pagination);

    result.fold(
      (failure) {
        debugPrint('❌ [ProductNotifier] 찜 목록 로드 실패: ${failure.message}');
        state = ProductError(failure.message);
      },
      (response) {
        debugPrint('✅ [ProductNotifier] 찜 목록 로드 성공: '
            'page=${response.pagination.page}, '
            'totalCount=${response.pagination.totalCount}, '
            'hasMore=${response.pagination.hasMore}, '
            'products=${response.products.length}개');
        state = ProductPaginatedLoaded(
          products: response.products,
          pagination: response.pagination,
          sortBy: null,
          profileType: 'myFavorite',
        );
      },
    );
  }
}
