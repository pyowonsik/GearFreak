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
import '../../../../feature/product/model/report_reason.dart' as _i2;

/// 상품 신고 생성 요청 DTO
abstract class CreateProductReportRequestDto implements _i1.SerializableModel {
  CreateProductReportRequestDto._({
    required this.productId,
    required this.reason,
    this.description,
  });

  factory CreateProductReportRequestDto({
    required int productId,
    required _i2.ReportReason reason,
    String? description,
  }) = _CreateProductReportRequestDtoImpl;

  factory CreateProductReportRequestDto.fromJson(
      Map<String, dynamic> jsonSerialization) {
    return CreateProductReportRequestDto(
      productId: jsonSerialization['productId'] as int,
      reason: _i2.ReportReason.fromJson((jsonSerialization['reason'] as int)),
      description: jsonSerialization['description'] as String?,
    );
  }

  /// 신고 대상 상품 ID
  int productId;

  /// 신고 사유
  _i2.ReportReason reason;

  /// 신고 상세 내용 (선택적)
  String? description;

  /// Returns a shallow copy of this [CreateProductReportRequestDto]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  CreateProductReportRequestDto copyWith({
    int? productId,
    _i2.ReportReason? reason,
    String? description,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'reason': reason.toJson(),
      if (description != null) 'description': description,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CreateProductReportRequestDtoImpl extends CreateProductReportRequestDto {
  _CreateProductReportRequestDtoImpl({
    required int productId,
    required _i2.ReportReason reason,
    String? description,
  }) : super._(
          productId: productId,
          reason: reason,
          description: description,
        );

  /// Returns a shallow copy of this [CreateProductReportRequestDto]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  CreateProductReportRequestDto copyWith({
    int? productId,
    _i2.ReportReason? reason,
    Object? description = _Undefined,
  }) {
    return CreateProductReportRequestDto(
      productId: productId ?? this.productId,
      reason: reason ?? this.reason,
      description: description is String? ? description : this.description,
    );
  }
}
