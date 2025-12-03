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
import '../../../../feature/chat/model/dto/chat_message_response.dto.dart'
    as _i2;

/// 페이지네이션된 채팅 메시지 응답
abstract class PaginatedChatMessagesResponseDto
    implements _i1.SerializableModel {
  PaginatedChatMessagesResponseDto._({
    required this.messages,
    required this.totalCount,
    required this.mediaTotalCount,
    required this.fileTotalCount,
    required this.currentPage,
    required this.pageSize,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });

  factory PaginatedChatMessagesResponseDto({
    required List<_i2.ChatMessageResponseDto> messages,
    required int totalCount,
    required int mediaTotalCount,
    required int fileTotalCount,
    required int currentPage,
    required int pageSize,
    required bool hasNextPage,
    required bool hasPreviousPage,
  }) = _PaginatedChatMessagesResponseDtoImpl;

  factory PaginatedChatMessagesResponseDto.fromJson(
      Map<String, dynamic> jsonSerialization) {
    return PaginatedChatMessagesResponseDto(
      messages: (jsonSerialization['messages'] as List)
          .map((e) =>
              _i2.ChatMessageResponseDto.fromJson((e as Map<String, dynamic>)))
          .toList(),
      totalCount: jsonSerialization['totalCount'] as int,
      mediaTotalCount: jsonSerialization['mediaTotalCount'] as int,
      fileTotalCount: jsonSerialization['fileTotalCount'] as int,
      currentPage: jsonSerialization['currentPage'] as int,
      pageSize: jsonSerialization['pageSize'] as int,
      hasNextPage: jsonSerialization['hasNextPage'] as bool,
      hasPreviousPage: jsonSerialization['hasPreviousPage'] as bool,
    );
  }

  /// 채팅 메시지 목록
  List<_i2.ChatMessageResponseDto> messages;

  /// 전체 메시지 수
  int totalCount;

  /// 이미지/동영상 총 개수 (messageType=image)
  int mediaTotalCount;

  /// 파일 총 개수 (messageType=file)
  int fileTotalCount;

  /// 현재 페이지
  int currentPage;

  /// 페이지당 항목 수
  int pageSize;

  /// 다음 페이지 존재 여부
  bool hasNextPage;

  /// 이전 페이지 존재 여부
  bool hasPreviousPage;

  /// Returns a shallow copy of this [PaginatedChatMessagesResponseDto]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  PaginatedChatMessagesResponseDto copyWith({
    List<_i2.ChatMessageResponseDto>? messages,
    int? totalCount,
    int? mediaTotalCount,
    int? fileTotalCount,
    int? currentPage,
    int? pageSize,
    bool? hasNextPage,
    bool? hasPreviousPage,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      'messages': messages.toJson(valueToJson: (v) => v.toJson()),
      'totalCount': totalCount,
      'mediaTotalCount': mediaTotalCount,
      'fileTotalCount': fileTotalCount,
      'currentPage': currentPage,
      'pageSize': pageSize,
      'hasNextPage': hasNextPage,
      'hasPreviousPage': hasPreviousPage,
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
    required List<_i2.ChatMessageResponseDto> messages,
    required int totalCount,
    required int mediaTotalCount,
    required int fileTotalCount,
    required int currentPage,
    required int pageSize,
    required bool hasNextPage,
    required bool hasPreviousPage,
  }) : super._(
          messages: messages,
          totalCount: totalCount,
          mediaTotalCount: mediaTotalCount,
          fileTotalCount: fileTotalCount,
          currentPage: currentPage,
          pageSize: pageSize,
          hasNextPage: hasNextPage,
          hasPreviousPage: hasPreviousPage,
        );

  /// Returns a shallow copy of this [PaginatedChatMessagesResponseDto]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  PaginatedChatMessagesResponseDto copyWith({
    List<_i2.ChatMessageResponseDto>? messages,
    int? totalCount,
    int? mediaTotalCount,
    int? fileTotalCount,
    int? currentPage,
    int? pageSize,
    bool? hasNextPage,
    bool? hasPreviousPage,
  }) {
    return PaginatedChatMessagesResponseDto(
      messages: messages ?? this.messages.map((e0) => e0.copyWith()).toList(),
      totalCount: totalCount ?? this.totalCount,
      mediaTotalCount: mediaTotalCount ?? this.mediaTotalCount,
      fileTotalCount: fileTotalCount ?? this.fileTotalCount,
      currentPage: currentPage ?? this.currentPage,
      pageSize: pageSize ?? this.pageSize,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      hasPreviousPage: hasPreviousPage ?? this.hasPreviousPage,
    );
  }
}
