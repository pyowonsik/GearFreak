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
import '../../../feature/notification/model/notification_type.dart' as _i2;

/// 알림 정보
abstract class Notification implements _i1.SerializableModel {
  Notification._({
    this.id,
    required this.userId,
    required this.notificationType,
    required this.title,
    required this.body,
    this.data,
    required this.isRead,
    this.readAt,
    this.createdAt,
    this.updatedAt,
  });

  factory Notification({
    int? id,
    required int userId,
    required _i2.NotificationType notificationType,
    required String title,
    required String body,
    String? data,
    required bool isRead,
    DateTime? readAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _NotificationImpl;

  factory Notification.fromJson(Map<String, dynamic> jsonSerialization) {
    return Notification(
      id: jsonSerialization['id'] as int?,
      userId: jsonSerialization['userId'] as int,
      notificationType: _i2.NotificationType.fromJson(
          (jsonSerialization['notificationType'] as int)),
      title: jsonSerialization['title'] as String,
      body: jsonSerialization['body'] as String,
      data: jsonSerialization['data'] as String?,
      isRead: jsonSerialization['isRead'] as bool,
      readAt: jsonSerialization['readAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['readAt']),
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

  /// 수신자 사용자 ID
  int userId;

  /// 알림 타입
  _i2.NotificationType notificationType;

  /// 알림 제목
  String title;

  /// 알림 본문
  String body;

  /// 알림 데이터 (JSON 형태로 딥링크 정보 저장)
  String? data;

  /// 알림 데이터 (JSON 형태로 딥링크 정보 저장)
  /// 읽음 여부
  bool isRead;

  /// 읽은 시간
  DateTime? readAt;

  /// 생성일
  DateTime? createdAt;

  /// 수정일
  DateTime? updatedAt;

  /// Returns a shallow copy of this [Notification]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  Notification copyWith({
    int? id,
    int? userId,
    _i2.NotificationType? notificationType,
    String? title,
    String? body,
    String? data,
    bool? isRead,
    DateTime? readAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'userId': userId,
      'notificationType': notificationType.toJson(),
      'title': title,
      'body': body,
      if (data != null) 'data': data,
      'isRead': isRead,
      if (readAt != null) 'readAt': readAt?.toJson(),
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

class _NotificationImpl extends Notification {
  _NotificationImpl({
    int? id,
    required int userId,
    required _i2.NotificationType notificationType,
    required String title,
    required String body,
    String? data,
    required bool isRead,
    DateTime? readAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : super._(
          id: id,
          userId: userId,
          notificationType: notificationType,
          title: title,
          body: body,
          data: data,
          isRead: isRead,
          readAt: readAt,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

  /// Returns a shallow copy of this [Notification]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  Notification copyWith({
    Object? id = _Undefined,
    int? userId,
    _i2.NotificationType? notificationType,
    String? title,
    String? body,
    Object? data = _Undefined,
    bool? isRead,
    Object? readAt = _Undefined,
    Object? createdAt = _Undefined,
    Object? updatedAt = _Undefined,
  }) {
    return Notification(
      id: id is int? ? id : this.id,
      userId: userId ?? this.userId,
      notificationType: notificationType ?? this.notificationType,
      title: title ?? this.title,
      body: body ?? this.body,
      data: data is String? ? data : this.data,
      isRead: isRead ?? this.isRead,
      readAt: readAt is DateTime? ? readAt : this.readAt,
      createdAt: createdAt is DateTime? ? createdAt : this.createdAt,
      updatedAt: updatedAt is DateTime? ? updatedAt : this.updatedAt,
    );
  }
}
