import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/datasource/product_remote_datasource.dart';
import '../data/repository/product_repository_impl.dart';
import '../domain/repository/product_repository.dart';
import '../domain/usecase/get_recent_products_usecase.dart';
import '../domain/usecase/get_all_products_usecase.dart';
import '../domain/usecase/get_product_detail_usecase.dart';
import '../presentation/provider/product_notifier.dart';
import '../presentation/provider/product_state.dart';

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

/// Get Recent Products UseCase Provider
final getRecentProductsUseCaseProvider =
    Provider<GetRecentProductsUseCase>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  return GetRecentProductsUseCase(repository);
});

/// Get All Products UseCase Provider
final getAllProductsUseCaseProvider = Provider<GetAllProductsUseCase>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  return GetAllProductsUseCase(repository);
});

/// Get Product Detail UseCase Provider
final getProductDetailUseCaseProvider =
    Provider<GetProductDetailUseCase>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  return GetProductDetailUseCase(repository);
});

/// Product Notifier Provider
final productNotifierProvider =
    StateNotifierProvider<ProductNotifier, ProductState>((ref) {
  final getRecentProductsUseCase = ref.watch(getRecentProductsUseCaseProvider);
  final getAllProductsUseCase = ref.watch(getAllProductsUseCaseProvider);
  final getProductDetailUseCase = ref.watch(getProductDetailUseCaseProvider);
  return ProductNotifier(
    getRecentProductsUseCase,
    getAllProductsUseCase,
    getProductDetailUseCase,
  );
});
