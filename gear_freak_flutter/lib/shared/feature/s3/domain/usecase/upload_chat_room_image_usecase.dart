import 'package:dartz/dartz.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import 'package:gear_freak_flutter/shared/domain/usecase/usecase.dart';
import 'package:gear_freak_flutter/shared/feature/s3/domain/failures/s3_failure.dart';
import 'package:gear_freak_flutter/shared/feature/s3/domain/repository/s3_repository.dart';

/// 채팅방 이미지 업로드 UseCase
/// Private 버킷의 chatRoom/{chatRoomId}/ 경로에 바로 업로드
class UploadChatRoomImageUseCase
    implements
        UseCase<pod.GeneratePresignedUploadUrlResponseDto,
            UploadChatRoomImageParams, S3Repository> {
  /// UploadChatRoomImageUseCase 생성자
  ///
  /// [repository]는 S3 Repository 인스턴스입니다.
  const UploadChatRoomImageUseCase(this.repository);

  /// S3 Repository 인스턴스
  final S3Repository repository;

  @override
  S3Repository get repo => repository;

  @override
  Future<Either<S3Failure, pod.GeneratePresignedUploadUrlResponseDto>> call(
    UploadChatRoomImageParams param,
  ) async {
    try {
      // 1. Presigned URL 요청
      final presignedUrlResponse =
          await repository.generateChatRoomImageUploadUrl(
        chatRoomId: param.chatRoomId,
        fileName: param.fileName,
        contentType: param.contentType,
        fileSize: param.fileSize,
      );

      // 2. S3에 파일 업로드
      await repository.uploadFile(
        presignedUrl: presignedUrlResponse.presignedUrl,
        fileBytes: param.fileBytes,
        contentType: param.contentType,
      );

      // 3. Presigned URL 응답 DTO 반환
      return Right(presignedUrlResponse);
    } on Exception catch (e, stackTrace) {
      if (e.toString().contains('Presigned URL') ||
          e.toString().contains('생성에 실패')) {
        return Left(
          GeneratePresignedUrlFailure(
            '업로드 URL 생성에 실패했습니다.',
            exception: e,
            stackTrace: stackTrace,
          ),
        );
      } else {
        return Left(
          UploadFileFailure(
            '파일 업로드에 실패했습니다.',
            exception: e,
            stackTrace: stackTrace,
          ),
        );
      }
    }
  }
}

/// 채팅방 이미지 업로드 파라미터
class UploadChatRoomImageParams {
  /// UploadChatRoomImageParams 생성자
  ///
  /// [chatRoomId]는 채팅방 ID입니다.
  /// [fileName]은 파일 이름입니다.
  /// [contentType]은 파일의 Content-Type입니다.
  /// [fileSize]는 파일 크기입니다.
  /// [fileBytes]는 파일 바이트 데이터입니다.
  const UploadChatRoomImageParams({
    required this.chatRoomId,
    required this.fileName,
    required this.contentType,
    required this.fileSize,
    required this.fileBytes,
  });

  /// 채팅방 ID
  final int chatRoomId;

  /// 파일 이름
  final String fileName;

  /// Content-Type
  final String contentType;

  /// 파일 크기
  final int fileSize;

  /// 파일 바이트 데이터
  final List<int> fileBytes;
}
