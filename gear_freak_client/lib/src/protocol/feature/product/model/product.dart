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
import '../../../feature/user/model/user.dart' as _i2;
import '../../../feature/product/model/product_category.dart' as _i3;
import '../../../feature/product/model/product_condition.dart' as _i4;
import '../../../feature/product/model/trade_method.dart' as _i5;

/// 상품 정보
abstract class Product implements _i1.SerializableModel {
  Product._({
    this.id,
    required this.sellerId,
    this.seller,
    required this.title,
    required this.category,
    required this.price,
    required this.condition,
    required this.description,
    required this.tradeMethod,
    this.baseAddress,
    this.detailAddress,
    this.imageUrls,
    this.viewCount,
    this.favoriteCount,
    this.chatCount,
    this.createdAt,
    this.updatedAt,
  });

  factory Product({
    int? id,
    required int sellerId,
    _i2.User? seller,
    required String title,
    required _i3.ProductCategory category,
    required int price,
    required _i4.ProductCondition condition,
    required String description,
    required _i5.TradeMethod tradeMethod,
    String? baseAddress,
    String? detailAddress,
    List<String>? imageUrls,
    int? viewCount,
    int? favoriteCount,
    int? chatCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _ProductImpl;

  factory Product.fromJson(Map<String, dynamic> jsonSerialization) {
    return Product(
      id: jsonSerialization['id'] as int?,
      sellerId: jsonSerialization['sellerId'] as int,
      seller: jsonSerialization['seller'] == null
          ? null
          : _i2.User.fromJson(
              (jsonSerialization['seller'] as Map<String, dynamic>)),
      title: jsonSerialization['title'] as String,
      category:
          _i3.ProductCategory.fromJson((jsonSerialization['category'] as int)),
      price: jsonSerialization['price'] as int,
      condition: _i4.ProductCondition.fromJson(
          (jsonSerialization['condition'] as int)),
      description: jsonSerialization['description'] as String,
      tradeMethod:
          _i5.TradeMethod.fromJson((jsonSerialization['tradeMethod'] as int)),
      baseAddress: jsonSerialization['baseAddress'] as String?,
      detailAddress: jsonSerialization['detailAddress'] as String?,
      imageUrls: (jsonSerialization['imageUrls'] as List?)
          ?.map((e) => e as String)
          .toList(),
      viewCount: jsonSerialization['viewCount'] as int?,
      favoriteCount: jsonSerialization['favoriteCount'] as int?,
      chatCount: jsonSerialization['chatCount'] as int?,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int sellerId;

  /// 판매자 (User와의 관계)
  _i2.User? seller;

  /// 상품명
  String title;

  /// 카테고리
  _i3.ProductCategory category;

  /// 가격
  int price;

  /// 상품 상태
  _i4.ProductCondition condition;

  /// 상품 설명
  String description;

  /// 거래 방법
  _i5.TradeMethod tradeMethod;

  /// 기본 주소 (kpostal에서 검색한 주소)
  String? baseAddress;

  /// 상세 주소 (동/호수 등)
  String? detailAddress;

  /// 상품 이미지 URL 목록
  List<String>? imageUrls;

  /// 조회수
  int? viewCount;

  /// 찜 개수
  int? favoriteCount;

  /// 채팅 개수
  int? chatCount;

  /// 상품 생성일
  DateTime? createdAt;

  /// 상품 수정일
  DateTime? updatedAt;

  /// Returns a shallow copy of this [Product]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  Product copyWith({
    int? id,
    int? sellerId,
    _i2.User? seller,
    String? title,
    _i3.ProductCategory? category,
    int? price,
    _i4.ProductCondition? condition,
    String? description,
    _i5.TradeMethod? tradeMethod,
    String? baseAddress,
    String? detailAddress,
    List<String>? imageUrls,
    int? viewCount,
    int? favoriteCount,
    int? chatCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'sellerId': sellerId,
      if (seller != null) 'seller': seller?.toJson(),
      'title': title,
      'category': category.toJson(),
      'price': price,
      'condition': condition.toJson(),
      'description': description,
      'tradeMethod': tradeMethod.toJson(),
      if (baseAddress != null) 'baseAddress': baseAddress,
      if (detailAddress != null) 'detailAddress': detailAddress,
      if (imageUrls != null) 'imageUrls': imageUrls?.toJson(),
      if (viewCount != null) 'viewCount': viewCount,
      if (favoriteCount != null) 'favoriteCount': favoriteCount,
      if (chatCount != null) 'chatCount': chatCount,
      if (createdAt != null) 'createdAt': createdAt?.toJson(),
      if (updatedAt != null) 'updatedAt': updatedAt?.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ProductImpl extends Product {
  _ProductImpl({
    int? id,
    required int sellerId,
    _i2.User? seller,
    required String title,
    required _i3.ProductCategory category,
    required int price,
    required _i4.ProductCondition condition,
    required String description,
    required _i5.TradeMethod tradeMethod,
    String? baseAddress,
    String? detailAddress,
    List<String>? imageUrls,
    int? viewCount,
    int? favoriteCount,
    int? chatCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : super._(
          id: id,
          sellerId: sellerId,
          seller: seller,
          title: title,
          category: category,
          price: price,
          condition: condition,
          description: description,
          tradeMethod: tradeMethod,
          baseAddress: baseAddress,
          detailAddress: detailAddress,
          imageUrls: imageUrls,
          viewCount: viewCount,
          favoriteCount: favoriteCount,
          chatCount: chatCount,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

  /// Returns a shallow copy of this [Product]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  Product copyWith({
    Object? id = _Undefined,
    int? sellerId,
    Object? seller = _Undefined,
    String? title,
    _i3.ProductCategory? category,
    int? price,
    _i4.ProductCondition? condition,
    String? description,
    _i5.TradeMethod? tradeMethod,
    Object? baseAddress = _Undefined,
    Object? detailAddress = _Undefined,
    Object? imageUrls = _Undefined,
    Object? viewCount = _Undefined,
    Object? favoriteCount = _Undefined,
    Object? chatCount = _Undefined,
    Object? createdAt = _Undefined,
    Object? updatedAt = _Undefined,
  }) {
    return Product(
      id: id is int? ? id : this.id,
      sellerId: sellerId ?? this.sellerId,
      seller: seller is _i2.User? ? seller : this.seller?.copyWith(),
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
      viewCount: viewCount is int? ? viewCount : this.viewCount,
      favoriteCount: favoriteCount is int? ? favoriteCount : this.favoriteCount,
      chatCount: chatCount is int? ? chatCount : this.chatCount,
      createdAt: createdAt is DateTime? ? createdAt : this.createdAt,
      updatedAt: updatedAt is DateTime? ? updatedAt : this.updatedAt,
    );
  }
}
