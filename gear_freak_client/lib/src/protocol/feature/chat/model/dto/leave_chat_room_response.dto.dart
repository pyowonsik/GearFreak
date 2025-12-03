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

/// 채팅방 나가기 응답
abstract class LeaveChatRoomResponseDto implements _i1.SerializableModel {
  LeaveChatRoomResponseDto._({
    required this.success,
    required this.chatRoomId,
    this.message,
  });

  factory LeaveChatRoomResponseDto({
    required bool success,
    required int chatRoomId,
    String? message,
  }) = _LeaveChatRoomResponseDtoImpl;

  factory LeaveChatRoomResponseDto.fromJson(
      Map<String, dynamic> jsonSerialization) {
    return LeaveChatRoomResponseDto(
      success: jsonSerialization['success'] as bool,
      chatRoomId: jsonSerialization['chatRoomId'] as int,
      message: jsonSerialization['message'] as String?,
    );
  }

  /// 나가기 성공 여부
  bool success;

  /// 채팅방 ID
  int chatRoomId;

  /// 메시지 (성공/실패 메시지)
  String? message;

  /// Returns a shallow copy of this [LeaveChatRoomResponseDto]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  LeaveChatRoomResponseDto copyWith({
    bool? success,
    int? chatRoomId,
    String? message,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'chatRoomId': chatRoomId,
      if (message != null) 'message': message,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _LeaveChatRoomResponseDtoImpl extends LeaveChatRoomResponseDto {
  _LeaveChatRoomResponseDtoImpl({
    required bool success,
    required int chatRoomId,
    String? message,
  }) : super._(
          success: success,
          chatRoomId: chatRoomId,
          message: message,
        );

  /// Returns a shallow copy of this [LeaveChatRoomResponseDto]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  LeaveChatRoomResponseDto copyWith({
    bool? success,
    int? chatRoomId,
    Object? message = _Undefined,
  }) {
    return LeaveChatRoomResponseDto(
      success: success ?? this.success,
      chatRoomId: chatRoomId ?? this.chatRoomId,
      message: message is String? ? message : this.message,
    );
  }
}
