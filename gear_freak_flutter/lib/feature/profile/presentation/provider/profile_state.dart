import 'package:gear_freak_client/gear_freak_client.dart' as pod;

/// 프로필 상태 (Sealed Class 방식)
sealed class ProfileState {
  const ProfileState();
}

/// 초기 상태
class ProfileInitial extends ProfileState {
  /// ProfileInitial 생성자
  const ProfileInitial();
}

/// 로딩 중 상태
class ProfileLoading extends ProfileState {
  /// ProfileLoading 생성자
  const ProfileLoading();
}

/// 프로필 로드 성공 상태
class ProfileLoaded extends ProfileState {
  /// ProfileLoaded 생성자
  ///
  /// [user]는 사용자 정보입니다.
  /// [uploadedFileKey]는 업로드된 프로필 이미지 파일 키입니다.
  const ProfileLoaded({
    required this.user,
    this.uploadedFileKey,
  });

  /// 사용자 정보
  final pod.User user;

  /// 업로드된 프로필 이미지 파일 키 (temp/profile에 업로드된 새 이미지)
  final String? uploadedFileKey;
}

/// 프로필 이미지 업로드 중 상태
class ProfileImageUploading extends ProfileLoaded {
  /// ProfileImageUploading 생성자
  ///
  /// [user]는 사용자 정보입니다.
  /// [uploadedFileKey]는 기존에 업로드된 프로필 이미지 파일 키입니다.
  /// [currentFileName]은 현재 업로드 중인 파일 이름입니다.
  const ProfileImageUploading({
    required super.user,
    required this.currentFileName,
    super.uploadedFileKey,
  });

  /// 현재 업로드 중인 파일 이름
  final String currentFileName;
}

/// 프로필 이미지 업로드 성공 상태
class ProfileImageUploadSuccess extends ProfileLoaded {
  /// ProfileImageUploadSuccess 생성자
  ///
  /// [user]는 사용자 정보입니다.
  /// [uploadedFileKey]는 업로드된 프로필 이미지 파일 키입니다.
  const ProfileImageUploadSuccess({
    required super.user,
    required super.uploadedFileKey,
  });
}

/// 프로필 이미지 업로드 실패 상태
class ProfileImageUploadError extends ProfileLoaded {
  /// ProfileImageUploadError 생성자
  ///
  /// [user]는 사용자 정보입니다.
  /// [uploadedFileKey]는 기존에 업로드된 프로필 이미지 파일 키입니다.
  /// [error]는 에러 메시지입니다.
  const ProfileImageUploadError({
    required super.user,
    required this.error,
    super.uploadedFileKey,
  });

  /// 에러 메시지
  final String error;
}

/// 프로필 업데이트 중 상태
class ProfileUpdating extends ProfileLoaded {
  /// ProfileUpdating 생성자
  ///
  /// [user]는 사용자 정보입니다.
  /// [uploadedFileKey]는 업로드된 프로필 이미지 파일 키입니다.
  const ProfileUpdating({
    required super.user,
    super.uploadedFileKey,
  });
}

/// 프로필 업데이트 성공 상태
class ProfileUpdated extends ProfileLoaded {
  /// ProfileUpdated 생성자
  ///
  /// [user]는 업데이트된 사용자 정보입니다.
  const ProfileUpdated({
    required super.user,
  });
}

/// 프로필 업데이트 실패 상태
class ProfileUpdateError extends ProfileLoaded {
  /// ProfileUpdateError 생성자
  ///
  /// [user]는 사용자 정보입니다.
  /// [uploadedFileKey]는 업로드된 프로필 이미지 파일 키입니다.
  /// [error]는 에러 메시지입니다.
  const ProfileUpdateError({
    required super.user,
    required this.error,
    super.uploadedFileKey,
  });

  /// 에러 메시지
  final String error;
}

/// 프로필 로드 실패 상태
class ProfileError extends ProfileState {
  /// ProfileError 생성자
  ///
  /// [message]는 에러 메시지입니다.
  const ProfileError(this.message);

  /// 에러 메시지
  final String message;
}
