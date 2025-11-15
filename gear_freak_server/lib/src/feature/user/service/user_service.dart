import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_server/serverpod_auth_server.dart';

/// 사용자 서비스
/// 사용자 정보 조회 등 사용자 관련 비즈니스 로직을 처리합니다.
class UserService {
  /// 현재 로그인한 사용자 정보를 가져옵니다
  static Future<UserInfo> getMe(Session session) async {
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

    return userInfo;
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
