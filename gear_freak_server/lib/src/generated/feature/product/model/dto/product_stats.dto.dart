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

/// 상품 통계 DTO
abstract class ProductStatsDto
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  ProductStatsDto._({
    required this.sellingCount,
    required this.soldCount,
    required this.favoriteCount,
    required this.reviewCount,
  });

  factory ProductStatsDto({
    required int sellingCount,
    required int soldCount,
    required int favoriteCount,
    required int reviewCount,
  }) = _ProductStatsDtoImpl;

  factory ProductStatsDto.fromJson(Map<String, dynamic> jsonSerialization) {
    return ProductStatsDto(
      sellingCount: jsonSerialization['sellingCount'] as int,
      soldCount: jsonSerialization['soldCount'] as int,
      favoriteCount: jsonSerialization['favoriteCount'] as int,
      reviewCount: jsonSerialization['reviewCount'] as int,
    );
  }

  /// 판매중 상품 개수
  int sellingCount;

  /// 거래완료 상품 개수
  int soldCount;

  /// 관심목록 상품 개수
  int favoriteCount;

  /// 후기 개수
  int reviewCount;

  /// Returns a shallow copy of this [ProductStatsDto]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ProductStatsDto copyWith({
    int? sellingCount,
    int? soldCount,
    int? favoriteCount,
    int? reviewCount,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      'sellingCount': sellingCount,
      'soldCount': soldCount,
      'favoriteCount': favoriteCount,
      'reviewCount': reviewCount,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      'sellingCount': sellingCount,
      'soldCount': soldCount,
      'favoriteCount': favoriteCount,
      'reviewCount': reviewCount,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _ProductStatsDtoImpl extends ProductStatsDto {
  _ProductStatsDtoImpl({
    required int sellingCount,
    required int soldCount,
    required int favoriteCount,
    required int reviewCount,
  }) : super._(
          sellingCount: sellingCount,
          soldCount: soldCount,
          favoriteCount: favoriteCount,
          reviewCount: reviewCount,
        );

  /// Returns a shallow copy of this [ProductStatsDto]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ProductStatsDto copyWith({
    int? sellingCount,
    int? soldCount,
    int? favoriteCount,
    int? reviewCount,
  }) {
    return ProductStatsDto(
      sellingCount: sellingCount ?? this.sellingCount,
      soldCount: soldCount ?? this.soldCount,
      favoriteCount: favoriteCount ?? this.favoriteCount,
      reviewCount: reviewCount ?? this.reviewCount,
    );
  }
}
