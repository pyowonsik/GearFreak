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

  /// 현재 사용자의 권한(Scope) 정보를 조회합니다
  Future<List<String>> getUserScopes(Session session) async {
    return await UserService.getUserScopes(session);
  }
}
