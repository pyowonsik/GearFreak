/// 후기 관련 상수
class ReviewConstants {
  /// 최소 평점
  static const int minRating = 1;

  /// 최대 평점
  static const int maxRating = 5;

  /// 후기 내용 최대 길이
  static const int maxContentLength = 500;

  /// FCM 알림에서 후기 내용 미리보기 길이
  static const int fcmContentPreviewLength = 16;
}

/// 페이지네이션 상수
class PaginationConstants {
  /// 기본 페이지 번호
  static const int defaultPage = 1;

  /// 기본 페이지 크기
  static const int defaultLimit = 10;

  /// 최대 페이지 크기
  static const int maxLimit = 100;
}

/// FCM 상수
class FcmConstants {
  /// FCM 토큰 로그에 표시할 길이 (토큰 전체를 로그에 남기지 않기 위해)
  static const int tokenLogLength = 20;

  /// 채팅 알림 채널
  static const String chatChannel = 'chat_channel';
}

/// 사용자 상수
class UserConstants {
  /// 닉네임에 사용할 UUID 길이
  static const int nicknameUuidLength = 9;

  /// 닉네임 접두사
  static const String nicknamePrefix = '장비충#';
}
