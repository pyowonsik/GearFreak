import 'package:dartz/dartz.dart';
import 'package:gear_freak_flutter/shared/domain/failure/failure.dart';

/// UseCase 인터페이스
///
/// 모든 비즈니스 로직 UseCase의 기본 인터페이스입니다.
///
/// [T]: 반환될 데이터의 타입
/// [Params]: UseCase의 입력 파라미터 타입
/// [Repo]: UseCase가 사용할 Repository 인터페이스 타입
abstract class UseCase<T, Params, Repo> {
  /// Repository 인스턴스를 반환합니다.
  Repo get repo;

  /// UseCase를 실행합니다.
  ///
  /// 성공 시 [T] 타입의 데이터를 포함한 [Right]를 반환하고,
  /// 실패 시 [Failure] 타입의 오류를 포함한 [Left]를 반환합니다.
  Future<Either<Failure, T>> call(Params param);
}
