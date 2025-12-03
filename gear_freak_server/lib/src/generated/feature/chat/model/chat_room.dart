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
import '../../../feature/chat/model/enum/chat_room_type.dart' as _i2;

/// 채팅방 정보
abstract class ChatRoom
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  ChatRoom._({
    this.id,
    required this.productId,
    this.title,
    required this.chatRoomType,
    required this.participantCount,
    this.lastActivityAt,
    this.createdAt,
    this.updatedAt,
  });

  factory ChatRoom({
    int? id,
    required int productId,
    String? title,
    required _i2.ChatRoomType chatRoomType,
    required int participantCount,
    DateTime? lastActivityAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _ChatRoomImpl;

  factory ChatRoom.fromJson(Map<String, dynamic> jsonSerialization) {
    return ChatRoom(
      id: jsonSerialization['id'] as int?,
      productId: jsonSerialization['productId'] as int,
      title: jsonSerialization['title'] as String?,
      chatRoomType:
          _i2.ChatRoomType.fromJson((jsonSerialization['chatRoomType'] as int)),
      participantCount: jsonSerialization['participantCount'] as int,
      lastActivityAt: jsonSerialization['lastActivityAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(
              jsonSerialization['lastActivityAt']),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
    );
  }

  static final t = ChatRoomTable();

  static const db = ChatRoomRepository._();

  @override
  int? id;

  /// 연결된 상품 ID
  int productId;

  /// 채팅방 제목
  String? title;

  /// 채팅방 타입 (1:1, 그룹)
  _i2.ChatRoomType chatRoomType;

  /// 참여자 수 (캐시된 값)
  int participantCount;

  /// 최근 활동 일시
  DateTime? lastActivityAt;

  /// 채팅방 생성일
  DateTime? createdAt;

  /// 수정일
  DateTime? updatedAt;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [ChatRoom]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ChatRoom copyWith({
    int? id,
    int? productId,
    String? title,
    _i2.ChatRoomType? chatRoomType,
    int? participantCount,
    DateTime? lastActivityAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'productId': productId,
      if (title != null) 'title': title,
      'chatRoomType': chatRoomType.toJson(),
      'participantCount': participantCount,
      if (lastActivityAt != null) 'lastActivityAt': lastActivityAt?.toJson(),
      if (createdAt != null) 'createdAt': createdAt?.toJson(),
      if (updatedAt != null) 'updatedAt': updatedAt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      if (id != null) 'id': id,
      'productId': productId,
      if (title != null) 'title': title,
      'chatRoomType': chatRoomType.toJson(),
      'participantCount': participantCount,
      if (lastActivityAt != null) 'lastActivityAt': lastActivityAt?.toJson(),
      if (createdAt != null) 'createdAt': createdAt?.toJson(),
      if (updatedAt != null) 'updatedAt': updatedAt?.toJson(),
    };
  }

  static ChatRoomInclude include() {
    return ChatRoomInclude._();
  }

  static ChatRoomIncludeList includeList({
    _i1.WhereExpressionBuilder<ChatRoomTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ChatRoomTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ChatRoomTable>? orderByList,
    ChatRoomInclude? include,
  }) {
    return ChatRoomIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ChatRoom.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(ChatRoom.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ChatRoomImpl extends ChatRoom {
  _ChatRoomImpl({
    int? id,
    required int productId,
    String? title,
    required _i2.ChatRoomType chatRoomType,
    required int participantCount,
    DateTime? lastActivityAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : super._(
          id: id,
          productId: productId,
          title: title,
          chatRoomType: chatRoomType,
          participantCount: participantCount,
          lastActivityAt: lastActivityAt,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

  /// Returns a shallow copy of this [ChatRoom]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ChatRoom copyWith({
    Object? id = _Undefined,
    int? productId,
    Object? title = _Undefined,
    _i2.ChatRoomType? chatRoomType,
    int? participantCount,
    Object? lastActivityAt = _Undefined,
    Object? createdAt = _Undefined,
    Object? updatedAt = _Undefined,
  }) {
    return ChatRoom(
      id: id is int? ? id : this.id,
      productId: productId ?? this.productId,
      title: title is String? ? title : this.title,
      chatRoomType: chatRoomType ?? this.chatRoomType,
      participantCount: participantCount ?? this.participantCount,
      lastActivityAt:
          lastActivityAt is DateTime? ? lastActivityAt : this.lastActivityAt,
      createdAt: createdAt is DateTime? ? createdAt : this.createdAt,
      updatedAt: updatedAt is DateTime? ? updatedAt : this.updatedAt,
    );
  }
}

class ChatRoomTable extends _i1.Table<int?> {
  ChatRoomTable({super.tableRelation}) : super(tableName: 'chat_room') {
    productId = _i1.ColumnInt(
      'productId',
      this,
    );
    title = _i1.ColumnString(
      'title',
      this,
    );
    chatRoomType = _i1.ColumnEnum(
      'chatRoomType',
      this,
      _i1.EnumSerialization.byIndex,
    );
    participantCount = _i1.ColumnInt(
      'participantCount',
      this,
    );
    lastActivityAt = _i1.ColumnDateTime(
      'lastActivityAt',
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

  /// 연결된 상품 ID
  late final _i1.ColumnInt productId;

  /// 채팅방 제목
  late final _i1.ColumnString title;

  /// 채팅방 타입 (1:1, 그룹)
  late final _i1.ColumnEnum<_i2.ChatRoomType> chatRoomType;

  /// 참여자 수 (캐시된 값)
  late final _i1.ColumnInt participantCount;

  /// 최근 활동 일시
  late final _i1.ColumnDateTime lastActivityAt;

  /// 채팅방 생성일
  late final _i1.ColumnDateTime createdAt;

  /// 수정일
  late final _i1.ColumnDateTime updatedAt;

  @override
  List<_i1.Column> get columns => [
        id,
        productId,
        title,
        chatRoomType,
        participantCount,
        lastActivityAt,
        createdAt,
        updatedAt,
      ];
}

class ChatRoomInclude extends _i1.IncludeObject {
  ChatRoomInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => ChatRoom.t;
}

class ChatRoomIncludeList extends _i1.IncludeList {
  ChatRoomIncludeList._({
    _i1.WhereExpressionBuilder<ChatRoomTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(ChatRoom.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => ChatRoom.t;
}

class ChatRoomRepository {
  const ChatRoomRepository._();

  /// Returns a list of [ChatRoom]s matching the given query parameters.
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
  Future<List<ChatRoom>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<ChatRoomTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ChatRoomTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ChatRoomTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.find<ChatRoom>(
      where: where?.call(ChatRoom.t),
      orderBy: orderBy?.call(ChatRoom.t),
      orderByList: orderByList?.call(ChatRoom.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Returns the first matching [ChatRoom] matching the given query parameters.
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
  Future<ChatRoom?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<ChatRoomTable>? where,
    int? offset,
    _i1.OrderByBuilder<ChatRoomTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ChatRoomTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.findFirstRow<ChatRoom>(
      where: where?.call(ChatRoom.t),
      orderBy: orderBy?.call(ChatRoom.t),
      orderByList: orderByList?.call(ChatRoom.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Finds a single [ChatRoom] by its [id] or null if no such row exists.
  Future<ChatRoom?> findById(
    _i1.Session session,
    int id, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.findById<ChatRoom>(
      id,
      transaction: transaction,
    );
  }

  /// Inserts all [ChatRoom]s in the list and returns the inserted rows.
  ///
  /// The returned [ChatRoom]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  Future<List<ChatRoom>> insert(
    _i1.Session session,
    List<ChatRoom> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<ChatRoom>(
      rows,
      transaction: transaction,
    );
  }

  /// Inserts a single [ChatRoom] and returns the inserted row.
  ///
  /// The returned [ChatRoom] will have its `id` field set.
  Future<ChatRoom> insertRow(
    _i1.Session session,
    ChatRoom row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<ChatRoom>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [ChatRoom]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<ChatRoom>> update(
    _i1.Session session,
    List<ChatRoom> rows, {
    _i1.ColumnSelections<ChatRoomTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<ChatRoom>(
      rows,
      columns: columns?.call(ChatRoom.t),
      transaction: transaction,
    );
  }

  /// Updates a single [ChatRoom]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<ChatRoom> updateRow(
    _i1.Session session,
    ChatRoom row, {
    _i1.ColumnSelections<ChatRoomTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<ChatRoom>(
      row,
      columns: columns?.call(ChatRoom.t),
      transaction: transaction,
    );
  }

  /// Deletes all [ChatRoom]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<ChatRoom>> delete(
    _i1.Session session,
    List<ChatRoom> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<ChatRoom>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [ChatRoom].
  Future<ChatRoom> deleteRow(
    _i1.Session session,
    ChatRoom row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<ChatRoom>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<ChatRoom>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<ChatRoomTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<ChatRoom>(
      where: where(ChatRoom.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<ChatRoomTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<ChatRoom>(
      where: where?.call(ChatRoom.t),
      limit: limit,
      transaction: transaction,
    );
  }
}
