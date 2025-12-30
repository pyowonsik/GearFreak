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

  /// S3 파일 삭제
  Future<void> deleteFile({
    required String fileKey,
    required String bucketType,
  });

  /// 채팅방 이미지 업로드를 위한 Presigned URL 생성
  ///
  /// [chatRoomId]는 채팅방 ID입니다.
  /// [fileName]은 파일 이름입니다.
  /// [contentType]은 파일의 Content-Type입니다.
  /// [fileSize]는 파일 크기입니다.
  /// 반환: Presigned URL 응답 DTO
  Future<pod.GeneratePresignedUploadUrlResponseDto>
      generateChatRoomImageUploadUrl({
    required int chatRoomId,
    required String fileName,
    required String contentType,
    required int fileSize,
  });
}
