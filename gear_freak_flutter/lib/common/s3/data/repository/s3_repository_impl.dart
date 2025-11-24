import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import '../../domain/repository/s3_repository.dart';
import '../datasource/s3_remote_datasource.dart';

/// S3 Repository 구현
class S3RepositoryImpl implements S3Repository {
  final S3RemoteDataSource remoteDataSource;

  const S3RepositoryImpl(this.remoteDataSource);

  @override
  Future<pod.GeneratePresignedUploadUrlResponseDto> generatePresignedUploadUrl(
    pod.GeneratePresignedUploadUrlRequestDto request,
  ) async {
    return await remoteDataSource.generatePresignedUploadUrl(request);
  }

  @override
  Future<void> uploadFile({
    required String presignedUrl,
    required List<int> fileBytes,
    required String contentType,
  }) async {
    return await remoteDataSource.uploadFile(
      presignedUrl: presignedUrl,
      fileBytes: fileBytes,
      contentType: contentType,
    );
  }
}
