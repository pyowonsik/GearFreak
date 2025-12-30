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
import '../../../feature/product/model/report_reason.dart' as _i2;
import '../../../feature/product/model/report_status.dart' as _i3;

/// 상품 신고
abstract class ProductReport
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
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

  static final t = ProductReportTable();

  static const db = ProductReportRepository._();

  @override
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

  @override
  _i1.Table<int?> get table => t;

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
  Map<String, dynamic> toJsonForProtocol() {
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

  static ProductReportInclude include() {
    return ProductReportInclude._();
  }

  static ProductReportIncludeList includeList({
    _i1.WhereExpressionBuilder<ProductReportTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ProductReportTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ProductReportTable>? orderByList,
    ProductReportInclude? include,
  }) {
    return ProductReportIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ProductReport.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(ProductReport.t),
      include: include,
    );
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

class ProductReportTable extends _i1.Table<int?> {
  ProductReportTable({super.tableRelation})
      : super(tableName: 'product_report') {
    productId = _i1.ColumnInt(
      'productId',
      this,
    );
    reporterId = _i1.ColumnInt(
      'reporterId',
      this,
    );
    reason = _i1.ColumnEnum(
      'reason',
      this,
      _i1.EnumSerialization.byIndex,
    );
    description = _i1.ColumnString(
      'description',
      this,
    );
    status = _i1.ColumnEnum(
      'status',
      this,
      _i1.EnumSerialization.byIndex,
    );
    processedBy = _i1.ColumnInt(
      'processedBy',
      this,
    );
    processedAt = _i1.ColumnDateTime(
      'processedAt',
      this,
    );
    processNote = _i1.ColumnString(
      'processNote',
      this,
    );
    createdAt = _i1.ColumnDateTime(
      'createdAt',
      this,
    );
    updatedAt = _i1.ColumnDateTime(
      'updatedAt',
      this,
    );
  }

  /// 신고 대상 상품 ID
  late final _i1.ColumnInt productId;

  /// 신고자 사용자 ID
  late final _i1.ColumnInt reporterId;

  /// 신고 사유
  late final _i1.ColumnEnum<_i2.ReportReason> reason;

  /// 신고 상세 내용 (선택적)
  late final _i1.ColumnString description;

  /// 처리 상태
  late final _i1.ColumnEnum<_i3.ReportStatus> status;

  /// 처리자 사용자 ID (관리자, 선택적)
  late final _i1.ColumnInt processedBy;

  /// 처리일시 (선택적)
  late final _i1.ColumnDateTime processedAt;

  /// 처리 메모 (관리자 메모, 선택적)
  late final _i1.ColumnString processNote;

  /// 생성일
  late final _i1.ColumnDateTime createdAt;

  /// 수정일
  late final _i1.ColumnDateTime updatedAt;

  @override
  List<_i1.Column> get columns => [
        id,
        productId,
        reporterId,
        reason,
        description,
        status,
        processedBy,
        processedAt,
        processNote,
        createdAt,
        updatedAt,
      ];
}

class ProductReportInclude extends _i1.IncludeObject {
  ProductReportInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => ProductReport.t;
}

class ProductReportIncludeList extends _i1.IncludeList {
  ProductReportIncludeList._({
    _i1.WhereExpressionBuilder<ProductReportTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(ProductReport.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => ProductReport.t;
}

class ProductReportRepository {
  const ProductReportRepository._();

  /// Returns a list of [ProductReport]s matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order of the items use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// The maximum number of items can be set by [limit]. If no limit is set,
  /// all items matching the query will be returned.
  ///
  /// [offset] defines how many items to skip, after which [limit] (or all)
  /// items are read from the database.
  ///
  /// ```dart
  /// var persons = await Persons.db.find(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.firstName,
  ///   limit: 100,
  /// );
  /// ```
  Future<List<ProductReport>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<ProductReportTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ProductReportTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ProductReportTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.find<ProductReport>(
      where: where?.call(ProductReport.t),
      orderBy: orderBy?.call(ProductReport.t),
      orderByList: orderByList?.call(ProductReport.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Returns the first matching [ProductReport] matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// [offset] defines how many items to skip, after which the next one will be picked.
  ///
  /// ```dart
  /// var youngestPerson = await Persons.db.findFirstRow(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.age,
  /// );
  /// ```
  Future<ProductReport?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<ProductReportTable>? where,
    int? offset,
    _i1.OrderByBuilder<ProductReportTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ProductReportTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.findFirstRow<ProductReport>(
      where: where?.call(ProductReport.t),
      orderBy: orderBy?.call(ProductReport.t),
      orderByList: orderByList?.call(ProductReport.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Finds a single [ProductReport] by its [id] or null if no such row exists.
  Future<ProductReport?> findById(
    _i1.Session session,
    int id, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.findById<ProductReport>(
      id,
      transaction: transaction,
    );
  }

  /// Inserts all [ProductReport]s in the list and returns the inserted rows.
  ///
  /// The returned [ProductReport]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  Future<List<ProductReport>> insert(
    _i1.Session session,
    List<ProductReport> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<ProductReport>(
      rows,
      transaction: transaction,
    );
  }

  /// Inserts a single [ProductReport] and returns the inserted row.
  ///
  /// The returned [ProductReport] will have its `id` field set.
  Future<ProductReport> insertRow(
    _i1.Session session,
    ProductReport row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<ProductReport>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [ProductReport]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<ProductReport>> update(
    _i1.Session session,
    List<ProductReport> rows, {
    _i1.ColumnSelections<ProductReportTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<ProductReport>(
      rows,
      columns: columns?.call(ProductReport.t),
      transaction: transaction,
    );
  }

  /// Updates a single [ProductReport]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<ProductReport> updateRow(
    _i1.Session session,
    ProductReport row, {
    _i1.ColumnSelections<ProductReportTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<ProductReport>(
      row,
      columns: columns?.call(ProductReport.t),
      transaction: transaction,
    );
  }

  /// Deletes all [ProductReport]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<ProductReport>> delete(
    _i1.Session session,
    List<ProductReport> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<ProductReport>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [ProductReport].
  Future<ProductReport> deleteRow(
    _i1.Session session,
    ProductReport row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<ProductReport>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<ProductReport>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<ProductReportTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<ProductReport>(
      where: where(ProductReport.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<ProductReportTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<ProductReport>(
      where: where?.call(ProductReport.t),
      limit: limit,
      transaction: transaction,
    );
  }
}
