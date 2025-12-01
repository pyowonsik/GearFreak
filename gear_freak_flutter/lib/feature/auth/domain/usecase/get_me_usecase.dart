import 'package:dartz/dartz.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import 'package:gear_freak_flutter/common/domain/usecase/usecase.dart';
import 'package:gear_freak_flutter/feature/auth/domain/domain.dart';

/// 현재 사용자 정보 조회 UseCase
class GetMeUseCase implements UseCase<pod.User?, void, AuthRepository> {
  /// GetMeUseCase 생성자
  ///
  /// [repository]는 인증 Repository 인스턴스입니다.
  const GetMeUseCase(this.repository);

  /// 인증 Repository 인스턴스
  final AuthRepository repository;

  @override
  AuthRepository get repo => repository;

  @override
  Future<Either<Failure, pod.User?>> call(void param) async {
    try {
      final result = await repository.getMe();
      return Right(result);
    } on Exception catch (e) {
      return Left(
        GetMeFailure(
          '사용자 정보를 불러올 수 없습니다.',
          exception: e,
        ),
      );
    }
  }
}
