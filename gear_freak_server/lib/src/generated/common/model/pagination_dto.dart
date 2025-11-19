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

/// 페이지네이션 DTO
/// 요청 및 응답에서 공통으로 사용
abstract class PaginationDto
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  PaginationDto._({
    required this.page,
    required this.limit,
    this.totalCount,
    this.hasMore,
    this.title,
    this.random,
  });

  factory PaginationDto({
    required int page,
    required int limit,
    int? totalCount,
    bool? hasMore,
    String? title,
    bool? random,
  }) = _PaginationDtoImpl;

  factory PaginationDto.fromJson(Map<String, dynamic> jsonSerialization) {
    return PaginationDto(
      page: jsonSerialization['page'] as int,
      limit: jsonSerialization['limit'] as int,
      totalCount: jsonSerialization['totalCount'] as int?,
      hasMore: jsonSerialization['hasMore'] as bool?,
      title: jsonSerialization['title'] as String?,
      random: jsonSerialization['random'] as bool?,
    );
  }

  /// 현재 페이지 번호 (1부터 시작)
  int page;

  /// 페이지당 아이템 수
  int limit;

  /// 전체 아이템 수 (응답 시 사용, 선택적)
  int? totalCount;

  /// 더 많은 데이터가 있는지 여부 (응답 시 사용, 선택적)
  bool? hasMore;

  /// 검색어 (제목 필터링용, 선택적)
  String? title;

  /// 랜덤 정렬 여부 (선택적)
  bool? random;

  /// Returns a shallow copy of this [PaginationDto]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  PaginationDto copyWith({
    int? page,
    int? limit,
    int? totalCount,
    bool? hasMore,
    String? title,
    bool? random,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'limit': limit,
      if (totalCount != null) 'totalCount': totalCount,
      if (hasMore != null) 'hasMore': hasMore,
      if (title != null) 'title': title,
      if (random != null) 'random': random,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      'page': page,
      'limit': limit,
      if (totalCount != null) 'totalCount': totalCount,
      if (hasMore != null) 'hasMore': hasMore,
      if (title != null) 'title': title,
      if (random != null) 'random': random,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _PaginationDtoImpl extends PaginationDto {
  _PaginationDtoImpl({
    required int page,
    required int limit,
    int? totalCount,
    bool? hasMore,
    String? title,
    bool? random,
  }) : super._(
          page: page,
          limit: limit,
          totalCount: totalCount,
          hasMore: hasMore,
          title: title,
          random: random,
        );

  /// Returns a shallow copy of this [PaginationDto]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  PaginationDto copyWith({
    int? page,
    int? limit,
    Object? totalCount = _Undefined,
    Object? hasMore = _Undefined,
    Object? title = _Undefined,
    Object? random = _Undefined,
  }) {
    return PaginationDto(
      page: page ?? this.page,
      limit: limit ?? this.limit,
      totalCount: totalCount is int? ? totalCount : this.totalCount,
      hasMore: hasMore is bool? ? hasMore : this.hasMore,
      title: title is String? ? title : this.title,
      random: random is bool? ? random : this.random,
    );
  }
}
