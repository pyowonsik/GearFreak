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

/// FCM 토큰 정보
abstract class FcmToken
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  FcmToken._({
    this.id,
    required this.userId,
    required this.token,
    this.deviceType,
    this.updatedAt,
    this.createdAt,
  });

  factory FcmToken({
    int? id,
    required int userId,
    required String token,
    String? deviceType,
    DateTime? updatedAt,
    DateTime? createdAt,
  }) = _FcmTokenImpl;

  factory FcmToken.fromJson(Map<String, dynamic> jsonSerialization) {
    return FcmToken(
      id: jsonSerialization['id'] as int?,
      userId: jsonSerialization['userId'] as int,
      token: jsonSerialization['token'] as String,
      deviceType: jsonSerialization['deviceType'] as String?,
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  static final t = FcmTokenTable();

  static const db = FcmTokenRepository._();

  @override
  int? id;

  /// 사용자 ID (User.id)
  int userId;

  /// FCM 토큰
  String token;

  /// 디바이스 타입 (ios, android)
  String? deviceType;

  /// 토큰 생성/업데이트 시간
  DateTime? updatedAt;

  /// 토큰 생성 시간
  DateTime? createdAt;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [FcmToken]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  FcmToken copyWith({
    int? id,
    int? userId,
    String? token,
    String? deviceType,
    DateTime? updatedAt,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'userId': userId,
      'token': token,
      if (deviceType != null) 'deviceType': deviceType,
      if (updatedAt != null) 'updatedAt': updatedAt?.toJson(),
      if (createdAt != null) 'createdAt': createdAt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      if (id != null) 'id': id,
      'userId': userId,
      'token': token,
      if (deviceType != null) 'deviceType': deviceType,
      if (updatedAt != null) 'updatedAt': updatedAt?.toJson(),
      if (createdAt != null) 'createdAt': createdAt?.toJson(),
    };
  }

  static FcmTokenInclude include() {
    return FcmTokenInclude._();
  }

  static FcmTokenIncludeList includeList({
    _i1.WhereExpressionBuilder<FcmTokenTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<FcmTokenTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<FcmTokenTable>? orderByList,
    FcmTokenInclude? include,
  }) {
    return FcmTokenIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(FcmToken.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(FcmToken.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _FcmTokenImpl extends FcmToken {
  _FcmTokenImpl({
    int? id,
    required int userId,
    required String token,
    String? deviceType,
    DateTime? updatedAt,
    DateTime? createdAt,
  }) : super._(
          id: id,
          userId: userId,
          token: token,
          deviceType: deviceType,
          updatedAt: updatedAt,
          createdAt: createdAt,
        );

  /// Returns a shallow copy of this [FcmToken]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  FcmToken copyWith({
    Object? id = _Undefined,
    int? userId,
    String? token,
    Object? deviceType = _Undefined,
    Object? updatedAt = _Undefined,
    Object? createdAt = _Undefined,
  }) {
    return FcmToken(
      id: id is int? ? id : this.id,
      userId: userId ?? this.userId,
      token: token ?? this.token,
      deviceType: deviceType is String? ? deviceType : this.deviceType,
      updatedAt: updatedAt is DateTime? ? updatedAt : this.updatedAt,
      createdAt: createdAt is DateTime? ? createdAt : this.createdAt,
    );
  }
}

class FcmTokenTable extends _i1.Table<int?> {
  FcmTokenTable({super.tableRelation}) : super(tableName: 'fcm_token') {
    userId = _i1.ColumnInt(
      'userId',
      this,
    );
    token = _i1.ColumnString(
      'token',
      this,
    );
    deviceType = _i1.ColumnString(
      'deviceType',
      this,
    );
    updatedAt = _i1.ColumnDateTime(
      'updatedAt',
      this,
    );
    createdAt = _i1.ColumnDateTime(
      'createdAt',
      this,
    );
  }

  /// 사용자 ID (User.id)
  late final _i1.ColumnInt userId;

  /// FCM 토큰
  late final _i1.ColumnString token;

  /// 디바이스 타입 (ios, android)
  late final _i1.ColumnString deviceType;

  /// 토큰 생성/업데이트 시간
  late final _i1.ColumnDateTime updatedAt;

  /// 토큰 생성 시간
  late final _i1.ColumnDateTime createdAt;

  @override
  List<_i1.Column> get columns => [
        id,
        userId,
        token,
        deviceType,
        updatedAt,
        createdAt,
      ];
}

class FcmTokenInclude extends _i1.IncludeObject {
  FcmTokenInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => FcmToken.t;
}

class FcmTokenIncludeList extends _i1.IncludeList {
  FcmTokenIncludeList._({
    _i1.WhereExpressionBuilder<FcmTokenTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(FcmToken.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => FcmToken.t;
}

class FcmTokenRepository {
  const FcmTokenRepository._();

  /// Returns a list of [FcmToken]s matching the given query parameters.
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
  Future<List<FcmToken>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<FcmTokenTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<FcmTokenTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<FcmTokenTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.find<FcmToken>(
      where: where?.call(FcmToken.t),
      orderBy: orderBy?.call(FcmToken.t),
      orderByList: orderByList?.call(FcmToken.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Returns the first matching [FcmToken] matching the given query parameters.
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
  Future<FcmToken?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<FcmTokenTable>? where,
    int? offset,
    _i1.OrderByBuilder<FcmTokenTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<FcmTokenTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.findFirstRow<FcmToken>(
      where: where?.call(FcmToken.t),
      orderBy: orderBy?.call(FcmToken.t),
      orderByList: orderByList?.call(FcmToken.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Finds a single [FcmToken] by its [id] or null if no such row exists.
  Future<FcmToken?> findById(
    _i1.Session session,
    int id, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.findById<FcmToken>(
      id,
      transaction: transaction,
    );
  }

  /// Inserts all [FcmToken]s in the list and returns the inserted rows.
  ///
  /// The returned [FcmToken]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  Future<List<FcmToken>> insert(
    _i1.Session session,
    List<FcmToken> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<FcmToken>(
      rows,
      transaction: transaction,
    );
  }

  /// Inserts a single [FcmToken] and returns the inserted row.
  ///
  /// The returned [FcmToken] will have its `id` field set.
  Future<FcmToken> insertRow(
    _i1.Session session,
    FcmToken row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<FcmToken>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [FcmToken]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<FcmToken>> update(
    _i1.Session session,
    List<FcmToken> rows, {
    _i1.ColumnSelections<FcmTokenTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<FcmToken>(
      rows,
      columns: columns?.call(FcmToken.t),
      transaction: transaction,
    );
  }

  /// Updates a single [FcmToken]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<FcmToken> updateRow(
    _i1.Session session,
    FcmToken row, {
    _i1.ColumnSelections<FcmTokenTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<FcmToken>(
      row,
      columns: columns?.call(FcmToken.t),
      transaction: transaction,
    );
  }

  /// Deletes all [FcmToken]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<FcmToken>> delete(
    _i1.Session session,
    List<FcmToken> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<FcmToken>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [FcmToken].
  Future<FcmToken> deleteRow(
    _i1.Session session,
    FcmToken row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<FcmToken>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<FcmToken>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<FcmTokenTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<FcmToken>(
      where: where(FcmToken.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<FcmTokenTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<FcmToken>(
      where: where?.call(FcmToken.t),
      limit: limit,
      transaction: transaction,
    );
  }
}
