import 'package:dartz/dartz.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import 'package:gear_freak_flutter/feature/auth/domain/domain.dart';
import 'package:gear_freak_flutter/shared/domain/usecase/usecase.dart';

/// 로그인 UseCase
class LoginUseCase implements UseCase<pod.User, LoginParams, AuthRepository> {
  /// LoginUseCase 생성자
  ///
  /// [repository]는 인증 Repository 인스턴스입니다.
  const LoginUseCase(this.repository);

  /// 인증 Repository 인스턴스
  final AuthRepository repository;

  @override
  AuthRepository get repo => repository;

  @override
  Future<Either<Failure, pod.User>> call(LoginParams param) async {
    try {
      final result = await repository.login(
        email: param.email,
        password: param.password,
      );
      return Right(result);
    } on Exception catch (e) {
      return Left(
        LoginFailure(
          '로그인에 실패했습니다.',
          exception: e,
        ),
      );
    }
  }
}

/// 로그인 파라미터
class LoginParams {
  /// LoginParams 생성자
  ///
  /// [email]는 이메일입니다.
  /// [password]는 비밀번호입니다.
  const LoginParams({
    required this.email,
    required this.password,
  });

  /// 이메일
  final String email;

  /// 비밀번호
  final String password;
}
