import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import 'package:gear_freak_flutter/feature/profile/data/datasource/profile_remote_datasource.dart';
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
  Future<pod.User> getUserById(int id) async {
    return remoteDataSource.getUserById(id);
  }

  @override
  Future<pod.User> updateUserProfile(
    pod.UpdateUserProfileRequestDto request,
  ) async {
    return remoteDataSource.updateUserProfile(request);
  }
}
