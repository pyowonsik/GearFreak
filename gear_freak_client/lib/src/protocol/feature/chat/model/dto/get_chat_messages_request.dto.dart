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
import '../../../../feature/chat/model/enum/message_type.dart' as _i2;

/// 채팅 메시지 조회 요청 (페이지네이션)
abstract class GetChatMessagesRequestDto implements _i1.SerializableModel {
  GetChatMessagesRequestDto._({
    required this.chatRoomId,
    required this.page,
    required this.limit,
    this.messageType,
  });

  factory GetChatMessagesRequestDto({
    required int chatRoomId,
    required int page,
    required int limit,
    _i2.MessageType? messageType,
  }) = _GetChatMessagesRequestDtoImpl;

  factory GetChatMessagesRequestDto.fromJson(
      Map<String, dynamic> jsonSerialization) {
    return GetChatMessagesRequestDto(
      chatRoomId: jsonSerialization['chatRoomId'] as int,
      page: jsonSerialization['page'] as int,
      limit: jsonSerialization['limit'] as int,
      messageType: jsonSerialization['messageType'] == null
          ? null
          : _i2.MessageType.fromJson((jsonSerialization['messageType'] as int)),
    );
  }

  /// 채팅방 ID
  int chatRoomId;

  /// 페이지 번호 (1부터 시작)
  int page;

  /// 페이지당 항목 수
  int limit;

  /// (선택) 메시지 타입 필터 (text, image, file, system)
  _i2.MessageType? messageType;

  /// Returns a shallow copy of this [GetChatMessagesRequestDto]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  GetChatMessagesRequestDto copyWith({
    int? chatRoomId,
    int? page,
    int? limit,
    _i2.MessageType? messageType,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      'chatRoomId': chatRoomId,
      'page': page,
      'limit': limit,
      if (messageType != null) 'messageType': messageType?.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _GetChatMessagesRequestDtoImpl extends GetChatMessagesRequestDto {
  _GetChatMessagesRequestDtoImpl({
    required int chatRoomId,
    required int page,
    required int limit,
    _i2.MessageType? messageType,
  }) : super._(
          chatRoomId: chatRoomId,
          page: page,
          limit: limit,
          messageType: messageType,
        );

  /// Returns a shallow copy of this [GetChatMessagesRequestDto]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  GetChatMessagesRequestDto copyWith({
    int? chatRoomId,
    int? page,
    int? limit,
    Object? messageType = _Undefined,
  }) {
    return GetChatMessagesRequestDto(
      chatRoomId: chatRoomId ?? this.chatRoomId,
      page: page ?? this.page,
      limit: limit ?? this.limit,
      messageType:
          messageType is _i2.MessageType? ? messageType : this.messageType,
    );
  }
}
