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

/// FCM 토큰 정보
abstract class FcmToken implements _i1.SerializableModel {
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

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
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
