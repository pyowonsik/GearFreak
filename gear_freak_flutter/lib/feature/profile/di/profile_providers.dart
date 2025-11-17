import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/datasource/profile_remote_datasource.dart';
import '../data/repository/profile_repository_impl.dart';
import '../domain/repository/profile_repository.dart';
import '../domain/usecase/get_user_profile_usecase.dart';
import '../presentation/provider/profile_notifier.dart';

/// Profile Remote DataSource Provider
final profileRemoteDataSourceProvider = Provider<ProfileRemoteDataSource>((ref) {
  return const ProfileRemoteDataSource();
});

/// Profile Repository Provider
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final remoteDataSource = ref.watch(profileRemoteDataSourceProvider);
  return ProfileRepositoryImpl(remoteDataSource);
});

/// Get User Profile UseCase Provider
final getUserProfileUseCaseProvider = Provider<GetUserProfileUseCase>((ref) {
  final repository = ref.watch(profileRepositoryProvider);
  return GetUserProfileUseCase(repository);
});

/// Profile Notifier Provider
final profileNotifierProvider = StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  final getUserProfileUseCase = ref.watch(getUserProfileUseCaseProvider);
  return ProfileNotifier(getUserProfileUseCase);
});

