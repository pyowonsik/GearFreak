import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/datasource/s3_remote_datasource.dart';
import '../data/repository/s3_repository_impl.dart';
import '../domain/repository/s3_repository.dart';
import '../domain/usecase/upload_image_usecase.dart';

/// S3 Remote DataSource Provider
final s3RemoteDataSourceProvider = Provider<S3RemoteDataSource>((ref) {
  return const S3RemoteDataSource();
});

/// S3 Repository Provider
final s3RepositoryProvider = Provider<S3Repository>((ref) {
  final remoteDataSource = ref.watch(s3RemoteDataSourceProvider);
  return S3RepositoryImpl(remoteDataSource);
});

/// Upload Image UseCase Provider
final uploadImageUseCaseProvider = Provider<UploadImageUseCase>((ref) {
  final repository = ref.watch(s3RepositoryProvider);
  return UploadImageUseCase(repository);
});
