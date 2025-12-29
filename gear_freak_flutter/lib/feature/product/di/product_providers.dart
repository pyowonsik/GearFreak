import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import 'package:gear_freak_flutter/common/s3/di/s3_providers.dart';
import 'package:gear_freak_flutter/feature/product/data/datasource/product_remote_datasource.dart';
import 'package:gear_freak_flutter/feature/product/data/repository/product_repository_impl.dart';
import 'package:gear_freak_flutter/feature/product/domain/repository/product_repository.dart';
import 'package:gear_freak_flutter/feature/product/domain/usecase/bump_product_usecase.dart';
import 'package:gear_freak_flutter/feature/product/domain/usecase/create_product_usecase.dart';
import 'package:gear_freak_flutter/feature/product/domain/usecase/delete_product_usecase.dart';
import 'package:gear_freak_flutter/feature/product/domain/usecase/get_my_favorite_products_usecase.dart';
import 'package:gear_freak_flutter/feature/product/domain/usecase/get_my_products_usecase.dart';
import 'package:gear_freak_flutter/feature/product/domain/usecase/get_paginated_products_usecase.dart';
import 'package:gear_freak_flutter/feature/product/domain/usecase/get_product_detail_usecase.dart';
import 'package:gear_freak_flutter/feature/product/domain/usecase/get_product_stats_by_user_id_usecase.dart';
import 'package:gear_freak_flutter/feature/product/domain/usecase/get_product_stats_usecase.dart';
import 'package:gear_freak_flutter/feature/product/domain/usecase/get_products_by_user_id_usecase.dart';
import 'package:gear_freak_flutter/feature/product/domain/usecase/increment_view_count_usecase.dart';
import 'package:gear_freak_flutter/feature/product/domain/usecase/is_favorite_usecase.dart';
import 'package:gear_freak_flutter/feature/product/domain/usecase/toggle_favorite_usecase.dart';
import 'package:gear_freak_flutter/feature/product/domain/usecase/update_product_status_usecase.dart';
import 'package:gear_freak_flutter/feature/product/domain/usecase/update_product_usecase.dart';
import 'package:gear_freak_flutter/feature/product/presentation/provider/create_product_notifier.dart';
import 'package:gear_freak_flutter/feature/product/presentation/provider/create_product_state.dart';
import 'package:gear_freak_flutter/feature/product/presentation/provider/other_user_product_list_notifier.dart';
import 'package:gear_freak_flutter/feature/product/presentation/provider/product_detail_notifier.dart';
import 'package:gear_freak_flutter/feature/product/presentation/provider/product_detail_state.dart';
import 'package:gear_freak_flutter/feature/product/presentation/provider/product_notifier.dart';
import 'package:gear_freak_flutter/feature/product/presentation/provider/product_state.dart';
import 'package:gear_freak_flutter/feature/product/presentation/provider/update_product_notifier.dart';
import 'package:gear_freak_flutter/feature/product/presentation/provider/update_product_state.dart';
import 'package:gear_freak_flutter/feature/profile/di/profile_providers.dart';

/// Product Remote DataSource Provider
final productRemoteDataSourceProvider =
    Provider<ProductRemoteDataSource>((ref) {
  return const ProductRemoteDataSource();
});

/// Product Repository Provider
final productRepositoryProvider = Provider<ProductRepository>((ref) {
  final remoteDataSource = ref.watch(productRemoteDataSourceProvider);
  return ProductRepositoryImpl(remoteDataSource);
});

/// Get Paginated Products UseCase Provider
final getPaginatedProductsUseCaseProvider =
    Provider<GetPaginatedProductsUseCase>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  return GetPaginatedProductsUseCase(repository);
});

/// Get Product Detail UseCase Provider
final getProductDetailUseCaseProvider =
    Provider<GetProductDetailUseCase>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  return GetProductDetailUseCase(repository);
});

/// Toggle Favorite UseCase Provider
final toggleFavoriteUseCaseProvider = Provider<ToggleFavoriteUseCase>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  return ToggleFavoriteUseCase(repository);
});

/// Is Favorite UseCase Provider
final isFavoriteUseCaseProvider = Provider<IsFavoriteUseCase>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  return IsFavoriteUseCase(repository);
});

/// Increment View Count UseCase Provider
final incrementViewCountUseCaseProvider =
    Provider<IncrementViewCountUseCase>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  return IncrementViewCountUseCase(repository);
});

/// Create Product UseCase Provider
final createProductUseCaseProvider = Provider<CreateProductUseCase>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  return CreateProductUseCase(repository);
});

/// Update Product UseCase Provider
final updateProductUseCaseProvider = Provider<UpdateProductUseCase>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  return UpdateProductUseCase(repository);
});

/// Delete Product UseCase Provider
final deleteProductUseCaseProvider = Provider<DeleteProductUseCase>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  return DeleteProductUseCase(repository);
});

/// Bump Product UseCase Provider
final bumpProductUseCaseProvider = Provider<BumpProductUseCase>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  return BumpProductUseCase(repository);
});

/// Get My Products UseCase Provider
final getMyProductsUseCaseProvider = Provider<GetMyProductsUseCase>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  return GetMyProductsUseCase(repository);
});

/// Get My Favorite Products UseCase Provider
final getMyFavoriteProductsUseCaseProvider =
    Provider<GetMyFavoriteProductsUseCase>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  return GetMyFavoriteProductsUseCase(repository);
});

/// Update Product Status UseCase Provider
final updateProductStatusUseCaseProvider =
    Provider<UpdateProductStatusUseCase>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  return UpdateProductStatusUseCase(repository);
});

/// Get Product Stats UseCase Provider
final getProductStatsUseCaseProvider = Provider<GetProductStatsUseCase>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  return GetProductStatsUseCase(repository);
});

/// Get Product Stats By User Id UseCase Provider
final getProductStatsByUserIdUseCaseProvider =
    Provider<GetProductStatsByUserIdUseCase>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  return GetProductStatsByUserIdUseCase(repository);
});

/// Get Products By User Id UseCase Provider
final getProductsByUserIdUseCaseProvider =
    Provider<GetProductsByUserIdUseCase>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  return GetProductsByUserIdUseCase(repository);
});

/// 삭제된 상품 ID 이벤트 Provider (단일 소스)
/// 상품 삭제 시 이 Provider에 productId를 설정하면
/// 모든 목록 Provider가 자동으로 해당 상품을 제거합니다.
final deletedProductIdProvider = StateProvider<int?>((ref) => null);

/// 수정된 상품 이벤트 Provider (단일 소스)
/// 상품 수정 시 이 Provider에 product를 설정하면
/// 모든 목록 Provider가 자동으로 해당 상품을 업데이트합니다.
final updatedProductProvider = StateProvider<pod.Product?>((ref) => null);

/// Product Notifier Provider (메인 상품 목록용)
/// 홈 화면에서 전체/카테고리별 상품 목록, 정렬, 무한 스크롤 관리
final productNotifierProvider =
    StateNotifierProvider.autoDispose<ProductNotifier, ProductState>((ref) {
  final getPaginatedProductsUseCase =
      ref.watch(getPaginatedProductsUseCaseProvider);
  final getProductDetailUseCase = ref.watch(getProductDetailUseCaseProvider);
  return ProductNotifier(
    ref,
    getPaginatedProductsUseCase,
    getProductDetailUseCase,
  );
});

/// Product Detail Notifier Provider (상세 화면용)
final productDetailNotifierProvider = StateNotifierProvider.autoDispose<
    ProductDetailNotifier, ProductDetailState>((ref) {
  final getProductDetailUseCase = ref.watch(getProductDetailUseCaseProvider);
  final toggleFavoriteUseCase = ref.watch(toggleFavoriteUseCaseProvider);
  final isFavoriteUseCase = ref.watch(isFavoriteUseCaseProvider);
  final incrementViewCountUseCase =
      ref.watch(incrementViewCountUseCaseProvider);
  final getUserByIdUseCase = ref.watch(getUserByIdUseCaseProvider);
  final deleteProductUseCase = ref.watch(deleteProductUseCaseProvider);
  final updateProductStatusUseCase =
      ref.watch(updateProductStatusUseCaseProvider);
  final bumpProductUseCase = ref.watch(bumpProductUseCaseProvider);
  return ProductDetailNotifier(
    ref,
    getProductDetailUseCase,
    toggleFavoriteUseCase,
    isFavoriteUseCase,
    incrementViewCountUseCase,
    getUserByIdUseCase,
    deleteProductUseCase,
    updateProductStatusUseCase,
    bumpProductUseCase,
  );
});

/// Create Product Notifier Provider (상품 등록 화면용)
final createProductNotifierProvider = StateNotifierProvider.autoDispose<
    CreateProductNotifier, CreateProductState>((ref) {
  final uploadImageUseCase = ref.watch(uploadImageUseCaseProvider);
  final deleteImageUseCase = ref.watch(deleteImageUseCaseProvider);
  final createProductUseCase = ref.watch(createProductUseCaseProvider);
  return CreateProductNotifier(
    uploadImageUseCase,
    deleteImageUseCase,
    createProductUseCase,
  );
});

/// Update Product Notifier Provider (상품 수정 화면용)
final updateProductNotifierProvider = StateNotifierProvider.autoDispose<
    UpdateProductNotifier, UpdateProductState>((ref) {
  final getProductDetailUseCase = ref.watch(getProductDetailUseCaseProvider);
  final uploadImageUseCase = ref.watch(uploadImageUseCaseProvider);
  final deleteImageUseCase = ref.watch(deleteImageUseCaseProvider);
  final updateProductUseCase = ref.watch(updateProductUseCaseProvider);
  return UpdateProductNotifier(
    ref, // Ref 추가
    getProductDetailUseCase,
    uploadImageUseCase,
    deleteImageUseCase,
    updateProductUseCase,
  );
});

/// Profile Product Notifier Provider (프로필 화면용)
/// type: "myProducts" (내 상품) 또는 "myFavorite" (찜 목록)
final profileProductNotifierProvider = StateNotifierProvider.autoDispose
    .family<ProductNotifier, ProductState, String>((ref, type) {
  final getPaginatedProductsUseCase =
      ref.watch(getPaginatedProductsUseCaseProvider);
  final getProductDetailUseCase = ref.watch(getProductDetailUseCaseProvider);
  final getMyProductsUseCase = ref.watch(getMyProductsUseCaseProvider);
  final getMyFavoriteProductsUseCase =
      ref.watch(getMyFavoriteProductsUseCaseProvider);
  return ProductNotifier(
    ref,
    getPaginatedProductsUseCase,
    getProductDetailUseCase,
    getMyProductsUseCase: getMyProductsUseCase,
    getMyFavoriteProductsUseCase: getMyFavoriteProductsUseCase,
  );
});

/// 다른 사용자의 상품 목록 Notifier Provider
final otherUserProductListNotifierProvider = StateNotifierProvider.autoDispose
    .family<OtherUserProductListNotifier, ProductState, int>(
  (ref, userId) {
    final getProductsByUserIdUseCase =
        ref.watch(getProductsByUserIdUseCaseProvider);
    return OtherUserProductListNotifier(
      getProductsByUserIdUseCase,
      userId,
    );
  },
);
