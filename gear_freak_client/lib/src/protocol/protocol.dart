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
import 'feature/product/model/product.dart' as _i2;
import 'feature/product/model/product_category.dart' as _i3;
import 'feature/product/model/product_condition.dart' as _i4;
import 'feature/product/model/trade_method.dart' as _i5;
import 'feature/user/model/user.dart' as _i6;
import 'greeting.dart' as _i7;
import 'package:serverpod_auth_client/serverpod_auth_client.dart' as _i8;
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
    if (t == _i2.Product) {
      return _i2.Product.fromJson(data) as T;
    }
    if (t == _i3.ProductCategory) {
      return _i3.ProductCategory.fromJson(data) as T;
    }
    if (t == _i4.ProductCondition) {
      return _i4.ProductCondition.fromJson(data) as T;
    }
    if (t == _i5.TradeMethod) {
      return _i5.TradeMethod.fromJson(data) as T;
    }
    if (t == _i6.User) {
      return _i6.User.fromJson(data) as T;
    }
    if (t == _i7.Greeting) {
      return _i7.Greeting.fromJson(data) as T;
    }
    if (t == _i1.getType<_i2.Product?>()) {
      return (data != null ? _i2.Product.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i3.ProductCategory?>()) {
      return (data != null ? _i3.ProductCategory.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i4.ProductCondition?>()) {
      return (data != null ? _i4.ProductCondition.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i5.TradeMethod?>()) {
      return (data != null ? _i5.TradeMethod.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i6.User?>()) {
      return (data != null ? _i6.User.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i7.Greeting?>()) {
      return (data != null ? _i7.Greeting.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<List<String>?>()) {
      return (data != null
          ? (data as List).map((e) => deserialize<String>(e)).toList()
          : null) as T;
    }
    if (t == List<String>) {
      return (data as List).map((e) => deserialize<String>(e)).toList() as T;
    }
    try {
      return _i8.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  @override
  String? getClassNameForObject(Object? data) {
    String? className = super.getClassNameForObject(data);
    if (className != null) return className;
    if (data is _i2.Product) {
      return 'Product';
    }
    if (data is _i3.ProductCategory) {
      return 'ProductCategory';
    }
    if (data is _i4.ProductCondition) {
      return 'ProductCondition';
    }
    if (data is _i5.TradeMethod) {
      return 'TradeMethod';
    }
    if (data is _i6.User) {
      return 'User';
    }
    if (data is _i7.Greeting) {
      return 'Greeting';
    }
    className = _i8.Protocol().getClassNameForObject(data);
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
    if (dataClassName == 'Product') {
      return deserialize<_i2.Product>(data['data']);
    }
    if (dataClassName == 'ProductCategory') {
      return deserialize<_i3.ProductCategory>(data['data']);
    }
    if (dataClassName == 'ProductCondition') {
      return deserialize<_i4.ProductCondition>(data['data']);
    }
    if (dataClassName == 'TradeMethod') {
      return deserialize<_i5.TradeMethod>(data['data']);
    }
    if (dataClassName == 'User') {
      return deserialize<_i6.User>(data['data']);
    }
    if (dataClassName == 'Greeting') {
      return deserialize<_i7.Greeting>(data['data']);
    }
    if (dataClassName.startsWith('serverpod_auth.')) {
      data['className'] = dataClassName.substring(15);
      return _i8.Protocol().deserializeByClassName(data);
    }
    return super.deserializeByClassName(data);
  }
}
