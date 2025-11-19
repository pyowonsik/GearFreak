import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import '../data/datasource/product_remote_datasource.dart';
import '../data/repository/product_repository_impl.dart';
import '../domain/repository/product_repository.dart';
import '../domain/usecase/get_paginated_products_usecase.dart';
import '../domain/usecase/get_product_detail_usecase.dart';
import '../domain/usecase/toggle_favorite_usecase.dart';
import '../domain/usecase/is_favorite_usecase.dart';
import '../presentation/provider/product_notifier.dart';
import '../presentation/provider/product_state.dart';
import '../presentation/provider/product_detail_notifier.dart';
import '../presentation/provider/product_detail_state.dart';
import '../../profile/di/profile_providers.dart';

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

/// Home Products Notifier Provider (홈 화면용 - 최근 상품 5개)
final homeProductsNotifierProvider =
    StateNotifierProvider.autoDispose<ProductNotifier, ProductState>((ref) {
  final getPaginatedProductsUseCase =
      ref.watch(getPaginatedProductsUseCaseProvider);
  final getProductDetailUseCase = ref.watch(getProductDetailUseCaseProvider);
  return ProductNotifier(
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
  return ProductDetailNotifier(
    getProductDetailUseCase,
    toggleFavoriteUseCase,
    isFavoriteUseCase,
    getUserByIdUseCase,
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
    getPaginatedProductsUseCase,
    getProductDetailUseCase,
  );
});
