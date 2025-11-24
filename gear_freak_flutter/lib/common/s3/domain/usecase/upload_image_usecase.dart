import 'package:dartz/dartz.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import '../../../../common/domain/usecase/usecase.dart';
import '../failures/s3_failure.dart';
import '../repository/s3_repository.dart';

/// 이미지 업로드 파라미터
class UploadImageParams {
  final pod.GeneratePresignedUploadUrlRequestDto request;
  final List<int> fileBytes;

  const UploadImageParams({
    required this.request,
    required this.fileBytes,
  });
}

/// 이미지 업로드 UseCase
class UploadImageUseCase
    implements
        UseCase<pod.GeneratePresignedUploadUrlResponseDto, UploadImageParams,
            S3Repository> {
  final S3Repository repository;

  const UploadImageUseCase(this.repository);

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

