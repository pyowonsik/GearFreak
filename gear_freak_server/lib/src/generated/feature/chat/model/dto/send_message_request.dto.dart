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

/// 채팅 메시지 전송 요청
abstract class SendMessageRequestDto
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  SendMessageRequestDto._({
    required this.chatRoomId,
    required this.content,
    required this.messageType,
    this.attachmentUrl,
    this.attachmentName,
    this.attachmentSize,
  });

  factory SendMessageRequestDto({
    required int chatRoomId,
    required String content,
    required _i2.MessageType messageType,
    String? attachmentUrl,
    String? attachmentName,
    int? attachmentSize,
  }) = _SendMessageRequestDtoImpl;

  factory SendMessageRequestDto.fromJson(
      Map<String, dynamic> jsonSerialization) {
    return SendMessageRequestDto(
      chatRoomId: jsonSerialization['chatRoomId'] as int,
      content: jsonSerialization['content'] as String,
      messageType:
          _i2.MessageType.fromJson((jsonSerialization['messageType'] as int)),
      attachmentUrl: jsonSerialization['attachmentUrl'] as String?,
      attachmentName: jsonSerialization['attachmentName'] as String?,
      attachmentSize: jsonSerialization['attachmentSize'] as int?,
    );
  }

  /// 채팅방 ID
  int chatRoomId;

  /// 메시지 내용
  String content;

  /// 메시지 타입 (text, image, file)
  _i2.MessageType messageType;

  /// 첨부파일 URL (선택적)
  String? attachmentUrl;

  /// 첨부파일 이름 (선택적)
  String? attachmentName;

  /// 첨부파일 크기 (선택적)
  int? attachmentSize;

  /// Returns a shallow copy of this [SendMessageRequestDto]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  SendMessageRequestDto copyWith({
    int? chatRoomId,
    String? content,
    _i2.MessageType? messageType,
    String? attachmentUrl,
    String? attachmentName,
    int? attachmentSize,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      'chatRoomId': chatRoomId,
      'content': content,
      'messageType': messageType.toJson(),
      if (attachmentUrl != null) 'attachmentUrl': attachmentUrl,
      if (attachmentName != null) 'attachmentName': attachmentName,
      if (attachmentSize != null) 'attachmentSize': attachmentSize,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      'chatRoomId': chatRoomId,
      'content': content,
      'messageType': messageType.toJson(),
      if (attachmentUrl != null) 'attachmentUrl': attachmentUrl,
      if (attachmentName != null) 'attachmentName': attachmentName,
      if (attachmentSize != null) 'attachmentSize': attachmentSize,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _SendMessageRequestDtoImpl extends SendMessageRequestDto {
  _SendMessageRequestDtoImpl({
    required int chatRoomId,
    required String content,
    required _i2.MessageType messageType,
    String? attachmentUrl,
    String? attachmentName,
    int? attachmentSize,
  }) : super._(
          chatRoomId: chatRoomId,
          content: content,
          messageType: messageType,
          attachmentUrl: attachmentUrl,
          attachmentName: attachmentName,
          attachmentSize: attachmentSize,
        );

  /// Returns a shallow copy of this [SendMessageRequestDto]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  SendMessageRequestDto copyWith({
    int? chatRoomId,
    String? content,
    _i2.MessageType? messageType,
    Object? attachmentUrl = _Undefined,
    Object? attachmentName = _Undefined,
    Object? attachmentSize = _Undefined,
  }) {
    return SendMessageRequestDto(
      chatRoomId: chatRoomId ?? this.chatRoomId,
      content: content ?? this.content,
      messageType: messageType ?? this.messageType,
      attachmentUrl:
          attachmentUrl is String? ? attachmentUrl : this.attachmentUrl,
      attachmentName:
          attachmentName is String? ? attachmentName : this.attachmentName,
      attachmentSize:
          attachmentSize is int? ? attachmentSize : this.attachmentSize,
    );
  }
}
