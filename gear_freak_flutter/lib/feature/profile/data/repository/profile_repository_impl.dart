import '../../domain/entity/user_profile.dart';
import '../../domain/repository/profile_repository.dart';
import '../datasource/profile_remote_datasource.dart';

/// 프로필 Repository 구현
class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  const ProfileRepositoryImpl(this.remoteDataSource);

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
}

