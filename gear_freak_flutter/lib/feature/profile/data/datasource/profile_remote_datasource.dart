import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import 'package:gear_freak_flutter/common/service/pod_service.dart';

/// 프로필 원격 데이터 소스
class ProfileRemoteDataSource {
  /// ProfileRemoteDataSource 생성자
  const ProfileRemoteDataSource();

  pod.Client get _client => PodService.instance.client;

  /// 🧪 Mock 데이터 사용 여부 (테스트용)
  static const bool _useMockData = true;

  /// 🧪 Mock 사용자 데이터 생성
  pod.User _generateMockUser(int id) {
    final now = DateTime.now();
    return pod.User(
      id: id,
      userInfoId: id,
      nickname: id == 1 ? '장비충#abc123' : '사용자$id',
      profileImageUrl: id % 3 == 0 ? 'https://picsum.photos/seed/$id/200' : null,
      createdAt: now.subtract(Duration(days: id * 10)),
    );
  }

  /// 사용자 ID로 사용자 정보 조회
  Future<pod.User> getUserById(int id) async {
    if (_useMockData) {
      await Future<void>.delayed(const Duration(milliseconds: 300));
      return _generateMockUser(id);
    }

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
