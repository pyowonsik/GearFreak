/// 사용자 엔티티
class User {
  final String id;
  final String email;
  final String? nickname;
  final String? profileImageUrl;
  final String? accessToken;
  final String? refreshToken;

  const User({
    required this.id,
    required this.email,
    this.nickname,
    this.profileImageUrl,
    this.accessToken,
    this.refreshToken,
  });

  User copyWith({
    String? id,
    String? email,
    String? nickname,
    String? profileImageUrl,
    String? accessToken,
    String? refreshToken,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      nickname: nickname ?? this.nickname,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
    );
  }
}

