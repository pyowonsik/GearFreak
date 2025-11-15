import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gear_freak_flutter/feature/auth/presentation/provider/auth_state.dart';
import '../../../core/di/providers.dart';
import '../data/datasource/auth_remote_datasource.dart';
import '../data/repository/auth_repository_impl.dart';
import '../domain/repository/auth_repository.dart';
import '../domain/usecase/login_usecase.dart';
import '../domain/usecase/signup_usecase.dart';
import '../presentation/provider/auth_notifier.dart';

/// Auth Remote DataSource Provider
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  final client = ref.watch(clientProvider);
  final sessionManager = ref.watch(sessionManagerProvider);
  return AuthRemoteDataSource(client, sessionManager);
});

/// Auth Repository Provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final remoteDataSource = ref.watch(authRemoteDataSourceProvider);
  final client = ref.watch(clientProvider);
  final sessionManager = ref.watch(sessionManagerProvider);

  return AuthRepositoryImpl(remoteDataSource, client, sessionManager);
});

/// Login UseCase Provider
final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return LoginUseCase(repository);
});

/// Signup UseCase Provider
final signupUseCaseProvider = Provider<SignupUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return SignupUseCase(repository);
});

/// Auth Notifier Provider
final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final loginUseCase = ref.watch(loginUseCaseProvider);
  final signupUseCase = ref.watch(signupUseCaseProvider);

  return AuthNotifier(loginUseCase, signupUseCase);
});
