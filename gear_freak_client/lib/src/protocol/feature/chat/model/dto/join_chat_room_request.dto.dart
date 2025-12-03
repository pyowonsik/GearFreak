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

/// 채팅방 참여 요청
abstract class JoinChatRoomRequestDto implements _i1.SerializableModel {
  JoinChatRoomRequestDto._({required this.chatRoomId});

  factory JoinChatRoomRequestDto({required int chatRoomId}) =
      _JoinChatRoomRequestDtoImpl;

  factory JoinChatRoomRequestDto.fromJson(
      Map<String, dynamic> jsonSerialization) {
    return JoinChatRoomRequestDto(
        chatRoomId: jsonSerialization['chatRoomId'] as int);
  }

  /// 참여할 채팅방 ID
  int chatRoomId;

  /// Returns a shallow copy of this [JoinChatRoomRequestDto]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  JoinChatRoomRequestDto copyWith({int? chatRoomId});
  @override
  Map<String, dynamic> toJson() {
    return {'chatRoomId': chatRoomId};
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _JoinChatRoomRequestDtoImpl extends JoinChatRoomRequestDto {
  _JoinChatRoomRequestDtoImpl({required int chatRoomId})
      : super._(chatRoomId: chatRoomId);

  /// Returns a shallow copy of this [JoinChatRoomRequestDto]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  JoinChatRoomRequestDto copyWith({int? chatRoomId}) {
    return JoinChatRoomRequestDto(chatRoomId: chatRoomId ?? this.chatRoomId);
  }
}
