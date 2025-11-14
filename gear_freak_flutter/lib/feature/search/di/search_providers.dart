import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/di/providers.dart';
import '../data/datasource/search_remote_datasource.dart';
import '../data/repository/search_repository_impl.dart';
import '../domain/repository/search_repository.dart';
import '../domain/usecase/search_products_usecase.dart';
import '../presentation/provider/search_notifier.dart';

/// Search Remote DataSource Provider
final searchRemoteDataSourceProvider = Provider<SearchRemoteDataSource>((ref) {
  final client = ref.watch(clientProvider);
  return SearchRemoteDataSource(client);
});

/// Search Repository Provider
final searchRepositoryProvider = Provider<SearchRepository>((ref) {
  final remoteDataSource = ref.watch(searchRemoteDataSourceProvider);
  return SearchRepositoryImpl(remoteDataSource);
});

/// Search Products UseCase Provider
final searchProductsUseCaseProvider = Provider<SearchProductsUseCase>((ref) {
  final repository = ref.watch(searchRepositoryProvider);
  return SearchProductsUseCase(repository);
});

/// Search Notifier Provider
final searchNotifierProvider = StateNotifierProvider<SearchNotifier, SearchState>((ref) {
  final searchProductsUseCase = ref.watch(searchProductsUseCaseProvider);
  return SearchNotifier(searchProductsUseCase);
});

