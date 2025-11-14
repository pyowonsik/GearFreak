import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/di/providers.dart';
import '../data/datasource/home_remote_datasource.dart';
import '../data/repository/home_repository_impl.dart';
import '../domain/repository/home_repository.dart';
import '../domain/usecase/get_recent_products_usecase.dart';
import '../presentation/provider/home_notifier.dart';

/// Home Remote DataSource Provider
final homeRemoteDataSourceProvider = Provider<HomeRemoteDataSource>((ref) {
  final client = ref.watch(clientProvider);
  return HomeRemoteDataSource(client);
});

/// Home Repository Provider
final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  final remoteDataSource = ref.watch(homeRemoteDataSourceProvider);
  return HomeRepositoryImpl(remoteDataSource);
});

/// Get Recent Products UseCase Provider
final getRecentProductsUseCaseProvider =
    Provider<GetRecentProductsUseCase>((ref) {
  final repository = ref.watch(homeRepositoryProvider);
  return GetRecentProductsUseCase(repository);
});

/// Home Notifier Provider
final homeNotifierProvider =
    StateNotifierProvider<HomeNotifier, HomeState>((ref) {
  final getRecentProductsUseCase = ref.watch(getRecentProductsUseCaseProvider);
  final repository = ref.watch(homeRepositoryProvider);
  return HomeNotifier(getRecentProductsUseCase, repository);
});
