import 'package:dartz/dartz.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import 'package:gear_freak_flutter/common/domain/usecase/usecase.dart';
import 'package:gear_freak_flutter/feature/auth/domain/domain.dart';

/// 네이버 로그인 UseCase
class LoginWithNaverUseCase implements UseCase<pod.User, void, AuthRepository> {
  /// LoginWithNaverUseCase 생성자
  ///
  /// [repository]는 인증 Repository 인스턴스입니다.
  const LoginWithNaverUseCase(this.repository);

  /// 인증 Repository 인스턴스
  final AuthRepository repository;

  @override
  AuthRepository get repo => repository;

  @override
  Future<Either<Failure, pod.User>> call(void param) async {
    try {
      final result = await repository.loginWithNaver();
      return Right(result);
    } on Exception catch (e) {
      return Left(
        LoginFailure(
          '네이버 로그인에 실패했습니다.',
          exception: e,
        ),
      );
    }
  }
}
