/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters

// ignore_for_file: unnecessary_null_comparison

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod/serverpod.dart' as _i1;
import '../../../feature/user/model/user.dart' as _i2;
import '../../../feature/product/model/product.dart' as _i3;

/// 찜 정보
abstract class Favorite
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  Favorite._({
    this.id,
    required this.userId,
    this.user,
    required this.productId,
    this.product,
    this.createdAt,
  });

  factory Favorite({
    int? id,
    required int userId,
    _i2.User? user,
    required int productId,
    _i3.Product? product,
    DateTime? createdAt,
  }) = _FavoriteImpl;

  factory Favorite.fromJson(Map<String, dynamic> jsonSerialization) {
    return Favorite(
      id: jsonSerialization['id'] as int?,
      userId: jsonSerialization['userId'] as int,
      user: jsonSerialization['user'] == null
          ? null
          : _i2.User.fromJson(
              (jsonSerialization['user'] as Map<String, dynamic>)),
      productId: jsonSerialization['productId'] as int,
      product: jsonSerialization['product'] == null
          ? null
          : _i3.Product.fromJson(
              (jsonSerialization['product'] as Map<String, dynamic>)),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  static final t = FavoriteTable();

  static const db = FavoriteRepository._();

  @override
  int? id;

  int userId;

  /// 사용자 (User와의 관계)
  _i2.User? user;

  int productId;

  /// 상품 (Product와의 관계)
  _i3.Product? product;

  /// 찜 생성일
  DateTime? createdAt;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [Favorite]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  Favorite copyWith({
    int? id,
    int? userId,
    _i2.User? user,
    int? productId,
    _i3.Product? product,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'userId': userId,
      if (user != null) 'user': user?.toJson(),
      'productId': productId,
      if (product != null) 'product': product?.toJson(),
      if (createdAt != null) 'createdAt': createdAt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      if (id != null) 'id': id,
      'userId': userId,
      if (user != null) 'user': user?.toJsonForProtocol(),
      'productId': productId,
      if (product != null) 'product': product?.toJsonForProtocol(),
      if (createdAt != null) 'createdAt': createdAt?.toJson(),
    };
  }

  static FavoriteInclude include({
    _i2.UserInclude? user,
    _i3.ProductInclude? product,
  }) {
    return FavoriteInclude._(
      user: user,
      product: product,
    );
  }

  static FavoriteIncludeList includeList({
    _i1.WhereExpressionBuilder<FavoriteTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<FavoriteTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<FavoriteTable>? orderByList,
    FavoriteInclude? include,
  }) {
    return FavoriteIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Favorite.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(Favorite.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _FavoriteImpl extends Favorite {
  _FavoriteImpl({
    int? id,
    required int userId,
    _i2.User? user,
    required int productId,
    _i3.Product? product,
    DateTime? createdAt,
  }) : super._(
          id: id,
          userId: userId,
          user: user,
          productId: productId,
          product: product,
          createdAt: createdAt,
        );

  /// Returns a shallow copy of this [Favorite]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  Favorite copyWith({
    Object? id = _Undefined,
    int? userId,
    Object? user = _Undefined,
    int? productId,
    Object? product = _Undefined,
    Object? createdAt = _Undefined,
  }) {
    return Favorite(
      id: id is int? ? id : this.id,
      userId: userId ?? this.userId,
      user: user is _i2.User? ? user : this.user?.copyWith(),
      productId: productId ?? this.productId,
      product: product is _i3.Product? ? product : this.product?.copyWith(),
      createdAt: createdAt is DateTime? ? createdAt : this.createdAt,
    );
  }
}

class FavoriteTable extends _i1.Table<int?> {
  FavoriteTable({super.tableRelation}) : super(tableName: 'favorite') {
    userId = _i1.ColumnInt(
      'userId',
      this,
    );
    productId = _i1.ColumnInt(
      'productId',
      this,
    );
    createdAt = _i1.ColumnDateTime(
      'createdAt',
      this,
    );
  }

  late final _i1.ColumnInt userId;

  /// 사용자 (User와의 관계)
  _i2.UserTable? _user;

  late final _i1.ColumnInt productId;

  /// 상품 (Product와의 관계)
  _i3.ProductTable? _product;

  /// 찜 생성일
  late final _i1.ColumnDateTime createdAt;

  _i2.UserTable get user {
    if (_user != null) return _user!;
    _user = _i1.createRelationTable(
      relationFieldName: 'user',
      field: Favorite.t.userId,
      foreignField: _i2.User.t.id,
      tableRelation: tableRelation,
      createTable: (foreignTableRelation) =>
          _i2.UserTable(tableRelation: foreignTableRelation),
    );
    return _user!;
  }

  _i3.ProductTable get product {
    if (_product != null) return _product!;
    _product = _i1.createRelationTable(
      relationFieldName: 'product',
      field: Favorite.t.productId,
      foreignField: _i3.Product.t.id,
      tableRelation: tableRelation,
      createTable: (foreignTableRelation) =>
          _i3.ProductTable(tableRelation: foreignTableRelation),
    );
    return _product!;
  }

  @override
  List<_i1.Column> get columns => [
        id,
        userId,
        productId,
        createdAt,
      ];

  @override
  _i1.Table? getRelationTable(String relationField) {
    if (relationField == 'user') {
      return user;
    }
    if (relationField == 'product') {
      return product;
    }
    return null;
  }
}

class FavoriteInclude extends _i1.IncludeObject {
  FavoriteInclude._({
    _i2.UserInclude? user,
    _i3.ProductInclude? product,
  }) {
    _user = user;
    _product = product;
  }

  _i2.UserInclude? _user;

  _i3.ProductInclude? _product;

  @override
  Map<String, _i1.Include?> get includes => {
        'user': _user,
        'product': _product,
      };

  @override
  _i1.Table<int?> get table => Favorite.t;
}

class FavoriteIncludeList extends _i1.IncludeList {
  FavoriteIncludeList._({
    _i1.WhereExpressionBuilder<FavoriteTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(Favorite.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => Favorite.t;
}

class FavoriteRepository {
  const FavoriteRepository._();

  final attachRow = const FavoriteAttachRowRepository._();

  /// Returns a list of [Favorite]s matching the given query parameters.
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
  Future<List<Favorite>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<FavoriteTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<FavoriteTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<FavoriteTable>? orderByList,
    _i1.Transaction? transaction,
    FavoriteInclude? include,
  }) async {
    return session.db.find<Favorite>(
      where: where?.call(Favorite.t),
      orderBy: orderBy?.call(Favorite.t),
      orderByList: orderByList?.call(Favorite.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      include: include,
    );
  }

  /// Returns the first matching [Favorite] matching the given query parameters.
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
  Future<Favorite?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<FavoriteTable>? where,
    int? offset,
    _i1.OrderByBuilder<FavoriteTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<FavoriteTable>? orderByList,
    _i1.Transaction? transaction,
    FavoriteInclude? include,
  }) async {
    return session.db.findFirstRow<Favorite>(
      where: where?.call(Favorite.t),
      orderBy: orderBy?.call(Favorite.t),
      orderByList: orderByList?.call(Favorite.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      include: include,
    );
  }

  /// Finds a single [Favorite] by its [id] or null if no such row exists.
  Future<Favorite?> findById(
    _i1.Session session,
    int id, {
    _i1.Transaction? transaction,
    FavoriteInclude? include,
  }) async {
    return session.db.findById<Favorite>(
      id,
      transaction: transaction,
      include: include,
    );
  }

  /// Inserts all [Favorite]s in the list and returns the inserted rows.
  ///
  /// The returned [Favorite]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  Future<List<Favorite>> insert(
    _i1.Session session,
    List<Favorite> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<Favorite>(
      rows,
      transaction: transaction,
    );
  }

  /// Inserts a single [Favorite] and returns the inserted row.
  ///
  /// The returned [Favorite] will have its `id` field set.
  Future<Favorite> insertRow(
    _i1.Session session,
    Favorite row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<Favorite>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [Favorite]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<Favorite>> update(
    _i1.Session session,
    List<Favorite> rows, {
    _i1.ColumnSelections<FavoriteTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<Favorite>(
      rows,
      columns: columns?.call(Favorite.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Favorite]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<Favorite> updateRow(
    _i1.Session session,
    Favorite row, {
    _i1.ColumnSelections<FavoriteTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<Favorite>(
      row,
      columns: columns?.call(Favorite.t),
      transaction: transaction,
    );
  }

  /// Deletes all [Favorite]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<Favorite>> delete(
    _i1.Session session,
    List<Favorite> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<Favorite>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [Favorite].
  Future<Favorite> deleteRow(
    _i1.Session session,
    Favorite row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<Favorite>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<Favorite>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<FavoriteTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<Favorite>(
      where: where(Favorite.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<FavoriteTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<Favorite>(
      where: where?.call(Favorite.t),
      limit: limit,
      transaction: transaction,
    );
  }
}

class FavoriteAttachRowRepository {
  const FavoriteAttachRowRepository._();

  /// Creates a relation between the given [Favorite] and [User]
  /// by setting the [Favorite]'s foreign key `userId` to refer to the [User].
  Future<void> user(
    _i1.Session session,
    Favorite favorite,
    _i2.User user, {
    _i1.Transaction? transaction,
  }) async {
    if (favorite.id == null) {
      throw ArgumentError.notNull('favorite.id');
    }
    if (user.id == null) {
      throw ArgumentError.notNull('user.id');
    }

    var $favorite = favorite.copyWith(userId: user.id);
    await session.db.updateRow<Favorite>(
      $favorite,
      columns: [Favorite.t.userId],
      transaction: transaction,
    );
  }

  /// Creates a relation between the given [Favorite] and [Product]
  /// by setting the [Favorite]'s foreign key `productId` to refer to the [Product].
  Future<void> product(
    _i1.Session session,
    Favorite favorite,
    _i3.Product product, {
    _i1.Transaction? transaction,
  }) async {
    if (favorite.id == null) {
      throw ArgumentError.notNull('favorite.id');
    }
    if (product.id == null) {
      throw ArgumentError.notNull('product.id');
    }

    var $favorite = favorite.copyWith(productId: product.id);
    await session.db.updateRow<Favorite>(
      $favorite,
      columns: [Favorite.t.productId],
      transaction: transaction,
    );
  }
}
