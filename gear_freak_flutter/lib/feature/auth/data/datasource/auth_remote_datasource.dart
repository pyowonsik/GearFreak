import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:flutter_naver_login/interface/types/naver_login_status.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import 'package:gear_freak_flutter/common/service/pod_service.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk_user.dart' as kakao;
import 'package:serverpod_auth_shared_flutter/serverpod_auth_shared_flutter.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

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

  /// 구글 로그인 API 호출 (Firebase Auth 사용)
  Future<pod.User> loginWithGoogle() async {
    try {
      debugPrint('🔵 구글 로그인 시작...');

      // 1. Google Sign-In으로 ID 토큰 획득
      // ⚠️ Android에서는 ID Token을 얻기 위해 serverClientId가 필요합니다.
      // 웹 클라이언트 ID를 사용합니다 (Firebase 프로젝트의 웹 클라이언트 ID).
      final serverClientId = dotenv.env['GOOGLE_SERVER_CLIENT_ID'];
      final googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
        serverClientId: serverClientId, // Android에서 ID Token 획득에 필요
      );

      // 이전 세션 정리
      try {
        await googleSignIn.disconnect();
      } catch (_) {}
      await googleSignIn.signOut();

      // Google 로그인 실행
      final googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        throw Exception('구글 로그인이 취소되었습니다.');
      }

      // Google 인증 정보 가져오기
      final googleAuth = await googleUser.authentication;

      debugPrint('🔵 구글 인증 정보:');
      debugPrint('   - Email: ${googleUser.email}');
      debugPrint('   - Display Name: ${googleUser.displayName}');

      if (googleAuth.idToken == null) {
        throw Exception('구글 ID Token을 가져올 수 없습니다.');
      }

      // 2. Firebase Auth로 로그인 (중간 처리)
      debugPrint('🔵 Firebase Auth로 로그인 중...');
      final credential = FirebaseAuth.instance.signInWithCredential(
        GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
          accessToken: googleAuth.accessToken,
        ),
      );

      // Firebase ID 토큰 획득
      final userCredential = await credential;
      final firebaseIdToken = await userCredential.user?.getIdToken();

      if (firebaseIdToken == null) {
        throw Exception('Firebase ID Token을 가져올 수 없습니다.');
      }

      debugPrint('🔵 Firebase ID Token 획득 성공');

      // 3. Serverpod Firebase 인증
      debugPrint('🔵 Serverpod Firebase 인증 시작...');
      final authenticate =
          await _client.modules.auth.firebase.authenticate(firebaseIdToken);

      debugPrint('🔵 Serverpod 인증 결과:');
      debugPrint('   - Success: ${authenticate.success}');
      debugPrint('   - Fail Reason: ${authenticate.failReason}');

      if (!authenticate.success || authenticate.userInfo == null) {
        throw Exception('구글 로그인 실패: ${authenticate.failReason ?? '알 수 없는 오류'}');
      }

      // 4. 세션 등록
      await _sessionManager.registerSignedInUser(
        authenticate.userInfo!,
        authenticate.keyId!,
        authenticate.key!,
      );

      // 5. User 테이블에 사용자 생성 또는 조회
      final user = await _client.auth.getOrCreateUserAfterGoogleLogin();

      debugPrint('✅ 구글 로그인 성공: user=${user.id}');

      return user;
    } catch (e) {
      debugPrint('❌ 구글 로그인 실패: $e');
      rethrow;
    }
  }

  /// 카카오 로그인 API 호출
  Future<pod.User> loginWithKakao() async {
    try {
      debugPrint('🟡 카카오 로그인 시작...');

      // 1. 카카오 SDK로 로그인
      // 카카오톡이 설치되어 있으면 카카오톡으로, 없으면 카카오계정으로 로그인
      kakao.OAuthToken token;
      try {
        token = await kakao.UserApi.instance.loginWithKakaoTalk();
        debugPrint('🟡 카카오톡으로 로그인 성공');
      } catch (error) {
        // 카카오톡 로그인 실패 시 카카오계정으로 로그인 시도
        try {
          token = await kakao.UserApi.instance.loginWithKakaoAccount();
          debugPrint('🟡 카카오계정으로 로그인 성공');
        } catch (e) {
          throw Exception('카카오 로그인이 취소되었습니다.');
        }
      }

      debugPrint('🟡 카카오 Access Token 획득 성공');

      // 2. Serverpod 카카오 인증
      debugPrint('🟡 Serverpod 카카오 인증 시작...');
      final authenticate =
          await _client.auth.authenticateWithKakao(token.accessToken);

      debugPrint('🟡 Serverpod 인증 결과:');
      debugPrint('   - Success: ${authenticate.success}');
      debugPrint('   - Fail Reason: ${authenticate.failReason}');

      if (!authenticate.success || authenticate.userInfo == null) {
        throw Exception(
          '카카오 로그인 실패: ${authenticate.failReason ?? '알 수 없는 오류'}',
        );
      }

      // 3. 세션 등록
      await _sessionManager.registerSignedInUser(
        authenticate.userInfo!,
        authenticate.keyId!,
        authenticate.key!,
      );

      // 4. User 테이블에 사용자 생성 또는 조회
      final user = await _client.auth.getOrCreateUserAfterKakaoLogin();

      debugPrint('✅ 카카오 로그인 성공: user=${user.id}');

      return user;
    } catch (e) {
      debugPrint('❌ 카카오 로그인 실패: $e');
      rethrow;
    }
  }

  /// 네이버 로그인 API 호출
  Future<pod.User> loginWithNaver() async {
    try {
      debugPrint('🟢 네이버 로그인 시작...');

      // 1. 네이버 SDK로 로그인
      final result = await FlutterNaverLogin.logIn();

      if (result.status != NaverLoginStatus.loggedIn) {
        throw Exception('네이버 로그인이 취소되었습니다.');
      }

      debugPrint('🟢 네이버 로그인 성공');

      // 2. Access Token 획득
      final token = await FlutterNaverLogin.getCurrentAccessToken();
      debugPrint('🟢 네이버 Access Token 획득 성공');

      // 3. Serverpod 네이버 인증
      debugPrint('🟢 Serverpod 네이버 인증 시작...');
      final authenticate =
          await _client.auth.authenticateWithNaver(token.accessToken);

      debugPrint('🟢 Serverpod 인증 결과:');
      debugPrint('   - Success: ${authenticate.success}');
      debugPrint('   - Fail Reason: ${authenticate.failReason}');

      if (!authenticate.success || authenticate.userInfo == null) {
        throw Exception(
          '네이버 로그인 실패: ${authenticate.failReason ?? '알 수 없는 오류'}',
        );
      }

      // 4. 세션 등록
      await _sessionManager.registerSignedInUser(
        authenticate.userInfo!,
        authenticate.keyId!,
        authenticate.key!,
      );

      // 5. User 테이블에 사용자 생성 또는 조회
      final user = await _client.auth.getOrCreateUserAfterNaverLogin();

      debugPrint('✅ 네이버 로그인 성공: user=${user.id}');

      return user;
    } catch (e) {
      debugPrint('❌ 네이버 로그인 실패: $e');
      rethrow;
    }
  }

  /// 애플 로그인 API 호출 (Firebase Auth 사용)
  Future<pod.User> loginWithApple() async {
    try {
      debugPrint('🍎 애플 로그인 시작...');

      // 1. Sign in with Apple으로 인증
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      debugPrint('🍎 애플 인증 정보:');
      debugPrint('   - User ID: ${appleCredential.userIdentifier}');
      debugPrint('   - Email: ${appleCredential.email}');
      debugPrint('   - Given Name: ${appleCredential.givenName}');
      debugPrint('   - Family Name: ${appleCredential.familyName}');

      if (appleCredential.identityToken == null) {
        throw Exception('애플 ID Token을 가져올 수 없습니다.');
      }

      // 2. Firebase Auth로 로그인
      debugPrint('🍎 Firebase Auth로 로그인 중...');
      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(oauthCredential);

      // Firebase ID 토큰 획득
      final firebaseIdToken = await userCredential.user?.getIdToken();

      if (firebaseIdToken == null) {
        throw Exception('Firebase ID Token을 가져올 수 없습니다.');
      }

      debugPrint('🍎 Firebase ID Token 획득 성공');

      // 3. Serverpod Firebase 인증
      debugPrint('🍎 Serverpod Firebase 인증 시작...');
      final authenticate =
          await _client.modules.auth.firebase.authenticate(firebaseIdToken);

      debugPrint('🍎 Serverpod 인증 결과:');
      debugPrint('   - Success: ${authenticate.success}');
      debugPrint('   - Fail Reason: ${authenticate.failReason}');

      if (!authenticate.success || authenticate.userInfo == null) {
        throw Exception(
          '애플 로그인 실패: ${authenticate.failReason ?? '알 수 없는 오류'}',
        );
      }

      // 4. 세션 등록
      await _sessionManager.registerSignedInUser(
        authenticate.userInfo!,
        authenticate.keyId!,
        authenticate.key!,
      );

      // 5. User 테이블에 사용자 생성 또는 조회
      final user = await _client.auth.getOrCreateUserAfterAppleLogin();

      debugPrint('✅ 애플 로그인 성공: user=${user.id}');

      return user;
    } catch (e) {
      debugPrint('❌ 애플 로그인 실패: $e');
      rethrow;
    }
  }
}
