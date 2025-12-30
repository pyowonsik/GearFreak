import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import 'package:gear_freak_flutter/shared/feature/s3/data/datasource/s3_remote_datasource.dart';
import 'package:gear_freak_flutter/shared/feature/s3/domain/repository/s3_repository.dart';

/// S3 Repository 구현
class S3RepositoryImpl implements S3Repository {
  /// S3RepositoryImpl 생성자
  ///
  /// [remoteDataSource]는 S3 원격 데이터 소스입니다.
  const S3RepositoryImpl(this.remoteDataSource);

  /// S3 원격 데이터 소스
  final S3RemoteDataSource remoteDataSource;

  @override
  Future<pod.GeneratePresignedUploadUrlResponseDto> generatePresignedUploadUrl(
    pod.GeneratePresignedUploadUrlRequestDto request,
  ) async {
    return remoteDataSource.generatePresignedUploadUrl(request);
  }

  @override
  Future<void> uploadFile({
    required String presignedUrl,
    required List<int> fileBytes,
    required String contentType,
  }) async {
    return remoteDataSource.uploadFile(
      presignedUrl: presignedUrl,
      fileBytes: fileBytes,
      contentType: contentType,
    );
  }

  @override
  Future<void> deleteFile({
    required String fileKey,
    required String bucketType,
  }) async {
    return remoteDataSource.deleteFile(
      fileKey: fileKey,
      bucketType: bucketType,
    );
  }

  @override
  Future<pod.GeneratePresignedUploadUrlResponseDto>
      generateChatRoomImageUploadUrl({
    required int chatRoomId,
    required String fileName,
    required String contentType,
    required int fileSize,
  }) async {
    return remoteDataSource.generateChatRoomImageUploadUrl(
      chatRoomId: chatRoomId,
      fileName: fileName,
      contentType: contentType,
      fileSize: fileSize,
    );
  }
}
