import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/datasource/home_remote_datasource.dart';
import '../data/repository/home_repository_impl.dart';
import '../domain/repository/home_repository.dart';
import '../domain/usecase/get_recent_products_usecase.dart';
import '../presentation/provider/home_notifier.dart';

/// Home Remote DataSource Provider
final homeRemoteDataSourceProvider = Provider<HomeRemoteDataSource>((ref) {
  return const HomeRemoteDataSource();
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
  return GetRecentProductsUseCase(repository); // const 생성자 사용 가능
});

/// Home Notifier Provider
final homeNotifierProvider =
    StateNotifierProvider<HomeNotifier, HomeState>((ref) {
  final getRecentProductsUseCase = ref.watch(getRecentProductsUseCaseProvider);
  return HomeNotifier(getRecentProductsUseCase);
});
