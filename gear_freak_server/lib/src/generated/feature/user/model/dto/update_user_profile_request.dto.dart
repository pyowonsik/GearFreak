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

/// 사용자 프로필 수정 요청 DTO
abstract class UpdateUserProfileRequestDto
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  UpdateUserProfileRequestDto._({
    this.nickname,
    this.profileImageUrl,
  });

  factory UpdateUserProfileRequestDto({
    String? nickname,
    String? profileImageUrl,
  }) = _UpdateUserProfileRequestDtoImpl;

  factory UpdateUserProfileRequestDto.fromJson(
      Map<String, dynamic> jsonSerialization) {
    return UpdateUserProfileRequestDto(
      nickname: jsonSerialization['nickname'] as String?,
      profileImageUrl: jsonSerialization['profileImageUrl'] as String?,
    );
  }

  /// 닉네임
  String? nickname;

  /// 프로필 이미지 URL (temp/profile/{userId}/{file} 또는 profile/{userId}/{file})
  String? profileImageUrl;

  /// Returns a shallow copy of this [UpdateUserProfileRequestDto]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  UpdateUserProfileRequestDto copyWith({
    String? nickname,
    String? profileImageUrl,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      if (nickname != null) 'nickname': nickname,
      if (profileImageUrl != null) 'profileImageUrl': profileImageUrl,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      if (nickname != null) 'nickname': nickname,
      if (profileImageUrl != null) 'profileImageUrl': profileImageUrl,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _UpdateUserProfileRequestDtoImpl extends UpdateUserProfileRequestDto {
  _UpdateUserProfileRequestDtoImpl({
    String? nickname,
    String? profileImageUrl,
  }) : super._(
          nickname: nickname,
          profileImageUrl: profileImageUrl,
        );

  /// Returns a shallow copy of this [UpdateUserProfileRequestDto]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  UpdateUserProfileRequestDto copyWith({
    Object? nickname = _Undefined,
    Object? profileImageUrl = _Undefined,
  }) {
    return UpdateUserProfileRequestDto(
      nickname: nickname is String? ? nickname : this.nickname,
      profileImageUrl:
          profileImageUrl is String? ? profileImageUrl : this.profileImageUrl,
    );
  }
}
