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

/// 상품 조회 정보
abstract class ProductView
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  ProductView._({
    this.id,
    required this.userId,
    this.user,
    required this.productId,
    this.product,
    this.viewedAt,
  });

  factory ProductView({
    int? id,
    required int userId,
    _i2.User? user,
    required int productId,
    _i3.Product? product,
    DateTime? viewedAt,
  }) = _ProductViewImpl;

  factory ProductView.fromJson(Map<String, dynamic> jsonSerialization) {
    return ProductView(
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
      viewedAt: jsonSerialization['viewedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['viewedAt']),
    );
  }

  static final t = ProductViewTable();

  static const db = ProductViewRepository._();

  @override
  int? id;

  int userId;

  /// 사용자 (User와의 관계)
  _i2.User? user;

  int productId;

  /// 상품 (Product와의 관계)
  _i3.Product? product;

  /// 조회일
  DateTime? viewedAt;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [ProductView]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ProductView copyWith({
    int? id,
    int? userId,
    _i2.User? user,
    int? productId,
    _i3.Product? product,
    DateTime? viewedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'userId': userId,
      if (user != null) 'user': user?.toJson(),
      'productId': productId,
      if (product != null) 'product': product?.toJson(),
      if (viewedAt != null) 'viewedAt': viewedAt?.toJson(),
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
      if (viewedAt != null) 'viewedAt': viewedAt?.toJson(),
    };
  }

  static ProductViewInclude include({
    _i2.UserInclude? user,
    _i3.ProductInclude? product,
  }) {
    return ProductViewInclude._(
      user: user,
      product: product,
    );
  }

  static ProductViewIncludeList includeList({
    _i1.WhereExpressionBuilder<ProductViewTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ProductViewTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ProductViewTable>? orderByList,
    ProductViewInclude? include,
  }) {
    return ProductViewIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ProductView.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(ProductView.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ProductViewImpl extends ProductView {
  _ProductViewImpl({
    int? id,
    required int userId,
    _i2.User? user,
    required int productId,
    _i3.Product? product,
    DateTime? viewedAt,
  }) : super._(
          id: id,
          userId: userId,
          user: user,
          productId: productId,
          product: product,
          viewedAt: viewedAt,
        );

  /// Returns a shallow copy of this [ProductView]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ProductView copyWith({
    Object? id = _Undefined,
    int? userId,
    Object? user = _Undefined,
    int? productId,
    Object? product = _Undefined,
    Object? viewedAt = _Undefined,
  }) {
    return ProductView(
      id: id is int? ? id : this.id,
      userId: userId ?? this.userId,
      user: user is _i2.User? ? user : this.user?.copyWith(),
      productId: productId ?? this.productId,
      product: product is _i3.Product? ? product : this.product?.copyWith(),
      viewedAt: viewedAt is DateTime? ? viewedAt : this.viewedAt,
    );
  }
}

class ProductViewTable extends _i1.Table<int?> {
  ProductViewTable({super.tableRelation}) : super(tableName: 'product_view') {
    userId = _i1.ColumnInt(
      'userId',
      this,
    );
    productId = _i1.ColumnInt(
      'productId',
      this,
    );
    viewedAt = _i1.ColumnDateTime(
      'viewedAt',
      this,
    );
  }

  late final _i1.ColumnInt userId;

  /// 사용자 (User와의 관계)
  _i2.UserTable? _user;

  late final _i1.ColumnInt productId;

  /// 상품 (Product와의 관계)
  _i3.ProductTable? _product;

  /// 조회일
  late final _i1.ColumnDateTime viewedAt;

  _i2.UserTable get user {
    if (_user != null) return _user!;
    _user = _i1.createRelationTable(
      relationFieldName: 'user',
      field: ProductView.t.userId,
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
      field: ProductView.t.productId,
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
        viewedAt,
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

class ProductViewInclude extends _i1.IncludeObject {
  ProductViewInclude._({
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
  _i1.Table<int?> get table => ProductView.t;
}

class ProductViewIncludeList extends _i1.IncludeList {
  ProductViewIncludeList._({
    _i1.WhereExpressionBuilder<ProductViewTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(ProductView.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => ProductView.t;
}

class ProductViewRepository {
  const ProductViewRepository._();

  final attachRow = const ProductViewAttachRowRepository._();

  /// Returns a list of [ProductView]s matching the given query parameters.
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
  Future<List<ProductView>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<ProductViewTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ProductViewTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ProductViewTable>? orderByList,
    _i1.Transaction? transaction,
    ProductViewInclude? include,
  }) async {
    return session.db.find<ProductView>(
      where: where?.call(ProductView.t),
      orderBy: orderBy?.call(ProductView.t),
      orderByList: orderByList?.call(ProductView.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      include: include,
    );
  }

  /// Returns the first matching [ProductView] matching the given query parameters.
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
  Future<ProductView?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<ProductViewTable>? where,
    int? offset,
    _i1.OrderByBuilder<ProductViewTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ProductViewTable>? orderByList,
    _i1.Transaction? transaction,
    ProductViewInclude? include,
  }) async {
    return session.db.findFirstRow<ProductView>(
      where: where?.call(ProductView.t),
      orderBy: orderBy?.call(ProductView.t),
      orderByList: orderByList?.call(ProductView.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      include: include,
    );
  }

  /// Finds a single [ProductView] by its [id] or null if no such row exists.
  Future<ProductView?> findById(
    _i1.Session session,
    int id, {
    _i1.Transaction? transaction,
    ProductViewInclude? include,
  }) async {
    return session.db.findById<ProductView>(
      id,
      transaction: transaction,
      include: include,
    );
  }

  /// Inserts all [ProductView]s in the list and returns the inserted rows.
  ///
  /// The returned [ProductView]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  Future<List<ProductView>> insert(
    _i1.Session session,
    List<ProductView> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<ProductView>(
      rows,
      transaction: transaction,
    );
  }

  /// Inserts a single [ProductView] and returns the inserted row.
  ///
  /// The returned [ProductView] will have its `id` field set.
  Future<ProductView> insertRow(
    _i1.Session session,
    ProductView row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<ProductView>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [ProductView]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<ProductView>> update(
    _i1.Session session,
    List<ProductView> rows, {
    _i1.ColumnSelections<ProductViewTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<ProductView>(
      rows,
      columns: columns?.call(ProductView.t),
      transaction: transaction,
    );
  }

  /// Updates a single [ProductView]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<ProductView> updateRow(
    _i1.Session session,
    ProductView row, {
    _i1.ColumnSelections<ProductViewTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<ProductView>(
      row,
      columns: columns?.call(ProductView.t),
      transaction: transaction,
    );
  }

  /// Deletes all [ProductView]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<ProductView>> delete(
    _i1.Session session,
    List<ProductView> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<ProductView>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [ProductView].
  Future<ProductView> deleteRow(
    _i1.Session session,
    ProductView row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<ProductView>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<ProductView>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<ProductViewTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<ProductView>(
      where: where(ProductView.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<ProductViewTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<ProductView>(
      where: where?.call(ProductView.t),
      limit: limit,
      transaction: transaction,
    );
  }
}

class ProductViewAttachRowRepository {
  const ProductViewAttachRowRepository._();

  /// Creates a relation between the given [ProductView] and [User]
  /// by setting the [ProductView]'s foreign key `userId` to refer to the [User].
  Future<void> user(
    _i1.Session session,
    ProductView productView,
    _i2.User user, {
    _i1.Transaction? transaction,
  }) async {
    if (productView.id == null) {
      throw ArgumentError.notNull('productView.id');
    }
    if (user.id == null) {
      throw ArgumentError.notNull('user.id');
    }

    var $productView = productView.copyWith(userId: user.id);
    await session.db.updateRow<ProductView>(
      $productView,
      columns: [ProductView.t.userId],
      transaction: transaction,
    );
  }

  /// Creates a relation between the given [ProductView] and [Product]
  /// by setting the [ProductView]'s foreign key `productId` to refer to the [Product].
  Future<void> product(
    _i1.Session session,
    ProductView productView,
    _i3.Product product, {
    _i1.Transaction? transaction,
  }) async {
    if (productView.id == null) {
      throw ArgumentError.notNull('productView.id');
    }
    if (product.id == null) {
      throw ArgumentError.notNull('product.id');
    }

    var $productView = productView.copyWith(productId: product.id);
    await session.db.updateRow<ProductView>(
      $productView,
      columns: [ProductView.t.productId],
      transaction: transaction,
    );
  }
}
