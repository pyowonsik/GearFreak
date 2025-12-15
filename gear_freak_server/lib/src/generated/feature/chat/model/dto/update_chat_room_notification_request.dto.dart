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

/// 채팅방 알림 설정 요청
abstract class UpdateChatRoomNotificationRequestDto
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  UpdateChatRoomNotificationRequestDto._({
    required this.chatRoomId,
    required this.isNotificationEnabled,
  });

  factory UpdateChatRoomNotificationRequestDto({
    required int chatRoomId,
    required bool isNotificationEnabled,
  }) = _UpdateChatRoomNotificationRequestDtoImpl;

  factory UpdateChatRoomNotificationRequestDto.fromJson(
      Map<String, dynamic> jsonSerialization) {
    return UpdateChatRoomNotificationRequestDto(
      chatRoomId: jsonSerialization['chatRoomId'] as int,
      isNotificationEnabled: jsonSerialization['isNotificationEnabled'] as bool,
    );
  }

  /// 채팅방 ID
  int chatRoomId;

  /// 알림 활성화 여부
  bool isNotificationEnabled;

  /// Returns a shallow copy of this [UpdateChatRoomNotificationRequestDto]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  UpdateChatRoomNotificationRequestDto copyWith({
    int? chatRoomId,
    bool? isNotificationEnabled,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      'chatRoomId': chatRoomId,
      'isNotificationEnabled': isNotificationEnabled,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      'chatRoomId': chatRoomId,
      'isNotificationEnabled': isNotificationEnabled,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _UpdateChatRoomNotificationRequestDtoImpl
    extends UpdateChatRoomNotificationRequestDto {
  _UpdateChatRoomNotificationRequestDtoImpl({
    required int chatRoomId,
    required bool isNotificationEnabled,
  }) : super._(
          chatRoomId: chatRoomId,
          isNotificationEnabled: isNotificationEnabled,
        );

  /// Returns a shallow copy of this [UpdateChatRoomNotificationRequestDto]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  UpdateChatRoomNotificationRequestDto copyWith({
    int? chatRoomId,
    bool? isNotificationEnabled,
  }) {
    return UpdateChatRoomNotificationRequestDto(
      chatRoomId: chatRoomId ?? this.chatRoomId,
      isNotificationEnabled:
          isNotificationEnabled ?? this.isNotificationEnabled,
    );
  }
}
