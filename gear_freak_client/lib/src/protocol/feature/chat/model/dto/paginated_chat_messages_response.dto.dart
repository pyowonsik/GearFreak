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
import '../../../../feature/chat/model/dto/chat_message_response.dto.dart'
    as _i3;

/// 페이지네이션된 채팅 메시지 응답
abstract class PaginatedChatMessagesResponseDto
    implements _i1.SerializableModel {
  PaginatedChatMessagesResponseDto._({
    required this.pagination,
    required this.messages,
  });

  factory PaginatedChatMessagesResponseDto({
    required _i2.PaginationDto pagination,
    required List<_i3.ChatMessageResponseDto> messages,
  }) = _PaginatedChatMessagesResponseDtoImpl;

  factory PaginatedChatMessagesResponseDto.fromJson(
      Map<String, dynamic> jsonSerialization) {
    return PaginatedChatMessagesResponseDto(
      pagination: _i2.PaginationDto.fromJson(
          (jsonSerialization['pagination'] as Map<String, dynamic>)),
      messages: (jsonSerialization['messages'] as List)
          .map((e) =>
              _i3.ChatMessageResponseDto.fromJson((e as Map<String, dynamic>)))
          .toList(),
    );
  }

  /// 페이지네이션 정보
  _i2.PaginationDto pagination;

  /// 채팅 메시지 목록
  List<_i3.ChatMessageResponseDto> messages;

  /// Returns a shallow copy of this [PaginatedChatMessagesResponseDto]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  PaginatedChatMessagesResponseDto copyWith({
    _i2.PaginationDto? pagination,
    List<_i3.ChatMessageResponseDto>? messages,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      'pagination': pagination.toJson(),
      'messages': messages.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _PaginatedChatMessagesResponseDtoImpl
    extends PaginatedChatMessagesResponseDto {
  _PaginatedChatMessagesResponseDtoImpl({
    required _i2.PaginationDto pagination,
    required List<_i3.ChatMessageResponseDto> messages,
  }) : super._(
          pagination: pagination,
          messages: messages,
        );

  /// Returns a shallow copy of this [PaginatedChatMessagesResponseDto]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  PaginatedChatMessagesResponseDto copyWith({
    _i2.PaginationDto? pagination,
    List<_i3.ChatMessageResponseDto>? messages,
  }) {
    return PaginatedChatMessagesResponseDto(
      pagination: pagination ?? this.pagination.copyWith(),
      messages: messages ?? this.messages.map((e0) => e0.copyWith()).toList(),
    );
  }
}
