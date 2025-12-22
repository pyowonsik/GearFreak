import 'dart:convert';
import 'package:gear_freak_server/src/generated/protocol.dart';
import 'package:http/http.dart' as http;
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_server/serverpod_auth_server.dart';
import 'package:uuid/uuid.dart';

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

  /// 구글 로그인 후 User 조회 또는 생성
  /// Serverpod Auth의 google.authenticate()가 UserInfo를 생성한 후 호출됩니다.
  /// 이미 User가 존재하면 조회하고, 없으면 생성합니다.
  static Future<User> getOrCreateUserAfterGoogleLogin(Session session) async {
    // 1. 현재 인증된 사용자 정보 가져오기
    final authenticationInfo = await session.authenticated;

    if (authenticationInfo == null) {
      throw Exception('인증이 필요합니다.');
    }

    // 2. UserInfo 조회
    final userInfo = await UserInfo.db.findById(
      session,
      authenticationInfo.userId,
    );

    if (userInfo == null) {
      throw Exception('사용자 정보를 찾을 수 없습니다.');
    }

    // 3. User 테이블에서 사용자 정보 조회 (userInfoId로 조회)
    final existingUser = await User.db.findFirstRow(
      session,
      where: (u) => u.userInfoId.equals(userInfo.id!),
    );

    // 4. User가 이미 존재하면 반환
    if (existingUser != null) {
      return existingUser.copyWith(userInfo: userInfo);
    }

    // 5. User가 없으면 생성 (구글 로그인 최초 시)
    // 구글 로그인 회원가입 시 닉네임은 무조건 "장비충#UUID" 형식으로 생성
    // ⭐ UUID 사용 - 중복 걱정 없음
    const uuid = Uuid();
    final shortId = uuid.v4().substring(0, 9); // 9자리만 사용
    final nickname = '장비충#$shortId';

    final newUser = User(
      userInfoId: userInfo.id!,
      userInfo: userInfo,
      nickname: nickname,
      createdAt: DateTime.now().toUtc(),
    );

    return await User.db.insertRow(session, newUser);
  }

  /// 애플 로그인 후 User 조회 또는 생성
  /// Serverpod Auth의 firebase.authenticate()가 UserInfo를 생성한 후 호출됩니다.
  /// 이미 User가 존재하면 조회하고, 없으면 생성합니다.
  static Future<User> getOrCreateUserAfterAppleLogin(Session session) async {
    // 1. 현재 인증된 사용자 정보 가져오기
    final authenticationInfo = await session.authenticated;

    if (authenticationInfo == null) {
      throw Exception('인증이 필요합니다.');
    }

    // 2. UserInfo 조회
    final userInfo = await UserInfo.db.findById(
      session,
      authenticationInfo.userId,
    );

    if (userInfo == null) {
      throw Exception('사용자 정보를 찾을 수 없습니다.');
    }

    // 3. User 테이블에서 사용자 정보 조회 (userInfoId로 조회)
    final existingUser = await User.db.findFirstRow(
      session,
      where: (u) => u.userInfoId.equals(userInfo.id!),
    );

    // 4. User가 이미 존재하면 반환
    if (existingUser != null) {
      return existingUser.copyWith(userInfo: userInfo);
    }

    // 5. User가 없으면 생성 (애플 로그인 최초 시)
    // 애플 로그인 회원가입 시 닉네임은 무조건 "장비충#UUID" 형식으로 생성
    // ⭐ UUID 사용 - 중복 걱정 없음
    const uuid = Uuid();
    final shortId = uuid.v4().substring(0, 9); // 9자리만 사용
    final nickname = '장비충#$shortId';

    final newUser = User(
      userInfoId: userInfo.id!,
      userInfo: userInfo,
      nickname: nickname,
      createdAt: DateTime.now().toUtc(),
    );

    return await User.db.insertRow(session, newUser);
  }

  /// 카카오 로그인 인증
  /// 카카오 Access Token을 받아서 검증하고, UserInfo를 생성/조회한 후 인증 키를 발급합니다.
  static Future<AuthenticationResponse> authenticateWithKakao(
    Session session,
    String accessToken,
  ) async {
    try {
      // 1. 카카오 API로 토큰 검증 및 사용자 정보 조회
      final kakaoUserInfo = await _verifyKakaoToken(accessToken);

      // 2. 카카오 ID로 기존 사용자 찾기
      final userIdentifier = 'kakao_${kakaoUserInfo['id']}';
      var userInfo = await Users.findUserByIdentifier(
        session,
        userIdentifier,
      );

      // 3. 사용자가 없으면 생성
      if (userInfo == null) {
        final email = kakaoUserInfo['kakao_account']?['email'] as String?;
        final nickname =
            kakaoUserInfo['kakao_account']?['profile']?['nickname'] as String?;

        userInfo = UserInfo(
          userIdentifier: userIdentifier,
          userName: nickname ?? '카카오사용자',
          email: email ?? '',
          fullName: nickname ?? '카카오사용자',
          scopeNames: [],
          blocked: false,
          created: DateTime.now().toUtc(),
        );

        userInfo = await Users.createUser(
          session,
          userInfo,
          'kakao',
        );
      }

      // 4. 인증 키 생성
      final authToken = await UserAuthentication.signInUser(
        session,
        userInfo?.id ?? 0,
        'kakao',
        scopes: {},
      );

      // 5. AuthenticationResponse 반환
      return AuthenticationResponse(
        success: true,
        keyId: authToken.id,
        key: authToken.key,
        userInfo: userInfo,
      );
    } catch (e) {
      return AuthenticationResponse(
        success: false,
        failReason: null,
      );
    }
  }

  /// 카카오 토큰 검증 및 사용자 정보 조회
  static Future<Map<String, dynamic>> _verifyKakaoToken(
    String accessToken,
  ) async {
    // 1. 카카오 API로 사용자 정보 조회
    final response = await http.get(
      Uri.parse('https://kapi.kakao.com/v2/user/me'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/x-www-form-urlencoded;charset=utf-8',
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
          '카카오 토큰 검증 실패: ${response.statusCode} - ${response.body}');
    }

    final userInfo = json.decode(response.body) as Map<String, dynamic>;

    if (userInfo['id'] == null) {
      throw Exception('카카오 사용자 정보를 가져올 수 없습니다.');
    }

    return userInfo;
  }

  /// 카카오 로그인 후 User 조회 또는 생성
  /// authenticateWithKakao()가 UserInfo를 생성한 후 호출됩니다.
  /// 이미 User가 존재하면 조회하고, 없으면 생성합니다.
  static Future<User> getOrCreateUserAfterKakaoLogin(Session session) async {
    // 1. 현재 인증된 사용자 정보 가져오기
    final authenticationInfo = await session.authenticated;

    if (authenticationInfo == null) {
      throw Exception('인증이 필요합니다.');
    }

    // 2. UserInfo 조회
    final userInfo = await UserInfo.db.findById(
      session,
      authenticationInfo.userId,
    );

    if (userInfo == null) {
      throw Exception('사용자 정보를 찾을 수 없습니다.');
    }

    // 3. User 테이블에서 사용자 정보 조회 (userInfoId로 조회)
    final existingUser = await User.db.findFirstRow(
      session,
      where: (u) => u.userInfoId.equals(userInfo.id!),
    );

    // 4. User가 이미 존재하면 반환
    if (existingUser != null) {
      return existingUser.copyWith(userInfo: userInfo);
    }

    // 5. User가 없으면 생성 (카카오 로그인 최초 시)
    // 카카오 로그인 회원가입 시 닉네임은 무조건 "장비충#UUID" 형식으로 생성
    // ⭐ UUID 사용 - 중복 걱정 없음
    const uuid = Uuid();
    final shortId = uuid.v4().substring(0, 9); // 9자리만 사용
    final nickname = '장비충#$shortId';

    final newUser = User(
      userInfoId: userInfo.id!,
      userInfo: userInfo,
      nickname: nickname,
      createdAt: DateTime.now().toUtc(),
    );

    return await User.db.insertRow(session, newUser);
  }
}
