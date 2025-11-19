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
import '../../../feature/product/model/product.dart' as _i3;

/// 찜 정보
abstract class Favorite implements _i1.SerializableModel {
  Favorite._({
    this.id,
    required this.userId,
    this.user,
    required this.productId,
    this.product,
    this.createdAt,
  });

  factory Favorite({
    int? id,
    required int userId,
    _i2.User? user,
    required int productId,
    _i3.Product? product,
    DateTime? createdAt,
  }) = _FavoriteImpl;

  factory Favorite.fromJson(Map<String, dynamic> jsonSerialization) {
    return Favorite(
      id: jsonSerialization['id'] as int?,
      userId: jsonSerialization['userId'] as int,
      user: jsonSerialization['user'] == null
          ? null
          : _i2.User.fromJson(
              (jsonSerialization['user'] as Map<String, dynamic>)),
      productId: jsonSerialization['productId'] as int,
      product: jsonSerialization['product'] == null
          ? null
          : _i3.Product.fromJson(
              (jsonSerialization['product'] as Map<String, dynamic>)),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int userId;

  /// 사용자 (User와의 관계)
  _i2.User? user;

  int productId;

  /// 상품 (Product와의 관계)
  _i3.Product? product;

  /// 찜 생성일
  DateTime? createdAt;

  /// Returns a shallow copy of this [Favorite]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  Favorite copyWith({
    int? id,
    int? userId,
    _i2.User? user,
    int? productId,
    _i3.Product? product,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'userId': userId,
      if (user != null) 'user': user?.toJson(),
      'productId': productId,
      if (product != null) 'product': product?.toJson(),
      if (createdAt != null) 'createdAt': createdAt?.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _FavoriteImpl extends Favorite {
  _FavoriteImpl({
    int? id,
    required int userId,
    _i2.User? user,
    required int productId,
    _i3.Product? product,
    DateTime? createdAt,
  }) : super._(
          id: id,
          userId: userId,
          user: user,
          productId: productId,
          product: product,
          createdAt: createdAt,
        );

  /// Returns a shallow copy of this [Favorite]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  Favorite copyWith({
    Object? id = _Undefined,
    int? userId,
    Object? user = _Undefined,
    int? productId,
    Object? product = _Undefined,
    Object? createdAt = _Undefined,
  }) {
    return Favorite(
      id: id is int? ? id : this.id,
      userId: userId ?? this.userId,
      user: user is _i2.User? ? user : this.user?.copyWith(),
      productId: productId ?? this.productId,
      product: product is _i3.Product? ? product : this.product?.copyWith(),
      createdAt: createdAt is DateTime? ? createdAt : this.createdAt,
    );
  }
}
