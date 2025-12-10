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

/// 채팅 메시지 타입
enum MessageType implements _i1.SerializableModel {
  /// 텍스트 메시지
  text,

  /// 이미지 메시지
  image,

  /// 파일 메시지
  file,

  /// 시스템 메시지 (입장, 퇴장 등)
  system;

  static MessageType fromJson(int index) {
    switch (index) {
      case 0:
        return MessageType.text;
      case 1:
        return MessageType.image;
      case 2:
        return MessageType.file;
      case 3:
        return MessageType.system;
      default:
        throw ArgumentError(
            'Value "$index" cannot be converted to "MessageType"');
    }
  }

  @override
  int toJson() => index;

  @override
  String toString() => name;
}
