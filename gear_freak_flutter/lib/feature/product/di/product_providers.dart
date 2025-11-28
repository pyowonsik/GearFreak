import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import 'package:gear_freak_flutter/common/s3/di/s3_providers.dart';
import 'package:gear_freak_flutter/feature/product/data/datasource/product_remote_datasource.dart';
import 'package:gear_freak_flutter/feature/product/data/repository/product_repository_impl.dart';
import 'package:gear_freak_flutter/feature/product/domain/repository/product_repository.dart';
import 'package:gear_freak_flutter/feature/product/domain/usecase/create_product_usecase.dart';
import 'package:gear_freak_flutter/feature/product/domain/usecase/delete_product_usecase.dart';
import 'package:gear_freak_flutter/feature/product/domain/usecase/get_paginated_products_usecase.dart';
import 'package:gear_freak_flutter/feature/product/domain/usecase/get_product_detail_usecase.dart';
import 'package:gear_freak_flutter/feature/product/domain/usecase/is_favorite_usecase.dart';
import 'package:gear_freak_flutter/feature/product/domain/usecase/toggle_favorite_usecase.dart';
import 'package:gear_freak_flutter/feature/product/domain/usecase/update_product_usecase.dart';
import 'package:gear_freak_flutter/feature/product/presentation/provider/create_product_notifier.dart';
import 'package:gear_freak_flutter/feature/product/presentation/provider/create_product_state.dart';
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

/// 삭제된 상품 ID 이벤트 Provider (단일 소스)
/// 상품 삭제 시 이 Provider에 productId를 설정하면
/// 모든 목록 Provider가 자동으로 해당 상품을 제거합니다.
final deletedProductIdProvider = StateProvider<int?>((ref) => null);

/// 수정된 상품 이벤트 Provider (단일 소스)
/// 상품 수정 시 이 Provider에 product를 설정하면
/// 모든 목록 Provider가 자동으로 해당 상품을 업데이트합니다.
final updatedProductProvider = StateProvider<pod.Product?>((ref) => null);

/// Home Products Notifier Provider (홈 화면용 - 최근 상품 5개)
final homeProductsNotifierProvider =
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

/// All Products Notifier Provider (전체 상품 화면용 - 페이지네이션)
final allProductsNotifierProvider =
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
  final getUserByIdUseCase = ref.watch(getUserByIdUseCaseProvider);
  final deleteProductUseCase = ref.watch(deleteProductUseCaseProvider);
  return ProductDetailNotifier(
    ref,
    getProductDetailUseCase,
    toggleFavoriteUseCase,
    isFavoriteUseCase,
    getUserByIdUseCase,
    deleteProductUseCase,
  );
});

/// Category Products Notifier Provider (카테고리별 상품 화면용 - 페이지네이션)
final categoryProductsNotifierProvider = StateNotifierProvider.autoDispose
    .family<ProductNotifier, ProductState, pod.ProductCategory>(
        (ref, category) {
  final getPaginatedProductsUseCase =
      ref.watch(getPaginatedProductsUseCaseProvider);
  final getProductDetailUseCase = ref.watch(getProductDetailUseCaseProvider);
  return ProductNotifier(
    ref,
    getPaginatedProductsUseCase,
    getProductDetailUseCase,
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
