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
import '../../../../feature/product/model/dto/product_report_response.dto.dart'
    as _i2;
import '../../../../common/model/pagination_dto.dart' as _i3;

/// 페이지네이션된 상품 신고 목록 응답 DTO
abstract class PaginatedProductReportsResponseDto
    implements _i1.SerializableModel {
  PaginatedProductReportsResponseDto._({
    required this.reports,
    required this.pagination,
  });

  factory PaginatedProductReportsResponseDto({
    required List<_i2.ProductReportResponseDto> reports,
    required _i3.PaginationDto pagination,
  }) = _PaginatedProductReportsResponseDtoImpl;

  factory PaginatedProductReportsResponseDto.fromJson(
      Map<String, dynamic> jsonSerialization) {
    return PaginatedProductReportsResponseDto(
      reports: (jsonSerialization['reports'] as List)
          .map((e) => _i2.ProductReportResponseDto.fromJson(
              (e as Map<String, dynamic>)))
          .toList(),
      pagination: _i3.PaginationDto.fromJson(
          (jsonSerialization['pagination'] as Map<String, dynamic>)),
    );
  }

  /// 신고 목록
  List<_i2.ProductReportResponseDto> reports;

  /// 페이지네이션 정보
  _i3.PaginationDto pagination;

  /// Returns a shallow copy of this [PaginatedProductReportsResponseDto]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  PaginatedProductReportsResponseDto copyWith({
    List<_i2.ProductReportResponseDto>? reports,
    _i3.PaginationDto? pagination,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      'reports': reports.toJson(valueToJson: (v) => v.toJson()),
      'pagination': pagination.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _PaginatedProductReportsResponseDtoImpl
    extends PaginatedProductReportsResponseDto {
  _PaginatedProductReportsResponseDtoImpl({
    required List<_i2.ProductReportResponseDto> reports,
    required _i3.PaginationDto pagination,
  }) : super._(
          reports: reports,
          pagination: pagination,
        );

  /// Returns a shallow copy of this [PaginatedProductReportsResponseDto]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  PaginatedProductReportsResponseDto copyWith({
    List<_i2.ProductReportResponseDto>? reports,
    _i3.PaginationDto? pagination,
  }) {
    return PaginatedProductReportsResponseDto(
      reports: reports ?? this.reports.map((e0) => e0.copyWith()).toList(),
      pagination: pagination ?? this.pagination.copyWith(),
    );
  }
}
