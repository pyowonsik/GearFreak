import 'package:flutter/foundation.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import 'package:gear_freak_flutter/common/service/pod_service.dart';
import 'package:serverpod_auth_shared_flutter/serverpod_auth_shared_flutter.dart';

/// 인증 원격 데이터 소스
class AuthRemoteDataSource {
  /// AuthRemoteDataSource 생성자
  const AuthRemoteDataSource();

  pod.Client get _client => PodService.instance.client;
  SessionManager get _sessionManager => PodService.instance.sessionManager;

  /// 로그인 API 호출
  Future<pod.User> login({
    required String email,
    required String password,
  }) async {
    try {
      // Serverpod 이메일 인증
      final authenticate =
          await _client.modules.auth.email.authenticate(email, password);

      if (!authenticate.success || authenticate.userInfo == null) {
        throw Exception('로그인 실패: ${authenticate.failReason ?? '알 수 없는 오류'}');
      }

      // 세션 등록
      await _sessionManager.registerSignedInUser(
        authenticate.userInfo!,
        authenticate.keyId!,
        authenticate.key!,
      );

      // 사용자 정보 조회 (User 클래스 반환)
      final user = await _client.user.getMe();
      debugPrint('✅ 로그인 성공: user=${user.id}, nickname=${user.nickname}');

      return user;
    } catch (e) {
      debugPrint('❌ 로그인 실패: $e');
      rethrow;
    }
  }

  /// 회원가입 API 호출 (이메일 인증 생략 - 개발용)
  Future<pod.User> signup({
    required String userName,
    required String email,
    required String password,
  }) async {
    try {
      debugPrint('📝 회원가입 시작: userName=$userName, email=$email');

      // 개발용: 이메일 인증 없이 바로 회원가입 (User 클래스 반환)
      final user = await _client.auth.signupWithoutEmailVerification(
        userName: userName,
        email: email,
        password: password,
      );

      debugPrint('📝 signupWithoutEmailVerification 결과: user=${user.id}, '
          'nickname=${user.nickname}');

      // 자동 로그인
      final authenticate =
          await _client.modules.auth.email.authenticate(email, password);

      if (authenticate.success && authenticate.userInfo != null) {
        await _sessionManager.registerSignedInUser(
          authenticate.userInfo!,
          authenticate.keyId!,
          authenticate.key!,
        );
      } else {
        throw Exception('회원가입은 성공했지만 로그인에 실패했습니다.');
      }

      debugPrint('✅ 회원가입 성공: user=${user.id}, nickname=${user.nickname}');

      return user;
    } catch (e, stackTrace) {
      debugPrint('❌ 회원가입 실패: $e');
      debugPrint('❌ Stack trace: $stackTrace');
      rethrow;
    }
  }
}
