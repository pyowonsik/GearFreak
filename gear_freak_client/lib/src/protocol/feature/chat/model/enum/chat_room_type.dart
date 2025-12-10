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

/// 채팅방 타입
enum ChatRoomType implements _i1.SerializableModel {
  /// 1:1 채팅방 (개인 간 대화)
  direct,

  /// 그룹 채팅방 (다중 참여자)
  group;

  static ChatRoomType fromJson(int index) {
    switch (index) {
      case 0:
        return ChatRoomType.direct;
      case 1:
        return ChatRoomType.group;
      default:
        throw ArgumentError(
            'Value "$index" cannot be converted to "ChatRoomType"');
    }
  }

  @override
  int toJson() => index;

  @override
  String toString() => name;
}
