import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gear_freak_flutter/common/s3/di/s3_providers.dart';
import 'package:gear_freak_flutter/feature/auth/di/auth_providers.dart';
import 'package:gear_freak_flutter/feature/product/di/product_providers.dart';
import 'package:gear_freak_flutter/feature/profile/data/datasource/profile_remote_datasource.dart';
import 'package:gear_freak_flutter/feature/profile/data/repository/profile_repository_impl.dart';
import 'package:gear_freak_flutter/feature/profile/domain/repository/profile_repository.dart';
import 'package:gear_freak_flutter/feature/profile/domain/usecase/get_user_by_id_usecase.dart';
import 'package:gear_freak_flutter/feature/profile/domain/usecase/update_user_profile_usecase.dart';
import 'package:gear_freak_flutter/feature/profile/presentation/provider/other_user_profile_notifier.dart';
import 'package:gear_freak_flutter/feature/profile/presentation/provider/other_user_profile_state.dart';
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

/// Get User By Id UseCase Provider
final getUserByIdUseCaseProvider = Provider<GetUserByIdUseCase>((ref) {
  final repository = ref.watch(profileRepositoryProvider);
  return GetUserByIdUseCase(repository);
});

/// Update User Profile UseCase Provider
final updateUserProfileUseCaseProvider =
    Provider<UpdateUserProfileUseCase>((ref) {
  final repository = ref.watch(profileRepositoryProvider);
  return UpdateUserProfileUseCase(repository);
});

/// Profile Notifier Provider
final profileNotifierProvider =
    StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  /// usecase 주입
  final getMeUseCase = ref.watch(getMeUseCaseProvider);
  final getUserByIdUseCase = ref.watch(getUserByIdUseCaseProvider);
  final uploadImageUseCase = ref.watch(uploadImageUseCaseProvider);
  final deleteImageUseCase = ref.watch(deleteImageUseCaseProvider);
  final updateUserProfileUseCase = ref.watch(updateUserProfileUseCaseProvider);
  final getProductStatsUseCase = ref.watch(getProductStatsUseCaseProvider);
  return ProfileNotifier(
    ref,
    getMeUseCase,
    getUserByIdUseCase,
    uploadImageUseCase,
    deleteImageUseCase,
    updateUserProfileUseCase,
    getProductStatsUseCase,
  );
});

/// 다른 사용자 프로필 Notifier Provider
final otherUserProfileNotifierProvider = StateNotifierProvider.autoDispose<
    OtherUserProfileNotifier, OtherUserProfileState>(
  (ref) {
    final getUserByIdUseCase = ref.watch(getUserByIdUseCaseProvider);
    return OtherUserProfileNotifier(getUserByIdUseCase);
  },
);
