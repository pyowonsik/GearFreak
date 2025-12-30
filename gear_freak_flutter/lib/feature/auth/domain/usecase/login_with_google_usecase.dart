import 'package:dartz/dartz.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import 'package:gear_freak_flutter/feature/auth/domain/domain.dart';
import 'package:gear_freak_flutter/shared/domain/usecase/usecase.dart';

/// 구글 로그인 UseCase
class LoginWithGoogleUseCase
    implements UseCase<pod.User, void, AuthRepository> {
  /// LoginWithGoogleUseCase 생성자
  ///
  /// [repository]는 인증 Repository 인스턴스입니다.
  const LoginWithGoogleUseCase(this.repository);

  /// 인증 Repository 인스턴스
  final AuthRepository repository;

  @override
  AuthRepository get repo => repository;

  @override
  Future<Either<Failure, pod.User>> call(void param) async {
    try {
      final result = await repository.loginWithGoogle();
      return Right(result);
    } on Exception catch (e) {
      return Left(
        LoginFailure(
          '구글 로그인에 실패했습니다.',
          exception: e,
        ),
      );
    }
  }
}
