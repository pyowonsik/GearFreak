/// 사용자 프로필 엔티티
class UserProfile {
  /// UserProfile 생성자
  ///
  /// [id]는 사용자 ID입니다.
  /// [nickname]는 사용자 닉네임입니다.
  /// [email]는 사용자 이메일입니다.
  /// [profileImageUrl]는 사용자 프로필 이미지 URL입니다.
  /// [sellingCount]는 판매 건수입니다.
  /// [soldCount]는 판매 건수입니다.
  /// [favoriteCount]는 찜 건수입니다.
  const UserProfile({
    required this.id,
    required this.nickname,
    required this.email,
    this.profileImageUrl,
    this.sellingCount = 0,
    this.soldCount = 0,
    this.favoriteCount = 0,
  });

  /// 사용자 ID
  final String id;

  /// 사용자 닉네임
  final String nickname;

  /// 사용자 이메일
  final String email;

  /// 사용자 프로필 이미지 URL
  final String? profileImageUrl;

  /// 판매 건수
  final int sellingCount;

  /// 판매 건수
  final int soldCount;

  /// 찜 건수
  final int favoriteCount;

  /// UserProfile 복사
  UserProfile copyWith({
    String? id,
    String? nickname,
    String? email,
    String? profileImageUrl,
    int? sellingCount,
    int? soldCount,
    int? favoriteCount,
  }) {
    return UserProfile(
      id: id ?? this.id,
      nickname: nickname ?? this.nickname,
      email: email ?? this.email,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      sellingCount: sellingCount ?? this.sellingCount,
      soldCount: soldCount ?? this.soldCount,
      favoriteCount: favoriteCount ?? this.favoriteCount,
    );
  }
}
