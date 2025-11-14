import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/di/providers.dart';
import '../data/datasource/auth_remote_datasource.dart';
import '../data/repository/auth_repository_impl.dart';
import '../domain/repository/auth_repository.dart';
import '../domain/usecase/login_usecase.dart';
import '../presentation/provider/auth_notifier.dart';

/// SharedPreferences Provider
final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) async {
  return await SharedPreferences.getInstance();
});

/// Auth Remote DataSource Provider
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  final client = ref.watch(clientProvider);
  return AuthRemoteDataSource(client);
});

/// Auth Repository Provider
final authRepositoryProvider = FutureProvider<AuthRepository>((ref) async {
  final remoteDataSource = ref.watch(authRemoteDataSourceProvider);
  final sharedPreferences = await ref.watch(sharedPreferencesProvider.future);
  
  return AuthRepositoryImpl(remoteDataSource, sharedPreferences);
});

/// Login UseCase Provider
final loginUseCaseProvider = FutureProvider<LoginUseCase>((ref) async {
  final repository = await ref.watch(authRepositoryProvider.future);
  return LoginUseCase(repository);
});

/// Auth Notifier Provider
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  // TODO: 실제 로그인 로직 구현 시 사용
  // final loginUseCase = ref.watch(loginUseCaseProvider);
  // return AuthNotifier(loginUseCase);
  throw UnimplementedError('AuthNotifier is not needed for now');
});

