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
import '../../../../feature/chat/model/enum/message_type.dart' as _i2;

/// 채팅 메시지 응답
abstract class ChatMessageResponseDto
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  ChatMessageResponseDto._({
    required this.id,
    required this.chatRoomId,
    required this.senderId,
    this.senderNickname,
    required this.content,
    required this.messageType,
    this.attachmentUrl,
    this.attachmentName,
    this.attachmentSize,
    required this.createdAt,
    this.updatedAt,
  });

  factory ChatMessageResponseDto({
    required int id,
    required int chatRoomId,
    required int senderId,
    String? senderNickname,
    required String content,
    required _i2.MessageType messageType,
    String? attachmentUrl,
    String? attachmentName,
    int? attachmentSize,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _ChatMessageResponseDtoImpl;

  factory ChatMessageResponseDto.fromJson(
      Map<String, dynamic> jsonSerialization) {
    return ChatMessageResponseDto(
      id: jsonSerialization['id'] as int,
      chatRoomId: jsonSerialization['chatRoomId'] as int,
      senderId: jsonSerialization['senderId'] as int,
      senderNickname: jsonSerialization['senderNickname'] as String?,
      content: jsonSerialization['content'] as String,
      messageType:
          _i2.MessageType.fromJson((jsonSerialization['messageType'] as int)),
      attachmentUrl: jsonSerialization['attachmentUrl'] as String?,
      attachmentName: jsonSerialization['attachmentName'] as String?,
      attachmentSize: jsonSerialization['attachmentSize'] as int?,
      createdAt:
          _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
    );
  }

  /// 메시지 ID
  int id;

  /// 채팅방 ID
  int chatRoomId;

  /// 발신자 사용자 ID
  int senderId;

  /// 발신자 닉네임
  String? senderNickname;

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
  DateTime createdAt;

  /// 수정일
  DateTime? updatedAt;

  /// Returns a shallow copy of this [ChatMessageResponseDto]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ChatMessageResponseDto copyWith({
    int? id,
    int? chatRoomId,
    int? senderId,
    String? senderNickname,
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
      'id': id,
      'chatRoomId': chatRoomId,
      'senderId': senderId,
      if (senderNickname != null) 'senderNickname': senderNickname,
      'content': content,
      'messageType': messageType.toJson(),
      if (attachmentUrl != null) 'attachmentUrl': attachmentUrl,
      if (attachmentName != null) 'attachmentName': attachmentName,
      if (attachmentSize != null) 'attachmentSize': attachmentSize,
      'createdAt': createdAt.toJson(),
      if (updatedAt != null) 'updatedAt': updatedAt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      'id': id,
      'chatRoomId': chatRoomId,
      'senderId': senderId,
      if (senderNickname != null) 'senderNickname': senderNickname,
      'content': content,
      'messageType': messageType.toJson(),
      if (attachmentUrl != null) 'attachmentUrl': attachmentUrl,
      if (attachmentName != null) 'attachmentName': attachmentName,
      if (attachmentSize != null) 'attachmentSize': attachmentSize,
      'createdAt': createdAt.toJson(),
      if (updatedAt != null) 'updatedAt': updatedAt?.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ChatMessageResponseDtoImpl extends ChatMessageResponseDto {
  _ChatMessageResponseDtoImpl({
    required int id,
    required int chatRoomId,
    required int senderId,
    String? senderNickname,
    required String content,
    required _i2.MessageType messageType,
    String? attachmentUrl,
    String? attachmentName,
    int? attachmentSize,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) : super._(
          id: id,
          chatRoomId: chatRoomId,
          senderId: senderId,
          senderNickname: senderNickname,
          content: content,
          messageType: messageType,
          attachmentUrl: attachmentUrl,
          attachmentName: attachmentName,
          attachmentSize: attachmentSize,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

  /// Returns a shallow copy of this [ChatMessageResponseDto]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ChatMessageResponseDto copyWith({
    int? id,
    int? chatRoomId,
    int? senderId,
    Object? senderNickname = _Undefined,
    String? content,
    _i2.MessageType? messageType,
    Object? attachmentUrl = _Undefined,
    Object? attachmentName = _Undefined,
    Object? attachmentSize = _Undefined,
    DateTime? createdAt,
    Object? updatedAt = _Undefined,
  }) {
    return ChatMessageResponseDto(
      id: id ?? this.id,
      chatRoomId: chatRoomId ?? this.chatRoomId,
      senderId: senderId ?? this.senderId,
      senderNickname:
          senderNickname is String? ? senderNickname : this.senderNickname,
      content: content ?? this.content,
      messageType: messageType ?? this.messageType,
      attachmentUrl:
          attachmentUrl is String? ? attachmentUrl : this.attachmentUrl,
      attachmentName:
          attachmentName is String? ? attachmentName : this.attachmentName,
      attachmentSize:
          attachmentSize is int? ? attachmentSize : this.attachmentSize,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt is DateTime? ? updatedAt : this.updatedAt,
    );
  }
}
