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
import '../../../../feature/product/model/product_category.dart' as _i2;
import '../../../../feature/product/model/product_condition.dart' as _i3;
import '../../../../feature/product/model/trade_method.dart' as _i4;

/// 상품 생성 요청 DTO
abstract class CreateProductRequestDto implements _i1.SerializableModel {
  CreateProductRequestDto._({
    required this.title,
    required this.category,
    required this.price,
    required this.condition,
    required this.description,
    required this.tradeMethod,
    this.baseAddress,
    this.detailAddress,
    this.imageUrls,
  });

  factory CreateProductRequestDto({
    required String title,
    required _i2.ProductCategory category,
    required int price,
    required _i3.ProductCondition condition,
    required String description,
    required _i4.TradeMethod tradeMethod,
    String? baseAddress,
    String? detailAddress,
    List<String>? imageUrls,
  }) = _CreateProductRequestDtoImpl;

  factory CreateProductRequestDto.fromJson(
      Map<String, dynamic> jsonSerialization) {
    return CreateProductRequestDto(
      title: jsonSerialization['title'] as String,
      category:
          _i2.ProductCategory.fromJson((jsonSerialization['category'] as int)),
      price: jsonSerialization['price'] as int,
      condition: _i3.ProductCondition.fromJson(
          (jsonSerialization['condition'] as int)),
      description: jsonSerialization['description'] as String,
      tradeMethod:
          _i4.TradeMethod.fromJson((jsonSerialization['tradeMethod'] as int)),
      baseAddress: jsonSerialization['baseAddress'] as String?,
      detailAddress: jsonSerialization['detailAddress'] as String?,
      imageUrls: (jsonSerialization['imageUrls'] as List?)
          ?.map((e) => e as String)
          .toList(),
    );
  }

  /// 상품명
  String title;

  /// 카테고리
  _i2.ProductCategory category;

  /// 가격
  int price;

  /// 상품 상태
  _i3.ProductCondition condition;

  /// 상품 설명
  String description;

  /// 거래 방법
  _i4.TradeMethod tradeMethod;

  /// 기본 주소 (kpostal에서 검색한 주소)
  String? baseAddress;

  /// 상세 주소 (동/호수 등)
  String? detailAddress;

  /// 상품 이미지 URL 목록
  List<String>? imageUrls;

  /// Returns a shallow copy of this [CreateProductRequestDto]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  CreateProductRequestDto copyWith({
    String? title,
    _i2.ProductCategory? category,
    int? price,
    _i3.ProductCondition? condition,
    String? description,
    _i4.TradeMethod? tradeMethod,
    String? baseAddress,
    String? detailAddress,
    List<String>? imageUrls,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'category': category.toJson(),
      'price': price,
      'condition': condition.toJson(),
      'description': description,
      'tradeMethod': tradeMethod.toJson(),
      if (baseAddress != null) 'baseAddress': baseAddress,
      if (detailAddress != null) 'detailAddress': detailAddress,
      if (imageUrls != null) 'imageUrls': imageUrls?.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CreateProductRequestDtoImpl extends CreateProductRequestDto {
  _CreateProductRequestDtoImpl({
    required String title,
    required _i2.ProductCategory category,
    required int price,
    required _i3.ProductCondition condition,
    required String description,
    required _i4.TradeMethod tradeMethod,
    String? baseAddress,
    String? detailAddress,
    List<String>? imageUrls,
  }) : super._(
          title: title,
          category: category,
          price: price,
          condition: condition,
          description: description,
          tradeMethod: tradeMethod,
          baseAddress: baseAddress,
          detailAddress: detailAddress,
          imageUrls: imageUrls,
        );

  /// Returns a shallow copy of this [CreateProductRequestDto]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  CreateProductRequestDto copyWith({
    String? title,
    _i2.ProductCategory? category,
    int? price,
    _i3.ProductCondition? condition,
    String? description,
    _i4.TradeMethod? tradeMethod,
    Object? baseAddress = _Undefined,
    Object? detailAddress = _Undefined,
    Object? imageUrls = _Undefined,
  }) {
    return CreateProductRequestDto(
      title: title ?? this.title,
      category: category ?? this.category,
      price: price ?? this.price,
      condition: condition ?? this.condition,
      description: description ?? this.description,
      tradeMethod: tradeMethod ?? this.tradeMethod,
      baseAddress: baseAddress is String? ? baseAddress : this.baseAddress,
      detailAddress:
          detailAddress is String? ? detailAddress : this.detailAddress,
      imageUrls: imageUrls is List<String>?
          ? imageUrls
          : this.imageUrls?.map((e0) => e0).toList(),
    );
  }
}
