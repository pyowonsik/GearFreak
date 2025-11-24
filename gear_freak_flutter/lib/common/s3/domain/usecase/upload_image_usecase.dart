import 'package:dartz/dartz.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import 'package:gear_freak_flutter/common/domain/usecase/usecase.dart';
import 'package:gear_freak_flutter/common/s3/domain/failures/s3_failure.dart';
import 'package:gear_freak_flutter/common/s3/domain/repository/s3_repository.dart';

/// 이미지 업로드 UseCase
class UploadImageUseCase
    implements
        UseCase<pod.GeneratePresignedUploadUrlResponseDto, UploadImageParams,
            S3Repository> {
  /// UploadImageUseCase 생성자
  ///
  /// [repository]는 S3 Repository 인스턴스입니다.

  const UploadImageUseCase(this.repository);

  /// S3 Repository 인스턴스
  final S3Repository repository;

  @override
  S3Repository get repo => repository;

  @override
  Future<Either<S3Failure, pod.GeneratePresignedUploadUrlResponseDto>> call(
    UploadImageParams param,
  ) async {
    try {
      // 1. Presigned URL 요청
      final presignedUrlResponse =
          await repository.generatePresignedUploadUrl(param.request);

      // 2. S3에 파일 업로드
      await repository.uploadFile(
        presignedUrl: presignedUrlResponse.presignedUrl,
        fileBytes: param.fileBytes,
        contentType: param.request.contentType,
      );

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

/// 이미지 업로드 파라미터
class UploadImageParams {
  /// UploadImageParams 생성자
  ///
  /// [request]는 업로드 요청 정보입니다.
  /// [fileBytes]는 파일 바이트 데이터입니다.
  const UploadImageParams({
    required this.request,
    required this.fileBytes,
  });

  /// 업로드 요청 정보
  final pod.GeneratePresignedUploadUrlRequestDto request;

  /// 파일 바이트 데이터
  final List<int> fileBytes;
}
