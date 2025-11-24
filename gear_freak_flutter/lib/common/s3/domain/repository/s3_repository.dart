import 'package:gear_freak_client/gear_freak_client.dart' as pod;

/// S3 Repository 인터페이스
abstract class S3Repository {
  /// Presigned URL 생성
  Future<pod.GeneratePresignedUploadUrlResponseDto> generatePresignedUploadUrl(
    pod.GeneratePresignedUploadUrlRequestDto request,
  );

  /// 파일 업로드 (Presigned URL 사용)
  Future<void> uploadFile({
    required String presignedUrl,
    required List<int> fileBytes,
    required String contentType,
  });
}
