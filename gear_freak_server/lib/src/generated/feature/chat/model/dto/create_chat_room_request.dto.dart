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

/// 채팅방 생성 요청
abstract class CreateChatRoomRequestDto
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  CreateChatRoomRequestDto._({
    required this.productId,
    this.targetUserId,
  });

  factory CreateChatRoomRequestDto({
    required int productId,
    int? targetUserId,
  }) = _CreateChatRoomRequestDtoImpl;

  factory CreateChatRoomRequestDto.fromJson(
      Map<String, dynamic> jsonSerialization) {
    return CreateChatRoomRequestDto(
      productId: jsonSerialization['productId'] as int,
      targetUserId: jsonSerialization['targetUserId'] as int?,
    );
  }

  /// 연결된 상품 ID
  int productId;

  /// 상대방 사용자 ID (1:1 채팅의 경우, 선택적)
  int? targetUserId;

  /// Returns a shallow copy of this [CreateChatRoomRequestDto]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  CreateChatRoomRequestDto copyWith({
    int? productId,
    int? targetUserId,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      if (targetUserId != null) 'targetUserId': targetUserId,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      'productId': productId,
      if (targetUserId != null) 'targetUserId': targetUserId,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CreateChatRoomRequestDtoImpl extends CreateChatRoomRequestDto {
  _CreateChatRoomRequestDtoImpl({
    required int productId,
    int? targetUserId,
  }) : super._(
          productId: productId,
          targetUserId: targetUserId,
        );

  /// Returns a shallow copy of this [CreateChatRoomRequestDto]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  CreateChatRoomRequestDto copyWith({
    int? productId,
    Object? targetUserId = _Undefined,
  }) {
    return CreateChatRoomRequestDto(
      productId: productId ?? this.productId,
      targetUserId: targetUserId is int? ? targetUserId : this.targetUserId,
    );
  }
}
