/// 사용자 프로필 엔티티
class UserProfile {
  final String id;
  final String nickname;
  final String email;
  final String? profileImageUrl;
  final int sellingCount;
  final int soldCount;
  final int favoriteCount;

  const UserProfile({
    required this.id,
    required this.nickname,
    required this.email,
    this.profileImageUrl,
    this.sellingCount = 0,
    this.soldCount = 0,
    this.favoriteCount = 0,
  });

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

