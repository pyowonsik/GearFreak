import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gear_freak_flutter/feature/search/data/datasource/search_remote_datasource.dart';
import 'package:gear_freak_flutter/feature/search/data/repository/search_repository_impl.dart';
import 'package:gear_freak_flutter/feature/search/domain/repository/search_repository.dart';
import 'package:gear_freak_flutter/feature/search/domain/usecase/search_products_usecase.dart';
import 'package:gear_freak_flutter/feature/search/presentation/provider/search_notifier.dart';
import 'package:gear_freak_flutter/feature/search/presentation/provider/search_state.dart';

/// Search Remote DataSource Provider
final searchRemoteDataSourceProvider = Provider<SearchRemoteDataSource>((ref) {
  return const SearchRemoteDataSource();
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
final searchNotifierProvider =
    StateNotifierProvider<SearchNotifier, SearchState>((ref) {
  final searchProductsUseCase = ref.watch(searchProductsUseCaseProvider);
  return SearchNotifier(ref, searchProductsUseCase);
});
