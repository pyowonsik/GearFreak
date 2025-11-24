import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import 'package:gear_freak_flutter/feature/profile/data/datasource/profile_remote_datasource.dart';
import 'package:gear_freak_flutter/feature/profile/domain/entity/user_profile.dart';
import 'package:gear_freak_flutter/feature/profile/domain/repository/profile_repository.dart';

/// 프로필 Repository 구현
class ProfileRepositoryImpl implements ProfileRepository {
  /// ProfileRepositoryImpl 생성자
  ///
  /// [remoteDataSource]는 프로필 원격 데이터 소스입니다.
  const ProfileRepositoryImpl(this.remoteDataSource);

  /// 프로필 원격 데이터 소스
  final ProfileRemoteDataSource remoteDataSource;

  @override
  Future<UserProfile> getUserProfile() async {
    final data = await remoteDataSource.getUserProfile();
    return UserProfile(
      id: data['id'] as String,
      nickname: data['nickname'] as String,
      email: data['email'] as String,
      sellingCount: data['sellingCount'] as int? ?? 0,
      soldCount: data['soldCount'] as int? ?? 0,
      favoriteCount: data['favoriteCount'] as int? ?? 0,
    );
  }

  @override
  Future<pod.User> getUserById(int id) async {
    return remoteDataSource.getUserById(id);
  }
}
