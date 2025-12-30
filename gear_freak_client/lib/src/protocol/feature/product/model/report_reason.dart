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

/// 상품 신고 사유
enum ReportReason implements _i1.SerializableModel {
  spam,
  inappropriate,
  fake,
  prohibited,
  duplicate,
  other;

  static ReportReason fromJson(int index) {
    switch (index) {
      case 0:
        return ReportReason.spam;
      case 1:
        return ReportReason.inappropriate;
      case 2:
        return ReportReason.fake;
      case 3:
        return ReportReason.prohibited;
      case 4:
        return ReportReason.duplicate;
      case 5:
        return ReportReason.other;
      default:
        throw ArgumentError(
            'Value "$index" cannot be converted to "ReportReason"');
    }
  }

  @override
  int toJson() => index;

  @override
  String toString() => name;
}
