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

/// 채팅방 참여자 정보
abstract class ChatParticipant implements _i1.SerializableModel {
  ChatParticipant._({
    this.id,
    required this.chatRoomId,
    required this.userId,
    this.joinedAt,
    required this.isActive,
    this.leftAt,
    this.lastReadAt,
    required this.isNotificationEnabled,
    this.createdAt,
    this.updatedAt,
  });

  factory ChatParticipant({
    int? id,
    required int chatRoomId,
    required int userId,
    DateTime? joinedAt,
    required bool isActive,
    DateTime? leftAt,
    DateTime? lastReadAt,
    required bool isNotificationEnabled,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _ChatParticipantImpl;

  factory ChatParticipant.fromJson(Map<String, dynamic> jsonSerialization) {
    return ChatParticipant(
      id: jsonSerialization['id'] as int?,
      chatRoomId: jsonSerialization['chatRoomId'] as int,
      userId: jsonSerialization['userId'] as int,
      joinedAt: jsonSerialization['joinedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['joinedAt']),
      isActive: jsonSerialization['isActive'] as bool,
      leftAt: jsonSerialization['leftAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['leftAt']),
      lastReadAt: jsonSerialization['lastReadAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['lastReadAt']),
      isNotificationEnabled: jsonSerialization['isNotificationEnabled'] as bool,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  /// 채팅방 ID
  int chatRoomId;

  /// 참여자 사용자 ID
  int userId;

  /// 참여 일시
  DateTime? joinedAt;

  /// 활성 상태 (퇴장 시 false)
  bool isActive;

  /// 참여 종료 일시
  DateTime? leftAt;

  /// 마지막 읽은 시간 (읽음 처리용)
  DateTime? lastReadAt;

  /// 알림 활성화 여부
  bool isNotificationEnabled;

  /// 생성일
  DateTime? createdAt;

  /// 수정일
  DateTime? updatedAt;

  /// Returns a shallow copy of this [ChatParticipant]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ChatParticipant copyWith({
    int? id,
    int? chatRoomId,
    int? userId,
    DateTime? joinedAt,
    bool? isActive,
    DateTime? leftAt,
    DateTime? lastReadAt,
    bool? isNotificationEnabled,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'chatRoomId': chatRoomId,
      'userId': userId,
      if (joinedAt != null) 'joinedAt': joinedAt?.toJson(),
      'isActive': isActive,
      if (leftAt != null) 'leftAt': leftAt?.toJson(),
      if (lastReadAt != null) 'lastReadAt': lastReadAt?.toJson(),
      'isNotificationEnabled': isNotificationEnabled,
      if (createdAt != null) 'createdAt': createdAt?.toJson(),
      if (updatedAt != null) 'updatedAt': updatedAt?.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ChatParticipantImpl extends ChatParticipant {
  _ChatParticipantImpl({
    int? id,
    required int chatRoomId,
    required int userId,
    DateTime? joinedAt,
    required bool isActive,
    DateTime? leftAt,
    DateTime? lastReadAt,
    required bool isNotificationEnabled,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : super._(
          id: id,
          chatRoomId: chatRoomId,
          userId: userId,
          joinedAt: joinedAt,
          isActive: isActive,
          leftAt: leftAt,
          lastReadAt: lastReadAt,
          isNotificationEnabled: isNotificationEnabled,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

  /// Returns a shallow copy of this [ChatParticipant]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ChatParticipant copyWith({
    Object? id = _Undefined,
    int? chatRoomId,
    int? userId,
    Object? joinedAt = _Undefined,
    bool? isActive,
    Object? leftAt = _Undefined,
    Object? lastReadAt = _Undefined,
    bool? isNotificationEnabled,
    Object? createdAt = _Undefined,
    Object? updatedAt = _Undefined,
  }) {
    return ChatParticipant(
      id: id is int? ? id : this.id,
      chatRoomId: chatRoomId ?? this.chatRoomId,
      userId: userId ?? this.userId,
      joinedAt: joinedAt is DateTime? ? joinedAt : this.joinedAt,
      isActive: isActive ?? this.isActive,
      leftAt: leftAt is DateTime? ? leftAt : this.leftAt,
      lastReadAt: lastReadAt is DateTime? ? lastReadAt : this.lastReadAt,
      isNotificationEnabled:
          isNotificationEnabled ?? this.isNotificationEnabled,
      createdAt: createdAt is DateTime? ? createdAt : this.createdAt,
      updatedAt: updatedAt is DateTime? ? updatedAt : this.updatedAt,
    );
  }
}
