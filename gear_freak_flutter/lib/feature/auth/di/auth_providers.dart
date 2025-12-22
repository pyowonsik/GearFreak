import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gear_freak_flutter/feature/auth/data/datasource/auth_remote_datasource.dart';
import 'package:gear_freak_flutter/feature/auth/data/repository/auth_repository_impl.dart';
import 'package:gear_freak_flutter/feature/auth/domain/repository/auth_repository.dart';
import 'package:gear_freak_flutter/feature/auth/domain/usecase/get_me_usecase.dart';
import 'package:gear_freak_flutter/feature/auth/domain/usecase/login_usecase.dart';
import 'package:gear_freak_flutter/feature/auth/domain/usecase/login_with_apple_usecase.dart';
import 'package:gear_freak_flutter/feature/auth/domain/usecase/login_with_google_usecase.dart';
import 'package:gear_freak_flutter/feature/auth/domain/usecase/login_with_kakao_usecase.dart';
import 'package:gear_freak_flutter/feature/auth/domain/usecase/signup_usecase.dart';
import 'package:gear_freak_flutter/feature/auth/presentation/provider/auth_notifier.dart';
import 'package:gear_freak_flutter/feature/auth/presentation/provider/auth_state.dart';

/// Auth Remote DataSource Provider
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return const AuthRemoteDataSource();
});

/// Auth Repository Provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final remoteDataSource = ref.watch(authRemoteDataSourceProvider);
  return AuthRepositoryImpl(remoteDataSource);
});

/// Get Me UseCase Provider
final getMeUseCaseProvider = Provider<GetMeUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return GetMeUseCase(repository);
});

/// Login UseCase Provider
final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return LoginUseCase(repository);
});

/// Login With Google UseCase Provider
final loginWithGoogleUseCaseProvider = Provider<LoginWithGoogleUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return LoginWithGoogleUseCase(repository);
});

/// Login With Kakao UseCase Provider
final loginWithKakaoUseCaseProvider = Provider<LoginWithKakaoUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return LoginWithKakaoUseCase(repository);
});

/// Login With Apple UseCase Provider
final loginWithAppleUseCaseProvider = Provider<LoginWithAppleUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return LoginWithAppleUseCase(repository);
});

/// Signup UseCase Provider
final signupUseCaseProvider = Provider<SignupUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return SignupUseCase(repository);
});

/// Auth Notifier Provider
final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final getMeUseCase = ref.watch(getMeUseCaseProvider);
  final loginUseCase = ref.watch(loginUseCaseProvider);
  final loginWithGoogleUseCase = ref.watch(loginWithGoogleUseCaseProvider);
  final loginWithKakaoUseCase = ref.watch(loginWithKakaoUseCaseProvider);
  final loginWithAppleUseCase = ref.watch(loginWithAppleUseCaseProvider);
  final signupUseCase = ref.watch(signupUseCaseProvider);

  return AuthNotifier(
    getMeUseCase,
    loginUseCase,
    loginWithGoogleUseCase,
    loginWithKakaoUseCase,
    loginWithAppleUseCase,
    signupUseCase,
  );
});
