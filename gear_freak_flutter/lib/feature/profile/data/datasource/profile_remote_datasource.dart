import 'package:gear_freak_client/gear_freak_client.dart';

/// 프로필 원격 데이터 소스
class ProfileRemoteDataSource {
  final Client client;

  ProfileRemoteDataSource(this.client);

  /// 사용자 프로필 조회
  Future<Map<String, dynamic>> getUserProfile() async {
    // TODO: Serverpod 엔드포인트 호출
    // 임시 더미 데이터
    return {
      'id': 'user_1',
      'nickname': '사용자 닉네임',
      'email': 'user@email.com',
      'sellingCount': 3,
      'soldCount': 12,
      'favoriteCount': 8,
    };
  }
}
