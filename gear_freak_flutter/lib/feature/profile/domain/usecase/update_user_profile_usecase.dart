import 'package:dartz/dartz.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import 'package:gear_freak_flutter/feature/profile/domain/domain.dart';
import 'package:gear_freak_flutter/shared/domain/usecase/usecase.dart';

/// 사용자 프로필 수정 UseCase
class UpdateUserProfileUseCase
    implements
        UseCase<pod.User, pod.UpdateUserProfileRequestDto, ProfileRepository> {
  /// UpdateUserProfileUseCase 생성자
  ///
  /// [repository]는 프로필 Repository 인스턴스입니다.
  const UpdateUserProfileUseCase(this.repository);

  /// 프로필 Repository 인스턴스
  final ProfileRepository repository;

  @override
  ProfileRepository get repo => repository;

  @override
  Future<Either<Failure, pod.User>> call(
    pod.UpdateUserProfileRequestDto param,
  ) async {
    try {
      final result = await repository.updateUserProfile(param);
      return Right(result);
    } on Exception catch (e) {
      return Left(
        UpdateUserProfileFailure(
          '프로필을 수정할 수 없습니다.',
          exception: e,
        ),
      );
    }
  }
}
