import 'package:dartz/dartz.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import 'package:gear_freak_flutter/feature/auth/domain/domain.dart';
import 'package:gear_freak_flutter/shared/domain/usecase/usecase.dart';

/// 회원가입 UseCase
class SignupUseCase implements UseCase<pod.User, SignupParams, AuthRepository> {
  /// 회원가입 UseCase 생성자
  ///
  /// [repository]는 인증 Repository 인스턴스입니다.
  const SignupUseCase(this.repository);

  /// 인증 Repository 인스턴스
  final AuthRepository repository;

  @override
  AuthRepository get repo => repository;

  @override
  Future<Either<Failure, pod.User>> call(SignupParams param) async {
    try {
      final result = await repository.signup(
        userName: param.userName,
        email: param.email,
        password: param.password,
      );
      return Right(result);
    } on Exception catch (e) {
      return Left(
        SignupFailure(
          '회원가입에 실패했습니다.',
          exception: e,
        ),
      );
    }
  }
}

/// 회원가입 파라미터
class SignupParams {
  /// SignupParams 생성자
  ///
  /// [userName]는 사용자 이름입니다.
  /// [email]는 이메일입니다.
  /// [password]는 비밀번호입니다.
  const SignupParams({
    required this.userName,
    required this.email,
    required this.password,
  });

  /// 사용자 이름
  final String userName;

  /// 이메일
  final String email;

  /// 비밀번호
  final String password;
}
