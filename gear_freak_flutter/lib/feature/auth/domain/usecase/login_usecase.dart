import 'package:dartz/dartz.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import '../../../../common/domain/usecase/usecase.dart';
import '../domain.dart';

/// 로그인 파라미터
class LoginParams {
  final String email;
  final String password;

  const LoginParams({
    required this.email,
    required this.password,
  });
}

/// 로그인 UseCase
class LoginUseCase implements UseCase<pod.User, LoginParams, AuthRepository> {
  final AuthRepository repository;

  const LoginUseCase(this.repository);

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
