import 'package:gear_freak_server/src/common/s3/service/s3_service.dart';
import 'package:gear_freak_server/src/common/s3/util/s3_util.dart';
import 'package:gear_freak_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_server/serverpod_auth_server.dart';

/// 사용자 서비스
/// 사용자 정보 조회 등 사용자 관련 비즈니스 로직을 처리합니다.
class UserService {
  /// 현재 로그인한 사용자 정보를 가져옵니다
  static Future<User> getMe(Session session) async {
    final authenticationInfo = await session.authenticated;

    if (authenticationInfo == null) {
      throw Exception('인증이 필요합니다.');
    }

    // UserInfo에서 기본 정보 가져오기
    final userInfo = await UserInfo.db.findById(
      session,
      authenticationInfo.userId,
    );

    if (userInfo == null) {
      throw Exception('사용자 정보를 찾을 수 없습니다.');
    }

    // User 테이블에서 사용자 정보 조회 (userInfoId로 조회)
    final user = await User.db.findFirstRow(
      session,
      where: (u) => u.userInfoId.equals(userInfo.id!),
    );

    // User가 없으면 생성 (회원가입 시 자동 생성되도록 해야 함)
    if (user == null) {
      // UserInfo를 기반으로 User 생성
      final newUser = User(
        userInfoId: userInfo.id!,
        userInfo: userInfo,
        nickname: userInfo.userName,
        createdAt: DateTime.now().toUtc(),
      );
      return await User.db.insertRow(session, newUser);
    }

    // userInfo 관계 업데이트
    return user.copyWith(userInfo: userInfo);
  }

  /// 사용자 Id로 사용자 정보를 가져옵니다
  static Future<User> getUserById(Session session, int id) async {
    final user = await User.db.findById(session, id);

    if (user == null) {
      throw Exception('사용자 정보를 찾을 수 없습니다.');
    }

    return user;
  }

  /// 현재 사용자의 권한(Scope) 정보를 조회합니다
  static Future<List<String>> getUserScopes(Session session) async {
    final authenticationInfo = await session.authenticated;

    if (authenticationInfo == null) {
      return [];
    }

    return authenticationInfo.scopes
        .map((scope) => scope.name)
        .where((name) => name != null)
        .cast<String>()
        .toList();
  }

  /// 사용자 프로필 수정
  static Future<User> updateUserProfile(
    Session session,
    UpdateUserProfileRequestDto request,
  ) async {
    // 1. 인증 확인
    final authenticationInfo = await session.authenticated;
    if (authenticationInfo == null) {
      throw Exception('인증이 필요합니다.');
    }

    // 2. 현재 사용자 정보 조회
    final currentUser = await getMe(session);
    final userId = currentUser.id!;

    // 3. 닉네임 중복 체크 (닉네임이 변경되는 경우에만)
    if (request.nickname != null &&
        request.nickname != currentUser.nickname &&
        request.nickname!.isNotEmpty) {
      final existingUser = await User.db.findFirstRow(
        session,
        where: (u) =>
            u.nickname.equals(request.nickname!) & u.id.notEquals(userId),
      );

      if (existingUser != null) {
        throw Exception('이미 사용 중인 닉네임입니다.');
      }
    }

    // 4. 프로필 이미지 처리 (temp/profile -> profile)
    String? finalProfileImageUrl;
    if (request.profileImageUrl != null &&
        request.profileImageUrl!.isNotEmpty) {
      try {
        final sourceKey = S3Util.extractKeyFromUrl(request.profileImageUrl!);

        if (sourceKey.startsWith('temp/profile/')) {
          // temp/profile/{userId}/{file} -> profile/{userId}/{file}
          final destinationKey =
              S3Util.convertTempKeyToProfileKey(sourceKey, userId);

          // S3에서 파일 이동
          final movedUrl = await S3Service.moveS3Object(
            session,
            sourceKey,
            destinationKey,
            'public', // 프로필 이미지는 public 버킷
          );

          finalProfileImageUrl = movedUrl;
        } else if (sourceKey.startsWith('profile/')) {
          // 이미 profile 경로에 있으면 그대로 사용
          finalProfileImageUrl = request.profileImageUrl;
        } else {
          // 다른 경로면 그대로 사용
          finalProfileImageUrl = request.profileImageUrl;
        }
      } catch (e) {
        session.log(
          'Failed to move profile image: ${request.profileImageUrl} - $e',
          level: LogLevel.warning,
        );
        // 이동 실패 시 원본 URL 유지
        finalProfileImageUrl = request.profileImageUrl;
      }
    } else if (request.profileImageUrl == null ||
        request.profileImageUrl!.isEmpty) {
      // 프로필 이미지가 null이거나 빈 문자열이면 기존 이미지 삭제
      final existingImageUrl = currentUser.profileImageUrl;
      if (existingImageUrl != null && existingImageUrl.isNotEmpty) {
        try {
          final fileKey = S3Util.extractKeyFromUrl(existingImageUrl);
          // profile 경로의 이미지만 삭제
          if (fileKey.startsWith('profile/')) {
            await S3Service.deleteS3Object(session, fileKey, 'public');
            session.log('Deleted profile image: $fileKey',
                level: LogLevel.info);
          }
        } catch (e) {
          session.log(
            'Failed to delete profile image: $existingImageUrl - $e',
            level: LogLevel.warning,
          );
          // 삭제 실패해도 계속 진행
        }
      }
      finalProfileImageUrl = null;
    }

    // 5. 사용자 정보 업데이트
    final updatedUser = currentUser.copyWith(
      nickname: request.nickname ?? currentUser.nickname,
      profileImageUrl: finalProfileImageUrl,
    );

    final result = await User.db.updateRow(
      session,
      updatedUser,
      columns: (t) => [
        t.nickname,
        t.profileImageUrl,
      ],
    );

    return result;
  }
}
