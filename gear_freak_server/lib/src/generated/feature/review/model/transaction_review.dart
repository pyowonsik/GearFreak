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
import '../../../feature/review/model/review_type.dart' as _i2;

/// 거래 후기
abstract class TransactionReview
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  TransactionReview._({
    this.id,
    required this.productId,
    required this.chatRoomId,
    required this.reviewerId,
    required this.revieweeId,
    required this.rating,
    this.content,
    required this.reviewType,
    this.createdAt,
    this.updatedAt,
  });

  factory TransactionReview({
    int? id,
    required int productId,
    required int chatRoomId,
    required int reviewerId,
    required int revieweeId,
    required int rating,
    String? content,
    required _i2.ReviewType reviewType,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _TransactionReviewImpl;

  factory TransactionReview.fromJson(Map<String, dynamic> jsonSerialization) {
    return TransactionReview(
      id: jsonSerialization['id'] as int?,
      productId: jsonSerialization['productId'] as int,
      chatRoomId: jsonSerialization['chatRoomId'] as int,
      reviewerId: jsonSerialization['reviewerId'] as int,
      revieweeId: jsonSerialization['revieweeId'] as int,
      rating: jsonSerialization['rating'] as int,
      content: jsonSerialization['content'] as String?,
      reviewType:
          _i2.ReviewType.fromJson((jsonSerialization['reviewType'] as int)),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
    );
  }

  static final t = TransactionReviewTable();

  static const db = TransactionReviewRepository._();

  @override
  int? id;

  /// 상품 ID
  int productId;

  /// 채팅방 ID
  int chatRoomId;

  /// 리뷰 작성자 ID
  int reviewerId;

  /// 리뷰 대상자 ID
  int revieweeId;

  /// 평점 (1~5)
  int rating;

  /// 후기 내용
  String? content;

  /// 리뷰 타입
  _i2.ReviewType reviewType;

  /// 생성일
  DateTime? createdAt;

  /// 수정일
  DateTime? updatedAt;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [TransactionReview]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  TransactionReview copyWith({
    int? id,
    int? productId,
    int? chatRoomId,
    int? reviewerId,
    int? revieweeId,
    int? rating,
    String? content,
    _i2.ReviewType? reviewType,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'productId': productId,
      'chatRoomId': chatRoomId,
      'reviewerId': reviewerId,
      'revieweeId': revieweeId,
      'rating': rating,
      if (content != null) 'content': content,
      'reviewType': reviewType.toJson(),
      if (createdAt != null) 'createdAt': createdAt?.toJson(),
      if (updatedAt != null) 'updatedAt': updatedAt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      if (id != null) 'id': id,
      'productId': productId,
      'chatRoomId': chatRoomId,
      'reviewerId': reviewerId,
      'revieweeId': revieweeId,
      'rating': rating,
      if (content != null) 'content': content,
      'reviewType': reviewType.toJson(),
      if (createdAt != null) 'createdAt': createdAt?.toJson(),
      if (updatedAt != null) 'updatedAt': updatedAt?.toJson(),
    };
  }

  static TransactionReviewInclude include() {
    return TransactionReviewInclude._();
  }

  static TransactionReviewIncludeList includeList({
    _i1.WhereExpressionBuilder<TransactionReviewTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<TransactionReviewTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<TransactionReviewTable>? orderByList,
    TransactionReviewInclude? include,
  }) {
    return TransactionReviewIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(TransactionReview.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(TransactionReview.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _TransactionReviewImpl extends TransactionReview {
  _TransactionReviewImpl({
    int? id,
    required int productId,
    required int chatRoomId,
    required int reviewerId,
    required int revieweeId,
    required int rating,
    String? content,
    required _i2.ReviewType reviewType,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : super._(
          id: id,
          productId: productId,
          chatRoomId: chatRoomId,
          reviewerId: reviewerId,
          revieweeId: revieweeId,
          rating: rating,
          content: content,
          reviewType: reviewType,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

  /// Returns a shallow copy of this [TransactionReview]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  TransactionReview copyWith({
    Object? id = _Undefined,
    int? productId,
    int? chatRoomId,
    int? reviewerId,
    int? revieweeId,
    int? rating,
    Object? content = _Undefined,
    _i2.ReviewType? reviewType,
    Object? createdAt = _Undefined,
    Object? updatedAt = _Undefined,
  }) {
    return TransactionReview(
      id: id is int? ? id : this.id,
      productId: productId ?? this.productId,
      chatRoomId: chatRoomId ?? this.chatRoomId,
      reviewerId: reviewerId ?? this.reviewerId,
      revieweeId: revieweeId ?? this.revieweeId,
      rating: rating ?? this.rating,
      content: content is String? ? content : this.content,
      reviewType: reviewType ?? this.reviewType,
      createdAt: createdAt is DateTime? ? createdAt : this.createdAt,
      updatedAt: updatedAt is DateTime? ? updatedAt : this.updatedAt,
    );
  }
}

class TransactionReviewTable extends _i1.Table<int?> {
  TransactionReviewTable({super.tableRelation})
      : super(tableName: 'transaction_review') {
    productId = _i1.ColumnInt(
      'productId',
      this,
    );
    chatRoomId = _i1.ColumnInt(
      'chatRoomId',
      this,
    );
    reviewerId = _i1.ColumnInt(
      'reviewerId',
      this,
    );
    revieweeId = _i1.ColumnInt(
      'revieweeId',
      this,
    );
    rating = _i1.ColumnInt(
      'rating',
      this,
    );
    content = _i1.ColumnString(
      'content',
      this,
    );
    reviewType = _i1.ColumnEnum(
      'reviewType',
      this,
      _i1.EnumSerialization.byIndex,
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

  /// 상품 ID
  late final _i1.ColumnInt productId;

  /// 채팅방 ID
  late final _i1.ColumnInt chatRoomId;

  /// 리뷰 작성자 ID
  late final _i1.ColumnInt reviewerId;

  /// 리뷰 대상자 ID
  late final _i1.ColumnInt revieweeId;

  /// 평점 (1~5)
  late final _i1.ColumnInt rating;

  /// 후기 내용
  late final _i1.ColumnString content;

  /// 리뷰 타입
  late final _i1.ColumnEnum<_i2.ReviewType> reviewType;

  /// 생성일
  late final _i1.ColumnDateTime createdAt;

  /// 수정일
  late final _i1.ColumnDateTime updatedAt;

  @override
  List<_i1.Column> get columns => [
        id,
        productId,
        chatRoomId,
        reviewerId,
        revieweeId,
        rating,
        content,
        reviewType,
        createdAt,
        updatedAt,
      ];
}

class TransactionReviewInclude extends _i1.IncludeObject {
  TransactionReviewInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => TransactionReview.t;
}

class TransactionReviewIncludeList extends _i1.IncludeList {
  TransactionReviewIncludeList._({
    _i1.WhereExpressionBuilder<TransactionReviewTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(TransactionReview.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => TransactionReview.t;
}

class TransactionReviewRepository {
  const TransactionReviewRepository._();

  /// Returns a list of [TransactionReview]s matching the given query parameters.
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
  Future<List<TransactionReview>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<TransactionReviewTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<TransactionReviewTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<TransactionReviewTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.find<TransactionReview>(
      where: where?.call(TransactionReview.t),
      orderBy: orderBy?.call(TransactionReview.t),
      orderByList: orderByList?.call(TransactionReview.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Returns the first matching [TransactionReview] matching the given query parameters.
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
  Future<TransactionReview?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<TransactionReviewTable>? where,
    int? offset,
    _i1.OrderByBuilder<TransactionReviewTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<TransactionReviewTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.findFirstRow<TransactionReview>(
      where: where?.call(TransactionReview.t),
      orderBy: orderBy?.call(TransactionReview.t),
      orderByList: orderByList?.call(TransactionReview.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Finds a single [TransactionReview] by its [id] or null if no such row exists.
  Future<TransactionReview?> findById(
    _i1.Session session,
    int id, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.findById<TransactionReview>(
      id,
      transaction: transaction,
    );
  }

  /// Inserts all [TransactionReview]s in the list and returns the inserted rows.
  ///
  /// The returned [TransactionReview]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  Future<List<TransactionReview>> insert(
    _i1.Session session,
    List<TransactionReview> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<TransactionReview>(
      rows,
      transaction: transaction,
    );
  }

  /// Inserts a single [TransactionReview] and returns the inserted row.
  ///
  /// The returned [TransactionReview] will have its `id` field set.
  Future<TransactionReview> insertRow(
    _i1.Session session,
    TransactionReview row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<TransactionReview>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [TransactionReview]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<TransactionReview>> update(
    _i1.Session session,
    List<TransactionReview> rows, {
    _i1.ColumnSelections<TransactionReviewTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<TransactionReview>(
      rows,
      columns: columns?.call(TransactionReview.t),
      transaction: transaction,
    );
  }

  /// Updates a single [TransactionReview]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<TransactionReview> updateRow(
    _i1.Session session,
    TransactionReview row, {
    _i1.ColumnSelections<TransactionReviewTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<TransactionReview>(
      row,
      columns: columns?.call(TransactionReview.t),
      transaction: transaction,
    );
  }

  /// Deletes all [TransactionReview]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<TransactionReview>> delete(
    _i1.Session session,
    List<TransactionReview> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<TransactionReview>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [TransactionReview].
  Future<TransactionReview> deleteRow(
    _i1.Session session,
    TransactionReview row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<TransactionReview>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<TransactionReview>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<TransactionReviewTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<TransactionReview>(
      where: where(TransactionReview.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<TransactionReviewTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<TransactionReview>(
      where: where?.call(TransactionReview.t),
      limit: limit,
      transaction: transaction,
    );
  }
}
