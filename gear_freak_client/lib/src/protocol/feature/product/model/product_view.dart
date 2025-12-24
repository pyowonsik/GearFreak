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

/// 상품 조회 정보
abstract class ProductView implements _i1.SerializableModel {
  ProductView._({
    this.id,
    required this.userId,
    this.user,
    required this.productId,
    this.product,
    this.viewedAt,
  });

  factory ProductView({
    int? id,
    required int userId,
    _i2.User? user,
    required int productId,
    _i3.Product? product,
    DateTime? viewedAt,
  }) = _ProductViewImpl;

  factory ProductView.fromJson(Map<String, dynamic> jsonSerialization) {
    return ProductView(
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
      viewedAt: jsonSerialization['viewedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['viewedAt']),
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

  /// 조회일
  DateTime? viewedAt;

  /// Returns a shallow copy of this [ProductView]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ProductView copyWith({
    int? id,
    int? userId,
    _i2.User? user,
    int? productId,
    _i3.Product? product,
    DateTime? viewedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'userId': userId,
      if (user != null) 'user': user?.toJson(),
      'productId': productId,
      if (product != null) 'product': product?.toJson(),
      if (viewedAt != null) 'viewedAt': viewedAt?.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ProductViewImpl extends ProductView {
  _ProductViewImpl({
    int? id,
    required int userId,
    _i2.User? user,
    required int productId,
    _i3.Product? product,
    DateTime? viewedAt,
  }) : super._(
          id: id,
          userId: userId,
          user: user,
          productId: productId,
          product: product,
          viewedAt: viewedAt,
        );

  /// Returns a shallow copy of this [ProductView]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ProductView copyWith({
    Object? id = _Undefined,
    int? userId,
    Object? user = _Undefined,
    int? productId,
    Object? product = _Undefined,
    Object? viewedAt = _Undefined,
  }) {
    return ProductView(
      id: id is int? ? id : this.id,
      userId: userId ?? this.userId,
      user: user is _i2.User? ? user : this.user?.copyWith(),
      productId: productId ?? this.productId,
      product: product is _i3.Product? ? product : this.product?.copyWith(),
      viewedAt: viewedAt is DateTime? ? viewedAt : this.viewedAt,
    );
  }
}
