import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gear_freak_flutter/common/s3/data/datasource/s3_remote_datasource.dart';
import 'package:gear_freak_flutter/common/s3/data/repository/s3_repository_impl.dart';
import 'package:gear_freak_flutter/common/s3/domain/repository/s3_repository.dart';
import 'package:gear_freak_flutter/common/s3/domain/usecase/upload_image_usecase.dart';

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
