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
import 'common/model/pagination_dto.dart' as _i2;
import 'feature/product/model/dto/create_product_request.dto.dart' as _i3;
import 'feature/product/model/dto/paginated_products_response.dto.dart' as _i4;
import 'feature/product/model/dto/update_product_request.dto.dart' as _i5;
import 'feature/product/model/product.dart' as _i6;
import 'feature/product/model/product_category.dart' as _i7;
import 'feature/product/model/product_condition.dart' as _i8;
import 'feature/product/model/product_sort_by.dart' as _i9;
import 'feature/product/model/trade_method.dart' as _i10;
import 'feature/user/model/user.dart' as _i11;
import 'greeting.dart' as _i12;
import 'package:serverpod_auth_client/serverpod_auth_client.dart' as _i13;
export 'common/model/pagination_dto.dart';
export 'feature/product/model/dto/create_product_request.dto.dart';
export 'feature/product/model/dto/paginated_products_response.dto.dart';
export 'feature/product/model/dto/update_product_request.dto.dart';
export 'feature/product/model/product.dart';
export 'feature/product/model/product_category.dart';
export 'feature/product/model/product_condition.dart';
export 'feature/product/model/product_sort_by.dart';
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
    if (t == _i2.PaginationDto) {
      return _i2.PaginationDto.fromJson(data) as T;
    }
    if (t == _i3.CreateProductRequestDto) {
      return _i3.CreateProductRequestDto.fromJson(data) as T;
    }
    if (t == _i4.PaginatedProductsResponseDto) {
      return _i4.PaginatedProductsResponseDto.fromJson(data) as T;
    }
    if (t == _i5.UpdateProductRequestDto) {
      return _i5.UpdateProductRequestDto.fromJson(data) as T;
    }
    if (t == _i6.Product) {
      return _i6.Product.fromJson(data) as T;
    }
    if (t == _i7.ProductCategory) {
      return _i7.ProductCategory.fromJson(data) as T;
    }
    if (t == _i8.ProductCondition) {
      return _i8.ProductCondition.fromJson(data) as T;
    }
    if (t == _i9.ProductSortBy) {
      return _i9.ProductSortBy.fromJson(data) as T;
    }
    if (t == _i10.TradeMethod) {
      return _i10.TradeMethod.fromJson(data) as T;
    }
    if (t == _i11.User) {
      return _i11.User.fromJson(data) as T;
    }
    if (t == _i12.Greeting) {
      return _i12.Greeting.fromJson(data) as T;
    }
    if (t == _i1.getType<_i2.PaginationDto?>()) {
      return (data != null ? _i2.PaginationDto.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i3.CreateProductRequestDto?>()) {
      return (data != null ? _i3.CreateProductRequestDto.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i4.PaginatedProductsResponseDto?>()) {
      return (data != null
          ? _i4.PaginatedProductsResponseDto.fromJson(data)
          : null) as T;
    }
    if (t == _i1.getType<_i5.UpdateProductRequestDto?>()) {
      return (data != null ? _i5.UpdateProductRequestDto.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i6.Product?>()) {
      return (data != null ? _i6.Product.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i7.ProductCategory?>()) {
      return (data != null ? _i7.ProductCategory.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i8.ProductCondition?>()) {
      return (data != null ? _i8.ProductCondition.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i9.ProductSortBy?>()) {
      return (data != null ? _i9.ProductSortBy.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i10.TradeMethod?>()) {
      return (data != null ? _i10.TradeMethod.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i11.User?>()) {
      return (data != null ? _i11.User.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i12.Greeting?>()) {
      return (data != null ? _i12.Greeting.fromJson(data) : null) as T;
    }
    if (t == List<_i6.Product>) {
      return (data as List).map((e) => deserialize<_i6.Product>(e)).toList()
          as T;
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
      return _i13.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  @override
  String? getClassNameForObject(Object? data) {
    String? className = super.getClassNameForObject(data);
    if (className != null) return className;
    if (data is _i2.PaginationDto) {
      return 'PaginationDto';
    }
    if (data is _i3.CreateProductRequestDto) {
      return 'CreateProductRequestDto';
    }
    if (data is _i4.PaginatedProductsResponseDto) {
      return 'PaginatedProductsResponseDto';
    }
    if (data is _i5.UpdateProductRequestDto) {
      return 'UpdateProductRequestDto';
    }
    if (data is _i6.Product) {
      return 'Product';
    }
    if (data is _i7.ProductCategory) {
      return 'ProductCategory';
    }
    if (data is _i8.ProductCondition) {
      return 'ProductCondition';
    }
    if (data is _i9.ProductSortBy) {
      return 'ProductSortBy';
    }
    if (data is _i10.TradeMethod) {
      return 'TradeMethod';
    }
    if (data is _i11.User) {
      return 'User';
    }
    if (data is _i12.Greeting) {
      return 'Greeting';
    }
    className = _i13.Protocol().getClassNameForObject(data);
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
    if (dataClassName == 'PaginationDto') {
      return deserialize<_i2.PaginationDto>(data['data']);
    }
    if (dataClassName == 'CreateProductRequestDto') {
      return deserialize<_i3.CreateProductRequestDto>(data['data']);
    }
    if (dataClassName == 'PaginatedProductsResponseDto') {
      return deserialize<_i4.PaginatedProductsResponseDto>(data['data']);
    }
    if (dataClassName == 'UpdateProductRequestDto') {
      return deserialize<_i5.UpdateProductRequestDto>(data['data']);
    }
    if (dataClassName == 'Product') {
      return deserialize<_i6.Product>(data['data']);
    }
    if (dataClassName == 'ProductCategory') {
      return deserialize<_i7.ProductCategory>(data['data']);
    }
    if (dataClassName == 'ProductCondition') {
      return deserialize<_i8.ProductCondition>(data['data']);
    }
    if (dataClassName == 'ProductSortBy') {
      return deserialize<_i9.ProductSortBy>(data['data']);
    }
    if (dataClassName == 'TradeMethod') {
      return deserialize<_i10.TradeMethod>(data['data']);
    }
    if (dataClassName == 'User') {
      return deserialize<_i11.User>(data['data']);
    }
    if (dataClassName == 'Greeting') {
      return deserialize<_i12.Greeting>(data['data']);
    }
    if (dataClassName.startsWith('serverpod_auth.')) {
      data['className'] = dataClassName.substring(15);
      return _i13.Protocol().deserializeByClassName(data);
    }
    return super.deserializeByClassName(data);
  }
}
