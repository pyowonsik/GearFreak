import 'package:dartz/dartz.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import 'package:gear_freak_flutter/common/domain/usecase/usecase.dart';
import 'package:gear_freak_flutter/feature/profile/domain/domain.dart';

/// 사용자 ID로 사용자 정보 조회 UseCase
class GetUserByIdUseCase implements UseCase<pod.User, int, ProfileRepository> {
  /// GetUserByIdUseCase 생성자
  ///
  /// [repository]는 프로필 Repository 인스턴스입니다.
  const GetUserByIdUseCase(this.repository);

  /// 프로필 Repository 인스턴스
  final ProfileRepository repository;

  @override
  ProfileRepository get repo => repository;

  @override
  Future<Either<Failure, pod.User>> call(int param) async {
    try {
      final result = await repository.getUserById(param);
      return Right(result);
    } on Exception catch (e) {
      return Left(
        GetUserByIdFailure(
          '사용자 정보를 불러올 수 없습니다.',
          exception: e,
        ),
      );
    }
  }
}
