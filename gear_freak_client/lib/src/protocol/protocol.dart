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
import 'feature/product/model/dto/create_product_request.dto.dart' as _i2;
import 'feature/product/model/dto/update_product_request.dto.dart' as _i3;
import 'feature/product/model/product.dart' as _i4;
import 'feature/product/model/product_category.dart' as _i5;
import 'feature/product/model/product_condition.dart' as _i6;
import 'feature/product/model/trade_method.dart' as _i7;
import 'feature/user/model/user.dart' as _i8;
import 'greeting.dart' as _i9;
import 'package:gear_freak_client/src/protocol/feature/product/model/product.dart'
    as _i10;
import 'package:serverpod_auth_client/serverpod_auth_client.dart' as _i11;
export 'feature/product/model/dto/create_product_request.dto.dart';
export 'feature/product/model/dto/update_product_request.dto.dart';
export 'feature/product/model/product.dart';
export 'feature/product/model/product_category.dart';
export 'feature/product/model/product_condition.dart';
export 'feature/product/model/trade_method.dart';
export 'feature/user/model/user.dart';
export 'greeting.dart';
export 'client.dart';

class Protocol extends _i1.SerializationManager {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._();

  @override
  T deserialize<T>(
    dynamic data, [
    Type? t,
  ]) {
    t ??= T;
    if (t == _i2.CreateProductRequestDto) {
      return _i2.CreateProductRequestDto.fromJson(data) as T;
    }
    if (t == _i3.UpdateProductRequestDto) {
      return _i3.UpdateProductRequestDto.fromJson(data) as T;
    }
    if (t == _i4.Product) {
      return _i4.Product.fromJson(data) as T;
    }
    if (t == _i5.ProductCategory) {
      return _i5.ProductCategory.fromJson(data) as T;
    }
    if (t == _i6.ProductCondition) {
      return _i6.ProductCondition.fromJson(data) as T;
    }
    if (t == _i7.TradeMethod) {
      return _i7.TradeMethod.fromJson(data) as T;
    }
    if (t == _i8.User) {
      return _i8.User.fromJson(data) as T;
    }
    if (t == _i9.Greeting) {
      return _i9.Greeting.fromJson(data) as T;
    }
    if (t == _i1.getType<_i2.CreateProductRequestDto?>()) {
      return (data != null ? _i2.CreateProductRequestDto.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i3.UpdateProductRequestDto?>()) {
      return (data != null ? _i3.UpdateProductRequestDto.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i4.Product?>()) {
      return (data != null ? _i4.Product.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i5.ProductCategory?>()) {
      return (data != null ? _i5.ProductCategory.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i6.ProductCondition?>()) {
      return (data != null ? _i6.ProductCondition.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i7.TradeMethod?>()) {
      return (data != null ? _i7.TradeMethod.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i8.User?>()) {
      return (data != null ? _i8.User.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i9.Greeting?>()) {
      return (data != null ? _i9.Greeting.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<List<String>?>()) {
      return (data != null
          ? (data as List).map((e) => deserialize<String>(e)).toList()
          : null) as T;
    }
    if (t == List<_i10.Product>) {
      return (data as List).map((e) => deserialize<_i10.Product>(e)).toList()
          as T;
    }
    if (t == List<String>) {
      return (data as List).map((e) => deserialize<String>(e)).toList() as T;
    }
    try {
      return _i11.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  @override
  String? getClassNameForObject(Object? data) {
    String? className = super.getClassNameForObject(data);
    if (className != null) return className;
    if (data is _i2.CreateProductRequestDto) {
      return 'CreateProductRequestDto';
    }
    if (data is _i3.UpdateProductRequestDto) {
      return 'UpdateProductRequestDto';
    }
    if (data is _i4.Product) {
      return 'Product';
    }
    if (data is _i5.ProductCategory) {
      return 'ProductCategory';
    }
    if (data is _i6.ProductCondition) {
      return 'ProductCondition';
    }
    if (data is _i7.TradeMethod) {
      return 'TradeMethod';
    }
    if (data is _i8.User) {
      return 'User';
    }
    if (data is _i9.Greeting) {
      return 'Greeting';
    }
    className = _i11.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod_auth.$className';
    }
    return null;
  }

  @override
  dynamic deserializeByClassName(Map<String, dynamic> data) {
    var dataClassName = data['className'];
    if (dataClassName is! String) {
      return super.deserializeByClassName(data);
    }
    if (dataClassName == 'CreateProductRequestDto') {
      return deserialize<_i2.CreateProductRequestDto>(data['data']);
    }
    if (dataClassName == 'UpdateProductRequestDto') {
      return deserialize<_i3.UpdateProductRequestDto>(data['data']);
    }
    if (dataClassName == 'Product') {
      return deserialize<_i4.Product>(data['data']);
    }
    if (dataClassName == 'ProductCategory') {
      return deserialize<_i5.ProductCategory>(data['data']);
    }
    if (dataClassName == 'ProductCondition') {
      return deserialize<_i6.ProductCondition>(data['data']);
    }
    if (dataClassName == 'TradeMethod') {
      return deserialize<_i7.TradeMethod>(data['data']);
    }
    if (dataClassName == 'User') {
      return deserialize<_i8.User>(data['data']);
    }
    if (dataClassName == 'Greeting') {
      return deserialize<_i9.Greeting>(data['data']);
    }
    if (dataClassName.startsWith('serverpod_auth.')) {
      data['className'] = dataClassName.substring(15);
      return _i11.Protocol().deserializeByClassName(data);
    }
    return super.deserializeByClassName(data);
  }
}
