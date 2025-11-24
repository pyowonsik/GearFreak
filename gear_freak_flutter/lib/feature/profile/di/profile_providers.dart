import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gear_freak_flutter/feature/profile/data/datasource/profile_remote_datasource.dart';
import 'package:gear_freak_flutter/feature/profile/data/repository/profile_repository_impl.dart';
import 'package:gear_freak_flutter/feature/profile/domain/repository/profile_repository.dart';
import 'package:gear_freak_flutter/feature/profile/domain/usecase/get_user_by_id_usecase.dart';
import 'package:gear_freak_flutter/feature/profile/domain/usecase/get_user_profile_usecase.dart';
import 'package:gear_freak_flutter/feature/profile/presentation/provider/profile_notifier.dart';
import 'package:gear_freak_flutter/feature/profile/presentation/provider/profile_state.dart';

/// Profile Remote DataSource Provider
final profileRemoteDataSourceProvider =
    Provider<ProfileRemoteDataSource>((ref) {
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

/// Get User By Id UseCase Provider
final getUserByIdUseCaseProvider = Provider<GetUserByIdUseCase>((ref) {
  final repository = ref.watch(profileRepositoryProvider);
  return GetUserByIdUseCase(repository);
});

/// Profile Notifier Provider
final profileNotifierProvider =
    StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  /// usecase 주입
  final getUserProfileUseCase = ref.watch(getUserProfileUseCaseProvider);
  final getUserByIdUseCase = ref.watch(getUserByIdUseCaseProvider);
  return ProfileNotifier(getUserProfileUseCase, getUserByIdUseCase);
});
