import 'package:dartz/dartz.dart';
import 'package:gear_freak_flutter/common/domain/usecase/usecase.dart';
import 'package:gear_freak_flutter/common/s3/domain/failures/s3_failure.dart';
import 'package:gear_freak_flutter/common/s3/domain/repository/s3_repository.dart';

/// 이미지 삭제 UseCase
class DeleteImageUseCase
    implements UseCase<void, DeleteImageParams, S3Repository> {
  /// DeleteImageUseCase 생성자
  ///
  /// [repository]는 S3 Repository 인스턴스입니다.
  const DeleteImageUseCase(this.repository);

  /// S3 Repository 인스턴스
  final S3Repository repository;

  @override
  S3Repository get repo => repository;

  @override
  Future<Either<S3Failure, void>> call(DeleteImageParams param) async {
    try {
      await repository.deleteFile(
        fileKey: param.fileKey,
        bucketType: param.bucketType,
      );
      return const Right(null);
    } on Exception catch (e, stackTrace) {
      return Left(
        DeleteFileFailure(
          '파일 삭제에 실패했습니다.',
          exception: e,
          stackTrace: stackTrace,
        ),
      );
    }
  }
}

/// 이미지 삭제 파라미터
class DeleteImageParams {
  /// DeleteImageParams 생성자
  ///
  /// [fileKey]는 삭제할 파일 키입니다.
  /// [bucketType]는 버킷 타입입니다 ('public' 또는 'private').
  const DeleteImageParams({
    required this.fileKey,
    required this.bucketType,
  });

  /// 삭제할 파일 키
  final String fileKey;

  /// 버킷 타입 ('public' 또는 'private')
  final String bucketType;
}
