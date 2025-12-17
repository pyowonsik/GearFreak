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
import '../../../../feature/notification/model/dto/notification_response.dto.dart'
    as _i2;
import '../../../../common/model/pagination_dto.dart' as _i3;

/// 알림 목록 응답
abstract class NotificationListResponseDto
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  NotificationListResponseDto._({
    required this.notifications,
    required this.pagination,
    required this.unreadCount,
  });

  factory NotificationListResponseDto({
    required List<_i2.NotificationResponseDto> notifications,
    required _i3.PaginationDto pagination,
    required int unreadCount,
  }) = _NotificationListResponseDtoImpl;

  factory NotificationListResponseDto.fromJson(
      Map<String, dynamic> jsonSerialization) {
    return NotificationListResponseDto(
      notifications: (jsonSerialization['notifications'] as List)
          .map((e) =>
              _i2.NotificationResponseDto.fromJson((e as Map<String, dynamic>)))
          .toList(),
      pagination: _i3.PaginationDto.fromJson(
          (jsonSerialization['pagination'] as Map<String, dynamic>)),
      unreadCount: jsonSerialization['unreadCount'] as int,
    );
  }

  /// 알림 목록
  List<_i2.NotificationResponseDto> notifications;

  /// 페이지네이션 정보
  _i3.PaginationDto pagination;

  /// 읽지 않은 알림 개수
  int unreadCount;

  /// Returns a shallow copy of this [NotificationListResponseDto]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  NotificationListResponseDto copyWith({
    List<_i2.NotificationResponseDto>? notifications,
    _i3.PaginationDto? pagination,
    int? unreadCount,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      'notifications': notifications.toJson(valueToJson: (v) => v.toJson()),
      'pagination': pagination.toJson(),
      'unreadCount': unreadCount,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      'notifications':
          notifications.toJson(valueToJson: (v) => v.toJsonForProtocol()),
      'pagination': pagination.toJsonForProtocol(),
      'unreadCount': unreadCount,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _NotificationListResponseDtoImpl extends NotificationListResponseDto {
  _NotificationListResponseDtoImpl({
    required List<_i2.NotificationResponseDto> notifications,
    required _i3.PaginationDto pagination,
    required int unreadCount,
  }) : super._(
          notifications: notifications,
          pagination: pagination,
          unreadCount: unreadCount,
        );

  /// Returns a shallow copy of this [NotificationListResponseDto]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  NotificationListResponseDto copyWith({
    List<_i2.NotificationResponseDto>? notifications,
    _i3.PaginationDto? pagination,
    int? unreadCount,
  }) {
    return NotificationListResponseDto(
      notifications: notifications ??
          this.notifications.map((e0) => e0.copyWith()).toList(),
      pagination: pagination ?? this.pagination.copyWith(),
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}
