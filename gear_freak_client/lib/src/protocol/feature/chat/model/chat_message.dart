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
import '../../../feature/chat/model/enum/message_type.dart' as _i2;

/// 채팅 메시지
abstract class ChatMessage implements _i1.SerializableModel {
  ChatMessage._({
    this.id,
    required this.chatRoomId,
    required this.senderId,
    required this.content,
    required this.messageType,
    this.attachmentUrl,
    this.attachmentName,
    this.attachmentSize,
    this.createdAt,
    this.updatedAt,
  });

  factory ChatMessage({
    int? id,
    required int chatRoomId,
    required int senderId,
    required String content,
    required _i2.MessageType messageType,
    String? attachmentUrl,
    String? attachmentName,
    int? attachmentSize,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _ChatMessageImpl;

  factory ChatMessage.fromJson(Map<String, dynamic> jsonSerialization) {
    return ChatMessage(
      id: jsonSerialization['id'] as int?,
      chatRoomId: jsonSerialization['chatRoomId'] as int,
      senderId: jsonSerialization['senderId'] as int,
      content: jsonSerialization['content'] as String,
      messageType:
          _i2.MessageType.fromJson((jsonSerialization['messageType'] as int)),
      attachmentUrl: jsonSerialization['attachmentUrl'] as String?,
      attachmentName: jsonSerialization['attachmentName'] as String?,
      attachmentSize: jsonSerialization['attachmentSize'] as int?,
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

  /// 발신자 사용자 ID
  int senderId;

  /// 메시지 내용
  String content;

  /// 메시지 타입 (text, image, file, system)
  _i2.MessageType messageType;

  /// 첨부파일 URL (선택적)
  String? attachmentUrl;

  /// 첨부파일 이름 (선택적)
  String? attachmentName;

  /// 첨부파일 크기 (bytes, 선택적)
  int? attachmentSize;

  /// 메시지 전송 일시
  DateTime? createdAt;

  /// 수정일 (메시지 수정 시)
  DateTime? updatedAt;

  /// Returns a shallow copy of this [ChatMessage]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ChatMessage copyWith({
    int? id,
    int? chatRoomId,
    int? senderId,
    String? content,
    _i2.MessageType? messageType,
    String? attachmentUrl,
    String? attachmentName,
    int? attachmentSize,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'chatRoomId': chatRoomId,
      'senderId': senderId,
      'content': content,
      'messageType': messageType.toJson(),
      if (attachmentUrl != null) 'attachmentUrl': attachmentUrl,
      if (attachmentName != null) 'attachmentName': attachmentName,
      if (attachmentSize != null) 'attachmentSize': attachmentSize,
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

class _ChatMessageImpl extends ChatMessage {
  _ChatMessageImpl({
    int? id,
    required int chatRoomId,
    required int senderId,
    required String content,
    required _i2.MessageType messageType,
    String? attachmentUrl,
    String? attachmentName,
    int? attachmentSize,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : super._(
          id: id,
          chatRoomId: chatRoomId,
          senderId: senderId,
          content: content,
          messageType: messageType,
          attachmentUrl: attachmentUrl,
          attachmentName: attachmentName,
          attachmentSize: attachmentSize,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

  /// Returns a shallow copy of this [ChatMessage]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ChatMessage copyWith({
    Object? id = _Undefined,
    int? chatRoomId,
    int? senderId,
    String? content,
    _i2.MessageType? messageType,
    Object? attachmentUrl = _Undefined,
    Object? attachmentName = _Undefined,
    Object? attachmentSize = _Undefined,
    Object? createdAt = _Undefined,
    Object? updatedAt = _Undefined,
  }) {
    return ChatMessage(
      id: id is int? ? id : this.id,
      chatRoomId: chatRoomId ?? this.chatRoomId,
      senderId: senderId ?? this.senderId,
      content: content ?? this.content,
      messageType: messageType ?? this.messageType,
      attachmentUrl:
          attachmentUrl is String? ? attachmentUrl : this.attachmentUrl,
      attachmentName:
          attachmentName is String? ? attachmentName : this.attachmentName,
      attachmentSize:
          attachmentSize is int? ? attachmentSize : this.attachmentSize,
      createdAt: createdAt is DateTime? ? createdAt : this.createdAt,
      updatedAt: updatedAt is DateTime? ? updatedAt : this.updatedAt,
    );
  }
}
