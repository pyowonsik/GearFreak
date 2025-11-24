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
import '../common/s3/endpoint/s3_endpoint.dart' as _i2;
import '../feature/auth/endpoint/auth_endpoint.dart' as _i3;
import '../feature/product/endpoint/product_endpoint.dart' as _i4;
import '../feature/user/endpoint/user_endpoint.dart' as _i5;
import '../greeting_endpoint.dart' as _i6;
import 'package:gear_freak_server/src/generated/common/s3/model/dto/generate_presigned_upload_url_request.dto.dart'
    as _i7;
import 'package:gear_freak_server/src/generated/common/model/pagination_dto.dart'
    as _i8;
import 'package:serverpod_auth_server/serverpod_auth_server.dart' as _i9;

class Endpoints extends _i1.EndpointDispatch {
  @override
  void initializeEndpoints(_i1.Server server) {
    var endpoints = <String, _i1.Endpoint>{
      's3': _i2.S3Endpoint()
        ..initialize(
          server,
          's3',
          null,
        ),
      'auth': _i3.AuthEndpoint()
        ..initialize(
          server,
          'auth',
          null,
        ),
      'product': _i4.ProductEndpoint()
        ..initialize(
          server,
          'product',
          null,
        ),
      'user': _i5.UserEndpoint()
        ..initialize(
          server,
          'user',
          null,
        ),
      'greeting': _i6.GreetingEndpoint()
        ..initialize(
          server,
          'greeting',
          null,
        ),
    };
    connectors['s3'] = _i1.EndpointConnector(
      name: 's3',
      endpoint: endpoints['s3']!,
      methodConnectors: {
        'generatePresignedUploadUrl': _i1.MethodConnector(
          name: 'generatePresignedUploadUrl',
          params: {
            'request': _i1.ParameterDescription(
              name: 'request',
              type: _i1.getType<_i7.GeneratePresignedUploadUrlRequestDto>(),
              nullable: false,
            )
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['s3'] as _i2.S3Endpoint).generatePresignedUploadUrl(
            session,
            params['request'],
          ),
        )
      },
    );
    connectors['auth'] = _i1.EndpointConnector(
      name: 'auth',
      endpoint: endpoints['auth']!,
      methodConnectors: {
        'signupWithoutEmailVerification': _i1.MethodConnector(
          name: 'signupWithoutEmailVerification',
          params: {
            'userName': _i1.ParameterDescription(
              name: 'userName',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'email': _i1.ParameterDescription(
              name: 'email',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'password': _i1.ParameterDescription(
              name: 'password',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['auth'] as _i3.AuthEndpoint)
                  .signupWithoutEmailVerification(
            session,
            userName: params['userName'],
            email: params['email'],
            password: params['password'],
          ),
        )
      },
    );
    connectors['product'] = _i1.EndpointConnector(
      name: 'product',
      endpoint: endpoints['product']!,
      methodConnectors: {
        'getProduct': _i1.MethodConnector(
          name: 'getProduct',
          params: {
            'id': _i1.ParameterDescription(
              name: 'id',
              type: _i1.getType<int>(),
              nullable: false,
            )
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['product'] as _i4.ProductEndpoint).getProduct(
            session,
            params['id'],
          ),
        ),
        'getPaginatedProducts': _i1.MethodConnector(
          name: 'getPaginatedProducts',
          params: {
            'pagination': _i1.ParameterDescription(
              name: 'pagination',
              type: _i1.getType<_i8.PaginationDto>(),
              nullable: false,
            )
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['product'] as _i4.ProductEndpoint)
                  .getPaginatedProducts(
            session,
            params['pagination'],
          ),
        ),
        'toggleFavorite': _i1.MethodConnector(
          name: 'toggleFavorite',
          params: {
            'productId': _i1.ParameterDescription(
              name: 'productId',
              type: _i1.getType<int>(),
              nullable: false,
            )
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['product'] as _i4.ProductEndpoint).toggleFavorite(
            session,
            params['productId'],
          ),
        ),
        'isFavorite': _i1.MethodConnector(
          name: 'isFavorite',
          params: {
            'productId': _i1.ParameterDescription(
              name: 'productId',
              type: _i1.getType<int>(),
              nullable: false,
            )
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['product'] as _i4.ProductEndpoint).isFavorite(
            session,
            params['productId'],
          ),
        ),
      },
    );
    connectors['user'] = _i1.EndpointConnector(
      name: 'user',
      endpoint: endpoints['user']!,
      methodConnectors: {
        'getMe': _i1.MethodConnector(
          name: 'getMe',
          params: {},
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['user'] as _i5.UserEndpoint).getMe(session),
        ),
        'getUserById': _i1.MethodConnector(
          name: 'getUserById',
          params: {
            'id': _i1.ParameterDescription(
              name: 'id',
              type: _i1.getType<int>(),
              nullable: false,
            )
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['user'] as _i5.UserEndpoint).getUserById(
            session,
            params['id'],
          ),
        ),
        'getUserScopes': _i1.MethodConnector(
          name: 'getUserScopes',
          params: {},
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['user'] as _i5.UserEndpoint).getUserScopes(session),
        ),
      },
    );
    connectors['greeting'] = _i1.EndpointConnector(
      name: 'greeting',
      endpoint: endpoints['greeting']!,
      methodConnectors: {
        'hello': _i1.MethodConnector(
          name: 'hello',
          params: {
            'name': _i1.ParameterDescription(
              name: 'name',
              type: _i1.getType<String>(),
              nullable: false,
            )
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['greeting'] as _i6.GreetingEndpoint).hello(
            session,
            params['name'],
          ),
        )
      },
    );
    modules['serverpod_auth'] = _i9.Endpoints()..initializeEndpoints(server);
  }
}
