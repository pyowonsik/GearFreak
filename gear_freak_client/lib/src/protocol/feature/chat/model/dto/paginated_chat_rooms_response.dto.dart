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
import '../../../../common/model/pagination_dto.dart' as _i2;
import '../../../../feature/chat/model/chat_room.dart' as _i3;

/// 페이지네이션된 채팅방 목록 응답 DTO
abstract class PaginatedChatRoomsResponseDto implements _i1.SerializableModel {
  PaginatedChatRoomsResponseDto._({
    required this.pagination,
    required this.chatRooms,
  });

  factory PaginatedChatRoomsResponseDto({
    required _i2.PaginationDto pagination,
    required List<_i3.ChatRoom> chatRooms,
  }) = _PaginatedChatRoomsResponseDtoImpl;

  factory PaginatedChatRoomsResponseDto.fromJson(
      Map<String, dynamic> jsonSerialization) {
    return PaginatedChatRoomsResponseDto(
      pagination: _i2.PaginationDto.fromJson(
          (jsonSerialization['pagination'] as Map<String, dynamic>)),
      chatRooms: (jsonSerialization['chatRooms'] as List)
          .map((e) => _i3.ChatRoom.fromJson((e as Map<String, dynamic>)))
          .toList(),
    );
  }

  /// 페이지네이션 정보
  _i2.PaginationDto pagination;

  /// 채팅방 목록
  List<_i3.ChatRoom> chatRooms;

  /// Returns a shallow copy of this [PaginatedChatRoomsResponseDto]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  PaginatedChatRoomsResponseDto copyWith({
    _i2.PaginationDto? pagination,
    List<_i3.ChatRoom>? chatRooms,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      'pagination': pagination.toJson(),
      'chatRooms': chatRooms.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _PaginatedChatRoomsResponseDtoImpl extends PaginatedChatRoomsResponseDto {
  _PaginatedChatRoomsResponseDtoImpl({
    required _i2.PaginationDto pagination,
    required List<_i3.ChatRoom> chatRooms,
  }) : super._(
          pagination: pagination,
          chatRooms: chatRooms,
        );

  /// Returns a shallow copy of this [PaginatedChatRoomsResponseDto]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  PaginatedChatRoomsResponseDto copyWith({
    _i2.PaginationDto? pagination,
    List<_i3.ChatRoom>? chatRooms,
  }) {
    return PaginatedChatRoomsResponseDto(
      pagination: pagination ?? this.pagination.copyWith(),
      chatRooms:
          chatRooms ?? this.chatRooms.map((e0) => e0.copyWith()).toList(),
    );
  }
}
