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
import '../../../feature/chat/model/enum/chat_room_type.dart' as _i2;

/// 채팅방 정보
abstract class ChatRoom implements _i1.SerializableModel {
  ChatRoom._({
    this.id,
    required this.productId,
    this.title,
    required this.chatRoomType,
    required this.participantCount,
    this.lastActivityAt,
    this.createdAt,
    this.updatedAt,
  });

  factory ChatRoom({
    int? id,
    required int productId,
    String? title,
    required _i2.ChatRoomType chatRoomType,
    required int participantCount,
    DateTime? lastActivityAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _ChatRoomImpl;

  factory ChatRoom.fromJson(Map<String, dynamic> jsonSerialization) {
    return ChatRoom(
      id: jsonSerialization['id'] as int?,
      productId: jsonSerialization['productId'] as int,
      title: jsonSerialization['title'] as String?,
      chatRoomType:
          _i2.ChatRoomType.fromJson((jsonSerialization['chatRoomType'] as int)),
      participantCount: jsonSerialization['participantCount'] as int,
      lastActivityAt: jsonSerialization['lastActivityAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(
              jsonSerialization['lastActivityAt']),
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

  /// 연결된 상품 ID
  int productId;

  /// 채팅방 제목
  String? title;

  /// 채팅방 타입 (1:1, 그룹)
  _i2.ChatRoomType chatRoomType;

  /// 참여자 수 (캐시된 값)
  int participantCount;

  /// 최근 활동 일시
  DateTime? lastActivityAt;

  /// 채팅방 생성일
  DateTime? createdAt;

  /// 수정일
  DateTime? updatedAt;

  /// Returns a shallow copy of this [ChatRoom]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ChatRoom copyWith({
    int? id,
    int? productId,
    String? title,
    _i2.ChatRoomType? chatRoomType,
    int? participantCount,
    DateTime? lastActivityAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'productId': productId,
      if (title != null) 'title': title,
      'chatRoomType': chatRoomType.toJson(),
      'participantCount': participantCount,
      if (lastActivityAt != null) 'lastActivityAt': lastActivityAt?.toJson(),
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

class _ChatRoomImpl extends ChatRoom {
  _ChatRoomImpl({
    int? id,
    required int productId,
    String? title,
    required _i2.ChatRoomType chatRoomType,
    required int participantCount,
    DateTime? lastActivityAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : super._(
          id: id,
          productId: productId,
          title: title,
          chatRoomType: chatRoomType,
          participantCount: participantCount,
          lastActivityAt: lastActivityAt,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

  /// Returns a shallow copy of this [ChatRoom]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ChatRoom copyWith({
    Object? id = _Undefined,
    int? productId,
    Object? title = _Undefined,
    _i2.ChatRoomType? chatRoomType,
    int? participantCount,
    Object? lastActivityAt = _Undefined,
    Object? createdAt = _Undefined,
    Object? updatedAt = _Undefined,
  }) {
    return ChatRoom(
      id: id is int? ? id : this.id,
      productId: productId ?? this.productId,
      title: title is String? ? title : this.title,
      chatRoomType: chatRoomType ?? this.chatRoomType,
      participantCount: participantCount ?? this.participantCount,
      lastActivityAt:
          lastActivityAt is DateTime? ? lastActivityAt : this.lastActivityAt,
      createdAt: createdAt is DateTime? ? createdAt : this.createdAt,
      updatedAt: updatedAt is DateTime? ? updatedAt : this.updatedAt,
    );
  }
}
