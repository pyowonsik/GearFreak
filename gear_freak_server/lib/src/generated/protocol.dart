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
import 'package:serverpod/protocol.dart' as _i2;
import 'package:serverpod_auth_server/serverpod_auth_server.dart' as _i3;
import 'common/model/pagination_dto.dart' as _i4;
import 'common/s3/model/dto/generate_presigned_upload_url_request.dto.dart'
    as _i5;
import 'common/s3/model/dto/generate_presigned_upload_url_response.dto.dart'
    as _i6;
import 'feature/product/model/dto/create_product_request.dto.dart' as _i7;
import 'feature/product/model/dto/paginated_products_response.dto.dart' as _i8;
import 'feature/product/model/dto/product_stats.dto.dart' as _i9;
import 'feature/product/model/dto/update_product_request.dto.dart' as _i10;
import 'feature/product/model/dto/update_product_status_request.dto.dart'
    as _i11;
import 'feature/product/model/favorite.dart' as _i12;
import 'feature/product/model/product.dart' as _i13;
import 'feature/product/model/product_category.dart' as _i14;
import 'feature/product/model/product_condition.dart' as _i15;
import 'feature/product/model/product_sort_by.dart' as _i16;
import 'feature/product/model/product_status.dart' as _i17;
import 'feature/product/model/trade_method.dart' as _i18;
import 'feature/user/model/dto/update_user_profile_request.dto.dart' as _i19;
import 'feature/user/model/user.dart' as _i20;
import 'greeting.dart' as _i21;
export 'common/model/pagination_dto.dart';
export 'common/s3/model/dto/generate_presigned_upload_url_request.dto.dart';
export 'common/s3/model/dto/generate_presigned_upload_url_response.dto.dart';
export 'feature/product/model/dto/create_product_request.dto.dart';
export 'feature/product/model/dto/paginated_products_response.dto.dart';
export 'feature/product/model/dto/product_stats.dto.dart';
export 'feature/product/model/dto/update_product_request.dto.dart';
export 'feature/product/model/dto/update_product_status_request.dto.dart';
export 'feature/product/model/favorite.dart';
export 'feature/product/model/product.dart';
export 'feature/product/model/product_category.dart';
export 'feature/product/model/product_condition.dart';
export 'feature/product/model/product_sort_by.dart';
export 'feature/product/model/product_status.dart';
export 'feature/product/model/trade_method.dart';
export 'feature/user/model/dto/update_user_profile_request.dto.dart';
export 'feature/user/model/user.dart';
export 'greeting.dart';

class Protocol extends _i1.SerializationManagerServer {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._();

  static final List<_i2.TableDefinition> targetTableDefinitions = [
    _i2.TableDefinition(
      name: 'favorite',
      dartName: 'Favorite',
      schema: 'public',
      module: 'gear_freak',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'nextval(\'favorite_id_seq\'::regclass)',
        ),
        _i2.ColumnDefinition(
          name: 'userId',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _i2.ColumnDefinition(
          name: 'productId',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _i2.ColumnDefinition(
          name: 'createdAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
      ],
      foreignKeys: [
        _i2.ForeignKeyDefinition(
          constraintName: 'favorite_fk_0',
          columns: ['userId'],
          referenceTable: 'user',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _i2.ForeignKeyAction.noAction,
          onDelete: _i2.ForeignKeyAction.noAction,
          matchType: null,
        ),
        _i2.ForeignKeyDefinition(
          constraintName: 'favorite_fk_1',
          columns: ['productId'],
          referenceTable: 'product',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _i2.ForeignKeyAction.noAction,
          onDelete: _i2.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'favorite_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            )
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
        _i2.IndexDefinition(
          indexName: 'user_product_unique_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'userId',
            ),
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'productId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _i2.TableDefinition(
      name: 'product',
      dartName: 'Product',
      schema: 'public',
      module: 'gear_freak',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'nextval(\'product_id_seq\'::regclass)',
        ),
        _i2.ColumnDefinition(
          name: 'sellerId',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _i2.ColumnDefinition(
          name: 'title',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'category',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'protocol:ProductCategory',
        ),
        _i2.ColumnDefinition(
          name: 'price',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _i2.ColumnDefinition(
          name: 'condition',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'protocol:ProductCondition',
        ),
        _i2.ColumnDefinition(
          name: 'description',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'tradeMethod',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'protocol:TradeMethod',
        ),
        _i2.ColumnDefinition(
          name: 'baseAddress',
          columnType: _i2.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _i2.ColumnDefinition(
          name: 'detailAddress',
          columnType: _i2.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _i2.ColumnDefinition(
          name: 'imageUrls',
          columnType: _i2.ColumnType.json,
          isNullable: true,
          dartType: 'List<String>?',
        ),
        _i2.ColumnDefinition(
          name: 'viewCount',
          columnType: _i2.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _i2.ColumnDefinition(
          name: 'favoriteCount',
          columnType: _i2.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _i2.ColumnDefinition(
          name: 'chatCount',
          columnType: _i2.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _i2.ColumnDefinition(
          name: 'createdAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _i2.ColumnDefinition(
          name: 'updatedAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _i2.ColumnDefinition(
          name: 'status',
          columnType: _i2.ColumnType.bigint,
          isNullable: true,
          dartType: 'protocol:ProductStatus?',
        ),
      ],
      foreignKeys: [
        _i2.ForeignKeyDefinition(
          constraintName: 'product_fk_0',
          columns: ['sellerId'],
          referenceTable: 'user',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _i2.ForeignKeyAction.noAction,
          onDelete: _i2.ForeignKeyAction.noAction,
          matchType: null,
        )
      ],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'product_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            )
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
        _i2.IndexDefinition(
          indexName: 'seller_id_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'sellerId',
            )
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _i2.IndexDefinition(
          indexName: 'category_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'category',
            )
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _i2.IndexDefinition(
          indexName: 'created_at_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'createdAt',
            )
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _i2.TableDefinition(
      name: 'user',
      dartName: 'User',
      schema: 'public',
      module: 'gear_freak',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'nextval(\'user_id_seq\'::regclass)',
        ),
        _i2.ColumnDefinition(
          name: 'userInfoId',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _i2.ColumnDefinition(
          name: 'nickname',
          columnType: _i2.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _i2.ColumnDefinition(
          name: 'profileImageUrl',
          columnType: _i2.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _i2.ColumnDefinition(
          name: 'bio',
          columnType: _i2.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _i2.ColumnDefinition(
          name: 'withdrawalDate',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _i2.ColumnDefinition(
          name: 'blockedReason',
          columnType: _i2.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _i2.ColumnDefinition(
          name: 'blockedAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _i2.ColumnDefinition(
          name: 'lastLoginAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _i2.ColumnDefinition(
          name: 'createdAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
      ],
      foreignKeys: [
        _i2.ForeignKeyDefinition(
          constraintName: 'user_fk_0',
          columns: ['userInfoId'],
          referenceTable: 'serverpod_user_info',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _i2.ForeignKeyAction.noAction,
          onDelete: _i2.ForeignKeyAction.noAction,
          matchType: null,
        )
      ],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'user_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            )
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
        _i2.IndexDefinition(
          indexName: 'user_info_id_unique_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'userInfoId',
            )
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    ..._i3.Protocol.targetTableDefinitions,
    ..._i2.Protocol.targetTableDefinitions,
  ];

  @override
  T deserialize<T>(
    dynamic data, [
    Type? t,
  ]) {
    t ??= T;
    if (t == _i4.PaginationDto) {
      return _i4.PaginationDto.fromJson(data) as T;
    }
    if (t == _i5.GeneratePresignedUploadUrlRequestDto) {
      return _i5.GeneratePresignedUploadUrlRequestDto.fromJson(data) as T;
    }
    if (t == _i6.GeneratePresignedUploadUrlResponseDto) {
      return _i6.GeneratePresignedUploadUrlResponseDto.fromJson(data) as T;
    }
    if (t == _i7.CreateProductRequestDto) {
      return _i7.CreateProductRequestDto.fromJson(data) as T;
    }
    if (t == _i8.PaginatedProductsResponseDto) {
      return _i8.PaginatedProductsResponseDto.fromJson(data) as T;
    }
    if (t == _i9.ProductStatsDto) {
      return _i9.ProductStatsDto.fromJson(data) as T;
    }
    if (t == _i10.UpdateProductRequestDto) {
      return _i10.UpdateProductRequestDto.fromJson(data) as T;
    }
    if (t == _i11.UpdateProductStatusRequestDto) {
      return _i11.UpdateProductStatusRequestDto.fromJson(data) as T;
    }
    if (t == _i12.Favorite) {
      return _i12.Favorite.fromJson(data) as T;
    }
    if (t == _i13.Product) {
      return _i13.Product.fromJson(data) as T;
    }
    if (t == _i14.ProductCategory) {
      return _i14.ProductCategory.fromJson(data) as T;
    }
    if (t == _i15.ProductCondition) {
      return _i15.ProductCondition.fromJson(data) as T;
    }
    if (t == _i16.ProductSortBy) {
      return _i16.ProductSortBy.fromJson(data) as T;
    }
    if (t == _i17.ProductStatus) {
      return _i17.ProductStatus.fromJson(data) as T;
    }
    if (t == _i18.TradeMethod) {
      return _i18.TradeMethod.fromJson(data) as T;
    }
    if (t == _i19.UpdateUserProfileRequestDto) {
      return _i19.UpdateUserProfileRequestDto.fromJson(data) as T;
    }
    if (t == _i20.User) {
      return _i20.User.fromJson(data) as T;
    }
    if (t == _i21.Greeting) {
      return _i21.Greeting.fromJson(data) as T;
    }
    if (t == _i1.getType<_i4.PaginationDto?>()) {
      return (data != null ? _i4.PaginationDto.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i5.GeneratePresignedUploadUrlRequestDto?>()) {
      return (data != null
          ? _i5.GeneratePresignedUploadUrlRequestDto.fromJson(data)
          : null) as T;
    }
    if (t == _i1.getType<_i6.GeneratePresignedUploadUrlResponseDto?>()) {
      return (data != null
          ? _i6.GeneratePresignedUploadUrlResponseDto.fromJson(data)
          : null) as T;
    }
    if (t == _i1.getType<_i7.CreateProductRequestDto?>()) {
      return (data != null ? _i7.CreateProductRequestDto.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i8.PaginatedProductsResponseDto?>()) {
      return (data != null
          ? _i8.PaginatedProductsResponseDto.fromJson(data)
          : null) as T;
    }
    if (t == _i1.getType<_i9.ProductStatsDto?>()) {
      return (data != null ? _i9.ProductStatsDto.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i10.UpdateProductRequestDto?>()) {
      return (data != null ? _i10.UpdateProductRequestDto.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i11.UpdateProductStatusRequestDto?>()) {
      return (data != null
          ? _i11.UpdateProductStatusRequestDto.fromJson(data)
          : null) as T;
    }
    if (t == _i1.getType<_i12.Favorite?>()) {
      return (data != null ? _i12.Favorite.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i13.Product?>()) {
      return (data != null ? _i13.Product.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i14.ProductCategory?>()) {
      return (data != null ? _i14.ProductCategory.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i15.ProductCondition?>()) {
      return (data != null ? _i15.ProductCondition.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i16.ProductSortBy?>()) {
      return (data != null ? _i16.ProductSortBy.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i17.ProductStatus?>()) {
      return (data != null ? _i17.ProductStatus.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i18.TradeMethod?>()) {
      return (data != null ? _i18.TradeMethod.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i19.UpdateUserProfileRequestDto?>()) {
      return (data != null
          ? _i19.UpdateUserProfileRequestDto.fromJson(data)
          : null) as T;
    }
    if (t == _i1.getType<_i20.User?>()) {
      return (data != null ? _i20.User.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i21.Greeting?>()) {
      return (data != null ? _i21.Greeting.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<List<String>?>()) {
      return (data != null
          ? (data as List).map((e) => deserialize<String>(e)).toList()
          : null) as T;
    }
    if (t == List<_i13.Product>) {
      return (data as List).map((e) => deserialize<_i13.Product>(e)).toList()
          as T;
    }
    if (t == _i1.getType<List<String>?>()) {
      return (data != null
          ? (data as List).map((e) => deserialize<String>(e)).toList()
          : null) as T;
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
      return _i3.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _i2.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  @override
  String? getClassNameForObject(Object? data) {
    String? className = super.getClassNameForObject(data);
    if (className != null) return className;
    if (data is _i4.PaginationDto) {
      return 'PaginationDto';
    }
    if (data is _i5.GeneratePresignedUploadUrlRequestDto) {
      return 'GeneratePresignedUploadUrlRequestDto';
    }
    if (data is _i6.GeneratePresignedUploadUrlResponseDto) {
      return 'GeneratePresignedUploadUrlResponseDto';
    }
    if (data is _i7.CreateProductRequestDto) {
      return 'CreateProductRequestDto';
    }
    if (data is _i8.PaginatedProductsResponseDto) {
      return 'PaginatedProductsResponseDto';
    }
    if (data is _i9.ProductStatsDto) {
      return 'ProductStatsDto';
    }
    if (data is _i10.UpdateProductRequestDto) {
      return 'UpdateProductRequestDto';
    }
    if (data is _i11.UpdateProductStatusRequestDto) {
      return 'UpdateProductStatusRequestDto';
    }
    if (data is _i12.Favorite) {
      return 'Favorite';
    }
    if (data is _i13.Product) {
      return 'Product';
    }
    if (data is _i14.ProductCategory) {
      return 'ProductCategory';
    }
    if (data is _i15.ProductCondition) {
      return 'ProductCondition';
    }
    if (data is _i16.ProductSortBy) {
      return 'ProductSortBy';
    }
    if (data is _i17.ProductStatus) {
      return 'ProductStatus';
    }
    if (data is _i18.TradeMethod) {
      return 'TradeMethod';
    }
    if (data is _i19.UpdateUserProfileRequestDto) {
      return 'UpdateUserProfileRequestDto';
    }
    if (data is _i20.User) {
      return 'User';
    }
    if (data is _i21.Greeting) {
      return 'Greeting';
    }
    className = _i2.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod.$className';
    }
    className = _i3.Protocol().getClassNameForObject(data);
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
      return deserialize<_i4.PaginationDto>(data['data']);
    }
    if (dataClassName == 'GeneratePresignedUploadUrlRequestDto') {
      return deserialize<_i5.GeneratePresignedUploadUrlRequestDto>(
          data['data']);
    }
    if (dataClassName == 'GeneratePresignedUploadUrlResponseDto') {
      return deserialize<_i6.GeneratePresignedUploadUrlResponseDto>(
          data['data']);
    }
    if (dataClassName == 'CreateProductRequestDto') {
      return deserialize<_i7.CreateProductRequestDto>(data['data']);
    }
    if (dataClassName == 'PaginatedProductsResponseDto') {
      return deserialize<_i8.PaginatedProductsResponseDto>(data['data']);
    }
    if (dataClassName == 'ProductStatsDto') {
      return deserialize<_i9.ProductStatsDto>(data['data']);
    }
    if (dataClassName == 'UpdateProductRequestDto') {
      return deserialize<_i10.UpdateProductRequestDto>(data['data']);
    }
    if (dataClassName == 'UpdateProductStatusRequestDto') {
      return deserialize<_i11.UpdateProductStatusRequestDto>(data['data']);
    }
    if (dataClassName == 'Favorite') {
      return deserialize<_i12.Favorite>(data['data']);
    }
    if (dataClassName == 'Product') {
      return deserialize<_i13.Product>(data['data']);
    }
    if (dataClassName == 'ProductCategory') {
      return deserialize<_i14.ProductCategory>(data['data']);
    }
    if (dataClassName == 'ProductCondition') {
      return deserialize<_i15.ProductCondition>(data['data']);
    }
    if (dataClassName == 'ProductSortBy') {
      return deserialize<_i16.ProductSortBy>(data['data']);
    }
    if (dataClassName == 'ProductStatus') {
      return deserialize<_i17.ProductStatus>(data['data']);
    }
    if (dataClassName == 'TradeMethod') {
      return deserialize<_i18.TradeMethod>(data['data']);
    }
    if (dataClassName == 'UpdateUserProfileRequestDto') {
      return deserialize<_i19.UpdateUserProfileRequestDto>(data['data']);
    }
    if (dataClassName == 'User') {
      return deserialize<_i20.User>(data['data']);
    }
    if (dataClassName == 'Greeting') {
      return deserialize<_i21.Greeting>(data['data']);
    }
    if (dataClassName.startsWith('serverpod.')) {
      data['className'] = dataClassName.substring(10);
      return _i2.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth.')) {
      data['className'] = dataClassName.substring(15);
      return _i3.Protocol().deserializeByClassName(data);
    }
    return super.deserializeByClassName(data);
  }

  @override
  _i1.Table? getTableForType(Type t) {
    {
      var table = _i3.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    {
      var table = _i2.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    switch (t) {
      case _i12.Favorite:
        return _i12.Favorite.t;
      case _i13.Product:
        return _i13.Product.t;
      case _i20.User:
        return _i20.User.t;
    }
    return null;
  }

  @override
  List<_i2.TableDefinition> getTargetTableDefinitions() =>
      targetTableDefinitions;

  @override
  String getModuleName() => 'gear_freak';
}
