import 'package:dartz/dartz.dart';
import '../../../../core/domain/usecase/usecase.dart';
import '../domain.dart';

/// 사용자 프로필 조회 UseCase
class GetUserProfileUseCase
    implements UseCase<UserProfile, void, ProfileRepository> {
  final ProfileRepository repository;

  const GetUserProfileUseCase(this.repository);

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
