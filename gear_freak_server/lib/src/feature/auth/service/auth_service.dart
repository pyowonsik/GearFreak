import 'package:gear_freak_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_server/serverpod_auth_server.dart';

/// 인증 서비스
/// 회원가입, 로그인 등 인증 관련 비즈니스 로직을 처리합니다.
class AuthService {
  // ==================== Public Methods (Endpoint에서 직접 호출) ====================

  /// 개발용: 이메일 인증 없이 바로 회원가입
  static Future<User> signupWithoutEmailVerification(
    Session session, {
    required String userName,
    required String email,
    required String password,
  }) async {
    // 1. 이미 존재하는 이메일인지 확인
    final existingEmailAuth = await EmailAuth.db.findFirstRow(
      session,
      where: (t) => t.email.equals(email),
    );

    if (existingEmailAuth != null) {
      throw Exception('이미 존재하는 이메일입니다.');
    }

    // 2. 비밀번호 해시 생성 (Serverpod의 Argon2id 사용)
    final passwordHash = await Emails.generatePasswordHash(password);

    // 3. UserInfo 생성
    final userInfo = UserInfo(
      userIdentifier: email,
      userName: userName,
      email: email,
      fullName: userName,
      scopeNames: [],
      blocked: false,
      created: DateTime.now().toUtc(),
    );
    final savedUserInfo = await UserInfo.db.insertRow(session, userInfo);

    // 4. EmailAuth 생성
    final emailAuth = EmailAuth(
      userId: savedUserInfo.id!,
      email: email,
      hash: passwordHash,
    );
    await EmailAuth.db.insertRow(session, emailAuth);

    // 5. User 생성 (UserInfo와 연결)
    final user = User(
      userInfoId: savedUserInfo.id!,
      userInfo: savedUserInfo,
      nickname: userName,
      createdAt: DateTime.now().toUtc(),
    );
    final savedUser = await User.db.insertRow(session, user);

    return savedUser;
  }
}
