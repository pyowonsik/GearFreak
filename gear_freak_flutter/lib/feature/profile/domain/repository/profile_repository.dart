import 'package:gear_freak_client/gear_freak_client.dart' as pod;

import 'package:gear_freak_flutter/feature/profile/domain/entity/user_profile.dart';

/// 프로필 Repository 인터페이스
abstract class ProfileRepository {
  /// 사용자 프로필 조회
  Future<UserProfile> getUserProfile();

  /// 사용자 Id로 사용자 정보를 가져옵니다
  Future<pod.User> getUserById(int id);
}
