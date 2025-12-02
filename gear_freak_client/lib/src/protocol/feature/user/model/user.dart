/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _i1;
import 'package:serverpod_auth_client/serverpod_auth_client.dart' as _i2;

/// 사용자 정보
abstract class User implements _i1.SerializableModel {
  User._({
    this.id,
    required this.userInfoId,
    this.userInfo,
    this.nickname,
    this.profileImageUrl,
    this.bio,
    this.withdrawalDate,
    this.blockedReason,
    this.blockedAt,
    this.lastLoginAt,
    this.createdAt,
  });

  factory User({
    int? id,
    required int userInfoId,
    _i2.UserInfo? userInfo,
    String? nickname,
    String? profileImageUrl,
    String? bio,
    DateTime? withdrawalDate,
    String? blockedReason,
    DateTime? blockedAt,
    DateTime? lastLoginAt,
    DateTime? createdAt,
  }) = _UserImpl;

  factory User.fromJson(Map<String, dynamic> jsonSerialization) {
    return User(
      id: jsonSerialization['id'] as int?,
      userInfoId: jsonSerialization['userInfoId'] as int,
      userInfo: jsonSerialization['userInfo'] == null
          ? null
          : _i2.UserInfo.fromJson(
              (jsonSerialization['userInfo'] as Map<String, dynamic>)),
      nickname: jsonSerialization['nickname'] as String?,
      profileImageUrl: jsonSerialization['profileImageUrl'] as String?,
      bio: jsonSerialization['bio'] as String?,
      withdrawalDate: jsonSerialization['withdrawalDate'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(
              jsonSerialization['withdrawalDate']),
      blockedReason: jsonSerialization['blockedReason'] as String?,
      blockedAt: jsonSerialization['blockedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['blockedAt']),
      lastLoginAt: jsonSerialization['lastLoginAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(
              jsonSerialization['lastLoginAt']),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int userInfoId;

  /// 인증 모듈에 저장된 사용자 정보
  _i2.UserInfo? userInfo;

  /// 닉네임
  String? nickname;

  /// 프로필 이미지 URL
  String? profileImageUrl;

  /// 자기 소개 (biography)
  String? bio;

  /// 사용자 탈퇴 요청 날짜 (3개월 후 사용자 정보 삭제)
  DateTime? withdrawalDate;

  /// 계정 정지 이유
  String? blockedReason;

  /// 계정 정지 날짜
  DateTime? blockedAt;

  /// 최근 접속일
  DateTime? lastLoginAt;

  /// 계정 생성일 (가입일)
  DateTime? createdAt;

  /// Returns a shallow copy of this [User]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  User copyWith({
    int? id,
    int? userInfoId,
    _i2.UserInfo? userInfo,
    String? nickname,
    String? profileImageUrl,
    String? bio,
    DateTime? withdrawalDate,
    String? blockedReason,
    DateTime? blockedAt,
    DateTime? lastLoginAt,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'userInfoId': userInfoId,
      if (userInfo != null) 'userInfo': userInfo?.toJson(),
      if (nickname != null) 'nickname': nickname,
      if (profileImageUrl != null) 'profileImageUrl': profileImageUrl,
      if (bio != null) 'bio': bio,
      if (withdrawalDate != null) 'withdrawalDate': withdrawalDate?.toJson(),
      if (blockedReason != null) 'blockedReason': blockedReason,
      if (blockedAt != null) 'blockedAt': blockedAt?.toJson(),
      if (lastLoginAt != null) 'lastLoginAt': lastLoginAt?.toJson(),
      if (createdAt != null) 'createdAt': createdAt?.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _UserImpl extends User {
  _UserImpl({
    int? id,
    required int userInfoId,
    _i2.UserInfo? userInfo,
    String? nickname,
    String? profileImageUrl,
    String? bio,
    DateTime? withdrawalDate,
    String? blockedReason,
    DateTime? blockedAt,
    DateTime? lastLoginAt,
    DateTime? createdAt,
  }) : super._(
          id: id,
          userInfoId: userInfoId,
          userInfo: userInfo,
          nickname: nickname,
          profileImageUrl: profileImageUrl,
          bio: bio,
          withdrawalDate: withdrawalDate,
          blockedReason: blockedReason,
          blockedAt: blockedAt,
          lastLoginAt: lastLoginAt,
          createdAt: createdAt,
        );

  /// Returns a shallow copy of this [User]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  User copyWith({
    Object? id = _Undefined,
    int? userInfoId,
    Object? userInfo = _Undefined,
    Object? nickname = _Undefined,
    Object? profileImageUrl = _Undefined,
    Object? bio = _Undefined,
    Object? withdrawalDate = _Undefined,
    Object? blockedReason = _Undefined,
    Object? blockedAt = _Undefined,
    Object? lastLoginAt = _Undefined,
    Object? createdAt = _Undefined,
  }) {
    return User(
      id: id is int? ? id : this.id,
      userInfoId: userInfoId ?? this.userInfoId,
      userInfo:
          userInfo is _i2.UserInfo? ? userInfo : this.userInfo?.copyWith(),
      nickname: nickname is String? ? nickname : this.nickname,
      profileImageUrl:
          profileImageUrl is String? ? profileImageUrl : this.profileImageUrl,
      bio: bio is String? ? bio : this.bio,
      withdrawalDate:
          withdrawalDate is DateTime? ? withdrawalDate : this.withdrawalDate,
      blockedReason:
          blockedReason is String? ? blockedReason : this.blockedReason,
      blockedAt: blockedAt is DateTime? ? blockedAt : this.blockedAt,
      lastLoginAt: lastLoginAt is DateTime? ? lastLoginAt : this.lastLoginAt,
      createdAt: createdAt is DateTime? ? createdAt : this.createdAt,
    );
  }
}
