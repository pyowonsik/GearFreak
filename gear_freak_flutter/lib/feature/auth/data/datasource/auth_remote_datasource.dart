import 'package:gear_freak_client/gear_freak_client.dart';
import 'package:serverpod_auth_shared_flutter/serverpod_auth_shared_flutter.dart';

/// 인증 원격 데이터 소스
class AuthRemoteDataSource {
  final Client client;
  final SessionManager sessionManager;

  AuthRemoteDataSource(this.client, this.sessionManager);

  /// 로그인 API 호출
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      // Serverpod 이메일 인증
      final authenticate =
          await client.modules.auth.email.authenticate(email, password);

      if (!authenticate.success || authenticate.userInfo == null) {
        throw Exception('로그인 실패: ${authenticate.failReason ?? '알 수 없는 오류'}');
      }

      // 세션 등록
      await sessionManager.registerSignedInUser(
        authenticate.userInfo!,
        authenticate.keyId!,
        authenticate.key!,
      );

      // 사용자 정보 조회
      final userInfo = await client.user.getMe();
      final userInfoMap = {
        'id': userInfo.id?.toString(),
        'userName': userInfo.userName,
        'email': userInfo.email,
        'fullName': userInfo.fullName,
        'created': userInfo.created?.toIso8601String(),
      };
      print('✅ 로그인 성공: $userInfoMap');

      return userInfoMap;
    } catch (e) {
      print('❌ 로그인 실패: $e');
      rethrow;
    }
  }

  /// 회원가입 API 호출 (이메일 인증 생략 - 개발용)
  Future<Map<String, dynamic>> signup({
    required String userName,
    required String email,
    required String password,
  }) async {
    try {
      print('📝 회원가입 시작: userName=$userName, email=$email');

      // 개발용: 이메일 인증 없이 바로 회원가입
      final userInfo = await client.auth.signupWithoutEmailVerification(
        userName: userName,
        email: email,
        password: password,
      );

      print('📝 signupWithoutEmailVerification 결과: $userInfo');

      // UserInfo를 Map으로 변환
      final userInfoMap = {
        'id': userInfo.id?.toString(),
        'userName': userInfo.userName,
        'email': userInfo.email,
        'fullName': userInfo.fullName,
        'created': userInfo.created?.toIso8601String(),
      };

      // 자동 로그인
      final authenticate =
          await client.modules.auth.email.authenticate(email, password);

      if (authenticate.success && authenticate.userInfo != null) {
        await sessionManager.registerSignedInUser(
          authenticate.userInfo!,
          authenticate.keyId!,
          authenticate.key!,
        );
      } else {
        throw Exception('회원가입은 성공했지만 로그인에 실패했습니다.');
      }

      print('✅ 회원가입 성공: $userInfoMap');

      return userInfoMap;
    } catch (e, stackTrace) {
      print('❌ 회원가입 실패: $e');
      print('❌ Stack trace: $stackTrace');
      rethrow;
    }
  }
}
