import 'package:serverpod/serverpod.dart';
import 'package:gear_freak_server/src/generated/protocol.dart';
import '../service/user_service.dart';

/// 사용자 엔드포인트
class UserEndpoint extends Endpoint
// with AuthenticatedMixin
{
  /// 현재 로그인한 사용자 정보를 가져옵니다
  Future<User> getMe(Session session) async {
    return await UserService.getMe(session);
  }

  /// 사용자 Id로 사용자 정보를 가져옵니다
  Future<User> getUserById(Session session, int id) async {
    return await UserService.getUserById(session, id);
  }

  /// 현재 사용자의 권한(Scope) 정보를 조회합니다
  Future<List<String>> getUserScopes(Session session) async {
    return await UserService.getUserScopes(session);
  }

  // // 사용자 프로필 수정
  // Future<User> updateUserProfile(Session session, UpdateUserProfileRequestDto request) async {
  //   return await UserService.updateUserProfile(session, request);
  // }
}
