/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod/serverpod.dart' as _i1;

/// 채팅 참여자 정보
abstract class ChatParticipantInfoDto
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  ChatParticipantInfoDto._({
    required this.userId,
    this.nickname,
    this.profileImageUrl,
    this.joinedAt,
    required this.isActive,
    required this.isNotificationEnabled,
  });

  factory ChatParticipantInfoDto({
    required int userId,
    String? nickname,
    String? profileImageUrl,
    DateTime? joinedAt,
    required bool isActive,
    required bool isNotificationEnabled,
  }) = _ChatParticipantInfoDtoImpl;

  factory ChatParticipantInfoDto.fromJson(
      Map<String, dynamic> jsonSerialization) {
    return ChatParticipantInfoDto(
      userId: jsonSerialization['userId'] as int,
      nickname: jsonSerialization['nickname'] as String?,
      profileImageUrl: jsonSerialization['profileImageUrl'] as String?,
      joinedAt: jsonSerialization['joinedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['joinedAt']),
      isActive: jsonSerialization['isActive'] as bool,
      isNotificationEnabled: jsonSerialization['isNotificationEnabled'] as bool,
    );
  }

  /// 사용자 ID
  int userId;

  /// 사용자 닉네임
  String? nickname;

  /// 프로필 이미지 URL
  String? profileImageUrl;

  /// 참여 일시
  DateTime? joinedAt;

  /// 활성 상태
  bool isActive;

  /// 알림 활성화 여부
  bool isNotificationEnabled;

  /// Returns a shallow copy of this [ChatParticipantInfoDto]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ChatParticipantInfoDto copyWith({
    int? userId,
    String? nickname,
    String? profileImageUrl,
    DateTime? joinedAt,
    bool? isActive,
    bool? isNotificationEnabled,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      if (nickname != null) 'nickname': nickname,
      if (profileImageUrl != null) 'profileImageUrl': profileImageUrl,
      if (joinedAt != null) 'joinedAt': joinedAt?.toJson(),
      'isActive': isActive,
      'isNotificationEnabled': isNotificationEnabled,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      'userId': userId,
      if (nickname != null) 'nickname': nickname,
      if (profileImageUrl != null) 'profileImageUrl': profileImageUrl,
      if (joinedAt != null) 'joinedAt': joinedAt?.toJson(),
      'isActive': isActive,
      'isNotificationEnabled': isNotificationEnabled,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ChatParticipantInfoDtoImpl extends ChatParticipantInfoDto {
  _ChatParticipantInfoDtoImpl({
    required int userId,
    String? nickname,
    String? profileImageUrl,
    DateTime? joinedAt,
    required bool isActive,
    required bool isNotificationEnabled,
  }) : super._(
          userId: userId,
          nickname: nickname,
          profileImageUrl: profileImageUrl,
          joinedAt: joinedAt,
          isActive: isActive,
          isNotificationEnabled: isNotificationEnabled,
        );

  /// Returns a shallow copy of this [ChatParticipantInfoDto]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ChatParticipantInfoDto copyWith({
    int? userId,
    Object? nickname = _Undefined,
    Object? profileImageUrl = _Undefined,
    Object? joinedAt = _Undefined,
    bool? isActive,
    bool? isNotificationEnabled,
  }) {
    return ChatParticipantInfoDto(
      userId: userId ?? this.userId,
      nickname: nickname is String? ? nickname : this.nickname,
      profileImageUrl:
          profileImageUrl is String? ? profileImageUrl : this.profileImageUrl,
      joinedAt: joinedAt is DateTime? ? joinedAt : this.joinedAt,
      isActive: isActive ?? this.isActive,
      isNotificationEnabled:
          isNotificationEnabled ?? this.isNotificationEnabled,
    );
  }
}
