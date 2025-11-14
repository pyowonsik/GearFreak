import '../entity/user_profile.dart';

/// 프로필 Repository 인터페이스
abstract class ProfileRepository {
  /// 사용자 프로필 조회
  Future<UserProfile> getUserProfile();
}

