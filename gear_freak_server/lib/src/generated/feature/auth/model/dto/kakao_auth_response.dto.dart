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

/// 카카오 인증 응답
abstract class KakaoAuthResponseDto
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  KakaoAuthResponseDto._({
    required this.success,
    this.userId,
    this.userIdentifier,
    this.userName,
    this.email,
    this.fullName,
    this.scopeNames,
    this.blocked,
    this.created,
    this.keyId,
    this.key,
    this.failReason,
  });

  factory KakaoAuthResponseDto({
    required bool success,
    int? userId,
    String? userIdentifier,
    String? userName,
    String? email,
    String? fullName,
    List<String>? scopeNames,
    bool? blocked,
    DateTime? created,
    int? keyId,
    String? key,
    String? failReason,
  }) = _KakaoAuthResponseDtoImpl;

  factory KakaoAuthResponseDto.fromJson(
      Map<String, dynamic> jsonSerialization) {
    return KakaoAuthResponseDto(
      success: jsonSerialization['success'] as bool,
      userId: jsonSerialization['userId'] as int?,
      userIdentifier: jsonSerialization['userIdentifier'] as String?,
      userName: jsonSerialization['userName'] as String?,
      email: jsonSerialization['email'] as String?,
      fullName: jsonSerialization['fullName'] as String?,
      scopeNames: (jsonSerialization['scopeNames'] as List?)
          ?.map((e) => e as String)
          .toList(),
      blocked: jsonSerialization['blocked'] as bool?,
      created: jsonSerialization['created'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['created']),
      keyId: jsonSerialization['keyId'] as int?,
      key: jsonSerialization['key'] as String?,
      failReason: jsonSerialization['failReason'] as String?,
    );
  }

  /// 인증 성공 여부
  bool success;

  /// 사용자 정보 ID
  int? userId;

  /// 사용자 식별자
  String? userIdentifier;

  /// 사용자 이름
  String? userName;

  /// 이메일
  String? email;

  /// 전체 이름
  String? fullName;

  /// 권한 범위
  List<String>? scopeNames;

  /// 차단 여부
  bool? blocked;

  /// 생성 시각
  DateTime? created;

  /// 인증 키 ID
  int? keyId;

  /// 인증 키 (원본)
  String? key;

  /// 실패 사유
  String? failReason;

  /// Returns a shallow copy of this [KakaoAuthResponseDto]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  KakaoAuthResponseDto copyWith({
    bool? success,
    int? userId,
    String? userIdentifier,
    String? userName,
    String? email,
    String? fullName,
    List<String>? scopeNames,
    bool? blocked,
    DateTime? created,
    int? keyId,
    String? key,
    String? failReason,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      if (userId != null) 'userId': userId,
      if (userIdentifier != null) 'userIdentifier': userIdentifier,
      if (userName != null) 'userName': userName,
      if (email != null) 'email': email,
      if (fullName != null) 'fullName': fullName,
      if (scopeNames != null) 'scopeNames': scopeNames?.toJson(),
      if (blocked != null) 'blocked': blocked,
      if (created != null) 'created': created?.toJson(),
      if (keyId != null) 'keyId': keyId,
      if (key != null) 'key': key,
      if (failReason != null) 'failReason': failReason,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      'success': success,
      if (userId != null) 'userId': userId,
      if (userIdentifier != null) 'userIdentifier': userIdentifier,
      if (userName != null) 'userName': userName,
      if (email != null) 'email': email,
      if (fullName != null) 'fullName': fullName,
      if (scopeNames != null) 'scopeNames': scopeNames?.toJson(),
      if (blocked != null) 'blocked': blocked,
      if (created != null) 'created': created?.toJson(),
      if (keyId != null) 'keyId': keyId,
      if (key != null) 'key': key,
      if (failReason != null) 'failReason': failReason,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _KakaoAuthResponseDtoImpl extends KakaoAuthResponseDto {
  _KakaoAuthResponseDtoImpl({
    required bool success,
    int? userId,
    String? userIdentifier,
    String? userName,
    String? email,
    String? fullName,
    List<String>? scopeNames,
    bool? blocked,
    DateTime? created,
    int? keyId,
    String? key,
    String? failReason,
  }) : super._(
          success: success,
          userId: userId,
          userIdentifier: userIdentifier,
          userName: userName,
          email: email,
          fullName: fullName,
          scopeNames: scopeNames,
          blocked: blocked,
          created: created,
          keyId: keyId,
          key: key,
          failReason: failReason,
        );

  /// Returns a shallow copy of this [KakaoAuthResponseDto]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  KakaoAuthResponseDto copyWith({
    bool? success,
    Object? userId = _Undefined,
    Object? userIdentifier = _Undefined,
    Object? userName = _Undefined,
    Object? email = _Undefined,
    Object? fullName = _Undefined,
    Object? scopeNames = _Undefined,
    Object? blocked = _Undefined,
    Object? created = _Undefined,
    Object? keyId = _Undefined,
    Object? key = _Undefined,
    Object? failReason = _Undefined,
  }) {
    return KakaoAuthResponseDto(
      success: success ?? this.success,
      userId: userId is int? ? userId : this.userId,
      userIdentifier:
          userIdentifier is String? ? userIdentifier : this.userIdentifier,
      userName: userName is String? ? userName : this.userName,
      email: email is String? ? email : this.email,
      fullName: fullName is String? ? fullName : this.fullName,
      scopeNames: scopeNames is List<String>?
          ? scopeNames
          : this.scopeNames?.map((e0) => e0).toList(),
      blocked: blocked is bool? ? blocked : this.blocked,
      created: created is DateTime? ? created : this.created,
      keyId: keyId is int? ? keyId : this.keyId,
      key: key is String? ? key : this.key,
      failReason: failReason is String? ? failReason : this.failReason,
    );
  }
}
