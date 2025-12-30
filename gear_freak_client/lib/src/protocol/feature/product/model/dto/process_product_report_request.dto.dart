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
import '../../../../feature/product/model/report_status.dart' as _i2;

/// 상품 신고 처리 요청 DTO (관리자용)
abstract class ProcessProductReportRequestDto implements _i1.SerializableModel {
  ProcessProductReportRequestDto._({
    required this.reportId,
    required this.status,
    this.processNote,
  });

  factory ProcessProductReportRequestDto({
    required int reportId,
    required _i2.ReportStatus status,
    String? processNote,
  }) = _ProcessProductReportRequestDtoImpl;

  factory ProcessProductReportRequestDto.fromJson(
      Map<String, dynamic> jsonSerialization) {
    return ProcessProductReportRequestDto(
      reportId: jsonSerialization['reportId'] as int,
      status: _i2.ReportStatus.fromJson((jsonSerialization['status'] as int)),
      processNote: jsonSerialization['processNote'] as String?,
    );
  }

  /// 신고 ID
  int reportId;

  /// 처리 상태
  _i2.ReportStatus status;

  /// 처리 메모 (선택적)
  String? processNote;

  /// Returns a shallow copy of this [ProcessProductReportRequestDto]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ProcessProductReportRequestDto copyWith({
    int? reportId,
    _i2.ReportStatus? status,
    String? processNote,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      'reportId': reportId,
      'status': status.toJson(),
      if (processNote != null) 'processNote': processNote,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ProcessProductReportRequestDtoImpl
    extends ProcessProductReportRequestDto {
  _ProcessProductReportRequestDtoImpl({
    required int reportId,
    required _i2.ReportStatus status,
    String? processNote,
  }) : super._(
          reportId: reportId,
          status: status,
          processNote: processNote,
        );

  /// Returns a shallow copy of this [ProcessProductReportRequestDto]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ProcessProductReportRequestDto copyWith({
    int? reportId,
    _i2.ReportStatus? status,
    Object? processNote = _Undefined,
  }) {
    return ProcessProductReportRequestDto(
      reportId: reportId ?? this.reportId,
      status: status ?? this.status,
      processNote: processNote is String? ? processNote : this.processNote,
    );
  }
}
