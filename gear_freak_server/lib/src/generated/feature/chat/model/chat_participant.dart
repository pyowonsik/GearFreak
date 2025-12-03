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

/// 채팅방 참여자 정보
abstract class ChatParticipant
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  ChatParticipant._({
    this.id,
    required this.chatRoomId,
    required this.userId,
    this.joinedAt,
    required this.isActive,
    this.leftAt,
    this.createdAt,
    this.updatedAt,
  });

  factory ChatParticipant({
    int? id,
    required int chatRoomId,
    required int userId,
    DateTime? joinedAt,
    required bool isActive,
    DateTime? leftAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _ChatParticipantImpl;

  factory ChatParticipant.fromJson(Map<String, dynamic> jsonSerialization) {
    return ChatParticipant(
      id: jsonSerialization['id'] as int?,
      chatRoomId: jsonSerialization['chatRoomId'] as int,
      userId: jsonSerialization['userId'] as int,
      joinedAt: jsonSerialization['joinedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['joinedAt']),
      isActive: jsonSerialization['isActive'] as bool,
      leftAt: jsonSerialization['leftAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['leftAt']),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
    );
  }

  static final t = ChatParticipantTable();

  static const db = ChatParticipantRepository._();

  @override
  int? id;

  /// 채팅방 ID
  int chatRoomId;

  /// 참여자 사용자 ID
  int userId;

  /// 참여 일시
  DateTime? joinedAt;

  /// 활성 상태 (퇴장 시 false)
  bool isActive;

  /// 참여 종료 일시
  DateTime? leftAt;

  /// 생성일
  DateTime? createdAt;

  /// 수정일
  DateTime? updatedAt;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [ChatParticipant]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ChatParticipant copyWith({
    int? id,
    int? chatRoomId,
    int? userId,
    DateTime? joinedAt,
    bool? isActive,
    DateTime? leftAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'chatRoomId': chatRoomId,
      'userId': userId,
      if (joinedAt != null) 'joinedAt': joinedAt?.toJson(),
      'isActive': isActive,
      if (leftAt != null) 'leftAt': leftAt?.toJson(),
      if (createdAt != null) 'createdAt': createdAt?.toJson(),
      if (updatedAt != null) 'updatedAt': updatedAt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      if (id != null) 'id': id,
      'chatRoomId': chatRoomId,
      'userId': userId,
      if (joinedAt != null) 'joinedAt': joinedAt?.toJson(),
      'isActive': isActive,
      if (leftAt != null) 'leftAt': leftAt?.toJson(),
      if (createdAt != null) 'createdAt': createdAt?.toJson(),
      if (updatedAt != null) 'updatedAt': updatedAt?.toJson(),
    };
  }

  static ChatParticipantInclude include() {
    return ChatParticipantInclude._();
  }

  static ChatParticipantIncludeList includeList({
    _i1.WhereExpressionBuilder<ChatParticipantTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ChatParticipantTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ChatParticipantTable>? orderByList,
    ChatParticipantInclude? include,
  }) {
    return ChatParticipantIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ChatParticipant.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(ChatParticipant.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ChatParticipantImpl extends ChatParticipant {
  _ChatParticipantImpl({
    int? id,
    required int chatRoomId,
    required int userId,
    DateTime? joinedAt,
    required bool isActive,
    DateTime? leftAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : super._(
          id: id,
          chatRoomId: chatRoomId,
          userId: userId,
          joinedAt: joinedAt,
          isActive: isActive,
          leftAt: leftAt,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

  /// Returns a shallow copy of this [ChatParticipant]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ChatParticipant copyWith({
    Object? id = _Undefined,
    int? chatRoomId,
    int? userId,
    Object? joinedAt = _Undefined,
    bool? isActive,
    Object? leftAt = _Undefined,
    Object? createdAt = _Undefined,
    Object? updatedAt = _Undefined,
  }) {
    return ChatParticipant(
      id: id is int? ? id : this.id,
      chatRoomId: chatRoomId ?? this.chatRoomId,
      userId: userId ?? this.userId,
      joinedAt: joinedAt is DateTime? ? joinedAt : this.joinedAt,
      isActive: isActive ?? this.isActive,
      leftAt: leftAt is DateTime? ? leftAt : this.leftAt,
      createdAt: createdAt is DateTime? ? createdAt : this.createdAt,
      updatedAt: updatedAt is DateTime? ? updatedAt : this.updatedAt,
    );
  }
}

class ChatParticipantTable extends _i1.Table<int?> {
  ChatParticipantTable({super.tableRelation})
      : super(tableName: 'chat_participant') {
    chatRoomId = _i1.ColumnInt(
      'chatRoomId',
      this,
    );
    userId = _i1.ColumnInt(
      'userId',
      this,
    );
    joinedAt = _i1.ColumnDateTime(
      'joinedAt',
      this,
    );
    isActive = _i1.ColumnBool(
      'isActive',
      this,
    );
    leftAt = _i1.ColumnDateTime(
      'leftAt',
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

  /// 채팅방 ID
  late final _i1.ColumnInt chatRoomId;

  /// 참여자 사용자 ID
  late final _i1.ColumnInt userId;

  /// 참여 일시
  late final _i1.ColumnDateTime joinedAt;

  /// 활성 상태 (퇴장 시 false)
  late final _i1.ColumnBool isActive;

  /// 참여 종료 일시
  late final _i1.ColumnDateTime leftAt;

  /// 생성일
  late final _i1.ColumnDateTime createdAt;

  /// 수정일
  late final _i1.ColumnDateTime updatedAt;

  @override
  List<_i1.Column> get columns => [
        id,
        chatRoomId,
        userId,
        joinedAt,
        isActive,
        leftAt,
        createdAt,
        updatedAt,
      ];
}

class ChatParticipantInclude extends _i1.IncludeObject {
  ChatParticipantInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => ChatParticipant.t;
}

class ChatParticipantIncludeList extends _i1.IncludeList {
  ChatParticipantIncludeList._({
    _i1.WhereExpressionBuilder<ChatParticipantTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(ChatParticipant.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => ChatParticipant.t;
}

class ChatParticipantRepository {
  const ChatParticipantRepository._();

  /// Returns a list of [ChatParticipant]s matching the given query parameters.
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
  Future<List<ChatParticipant>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<ChatParticipantTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ChatParticipantTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ChatParticipantTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.find<ChatParticipant>(
      where: where?.call(ChatParticipant.t),
      orderBy: orderBy?.call(ChatParticipant.t),
      orderByList: orderByList?.call(ChatParticipant.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Returns the first matching [ChatParticipant] matching the given query parameters.
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
  Future<ChatParticipant?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<ChatParticipantTable>? where,
    int? offset,
    _i1.OrderByBuilder<ChatParticipantTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ChatParticipantTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.findFirstRow<ChatParticipant>(
      where: where?.call(ChatParticipant.t),
      orderBy: orderBy?.call(ChatParticipant.t),
      orderByList: orderByList?.call(ChatParticipant.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Finds a single [ChatParticipant] by its [id] or null if no such row exists.
  Future<ChatParticipant?> findById(
    _i1.Session session,
    int id, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.findById<ChatParticipant>(
      id,
      transaction: transaction,
    );
  }

  /// Inserts all [ChatParticipant]s in the list and returns the inserted rows.
  ///
  /// The returned [ChatParticipant]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  Future<List<ChatParticipant>> insert(
    _i1.Session session,
    List<ChatParticipant> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<ChatParticipant>(
      rows,
      transaction: transaction,
    );
  }

  /// Inserts a single [ChatParticipant] and returns the inserted row.
  ///
  /// The returned [ChatParticipant] will have its `id` field set.
  Future<ChatParticipant> insertRow(
    _i1.Session session,
    ChatParticipant row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<ChatParticipant>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [ChatParticipant]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<ChatParticipant>> update(
    _i1.Session session,
    List<ChatParticipant> rows, {
    _i1.ColumnSelections<ChatParticipantTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<ChatParticipant>(
      rows,
      columns: columns?.call(ChatParticipant.t),
      transaction: transaction,
    );
  }

  /// Updates a single [ChatParticipant]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<ChatParticipant> updateRow(
    _i1.Session session,
    ChatParticipant row, {
    _i1.ColumnSelections<ChatParticipantTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<ChatParticipant>(
      row,
      columns: columns?.call(ChatParticipant.t),
      transaction: transaction,
    );
  }

  /// Deletes all [ChatParticipant]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<ChatParticipant>> delete(
    _i1.Session session,
    List<ChatParticipant> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<ChatParticipant>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [ChatParticipant].
  Future<ChatParticipant> deleteRow(
    _i1.Session session,
    ChatParticipant row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<ChatParticipant>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<ChatParticipant>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<ChatParticipantTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<ChatParticipant>(
      where: where(ChatParticipant.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<ChatParticipantTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<ChatParticipant>(
      where: where?.call(ChatParticipant.t),
      limit: limit,
      transaction: transaction,
    );
  }
}
