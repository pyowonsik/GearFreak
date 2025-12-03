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

/// 채팅방 참여 응답
abstract class JoinChatRoomResponseDto implements _i1.SerializableModel {
  JoinChatRoomResponseDto._({
    required this.success,
    required this.chatRoomId,
    required this.joinedAt,
    this.message,
    this.participantCount,
  });

  factory JoinChatRoomResponseDto({
    required bool success,
    required int chatRoomId,
    required DateTime joinedAt,
    String? message,
    int? participantCount,
  }) = _JoinChatRoomResponseDtoImpl;

  factory JoinChatRoomResponseDto.fromJson(
      Map<String, dynamic> jsonSerialization) {
    return JoinChatRoomResponseDto(
      success: jsonSerialization['success'] as bool,
      chatRoomId: jsonSerialization['chatRoomId'] as int,
      joinedAt:
          _i1.DateTimeJsonExtension.fromJson(jsonSerialization['joinedAt']),
      message: jsonSerialization['message'] as String?,
      participantCount: jsonSerialization['participantCount'] as int?,
    );
  }

  /// 참여 성공 여부
  bool success;

  /// 채팅방 ID
  int chatRoomId;

  /// 참여 일시
  DateTime joinedAt;

  /// 메시지 (성공/실패 메시지)
  String? message;

  /// 현재 참여자 수
  int? participantCount;

  /// Returns a shallow copy of this [JoinChatRoomResponseDto]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  JoinChatRoomResponseDto copyWith({
    bool? success,
    int? chatRoomId,
    DateTime? joinedAt,
    String? message,
    int? participantCount,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'chatRoomId': chatRoomId,
      'joinedAt': joinedAt.toJson(),
      if (message != null) 'message': message,
      if (participantCount != null) 'participantCount': participantCount,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _JoinChatRoomResponseDtoImpl extends JoinChatRoomResponseDto {
  _JoinChatRoomResponseDtoImpl({
    required bool success,
    required int chatRoomId,
    required DateTime joinedAt,
    String? message,
    int? participantCount,
  }) : super._(
          success: success,
          chatRoomId: chatRoomId,
          joinedAt: joinedAt,
          message: message,
          participantCount: participantCount,
        );

  /// Returns a shallow copy of this [JoinChatRoomResponseDto]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  JoinChatRoomResponseDto copyWith({
    bool? success,
    int? chatRoomId,
    DateTime? joinedAt,
    Object? message = _Undefined,
    Object? participantCount = _Undefined,
  }) {
    return JoinChatRoomResponseDto(
      success: success ?? this.success,
      chatRoomId: chatRoomId ?? this.chatRoomId,
      joinedAt: joinedAt ?? this.joinedAt,
      message: message is String? ? message : this.message,
      participantCount:
          participantCount is int? ? participantCount : this.participantCount,
    );
  }
}
