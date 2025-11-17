import 'package:gear_freak_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_server/serverpod_auth_server.dart';

/// 사용자 서비스
/// 사용자 정보 조회 등 사용자 관련 비즈니스 로직을 처리합니다.
class UserService {
  /// 현재 로그인한 사용자 정보를 가져옵니다
  static Future<User> getMe(Session session) async {
    final authenticationInfo = await session.authenticated;

    if (authenticationInfo == null) {
      throw Exception('인증이 필요합니다.');
    }

    // UserInfo에서 기본 정보 가져오기
    final userInfo = await UserInfo.db.findById(
      session,
      authenticationInfo.userId,
    );

    if (userInfo == null) {
      throw Exception('사용자 정보를 찾을 수 없습니다.');
    }

    // User 테이블에서 사용자 정보 조회 (userInfoId로 조회)
    final user = await User.db.findFirstRow(
      session,
      where: (u) => u.userInfoId.equals(userInfo.id!),
    );

    // User가 없으면 생성 (회원가입 시 자동 생성되도록 해야 함)
    if (user == null) {
      // UserInfo를 기반으로 User 생성
      final newUser = User(
        userInfoId: userInfo.id!,
        userInfo: userInfo,
        nickname: userInfo.userName,
        createdAt: DateTime.now().toUtc(),
      );
      return await User.db.insertRow(session, newUser);
    }

    // userInfo 관계 업데이트
    return user.copyWith(userInfo: userInfo);
  }

  /// 사용자 Id로 사용자 정보를 가져옵니다
  static Future<User> getUserById(Session session, int id) async {
    final user = await User.db.findById(session, id);

    if (user == null) {
      throw Exception('사용자 정보를 찾을 수 없습니다.');
    }

    return user;
  }

  /// 현재 사용자의 권한(Scope) 정보를 조회합니다
  static Future<List<String>> getUserScopes(Session session) async {
    final authenticationInfo = await session.authenticated;

    if (authenticationInfo == null) {
      return [];
    }

    return authenticationInfo.scopes
        .map((scope) => scope.name)
        .where((name) => name != null)
        .cast<String>()
        .toList();
  }
}
