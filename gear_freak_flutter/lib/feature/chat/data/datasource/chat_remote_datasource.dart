import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import '../../../../common/service/pod_service.dart';

/// 채팅 원격 데이터 소스
/// Data Layer: Serverpod Client를 사용한 API 호출
class ChatRemoteDataSource {
  const ChatRemoteDataSource();

  pod.Client get _client => PodService.instance.client;

  /// 채팅 목록 조회
  Future<List<Map<String, dynamic>>> getChatList() async {
    // TODO: Serverpod 엔드포인트 호출
    // 예시: return await client.chat.getChatList();

    // 임시 더미 데이터
    return [
      {
        'id': '1',
        'senderId': 'user1',
        'senderName': '사용자 1',
        'content': '안녕하세요!',
        'timestamp': DateTime.now().toIso8601String(),
        'isRead': false,
      },
    ];
  }

  /// 메시지 전송
  Future<Map<String, dynamic>> sendMessage({
    required String chatRoomId,
    required String content,
  }) async {
    // TODO: Serverpod 엔드포인트 호출
    // 예시: return await client.chat.sendMessage(...);

    return {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'senderId': 'current_user',
      'senderName': '나',
      'content': content,
      'timestamp': DateTime.now().toIso8601String(),
      'isRead': false,
    };
  }
}
