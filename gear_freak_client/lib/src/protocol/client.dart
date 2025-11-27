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
import 'dart:async' as _i2;
import 'package:gear_freak_client/src/protocol/common/s3/model/dto/generate_presigned_upload_url_response.dto.dart'
    as _i3;
import 'package:gear_freak_client/src/protocol/common/s3/model/dto/generate_presigned_upload_url_request.dto.dart'
    as _i4;
import 'package:gear_freak_client/src/protocol/feature/user/model/user.dart'
    as _i5;
import 'package:gear_freak_client/src/protocol/feature/product/model/product.dart'
    as _i6;
import 'package:gear_freak_client/src/protocol/feature/product/model/dto/create_product_request.dto.dart'
    as _i7;
import 'package:gear_freak_client/src/protocol/feature/product/model/dto/update_product_request.dto.dart'
    as _i8;
import 'package:gear_freak_client/src/protocol/feature/product/model/dto/paginated_products_response.dto.dart'
    as _i9;
import 'package:gear_freak_client/src/protocol/common/model/pagination_dto.dart'
    as _i10;
import 'package:serverpod_auth_client/serverpod_auth_client.dart' as _i11;
import 'protocol.dart' as _i12;

/// S3 엔드포인트 (공통 사용)
/// {@category Endpoint}
class EndpointS3 extends _i1.EndpointRef {
  EndpointS3(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 's3';

  /// Presigned URL 생성 (업로드용)
  ///
  /// [session] - Serverpod 세션
  /// [request] - 업로드 요청 정보
  ///
  /// 반환: Presigned URL 및 파일 키
  _i2.Future<_i3.GeneratePresignedUploadUrlResponseDto>
      generatePresignedUploadUrl(
              _i4.GeneratePresignedUploadUrlRequestDto request) =>
          caller.callServerEndpoint<_i3.GeneratePresignedUploadUrlResponseDto>(
            's3',
            'generatePresignedUploadUrl',
            {'request': request},
          );

  /// S3 파일 삭제
  ///
  /// [session] - Serverpod 세션
  /// [fileKey] - 삭제할 파일 키 (예: temp/product/1/xxx.png)
  /// [bucketType] - 버킷 타입 ('public' 또는 'private')
  _i2.Future<void> deleteS3File(
    String fileKey,
    String bucketType,
  ) =>
      caller.callServerEndpoint<void>(
        's3',
        'deleteS3File',
        {
          'fileKey': fileKey,
          'bucketType': bucketType,
        },
      );
}

/// 인증 엔드포인트
/// {@category Endpoint}
class EndpointAuth extends _i1.EndpointRef {
  EndpointAuth(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'auth';

  /// 개발용: 이메일 인증 없이 바로 회원가입
  _i2.Future<_i5.User> signupWithoutEmailVerification({
    required String userName,
    required String email,
    required String password,
  }) =>
      caller.callServerEndpoint<_i5.User>(
        'auth',
        'signupWithoutEmailVerification',
        {
          'userName': userName,
          'email': email,
          'password': password,
        },
      );
}

/// 상품 엔드포인트
/// {@category Endpoint}
class EndpointProduct extends _i1.EndpointRef {
  EndpointProduct(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'product';

  /// 상품 생성
  _i2.Future<_i6.Product> createProduct(_i7.CreateProductRequestDto request) =>
      caller.callServerEndpoint<_i6.Product>(
        'product',
        'createProduct',
        {'request': request},
      );

  /// 상품 수정
  _i2.Future<_i6.Product> updateProduct(_i8.UpdateProductRequestDto request) =>
      caller.callServerEndpoint<_i6.Product>(
        'product',
        'updateProduct',
        {'request': request},
      );

  _i2.Future<_i6.Product> getProduct(int id) =>
      caller.callServerEndpoint<_i6.Product>(
        'product',
        'getProduct',
        {'id': id},
      );

  /// 페이지네이션된 상품 목록 조회
  _i2.Future<_i9.PaginatedProductsResponseDto> getPaginatedProducts(
          _i10.PaginationDto pagination) =>
      caller.callServerEndpoint<_i9.PaginatedProductsResponseDto>(
        'product',
        'getPaginatedProducts',
        {'pagination': pagination},
      );

  /// 찜 추가/제거 (토글)
  /// 반환값: true = 찜 추가됨, false = 찜 제거됨
  _i2.Future<bool> toggleFavorite(int productId) =>
      caller.callServerEndpoint<bool>(
        'product',
        'toggleFavorite',
        {'productId': productId},
      );

  /// 찜 상태 조회
  _i2.Future<bool> isFavorite(int productId) => caller.callServerEndpoint<bool>(
        'product',
        'isFavorite',
        {'productId': productId},
      );

  /// 상품 삭제
  _i2.Future<void> deleteProduct(int productId) =>
      caller.callServerEndpoint<void>(
        'product',
        'deleteProduct',
        {'productId': productId},
      );
}

/// 사용자 엔드포인트
/// {@category Endpoint}
class EndpointUser extends _i1.EndpointRef {
  EndpointUser(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'user';

  /// 현재 로그인한 사용자 정보를 가져옵니다
  _i2.Future<_i5.User> getMe() => caller.callServerEndpoint<_i5.User>(
        'user',
        'getMe',
        {},
      );

  /// 사용자 Id로 사용자 정보를 가져옵니다
  _i2.Future<_i5.User> getUserById(int id) =>
      caller.callServerEndpoint<_i5.User>(
        'user',
        'getUserById',
        {'id': id},
      );

  /// 현재 사용자의 권한(Scope) 정보를 조회합니다
  _i2.Future<List<String>> getUserScopes() =>
      caller.callServerEndpoint<List<String>>(
        'user',
        'getUserScopes',
        {},
      );
}

class Modules {
  Modules(Client client) {
    auth = _i11.Caller(client);
  }

  late final _i11.Caller auth;
}

class Client extends _i1.ServerpodClientShared {
  Client(
    String host, {
    dynamic securityContext,
    _i1.AuthenticationKeyManager? authenticationKeyManager,
    Duration? streamingConnectionTimeout,
    Duration? connectionTimeout,
    Function(
      _i1.MethodCallContext,
      Object,
      StackTrace,
    )? onFailedCall,
    Function(_i1.MethodCallContext)? onSucceededCall,
    bool? disconnectStreamsOnLostInternetConnection,
  }) : super(
          host,
          _i12.Protocol(),
          securityContext: securityContext,
          authenticationKeyManager: authenticationKeyManager,
          streamingConnectionTimeout: streamingConnectionTimeout,
          connectionTimeout: connectionTimeout,
          onFailedCall: onFailedCall,
          onSucceededCall: onSucceededCall,
          disconnectStreamsOnLostInternetConnection:
              disconnectStreamsOnLostInternetConnection,
        ) {
    s3 = EndpointS3(this);
    auth = EndpointAuth(this);
    product = EndpointProduct(this);
    user = EndpointUser(this);
    modules = Modules(this);
  }

  late final EndpointS3 s3;

  late final EndpointAuth auth;

  late final EndpointProduct product;

  late final EndpointUser user;

  late final Modules modules;

  @override
  Map<String, _i1.EndpointRef> get endpointRefLookup => {
        's3': s3,
        'auth': auth,
        'product': product,
        'user': user,
      };

  @override
  Map<String, _i1.ModuleEndpointCaller> get moduleLookup =>
      {'auth': modules.auth};
}
