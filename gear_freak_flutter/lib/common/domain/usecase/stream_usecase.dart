import 'dart:async';

/// Stream UseCase 인터페이스
///
/// 스트림 기반 비즈니스 로직 UseCase의 기본 인터페이스입니다.
///
/// [T]: 스트림에서 반환될 데이터의 타입
/// [Params]: UseCase의 입력 파라미터 타입
/// [Repo]: UseCase가 사용할 Repository 인터페이스 타입
abstract class StreamUseCase<T, Params, Repo> {
  /// Repository 인스턴스를 반환합니다.
  Repo get repo;

  /// UseCase를 실행하여 스트림을 반환합니다.
  ///
  /// 스트림에서 에러가 발생하면 Stream의 에러 핸들러로 처리됩니다.
  Stream<T> call(Params param);
}
