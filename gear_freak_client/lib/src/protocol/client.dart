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
import 'package:gear_freak_client/src/protocol/feature/user/model/user.dart'
    as _i3;
import 'package:gear_freak_client/src/protocol/feature/product/model/product.dart'
    as _i4;
import 'package:gear_freak_client/src/protocol/greeting.dart' as _i5;
import 'package:serverpod_auth_client/serverpod_auth_client.dart' as _i6;
import 'protocol.dart' as _i7;

/// 인증 엔드포인트
/// {@category Endpoint}
class EndpointAuth extends _i1.EndpointRef {
  EndpointAuth(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'auth';

  /// 개발용: 이메일 인증 없이 바로 회원가입
  _i2.Future<_i3.User> signupWithoutEmailVerification({
    required String userName,
    required String email,
    required String password,
  }) =>
      caller.callServerEndpoint<_i3.User>(
        'auth',
        'signupWithoutEmailVerification',
        {
          'userName': userName,
          'email': email,
          'password': password,
        },
      );
}

/// 인증 엔드포인트
/// {@category Endpoint}
class EndpointProduct extends _i1.EndpointRef {
  EndpointProduct(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'product';

  _i2.Future<_i4.Product> getProduct(int id) =>
      caller.callServerEndpoint<_i4.Product>(
        'product',
        'getProduct',
        {'id': id},
      );

  /// 최근 등록 상품 조회 (5개)
  _i2.Future<List<_i4.Product>> getRecentProducts() =>
      caller.callServerEndpoint<List<_i4.Product>>(
        'product',
        'getRecentProducts',
        {},
      );

  /// 전체 상품 조회
  _i2.Future<List<_i4.Product>> getAllProducts() =>
      caller.callServerEndpoint<List<_i4.Product>>(
        'product',
        'getAllProducts',
        {},
      );
}

/// 사용자 엔드포인트
/// {@category Endpoint}
class EndpointUser extends _i1.EndpointRef {
  EndpointUser(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'user';

  /// 현재 로그인한 사용자 정보를 가져옵니다
  _i2.Future<_i3.User> getMe() => caller.callServerEndpoint<_i3.User>(
        'user',
        'getMe',
        {},
      );

  /// 사용자 Id로 사용자 정보를 가져옵니다
  _i2.Future<_i3.User> getUserById(int id) =>
      caller.callServerEndpoint<_i3.User>(
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

/// This is an example endpoint that returns a greeting message through
/// its [hello] method.
/// {@category Endpoint}
class EndpointGreeting extends _i1.EndpointRef {
  EndpointGreeting(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'greeting';

  /// Returns a personalized greeting message: "Hello {name}".
  _i2.Future<_i5.Greeting> hello(String name) =>
      caller.callServerEndpoint<_i5.Greeting>(
        'greeting',
        'hello',
        {'name': name},
      );
}

class Modules {
  Modules(Client client) {
    auth = _i6.Caller(client);
  }

  late final _i6.Caller auth;
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
          _i7.Protocol(),
          securityContext: securityContext,
          authenticationKeyManager: authenticationKeyManager,
          streamingConnectionTimeout: streamingConnectionTimeout,
          connectionTimeout: connectionTimeout,
          onFailedCall: onFailedCall,
          onSucceededCall: onSucceededCall,
          disconnectStreamsOnLostInternetConnection:
              disconnectStreamsOnLostInternetConnection,
        ) {
    auth = EndpointAuth(this);
    product = EndpointProduct(this);
    user = EndpointUser(this);
    greeting = EndpointGreeting(this);
    modules = Modules(this);
  }

  late final EndpointAuth auth;

  late final EndpointProduct product;

  late final EndpointUser user;

  late final EndpointGreeting greeting;

  late final Modules modules;

  @override
  Map<String, _i1.EndpointRef> get endpointRefLookup => {
        'auth': auth,
        'product': product,
        'user': user,
        'greeting': greeting,
      };

  @override
  Map<String, _i1.ModuleEndpointCaller> get moduleLookup =>
      {'auth': modules.auth};
}
