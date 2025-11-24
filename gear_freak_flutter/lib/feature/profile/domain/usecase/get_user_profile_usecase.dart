import 'package:dartz/dartz.dart';
import 'package:gear_freak_flutter/common/domain/usecase/usecase.dart';
import 'package:gear_freak_flutter/feature/profile/domain/domain.dart';

/// 사용자 프로필 조회 UseCase
class GetUserProfileUseCase
    implements UseCase<UserProfile, void, ProfileRepository> {
  /// GetUserProfileUseCase 생성자
  ///
  /// [repository]는 프로필 Repository 인스턴스입니다.
  const GetUserProfileUseCase(this.repository);

  /// 프로필 Repository 인스턴스
  final ProfileRepository repository;

  @override
  ProfileRepository get repo => repository;

  @override
  Future<Either<Failure, UserProfile>> call(void param) async {
    try {
      final result = await repository.getUserProfile();
      return Right(result);
    } on Exception catch (e) {
      return Left(
        GetUserProfileFailure(
          '프로필을 불러올 수 없습니다.',
          exception: e,
        ),
      );
    }
  }
}
