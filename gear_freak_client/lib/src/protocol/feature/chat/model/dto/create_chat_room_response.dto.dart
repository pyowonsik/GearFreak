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
import '../../../../feature/chat/model/chat_room.dart' as _i2;

/// 채팅방 생성 응답
abstract class CreateChatRoomResponseDto implements _i1.SerializableModel {
  CreateChatRoomResponseDto._({
    required this.success,
    this.chatRoomId,
    this.chatRoom,
    this.message,
    this.isNewChatRoom,
  });

  factory CreateChatRoomResponseDto({
    required bool success,
    int? chatRoomId,
    _i2.ChatRoom? chatRoom,
    String? message,
    bool? isNewChatRoom,
  }) = _CreateChatRoomResponseDtoImpl;

  factory CreateChatRoomResponseDto.fromJson(
      Map<String, dynamic> jsonSerialization) {
    return CreateChatRoomResponseDto(
      success: jsonSerialization['success'] as bool,
      chatRoomId: jsonSerialization['chatRoomId'] as int?,
      chatRoom: jsonSerialization['chatRoom'] == null
          ? null
          : _i2.ChatRoom.fromJson(
              (jsonSerialization['chatRoom'] as Map<String, dynamic>)),
      message: jsonSerialization['message'] as String?,
      isNewChatRoom: jsonSerialization['isNewChatRoom'] as bool?,
    );
  }

  /// 생성 성공 여부
  bool success;

  /// 채팅방 ID
  int? chatRoomId;

  /// 채팅방 정보
  _i2.ChatRoom? chatRoom;

  /// 메시지 (성공/실패 메시지)
  String? message;

  /// 새로 생성된 채팅방인지 여부
  bool? isNewChatRoom;

  /// Returns a shallow copy of this [CreateChatRoomResponseDto]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  CreateChatRoomResponseDto copyWith({
    bool? success,
    int? chatRoomId,
    _i2.ChatRoom? chatRoom,
    String? message,
    bool? isNewChatRoom,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      if (chatRoomId != null) 'chatRoomId': chatRoomId,
      if (chatRoom != null) 'chatRoom': chatRoom?.toJson(),
      if (message != null) 'message': message,
      if (isNewChatRoom != null) 'isNewChatRoom': isNewChatRoom,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CreateChatRoomResponseDtoImpl extends CreateChatRoomResponseDto {
  _CreateChatRoomResponseDtoImpl({
    required bool success,
    int? chatRoomId,
    _i2.ChatRoom? chatRoom,
    String? message,
    bool? isNewChatRoom,
  }) : super._(
          success: success,
          chatRoomId: chatRoomId,
          chatRoom: chatRoom,
          message: message,
          isNewChatRoom: isNewChatRoom,
        );

  /// Returns a shallow copy of this [CreateChatRoomResponseDto]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  CreateChatRoomResponseDto copyWith({
    bool? success,
    Object? chatRoomId = _Undefined,
    Object? chatRoom = _Undefined,
    Object? message = _Undefined,
    Object? isNewChatRoom = _Undefined,
  }) {
    return CreateChatRoomResponseDto(
      success: success ?? this.success,
      chatRoomId: chatRoomId is int? ? chatRoomId : this.chatRoomId,
      chatRoom:
          chatRoom is _i2.ChatRoom? ? chatRoom : this.chatRoom?.copyWith(),
      message: message is String? ? message : this.message,
      isNewChatRoom:
          isNewChatRoom is bool? ? isNewChatRoom : this.isNewChatRoom,
    );
  }
}
