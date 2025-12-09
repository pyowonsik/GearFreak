import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import 'package:gear_freak_flutter/common/service/pod_service.dart';

/// 프로필 원격 데이터 소스
class ProfileRemoteDataSource {
  /// ProfileRemoteDataSource 생성자
  const ProfileRemoteDataSource();

  pod.Client get _client => PodService.instance.client;

  /// 사용자 ID로 사용자 정보 조회
  Future<pod.User> getUserById(int id) async {
    return _client.user.getUserById(id);
  }

  /// 사용자 프로필 수정
  Future<pod.User> updateUserProfile(
    pod.UpdateUserProfileRequestDto request,
  ) async {
    try {
      return await _client.user.updateUserProfile(request);
    } catch (e) {
      throw Exception('프로필을 수정하는데 실패했습니다: $e');
    }
  }
}
