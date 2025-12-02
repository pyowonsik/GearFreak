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
import '../../../../feature/product/model/product_status.dart' as _i2;

/// 상품 상태 변경 요청 DTO
abstract class UpdateProductStatusRequestDto
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  UpdateProductStatusRequestDto._({
    required this.productId,
    required this.status,
  });

  factory UpdateProductStatusRequestDto({
    required int productId,
    required _i2.ProductStatus status,
  }) = _UpdateProductStatusRequestDtoImpl;

  factory UpdateProductStatusRequestDto.fromJson(
      Map<String, dynamic> jsonSerialization) {
    return UpdateProductStatusRequestDto(
      productId: jsonSerialization['productId'] as int,
      status: _i2.ProductStatus.fromJson((jsonSerialization['status'] as int)),
    );
  }

  /// 상품 ID
  int productId;

  /// 판매 상태
  _i2.ProductStatus status;

  /// Returns a shallow copy of this [UpdateProductStatusRequestDto]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  UpdateProductStatusRequestDto copyWith({
    int? productId,
    _i2.ProductStatus? status,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'status': status.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      'productId': productId,
      'status': status.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _UpdateProductStatusRequestDtoImpl extends UpdateProductStatusRequestDto {
  _UpdateProductStatusRequestDtoImpl({
    required int productId,
    required _i2.ProductStatus status,
  }) : super._(
          productId: productId,
          status: status,
        );

  /// Returns a shallow copy of this [UpdateProductStatusRequestDto]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  UpdateProductStatusRequestDto copyWith({
    int? productId,
    _i2.ProductStatus? status,
  }) {
    return UpdateProductStatusRequestDto(
      productId: productId ?? this.productId,
      status: status ?? this.status,
    );
  }
}
