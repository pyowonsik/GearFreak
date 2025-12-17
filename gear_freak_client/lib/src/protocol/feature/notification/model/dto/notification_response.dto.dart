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
import '../../../../feature/notification/model/notification_type.dart' as _i2;

/// 알림 응답
abstract class NotificationResponseDto implements _i1.SerializableModel {
  NotificationResponseDto._({
    required this.id,
    required this.notificationType,
    required this.title,
    required this.body,
    this.data,
    required this.isRead,
    this.readAt,
    this.createdAt,
  });

  factory NotificationResponseDto({
    required int id,
    required _i2.NotificationType notificationType,
    required String title,
    required String body,
    Map<String, String>? data,
    required bool isRead,
    DateTime? readAt,
    DateTime? createdAt,
  }) = _NotificationResponseDtoImpl;

  factory NotificationResponseDto.fromJson(
      Map<String, dynamic> jsonSerialization) {
    return NotificationResponseDto(
      id: jsonSerialization['id'] as int,
      notificationType: _i2.NotificationType.fromJson(
          (jsonSerialization['notificationType'] as int)),
      title: jsonSerialization['title'] as String,
      body: jsonSerialization['body'] as String,
      data: (jsonSerialization['data'] as Map?)?.map((k, v) => MapEntry(
            k as String,
            v as String,
          )),
      isRead: jsonSerialization['isRead'] as bool,
      readAt: jsonSerialization['readAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['readAt']),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  /// 알림 ID
  int id;

  /// 알림 타입
  _i2.NotificationType notificationType;

  /// 알림 제목
  String title;

  /// 알림 본문
  String body;

  /// 알림 데이터 (JSON 파싱된 Map)
  Map<String, String>? data;

  /// 읽음 여부
  bool isRead;

  /// 읽은 시간
  DateTime? readAt;

  /// 생성일
  DateTime? createdAt;

  /// Returns a shallow copy of this [NotificationResponseDto]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  NotificationResponseDto copyWith({
    int? id,
    _i2.NotificationType? notificationType,
    String? title,
    String? body,
    Map<String, String>? data,
    bool? isRead,
    DateTime? readAt,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'notificationType': notificationType.toJson(),
      'title': title,
      'body': body,
      if (data != null) 'data': data?.toJson(),
      'isRead': isRead,
      if (readAt != null) 'readAt': readAt?.toJson(),
      if (createdAt != null) 'createdAt': createdAt?.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _NotificationResponseDtoImpl extends NotificationResponseDto {
  _NotificationResponseDtoImpl({
    required int id,
    required _i2.NotificationType notificationType,
    required String title,
    required String body,
    Map<String, String>? data,
    required bool isRead,
    DateTime? readAt,
    DateTime? createdAt,
  }) : super._(
          id: id,
          notificationType: notificationType,
          title: title,
          body: body,
          data: data,
          isRead: isRead,
          readAt: readAt,
          createdAt: createdAt,
        );

  /// Returns a shallow copy of this [NotificationResponseDto]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  NotificationResponseDto copyWith({
    int? id,
    _i2.NotificationType? notificationType,
    String? title,
    String? body,
    Object? data = _Undefined,
    bool? isRead,
    Object? readAt = _Undefined,
    Object? createdAt = _Undefined,
  }) {
    return NotificationResponseDto(
      id: id ?? this.id,
      notificationType: notificationType ?? this.notificationType,
      title: title ?? this.title,
      body: body ?? this.body,
      data: data is Map<String, String>?
          ? data
          : this.data?.map((
                key0,
                value0,
              ) =>
                  MapEntry(
                    key0,
                    value0,
                  )),
      isRead: isRead ?? this.isRead,
      readAt: readAt is DateTime? ? readAt : this.readAt,
      createdAt: createdAt is DateTime? ? createdAt : this.createdAt,
    );
  }
}
