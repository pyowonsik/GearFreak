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
import '../../../feature/product/model/product_category.dart' as _i3;
import '../../../feature/product/model/product_condition.dart' as _i4;
import '../../../feature/product/model/trade_method.dart' as _i5;
import '../../../feature/product/model/product_status.dart' as _i6;

/// 상품 정보
abstract class Product
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  Product._({
    this.id,
    required this.sellerId,
    this.seller,
    required this.title,
    required this.category,
    required this.price,
    required this.condition,
    required this.description,
    required this.tradeMethod,
    this.baseAddress,
    this.detailAddress,
    this.imageUrls,
    this.viewCount,
    this.favoriteCount,
    this.chatCount,
    this.createdAt,
    this.updatedAt,
    this.status,
  });

  factory Product({
    int? id,
    required int sellerId,
    _i2.User? seller,
    required String title,
    required _i3.ProductCategory category,
    required int price,
    required _i4.ProductCondition condition,
    required String description,
    required _i5.TradeMethod tradeMethod,
    String? baseAddress,
    String? detailAddress,
    List<String>? imageUrls,
    int? viewCount,
    int? favoriteCount,
    int? chatCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    _i6.ProductStatus? status,
  }) = _ProductImpl;

  factory Product.fromJson(Map<String, dynamic> jsonSerialization) {
    return Product(
      id: jsonSerialization['id'] as int?,
      sellerId: jsonSerialization['sellerId'] as int,
      seller: jsonSerialization['seller'] == null
          ? null
          : _i2.User.fromJson(
              (jsonSerialization['seller'] as Map<String, dynamic>)),
      title: jsonSerialization['title'] as String,
      category:
          _i3.ProductCategory.fromJson((jsonSerialization['category'] as int)),
      price: jsonSerialization['price'] as int,
      condition: _i4.ProductCondition.fromJson(
          (jsonSerialization['condition'] as int)),
      description: jsonSerialization['description'] as String,
      tradeMethod:
          _i5.TradeMethod.fromJson((jsonSerialization['tradeMethod'] as int)),
      baseAddress: jsonSerialization['baseAddress'] as String?,
      detailAddress: jsonSerialization['detailAddress'] as String?,
      imageUrls: (jsonSerialization['imageUrls'] as List?)
          ?.map((e) => e as String)
          .toList(),
      viewCount: jsonSerialization['viewCount'] as int?,
      favoriteCount: jsonSerialization['favoriteCount'] as int?,
      chatCount: jsonSerialization['chatCount'] as int?,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
      status: jsonSerialization['status'] == null
          ? null
          : _i6.ProductStatus.fromJson((jsonSerialization['status'] as int)),
    );
  }

  static final t = ProductTable();

  static const db = ProductRepository._();

  @override
  int? id;

  int sellerId;

  /// 판매자 (User와의 관계)
  _i2.User? seller;

  /// 상품명
  String title;

  /// 카테고리
  _i3.ProductCategory category;

  /// 가격
  int price;

  /// 상품 상태
  _i4.ProductCondition condition;

  /// 상품 설명
  String description;

  /// 거래 방법
  _i5.TradeMethod tradeMethod;

  /// 기본 주소 (kpostal에서 검색한 주소)
  String? baseAddress;

  /// 상세 주소 (동/호수 등)
  String? detailAddress;

  /// 상품 이미지 URL 목록
  List<String>? imageUrls;

  /// 조회수
  int? viewCount;

  /// 찜 개수
  int? favoriteCount;

  /// 채팅 개수
  int? chatCount;

  /// 상품 생성일
  DateTime? createdAt;

  /// 상품 수정일
  DateTime? updatedAt;

  /// 판매 상태
  _i6.ProductStatus? status;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [Product]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  Product copyWith({
    int? id,
    int? sellerId,
    _i2.User? seller,
    String? title,
    _i3.ProductCategory? category,
    int? price,
    _i4.ProductCondition? condition,
    String? description,
    _i5.TradeMethod? tradeMethod,
    String? baseAddress,
    String? detailAddress,
    List<String>? imageUrls,
    int? viewCount,
    int? favoriteCount,
    int? chatCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    _i6.ProductStatus? status,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'sellerId': sellerId,
      if (seller != null) 'seller': seller?.toJson(),
      'title': title,
      'category': category.toJson(),
      'price': price,
      'condition': condition.toJson(),
      'description': description,
      'tradeMethod': tradeMethod.toJson(),
      if (baseAddress != null) 'baseAddress': baseAddress,
      if (detailAddress != null) 'detailAddress': detailAddress,
      if (imageUrls != null) 'imageUrls': imageUrls?.toJson(),
      if (viewCount != null) 'viewCount': viewCount,
      if (favoriteCount != null) 'favoriteCount': favoriteCount,
      if (chatCount != null) 'chatCount': chatCount,
      if (createdAt != null) 'createdAt': createdAt?.toJson(),
      if (updatedAt != null) 'updatedAt': updatedAt?.toJson(),
      if (status != null) 'status': status?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      if (id != null) 'id': id,
      'sellerId': sellerId,
      if (seller != null) 'seller': seller?.toJsonForProtocol(),
      'title': title,
      'category': category.toJson(),
      'price': price,
      'condition': condition.toJson(),
      'description': description,
      'tradeMethod': tradeMethod.toJson(),
      if (baseAddress != null) 'baseAddress': baseAddress,
      if (detailAddress != null) 'detailAddress': detailAddress,
      if (imageUrls != null) 'imageUrls': imageUrls?.toJson(),
      if (viewCount != null) 'viewCount': viewCount,
      if (favoriteCount != null) 'favoriteCount': favoriteCount,
      if (chatCount != null) 'chatCount': chatCount,
      if (createdAt != null) 'createdAt': createdAt?.toJson(),
      if (updatedAt != null) 'updatedAt': updatedAt?.toJson(),
      if (status != null) 'status': status?.toJson(),
    };
  }

  static ProductInclude include({_i2.UserInclude? seller}) {
    return ProductInclude._(seller: seller);
  }

  static ProductIncludeList includeList({
    _i1.WhereExpressionBuilder<ProductTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ProductTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ProductTable>? orderByList,
    ProductInclude? include,
  }) {
    return ProductIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Product.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(Product.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ProductImpl extends Product {
  _ProductImpl({
    int? id,
    required int sellerId,
    _i2.User? seller,
    required String title,
    required _i3.ProductCategory category,
    required int price,
    required _i4.ProductCondition condition,
    required String description,
    required _i5.TradeMethod tradeMethod,
    String? baseAddress,
    String? detailAddress,
    List<String>? imageUrls,
    int? viewCount,
    int? favoriteCount,
    int? chatCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    _i6.ProductStatus? status,
  }) : super._(
          id: id,
          sellerId: sellerId,
          seller: seller,
          title: title,
          category: category,
          price: price,
          condition: condition,
          description: description,
          tradeMethod: tradeMethod,
          baseAddress: baseAddress,
          detailAddress: detailAddress,
          imageUrls: imageUrls,
          viewCount: viewCount,
          favoriteCount: favoriteCount,
          chatCount: chatCount,
          createdAt: createdAt,
          updatedAt: updatedAt,
          status: status,
        );

  /// Returns a shallow copy of this [Product]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  Product copyWith({
    Object? id = _Undefined,
    int? sellerId,
    Object? seller = _Undefined,
    String? title,
    _i3.ProductCategory? category,
    int? price,
    _i4.ProductCondition? condition,
    String? description,
    _i5.TradeMethod? tradeMethod,
    Object? baseAddress = _Undefined,
    Object? detailAddress = _Undefined,
    Object? imageUrls = _Undefined,
    Object? viewCount = _Undefined,
    Object? favoriteCount = _Undefined,
    Object? chatCount = _Undefined,
    Object? createdAt = _Undefined,
    Object? updatedAt = _Undefined,
    Object? status = _Undefined,
  }) {
    return Product(
      id: id is int? ? id : this.id,
      sellerId: sellerId ?? this.sellerId,
      seller: seller is _i2.User? ? seller : this.seller?.copyWith(),
      title: title ?? this.title,
      category: category ?? this.category,
      price: price ?? this.price,
      condition: condition ?? this.condition,
      description: description ?? this.description,
      tradeMethod: tradeMethod ?? this.tradeMethod,
      baseAddress: baseAddress is String? ? baseAddress : this.baseAddress,
      detailAddress:
          detailAddress is String? ? detailAddress : this.detailAddress,
      imageUrls: imageUrls is List<String>?
          ? imageUrls
          : this.imageUrls?.map((e0) => e0).toList(),
      viewCount: viewCount is int? ? viewCount : this.viewCount,
      favoriteCount: favoriteCount is int? ? favoriteCount : this.favoriteCount,
      chatCount: chatCount is int? ? chatCount : this.chatCount,
      createdAt: createdAt is DateTime? ? createdAt : this.createdAt,
      updatedAt: updatedAt is DateTime? ? updatedAt : this.updatedAt,
      status: status is _i6.ProductStatus? ? status : this.status,
    );
  }
}

class ProductTable extends _i1.Table<int?> {
  ProductTable({super.tableRelation}) : super(tableName: 'product') {
    sellerId = _i1.ColumnInt(
      'sellerId',
      this,
    );
    title = _i1.ColumnString(
      'title',
      this,
    );
    category = _i1.ColumnEnum(
      'category',
      this,
      _i1.EnumSerialization.byIndex,
    );
    price = _i1.ColumnInt(
      'price',
      this,
    );
    condition = _i1.ColumnEnum(
      'condition',
      this,
      _i1.EnumSerialization.byIndex,
    );
    description = _i1.ColumnString(
      'description',
      this,
    );
    tradeMethod = _i1.ColumnEnum(
      'tradeMethod',
      this,
      _i1.EnumSerialization.byIndex,
    );
    baseAddress = _i1.ColumnString(
      'baseAddress',
      this,
    );
    detailAddress = _i1.ColumnString(
      'detailAddress',
      this,
    );
    imageUrls = _i1.ColumnSerializable(
      'imageUrls',
      this,
    );
    viewCount = _i1.ColumnInt(
      'viewCount',
      this,
    );
    favoriteCount = _i1.ColumnInt(
      'favoriteCount',
      this,
    );
    chatCount = _i1.ColumnInt(
      'chatCount',
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
    status = _i1.ColumnEnum(
      'status',
      this,
      _i1.EnumSerialization.byIndex,
    );
  }

  late final _i1.ColumnInt sellerId;

  /// 판매자 (User와의 관계)
  _i2.UserTable? _seller;

  /// 상품명
  late final _i1.ColumnString title;

  /// 카테고리
  late final _i1.ColumnEnum<_i3.ProductCategory> category;

  /// 가격
  late final _i1.ColumnInt price;

  /// 상품 상태
  late final _i1.ColumnEnum<_i4.ProductCondition> condition;

  /// 상품 설명
  late final _i1.ColumnString description;

  /// 거래 방법
  late final _i1.ColumnEnum<_i5.TradeMethod> tradeMethod;

  /// 기본 주소 (kpostal에서 검색한 주소)
  late final _i1.ColumnString baseAddress;

  /// 상세 주소 (동/호수 등)
  late final _i1.ColumnString detailAddress;

  /// 상품 이미지 URL 목록
  late final _i1.ColumnSerializable imageUrls;

  /// 조회수
  late final _i1.ColumnInt viewCount;

  /// 찜 개수
  late final _i1.ColumnInt favoriteCount;

  /// 채팅 개수
  late final _i1.ColumnInt chatCount;

  /// 상품 생성일
  late final _i1.ColumnDateTime createdAt;

  /// 상품 수정일
  late final _i1.ColumnDateTime updatedAt;

  /// 판매 상태
  late final _i1.ColumnEnum<_i6.ProductStatus> status;

  _i2.UserTable get seller {
    if (_seller != null) return _seller!;
    _seller = _i1.createRelationTable(
      relationFieldName: 'seller',
      field: Product.t.sellerId,
      foreignField: _i2.User.t.id,
      tableRelation: tableRelation,
      createTable: (foreignTableRelation) =>
          _i2.UserTable(tableRelation: foreignTableRelation),
    );
    return _seller!;
  }

  @override
  List<_i1.Column> get columns => [
        id,
        sellerId,
        title,
        category,
        price,
        condition,
        description,
        tradeMethod,
        baseAddress,
        detailAddress,
        imageUrls,
        viewCount,
        favoriteCount,
        chatCount,
        createdAt,
        updatedAt,
        status,
      ];

  @override
  _i1.Table? getRelationTable(String relationField) {
    if (relationField == 'seller') {
      return seller;
    }
    return null;
  }
}

class ProductInclude extends _i1.IncludeObject {
  ProductInclude._({_i2.UserInclude? seller}) {
    _seller = seller;
  }

  _i2.UserInclude? _seller;

  @override
  Map<String, _i1.Include?> get includes => {'seller': _seller};

  @override
  _i1.Table<int?> get table => Product.t;
}

class ProductIncludeList extends _i1.IncludeList {
  ProductIncludeList._({
    _i1.WhereExpressionBuilder<ProductTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(Product.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => Product.t;
}

class ProductRepository {
  const ProductRepository._();

  final attachRow = const ProductAttachRowRepository._();

  /// Returns a list of [Product]s matching the given query parameters.
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
  Future<List<Product>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<ProductTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ProductTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ProductTable>? orderByList,
    _i1.Transaction? transaction,
    ProductInclude? include,
  }) async {
    return session.db.find<Product>(
      where: where?.call(Product.t),
      orderBy: orderBy?.call(Product.t),
      orderByList: orderByList?.call(Product.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      include: include,
    );
  }

  /// Returns the first matching [Product] matching the given query parameters.
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
  Future<Product?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<ProductTable>? where,
    int? offset,
    _i1.OrderByBuilder<ProductTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ProductTable>? orderByList,
    _i1.Transaction? transaction,
    ProductInclude? include,
  }) async {
    return session.db.findFirstRow<Product>(
      where: where?.call(Product.t),
      orderBy: orderBy?.call(Product.t),
      orderByList: orderByList?.call(Product.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      include: include,
    );
  }

  /// Finds a single [Product] by its [id] or null if no such row exists.
  Future<Product?> findById(
    _i1.Session session,
    int id, {
    _i1.Transaction? transaction,
    ProductInclude? include,
  }) async {
    return session.db.findById<Product>(
      id,
      transaction: transaction,
      include: include,
    );
  }

  /// Inserts all [Product]s in the list and returns the inserted rows.
  ///
  /// The returned [Product]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  Future<List<Product>> insert(
    _i1.Session session,
    List<Product> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<Product>(
      rows,
      transaction: transaction,
    );
  }

  /// Inserts a single [Product] and returns the inserted row.
  ///
  /// The returned [Product] will have its `id` field set.
  Future<Product> insertRow(
    _i1.Session session,
    Product row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<Product>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [Product]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<Product>> update(
    _i1.Session session,
    List<Product> rows, {
    _i1.ColumnSelections<ProductTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<Product>(
      rows,
      columns: columns?.call(Product.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Product]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<Product> updateRow(
    _i1.Session session,
    Product row, {
    _i1.ColumnSelections<ProductTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<Product>(
      row,
      columns: columns?.call(Product.t),
      transaction: transaction,
    );
  }

  /// Deletes all [Product]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<Product>> delete(
    _i1.Session session,
    List<Product> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<Product>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [Product].
  Future<Product> deleteRow(
    _i1.Session session,
    Product row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<Product>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<Product>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<ProductTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<Product>(
      where: where(Product.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<ProductTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<Product>(
      where: where?.call(Product.t),
      limit: limit,
      transaction: transaction,
    );
  }
}

class ProductAttachRowRepository {
  const ProductAttachRowRepository._();

  /// Creates a relation between the given [Product] and [User]
  /// by setting the [Product]'s foreign key `sellerId` to refer to the [User].
  Future<void> seller(
    _i1.Session session,
    Product product,
    _i2.User seller, {
    _i1.Transaction? transaction,
  }) async {
    if (product.id == null) {
      throw ArgumentError.notNull('product.id');
    }
    if (seller.id == null) {
      throw ArgumentError.notNull('seller.id');
    }

    var $product = product.copyWith(sellerId: seller.id);
    await session.db.updateRow<Product>(
      $product,
      columns: [Product.t.sellerId],
      transaction: transaction,
    );
  }
}
