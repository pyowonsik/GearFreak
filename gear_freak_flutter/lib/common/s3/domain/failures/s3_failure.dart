import 'package:gear_freak_flutter/common/domain/failure/failure.dart';

/// S3 실패 추상 클래스
abstract class S3Failure extends Failure {
  /// S3Failure 생성자
  const S3Failure(super.message, {super.exception, super.stackTrace});

  @override
  String toString() => 'S3Failure: $message';
}

/// Presigned URL 생성 실패
class GeneratePresignedUrlFailure extends S3Failure {
  /// GeneratePresignedUrlFailure 생성자
  const GeneratePresignedUrlFailure(
    super.message, {
    super.exception,
    super.stackTrace,
  });

  @override
  String toString() => 'GeneratePresignedUrlFailure: $message';
}

/// 파일 업로드 실패
class UploadFileFailure extends S3Failure {
  /// UploadFileFailure 생성자
  const UploadFileFailure(super.message, {super.exception, super.stackTrace});

  @override
  String toString() => 'UploadFileFailure: $message';
}

/// 파일 삭제 실패
class DeleteFileFailure extends S3Failure {
  /// DeleteFileFailure 생성자
  const DeleteFileFailure(super.message, {super.exception, super.stackTrace});

  @override
  String toString() => 'DeleteFileFailure: $message';
}
