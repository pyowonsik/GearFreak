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
    this.chatRoomId,
    this.productId,
    this.targetUserId,
    required this.content,
    required this.messageType,
    this.attachmentUrl,
    this.attachmentName,
    this.attachmentSize,
  });

  factory SendMessageRequestDto({
    int? chatRoomId,
    int? productId,
    int? targetUserId,
    required String content,
    required _i2.MessageType messageType,
    String? attachmentUrl,
    String? attachmentName,
    int? attachmentSize,
  }) = _SendMessageRequestDtoImpl;

  factory SendMessageRequestDto.fromJson(
      Map<String, dynamic> jsonSerialization) {
    return SendMessageRequestDto(
      chatRoomId: jsonSerialization['chatRoomId'] as int?,
      productId: jsonSerialization['productId'] as int?,
      targetUserId: jsonSerialization['targetUserId'] as int?,
      content: jsonSerialization['content'] as String,
      messageType:
          _i2.MessageType.fromJson((jsonSerialization['messageType'] as int)),
      attachmentUrl: jsonSerialization['attachmentUrl'] as String?,
      attachmentName: jsonSerialization['attachmentName'] as String?,
      attachmentSize: jsonSerialization['attachmentSize'] as int?,
    );
  }

  /// 채팅방 ID (채팅방이 없을 경우 null 또는 0)
  int? chatRoomId;

  /// 상품 ID (채팅방이 없을 경우 필수)
  int? productId;

  /// 상대방 사용자 ID (채팅방이 없을 경우 필수)
  int? targetUserId;

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
    int? productId,
    int? targetUserId,
    String? content,
    _i2.MessageType? messageType,
    String? attachmentUrl,
    String? attachmentName,
    int? attachmentSize,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      if (chatRoomId != null) 'chatRoomId': chatRoomId,
      if (productId != null) 'productId': productId,
      if (targetUserId != null) 'targetUserId': targetUserId,
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
      if (chatRoomId != null) 'chatRoomId': chatRoomId,
      if (productId != null) 'productId': productId,
      if (targetUserId != null) 'targetUserId': targetUserId,
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
    int? chatRoomId,
    int? productId,
    int? targetUserId,
    required String content,
    required _i2.MessageType messageType,
    String? attachmentUrl,
    String? attachmentName,
    int? attachmentSize,
  }) : super._(
          chatRoomId: chatRoomId,
          productId: productId,
          targetUserId: targetUserId,
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
    Object? chatRoomId = _Undefined,
    Object? productId = _Undefined,
    Object? targetUserId = _Undefined,
    String? content,
    _i2.MessageType? messageType,
    Object? attachmentUrl = _Undefined,
    Object? attachmentName = _Undefined,
    Object? attachmentSize = _Undefined,
  }) {
    return SendMessageRequestDto(
      chatRoomId: chatRoomId is int? ? chatRoomId : this.chatRoomId,
      productId: productId is int? ? productId : this.productId,
      targetUserId: targetUserId is int? ? targetUserId : this.targetUserId,
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
