import 'package:dartz/dartz.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import '../../../../common/domain/usecase/usecase.dart';
import '../domain.dart';

/// 회원가입 UseCase
class SignupUseCase implements UseCase<pod.User, SignupParams, AuthRepository> {
  final AuthRepository repository;

  const SignupUseCase(this.repository);

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
  final String userName;
  final String email;
  final String password;

  const SignupParams({
    required this.userName,
    required this.email,
    required this.password,
  });
}
