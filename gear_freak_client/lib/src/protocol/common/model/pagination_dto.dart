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
import '../../feature/product/model/product_category.dart' as _i2;
import '../../feature/product/model/product_sort_by.dart' as _i3;
import '../../feature/product/model/product_status.dart' as _i4;

/// 페이지네이션 DTO
/// 요청 및 응답에서 공통으로 사용
abstract class PaginationDto implements _i1.SerializableModel {
  PaginationDto._({
    required this.page,
    required this.limit,
    this.totalCount,
    this.hasMore,
    this.title,
    this.category,
    this.sortBy,
    this.status,
  });

  factory PaginationDto({
    required int page,
    required int limit,
    int? totalCount,
    bool? hasMore,
    String? title,
    _i2.ProductCategory? category,
    _i3.ProductSortBy? sortBy,
    _i4.ProductStatus? status,
  }) = _PaginationDtoImpl;

  factory PaginationDto.fromJson(Map<String, dynamic> jsonSerialization) {
    return PaginationDto(
      page: jsonSerialization['page'] as int,
      limit: jsonSerialization['limit'] as int,
      totalCount: jsonSerialization['totalCount'] as int?,
      hasMore: jsonSerialization['hasMore'] as bool?,
      title: jsonSerialization['title'] as String?,
      category: jsonSerialization['category'] == null
          ? null
          : _i2.ProductCategory.fromJson(
              (jsonSerialization['category'] as int)),
      sortBy: jsonSerialization['sortBy'] == null
          ? null
          : _i3.ProductSortBy.fromJson((jsonSerialization['sortBy'] as int)),
      status: jsonSerialization['status'] == null
          ? null
          : _i4.ProductStatus.fromJson((jsonSerialization['status'] as int)),
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

  /// 카테고리 필터링 (선택적)
  _i2.ProductCategory? category;

  /// 정렬 기준 (선택적, 기본값: latest)
  _i3.ProductSortBy? sortBy;

  /// 상품 상태 필터링 (선택적, getMyProducts에서 사용)
  _i4.ProductStatus? status;

  /// Returns a shallow copy of this [PaginationDto]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  PaginationDto copyWith({
    int? page,
    int? limit,
    int? totalCount,
    bool? hasMore,
    String? title,
    _i2.ProductCategory? category,
    _i3.ProductSortBy? sortBy,
    _i4.ProductStatus? status,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'limit': limit,
      if (totalCount != null) 'totalCount': totalCount,
      if (hasMore != null) 'hasMore': hasMore,
      if (title != null) 'title': title,
      if (category != null) 'category': category?.toJson(),
      if (sortBy != null) 'sortBy': sortBy?.toJson(),
      if (status != null) 'status': status?.toJson(),
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
    _i2.ProductCategory? category,
    _i3.ProductSortBy? sortBy,
    _i4.ProductStatus? status,
  }) : super._(
          page: page,
          limit: limit,
          totalCount: totalCount,
          hasMore: hasMore,
          title: title,
          category: category,
          sortBy: sortBy,
          status: status,
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
    Object? category = _Undefined,
    Object? sortBy = _Undefined,
    Object? status = _Undefined,
  }) {
    return PaginationDto(
      page: page ?? this.page,
      limit: limit ?? this.limit,
      totalCount: totalCount is int? ? totalCount : this.totalCount,
      hasMore: hasMore is bool? ? hasMore : this.hasMore,
      title: title is String? ? title : this.title,
      category: category is _i2.ProductCategory? ? category : this.category,
      sortBy: sortBy is _i3.ProductSortBy? ? sortBy : this.sortBy,
      status: status is _i4.ProductStatus? ? status : this.status,
    );
  }
}
