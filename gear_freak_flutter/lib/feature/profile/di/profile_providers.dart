import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/di/providers.dart';
import '../data/datasource/profile_remote_datasource.dart';
import '../data/repository/profile_repository_impl.dart';
import '../domain/repository/profile_repository.dart';
import '../presentation/provider/profile_notifier.dart';

/// Profile Remote DataSource Provider
final profileRemoteDataSourceProvider = Provider<ProfileRemoteDataSource>((ref) {
  final client = ref.watch(clientProvider);
  return ProfileRemoteDataSource(client);
});

/// Profile Repository Provider
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final remoteDataSource = ref.watch(profileRemoteDataSourceProvider);
  return ProfileRepositoryImpl(remoteDataSource);
});

/// Profile Notifier Provider
final profileNotifierProvider = StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  final repository = ref.watch(profileRepositoryProvider);
  return ProfileNotifier(repository);
});

