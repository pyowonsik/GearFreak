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
import '../../../../common/model/pagination_dto.dart' as _i2;
import '../../../../feature/product/model/product.dart' as _i3;

/// 페이지네이션된 상품 목록 응답 DTO
abstract class PaginatedProductsResponseDto
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  PaginatedProductsResponseDto._({
    required this.pagination,
    required this.products,
  });

  factory PaginatedProductsResponseDto({
    required _i2.PaginationDto pagination,
    required List<_i3.Product> products,
  }) = _PaginatedProductsResponseDtoImpl;

  factory PaginatedProductsResponseDto.fromJson(
      Map<String, dynamic> jsonSerialization) {
    return PaginatedProductsResponseDto(
      pagination: _i2.PaginationDto.fromJson(
          (jsonSerialization['pagination'] as Map<String, dynamic>)),
      products: (jsonSerialization['products'] as List)
          .map((e) => _i3.Product.fromJson((e as Map<String, dynamic>)))
          .toList(),
    );
  }

  /// 페이지네이션 정보
  _i2.PaginationDto pagination;

  /// 상품 목록
  List<_i3.Product> products;

  /// Returns a shallow copy of this [PaginatedProductsResponseDto]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  PaginatedProductsResponseDto copyWith({
    _i2.PaginationDto? pagination,
    List<_i3.Product>? products,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      'pagination': pagination.toJson(),
      'products': products.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      'pagination': pagination.toJsonForProtocol(),
      'products': products.toJson(valueToJson: (v) => v.toJsonForProtocol()),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _PaginatedProductsResponseDtoImpl extends PaginatedProductsResponseDto {
  _PaginatedProductsResponseDtoImpl({
    required _i2.PaginationDto pagination,
    required List<_i3.Product> products,
  }) : super._(
          pagination: pagination,
          products: products,
        );

  /// Returns a shallow copy of this [PaginatedProductsResponseDto]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  PaginatedProductsResponseDto copyWith({
    _i2.PaginationDto? pagination,
    List<_i3.Product>? products,
  }) {
    return PaginatedProductsResponseDto(
      pagination: pagination ?? this.pagination.copyWith(),
      products: products ?? this.products.map((e0) => e0.copyWith()).toList(),
    );
  }
}
