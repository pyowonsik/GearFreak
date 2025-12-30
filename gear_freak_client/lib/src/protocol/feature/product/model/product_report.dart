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
import '../../../feature/product/model/report_reason.dart' as _i2;
import '../../../feature/product/model/report_status.dart' as _i3;

/// 상품 신고
abstract class ProductReport implements _i1.SerializableModel {
  ProductReport._({
    this.id,
    required this.productId,
    required this.reporterId,
    required this.reason,
    this.description,
    required this.status,
    this.processedBy,
    this.processedAt,
    this.processNote,
    this.createdAt,
    this.updatedAt,
  });

  factory ProductReport({
    int? id,
    required int productId,
    required int reporterId,
    required _i2.ReportReason reason,
    String? description,
    required _i3.ReportStatus status,
    int? processedBy,
    DateTime? processedAt,
    String? processNote,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _ProductReportImpl;

  factory ProductReport.fromJson(Map<String, dynamic> jsonSerialization) {
    return ProductReport(
      id: jsonSerialization['id'] as int?,
      productId: jsonSerialization['productId'] as int,
      reporterId: jsonSerialization['reporterId'] as int,
      reason: _i2.ReportReason.fromJson((jsonSerialization['reason'] as int)),
      description: jsonSerialization['description'] as String?,
      status: _i3.ReportStatus.fromJson((jsonSerialization['status'] as int)),
      processedBy: jsonSerialization['processedBy'] as int?,
      processedAt: jsonSerialization['processedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(
              jsonSerialization['processedAt']),
      processNote: jsonSerialization['processNote'] as String?,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  /// 신고 대상 상품 ID
  int productId;

  /// 신고자 사용자 ID
  int reporterId;

  /// 신고 사유
  _i2.ReportReason reason;

  /// 신고 상세 내용 (선택적)
  String? description;

  /// 처리 상태
  _i3.ReportStatus status;

  /// 처리자 사용자 ID (관리자, 선택적)
  int? processedBy;

  /// 처리일시 (선택적)
  DateTime? processedAt;

  /// 처리 메모 (관리자 메모, 선택적)
  String? processNote;

  /// 생성일
  DateTime? createdAt;

  /// 수정일
  DateTime? updatedAt;

  /// Returns a shallow copy of this [ProductReport]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ProductReport copyWith({
    int? id,
    int? productId,
    int? reporterId,
    _i2.ReportReason? reason,
    String? description,
    _i3.ReportStatus? status,
    int? processedBy,
    DateTime? processedAt,
    String? processNote,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'productId': productId,
      'reporterId': reporterId,
      'reason': reason.toJson(),
      if (description != null) 'description': description,
      'status': status.toJson(),
      if (processedBy != null) 'processedBy': processedBy,
      if (processedAt != null) 'processedAt': processedAt?.toJson(),
      if (processNote != null) 'processNote': processNote,
      if (createdAt != null) 'createdAt': createdAt?.toJson(),
      if (updatedAt != null) 'updatedAt': updatedAt?.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ProductReportImpl extends ProductReport {
  _ProductReportImpl({
    int? id,
    required int productId,
    required int reporterId,
    required _i2.ReportReason reason,
    String? description,
    required _i3.ReportStatus status,
    int? processedBy,
    DateTime? processedAt,
    String? processNote,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : super._(
          id: id,
          productId: productId,
          reporterId: reporterId,
          reason: reason,
          description: description,
          status: status,
          processedBy: processedBy,
          processedAt: processedAt,
          processNote: processNote,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

  /// Returns a shallow copy of this [ProductReport]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ProductReport copyWith({
    Object? id = _Undefined,
    int? productId,
    int? reporterId,
    _i2.ReportReason? reason,
    Object? description = _Undefined,
    _i3.ReportStatus? status,
    Object? processedBy = _Undefined,
    Object? processedAt = _Undefined,
    Object? processNote = _Undefined,
    Object? createdAt = _Undefined,
    Object? updatedAt = _Undefined,
  }) {
    return ProductReport(
      id: id is int? ? id : this.id,
      productId: productId ?? this.productId,
      reporterId: reporterId ?? this.reporterId,
      reason: reason ?? this.reason,
      description: description is String? ? description : this.description,
      status: status ?? this.status,
      processedBy: processedBy is int? ? processedBy : this.processedBy,
      processedAt: processedAt is DateTime? ? processedAt : this.processedAt,
      processNote: processNote is String? ? processNote : this.processNote,
      createdAt: createdAt is DateTime? ? createdAt : this.createdAt,
      updatedAt: updatedAt is DateTime? ? updatedAt : this.updatedAt,
    );
  }
}
