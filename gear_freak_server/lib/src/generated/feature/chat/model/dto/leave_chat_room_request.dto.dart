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

/// 채팅방 나가기 요청
abstract class LeaveChatRoomRequestDto
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  LeaveChatRoomRequestDto._({required this.chatRoomId});

  factory LeaveChatRoomRequestDto({required int chatRoomId}) =
      _LeaveChatRoomRequestDtoImpl;

  factory LeaveChatRoomRequestDto.fromJson(
      Map<String, dynamic> jsonSerialization) {
    return LeaveChatRoomRequestDto(
        chatRoomId: jsonSerialization['chatRoomId'] as int);
  }

  /// 나갈 채팅방 ID
  int chatRoomId;

  /// Returns a shallow copy of this [LeaveChatRoomRequestDto]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  LeaveChatRoomRequestDto copyWith({int? chatRoomId});
  @override
  Map<String, dynamic> toJson() {
    return {'chatRoomId': chatRoomId};
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {'chatRoomId': chatRoomId};
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _LeaveChatRoomRequestDtoImpl extends LeaveChatRoomRequestDto {
  _LeaveChatRoomRequestDtoImpl({required int chatRoomId})
      : super._(chatRoomId: chatRoomId);

  /// Returns a shallow copy of this [LeaveChatRoomRequestDto]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  LeaveChatRoomRequestDto copyWith({int? chatRoomId}) {
    return LeaveChatRoomRequestDto(chatRoomId: chatRoomId ?? this.chatRoomId);
  }
}
