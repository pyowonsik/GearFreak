/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters

// ignore_for_file: no_leading_underscores_for_local_identifiers

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_test/serverpod_test.dart' as _i1;
import 'package:serverpod/serverpod.dart' as _i2;
import 'dart:async' as _i3;
import 'package:gear_freak_server/src/generated/common/s3/model/dto/generate_presigned_upload_url_response.dto.dart'
    as _i4;
import 'package:gear_freak_server/src/generated/common/s3/model/dto/generate_presigned_upload_url_request.dto.dart'
    as _i5;
import 'package:gear_freak_server/src/generated/feature/user/model/user.dart'
    as _i6;
import 'package:serverpod_auth_server/serverpod_auth_server.dart' as _i7;
import 'package:gear_freak_server/src/generated/feature/chat/model/dto/create_chat_room_response.dto.dart'
    as _i8;
import 'package:gear_freak_server/src/generated/feature/chat/model/dto/create_chat_room_request.dto.dart'
    as _i9;
import 'package:gear_freak_server/src/generated/feature/chat/model/chat_room.dart'
    as _i10;
import 'package:gear_freak_server/src/generated/feature/chat/model/dto/paginated_chat_rooms_response.dto.dart'
    as _i11;
import 'package:gear_freak_server/src/generated/common/model/pagination_dto.dart'
    as _i12;
import 'package:gear_freak_server/src/generated/feature/chat/model/dto/join_chat_room_response.dto.dart'
    as _i13;
import 'package:gear_freak_server/src/generated/feature/chat/model/dto/join_chat_room_request.dto.dart'
    as _i14;
import 'package:gear_freak_server/src/generated/feature/chat/model/dto/leave_chat_room_response.dto.dart'
    as _i15;
import 'package:gear_freak_server/src/generated/feature/chat/model/dto/leave_chat_room_request.dto.dart'
    as _i16;
import 'package:gear_freak_server/src/generated/feature/chat/model/dto/chat_participant_info.dto.dart'
    as _i17;
import 'package:gear_freak_server/src/generated/feature/chat/model/dto/chat_message_response.dto.dart'
    as _i18;
import 'package:gear_freak_server/src/generated/feature/chat/model/dto/send_message_request.dto.dart'
    as _i19;
import 'package:gear_freak_server/src/generated/feature/chat/model/dto/paginated_chat_messages_response.dto.dart'
    as _i20;
import 'package:gear_freak_server/src/generated/feature/chat/model/dto/get_chat_messages_request.dto.dart'
    as _i21;
import 'package:gear_freak_server/src/generated/feature/chat/model/chat_message.dart'
    as _i22;
import 'package:gear_freak_server/src/generated/feature/chat/model/dto/update_chat_room_notification_request.dto.dart'
    as _i23;
import 'package:gear_freak_server/src/generated/feature/notification/model/dto/notification_list_response.dto.dart'
    as _i24;
import 'package:gear_freak_server/src/generated/feature/product/model/product.dart'
    as _i25;
import 'package:gear_freak_server/src/generated/feature/product/model/dto/create_product_request.dto.dart'
    as _i26;
import 'package:gear_freak_server/src/generated/feature/product/model/dto/update_product_request.dto.dart'
    as _i27;
import 'package:gear_freak_server/src/generated/feature/product/model/dto/paginated_products_response.dto.dart'
    as _i28;
import 'package:gear_freak_server/src/generated/feature/product/model/dto/update_product_status_request.dto.dart'
    as _i29;
import 'package:gear_freak_server/src/generated/feature/product/model/dto/product_stats.dto.dart'
    as _i30;
import 'package:gear_freak_server/src/generated/feature/review/model/dto/transaction_review_response.dto.dart'
    as _i31;
import 'package:gear_freak_server/src/generated/feature/review/model/dto/create_transaction_review_request.dto.dart'
    as _i32;
import 'package:gear_freak_server/src/generated/feature/review/model/dto/transaction_review_list_response.dto.dart'
    as _i33;
import 'package:gear_freak_server/src/generated/feature/review/model/review_type.dart'
    as _i34;
import 'package:gear_freak_server/src/generated/feature/user/model/dto/update_user_profile_request.dto.dart'
    as _i35;
import 'package:gear_freak_server/src/generated/protocol.dart';
import 'package:gear_freak_server/src/generated/endpoints.dart';
export 'package:serverpod_test/serverpod_test_public_exports.dart';

/// Creates a new test group that takes a callback that can be used to write tests.
/// The callback has two parameters: `sessionBuilder` and `endpoints`.
/// `sessionBuilder` is used to build a `Session` object that represents the server state during an endpoint call and is used to set up scenarios.
/// `endpoints` contains all your Serverpod endpoints and lets you call them:
/// ```dart
/// withServerpod('Given Example endpoint', (sessionBuilder, endpoints) {
///   test('when calling `hello` then should return greeting', () async {
///     final greeting = await endpoints.example.hello(sessionBuilder, 'Michael');
///     expect(greeting, 'Hello Michael');
///   });
/// });
/// ```
///
/// **Configuration options**
///
/// [applyMigrations] Whether pending migrations should be applied when starting Serverpod. Defaults to `true`
///
/// [enableSessionLogging] Whether session logging should be enabled. Defaults to `false`
///
/// [rollbackDatabase] Options for when to rollback the database during the test lifecycle.
/// By default `withServerpod` does all database operations inside a transaction that is rolled back after each `test` case.
/// Just like the following enum describes, the behavior of the automatic rollbacks can be configured:
/// ```dart
/// /// Options for when to rollback the database during the test lifecycle.
/// enum RollbackDatabase {
///   /// After each test. This is the default.
///   afterEach,
///
///   /// After all tests.
///   afterAll,
///
///   /// Disable rolling back the database.
///   disabled,
/// }
/// ```
///
/// [runMode] The run mode that Serverpod should be running in. Defaults to `test`.
///
/// [serverpodLoggingMode] The logging mode used when creating Serverpod. Defaults to `ServerpodLoggingMode.normal`
///
/// [serverpodStartTimeout] The timeout to use when starting Serverpod, which connects to the database among other things. Defaults to `Duration(seconds: 30)`.
///
/// [testGroupTagsOverride] By default Serverpod test tools tags the `withServerpod` test group with `"integration"`.
/// This is to provide a simple way to only run unit or integration tests.
/// This property allows this tag to be overridden to something else. Defaults to `['integration']`.
///
/// [experimentalFeatures] Optionally specify experimental features. See [Serverpod] for more information.
@_i1.isTestGroup
void withServerpod(
  String testGroupName,
  _i1.TestClosure<TestEndpoints> testClosure, {
  bool? applyMigrations,
  bool? enableSessionLogging,
  _i2.ExperimentalFeatures? experimentalFeatures,
  _i1.RollbackDatabase? rollbackDatabase,
  String? runMode,
  _i2.RuntimeParametersListBuilder? runtimeParametersBuilder,
  _i2.ServerpodLoggingMode? serverpodLoggingMode,
  Duration? serverpodStartTimeout,
  List<String>? testGroupTagsOverride,
}) {
  _i1.buildWithServerpod<_InternalTestEndpoints>(
    testGroupName,
    _i1.TestServerpod(
      testEndpoints: _InternalTestEndpoints(),
      endpoints: Endpoints(),
      serializationManager: Protocol(),
      runMode: runMode,
      applyMigrations: applyMigrations,
      isDatabaseEnabled: true,
      serverpodLoggingMode: serverpodLoggingMode,
      experimentalFeatures: experimentalFeatures,
      runtimeParametersBuilder: runtimeParametersBuilder,
    ),
    maybeRollbackDatabase: rollbackDatabase,
    maybeEnableSessionLogging: enableSessionLogging,
    maybeTestGroupTagsOverride: testGroupTagsOverride,
    maybeServerpodStartTimeout: serverpodStartTimeout,
  )(testClosure);
}

class TestEndpoints {
  late final _S3Endpoint s3;

  late final _AuthEndpoint auth;

  late final _ChatEndpoint chat;

  late final _ChatStreamEndpoint chatStream;

  late final _NotificationEndpoint notification;

  late final _ProductEndpoint product;

  late final _ReviewEndpoint review;

  late final _FcmEndpoint fcm;

  late final _UserEndpoint user;
}

class _InternalTestEndpoints extends TestEndpoints
    implements _i1.InternalTestEndpoints {
  @override
  void initialize(
    _i2.SerializationManager serializationManager,
    _i2.EndpointDispatch endpoints,
  ) {
    s3 = _S3Endpoint(
      endpoints,
      serializationManager,
    );
    auth = _AuthEndpoint(
      endpoints,
      serializationManager,
    );
    chat = _ChatEndpoint(
      endpoints,
      serializationManager,
    );
    chatStream = _ChatStreamEndpoint(
      endpoints,
      serializationManager,
    );
    notification = _NotificationEndpoint(
      endpoints,
      serializationManager,
    );
    product = _ProductEndpoint(
      endpoints,
      serializationManager,
    );
    review = _ReviewEndpoint(
      endpoints,
      serializationManager,
    );
    fcm = _FcmEndpoint(
      endpoints,
      serializationManager,
    );
    user = _UserEndpoint(
      endpoints,
      serializationManager,
    );
  }
}

class _S3Endpoint {
  _S3Endpoint(
    this._endpointDispatch,
    this._serializationManager,
  );

  final _i2.EndpointDispatch _endpointDispatch;

  final _i2.SerializationManager _serializationManager;

  _i3.Future<_i4.GeneratePresignedUploadUrlResponseDto>
      generatePresignedUploadUrl(
    _i1.TestSessionBuilder sessionBuilder,
    _i5.GeneratePresignedUploadUrlRequestDto request,
  ) async {
    return _i1.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _i1.InternalTestSessionBuilder).internalBuild(
        endpoint: 's3',
        method: 'generatePresignedUploadUrl',
      );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 's3',
          methodName: 'generatePresignedUploadUrl',
          parameters: _i1.testObjectToJson({'request': request}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _i3.Future<_i4.GeneratePresignedUploadUrlResponseDto>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _i3.Future<void> deleteS3File(
    _i1.TestSessionBuilder sessionBuilder,
    String fileKey,
    String bucketType,
  ) async {
    return _i1.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _i1.InternalTestSessionBuilder).internalBuild(
        endpoint: 's3',
        method: 'deleteS3File',
      );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 's3',
          methodName: 'deleteS3File',
          parameters: _i1.testObjectToJson({
            'fileKey': fileKey,
            'bucketType': bucketType,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _i3.Future<void>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }
}

class _AuthEndpoint {
  _AuthEndpoint(
    this._endpointDispatch,
    this._serializationManager,
  );

  final _i2.EndpointDispatch _endpointDispatch;

  final _i2.SerializationManager _serializationManager;

  _i3.Future<_i6.User> signupWithoutEmailVerification(
    _i1.TestSessionBuilder sessionBuilder, {
    required String userName,
    required String email,
    required String password,
  }) async {
    return _i1.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _i1.InternalTestSessionBuilder).internalBuild(
        endpoint: 'auth',
        method: 'signupWithoutEmailVerification',
      );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'auth',
          methodName: 'signupWithoutEmailVerification',
          parameters: _i1.testObjectToJson({
            'userName': userName,
            'email': email,
            'password': password,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _i3.Future<_i6.User>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _i3.Future<_i6.User> getOrCreateUserAfterGoogleLogin(
      _i1.TestSessionBuilder sessionBuilder) async {
    return _i1.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _i1.InternalTestSessionBuilder).internalBuild(
        endpoint: 'auth',
        method: 'getOrCreateUserAfterGoogleLogin',
      );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'auth',
          methodName: 'getOrCreateUserAfterGoogleLogin',
          parameters: _i1.testObjectToJson({}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _i3.Future<_i6.User>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _i3.Future<_i7.AuthenticationResponse> authenticateWithKakao(
    _i1.TestSessionBuilder sessionBuilder,
    String accessToken,
  ) async {
    return _i1.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _i1.InternalTestSessionBuilder).internalBuild(
        endpoint: 'auth',
        method: 'authenticateWithKakao',
      );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'auth',
          methodName: 'authenticateWithKakao',
          parameters: _i1.testObjectToJson({'accessToken': accessToken}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _i3.Future<_i7.AuthenticationResponse>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _i3.Future<_i6.User> getOrCreateUserAfterKakaoLogin(
      _i1.TestSessionBuilder sessionBuilder) async {
    return _i1.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _i1.InternalTestSessionBuilder).internalBuild(
        endpoint: 'auth',
        method: 'getOrCreateUserAfterKakaoLogin',
      );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'auth',
          methodName: 'getOrCreateUserAfterKakaoLogin',
          parameters: _i1.testObjectToJson({}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _i3.Future<_i6.User>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _i3.Future<_i6.User> getOrCreateUserAfterAppleLogin(
      _i1.TestSessionBuilder sessionBuilder) async {
    return _i1.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _i1.InternalTestSessionBuilder).internalBuild(
        endpoint: 'auth',
        method: 'getOrCreateUserAfterAppleLogin',
      );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'auth',
          methodName: 'getOrCreateUserAfterAppleLogin',
          parameters: _i1.testObjectToJson({}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _i3.Future<_i6.User>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _i3.Future<_i7.AuthenticationResponse> authenticateWithNaver(
    _i1.TestSessionBuilder sessionBuilder,
    String accessToken,
  ) async {
    return _i1.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _i1.InternalTestSessionBuilder).internalBuild(
        endpoint: 'auth',
        method: 'authenticateWithNaver',
      );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'auth',
          methodName: 'authenticateWithNaver',
          parameters: _i1.testObjectToJson({'accessToken': accessToken}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _i3.Future<_i7.AuthenticationResponse>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _i3.Future<_i6.User> getOrCreateUserAfterNaverLogin(
      _i1.TestSessionBuilder sessionBuilder) async {
    return _i1.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _i1.InternalTestSessionBuilder).internalBuild(
        endpoint: 'auth',
        method: 'getOrCreateUserAfterNaverLogin',
      );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'auth',
          methodName: 'getOrCreateUserAfterNaverLogin',
          parameters: _i1.testObjectToJson({}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _i3.Future<_i6.User>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }
}

class _ChatEndpoint {
  _ChatEndpoint(
    this._endpointDispatch,
    this._serializationManager,
  );

  final _i2.EndpointDispatch _endpointDispatch;

  final _i2.SerializationManager _serializationManager;

  _i3.Future<_i8.CreateChatRoomResponseDto> createOrGetChatRoom(
    _i1.TestSessionBuilder sessionBuilder,
    _i9.CreateChatRoomRequestDto request,
  ) async {
    return _i1.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _i1.InternalTestSessionBuilder).internalBuild(
        endpoint: 'chat',
        method: 'createOrGetChatRoom',
      );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'chat',
          methodName: 'createOrGetChatRoom',
          parameters: _i1.testObjectToJson({'request': request}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _i3.Future<_i8.CreateChatRoomResponseDto>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _i3.Future<_i10.ChatRoom?> getChatRoomById(
    _i1.TestSessionBuilder sessionBuilder,
    int chatRoomId,
  ) async {
    return _i1.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _i1.InternalTestSessionBuilder).internalBuild(
        endpoint: 'chat',
        method: 'getChatRoomById',
      );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'chat',
          methodName: 'getChatRoomById',
          parameters: _i1.testObjectToJson({'chatRoomId': chatRoomId}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _i3.Future<_i10.ChatRoom?>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _i3.Future<List<_i10.ChatRoom>?> getChatRoomsByProductId(
    _i1.TestSessionBuilder sessionBuilder,
    int productId,
  ) async {
    return _i1.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _i1.InternalTestSessionBuilder).internalBuild(
        endpoint: 'chat',
        method: 'getChatRoomsByProductId',
      );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'chat',
          methodName: 'getChatRoomsByProductId',
          parameters: _i1.testObjectToJson({'productId': productId}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _i3.Future<List<_i10.ChatRoom>?>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _i3.Future<_i11.PaginatedChatRoomsResponseDto> getUserChatRoomsByProductId(
    _i1.TestSessionBuilder sessionBuilder,
    int productId,
    _i12.PaginationDto pagination,
  ) async {
    return _i1.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _i1.InternalTestSessionBuilder).internalBuild(
        endpoint: 'chat',
        method: 'getUserChatRoomsByProductId',
      );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'chat',
          methodName: 'getUserChatRoomsByProductId',
          parameters: _i1.testObjectToJson({
            'productId': productId,
            'pagination': pagination,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _i3.Future<_i11.PaginatedChatRoomsResponseDto>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _i3.Future<_i11.PaginatedChatRoomsResponseDto> getMyChatRooms(
    _i1.TestSessionBuilder sessionBuilder,
    _i12.PaginationDto pagination,
  ) async {
    return _i1.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _i1.InternalTestSessionBuilder).internalBuild(
        endpoint: 'chat',
        method: 'getMyChatRooms',
      );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'chat',
          methodName: 'getMyChatRooms',
          parameters: _i1.testObjectToJson({'pagination': pagination}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _i3.Future<_i11.PaginatedChatRoomsResponseDto>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _i3.Future<_i13.JoinChatRoomResponseDto> joinChatRoom(
    _i1.TestSessionBuilder sessionBuilder,
    _i14.JoinChatRoomRequestDto request,
  ) async {
    return _i1.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _i1.InternalTestSessionBuilder).internalBuild(
        endpoint: 'chat',
        method: 'joinChatRoom',
      );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'chat',
          methodName: 'joinChatRoom',
          parameters: _i1.testObjectToJson({'request': request}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _i3.Future<_i13.JoinChatRoomResponseDto>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _i3.Future<_i15.LeaveChatRoomResponseDto> leaveChatRoom(
    _i1.TestSessionBuilder sessionBuilder,
    _i16.LeaveChatRoomRequestDto request,
  ) async {
    return _i1.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _i1.InternalTestSessionBuilder).internalBuild(
        endpoint: 'chat',
        method: 'leaveChatRoom',
      );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'chat',
          methodName: 'leaveChatRoom',
          parameters: _i1.testObjectToJson({'request': request}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _i3.Future<_i15.LeaveChatRoomResponseDto>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _i3.Future<List<_i17.ChatParticipantInfoDto>> getChatParticipants(
    _i1.TestSessionBuilder sessionBuilder,
    int chatRoomId,
  ) async {
    return _i1.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _i1.InternalTestSessionBuilder).internalBuild(
        endpoint: 'chat',
        method: 'getChatParticipants',
      );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'chat',
          methodName: 'getChatParticipants',
          parameters: _i1.testObjectToJson({'chatRoomId': chatRoomId}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _i3.Future<List<_i17.ChatParticipantInfoDto>>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _i3.Future<_i18.ChatMessageResponseDto> sendMessage(
    _i1.TestSessionBuilder sessionBuilder,
    _i19.SendMessageRequestDto request,
  ) async {
    return _i1.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _i1.InternalTestSessionBuilder).internalBuild(
        endpoint: 'chat',
        method: 'sendMessage',
      );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'chat',
          methodName: 'sendMessage',
          parameters: _i1.testObjectToJson({'request': request}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _i3.Future<_i18.ChatMessageResponseDto>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _i3.Future<_i20.PaginatedChatMessagesResponseDto> getChatMessagesPaginated(
    _i1.TestSessionBuilder sessionBuilder,
    _i21.GetChatMessagesRequestDto request,
  ) async {
    return _i1.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _i1.InternalTestSessionBuilder).internalBuild(
        endpoint: 'chat',
        method: 'getChatMessagesPaginated',
      );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'chat',
          methodName: 'getChatMessagesPaginated',
          parameters: _i1.testObjectToJson({'request': request}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _i3.Future<_i20.PaginatedChatMessagesResponseDto>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _i3.Future<_i22.ChatMessage?> getLastMessageByChatRoomId(
    _i1.TestSessionBuilder sessionBuilder,
    int chatRoomId,
  ) async {
    return _i1.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _i1.InternalTestSessionBuilder).internalBuild(
        endpoint: 'chat',
        method: 'getLastMessageByChatRoomId',
      );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'chat',
          methodName: 'getLastMessageByChatRoomId',
          parameters: _i1.testObjectToJson({'chatRoomId': chatRoomId}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _i3.Future<_i22.ChatMessage?>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _i3.Future<_i4.GeneratePresignedUploadUrlResponseDto>
      generateChatRoomImageUploadUrl(
    _i1.TestSessionBuilder sessionBuilder,
    int chatRoomId,
    String fileName,
    String contentType,
    int fileSize,
  ) async {
    return _i1.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _i1.InternalTestSessionBuilder).internalBuild(
        endpoint: 'chat',
        method: 'generateChatRoomImageUploadUrl',
      );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'chat',
          methodName: 'generateChatRoomImageUploadUrl',
          parameters: _i1.testObjectToJson({
            'chatRoomId': chatRoomId,
            'fileName': fileName,
            'contentType': contentType,
            'fileSize': fileSize,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _i3.Future<_i4.GeneratePresignedUploadUrlResponseDto>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _i3.Future<void> markChatRoomAsRead(
    _i1.TestSessionBuilder sessionBuilder,
    int chatRoomId,
  ) async {
    return _i1.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _i1.InternalTestSessionBuilder).internalBuild(
        endpoint: 'chat',
        method: 'markChatRoomAsRead',
      );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'chat',
          methodName: 'markChatRoomAsRead',
          parameters: _i1.testObjectToJson({'chatRoomId': chatRoomId}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _i3.Future<void>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _i3.Future<void> updateChatRoomNotification(
    _i1.TestSessionBuilder sessionBuilder,
    _i23.UpdateChatRoomNotificationRequestDto request,
  ) async {
    return _i1.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _i1.InternalTestSessionBuilder).internalBuild(
        endpoint: 'chat',
        method: 'updateChatRoomNotification',
      );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'chat',
          methodName: 'updateChatRoomNotification',
          parameters: _i1.testObjectToJson({'request': request}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _i3.Future<void>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }
}

class _ChatStreamEndpoint {
  _ChatStreamEndpoint(
    this._endpointDispatch,
    this._serializationManager,
  );

  final _i2.EndpointDispatch _endpointDispatch;

  final _i2.SerializationManager _serializationManager;

  _i3.Stream<_i18.ChatMessageResponseDto> chatMessageStream(
    _i1.TestSessionBuilder sessionBuilder,
    int chatRoomId,
  ) {
    var _localTestStreamManager =
        _i1.TestStreamManager<_i18.ChatMessageResponseDto>();
    _i1.callStreamFunctionAndHandleExceptions(
      () async {
        var _localUniqueSession =
            (sessionBuilder as _i1.InternalTestSessionBuilder).internalBuild(
          endpoint: 'chatStream',
          method: 'chatMessageStream',
        );
        var _localCallContext =
            await _endpointDispatch.getMethodStreamCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'chatStream',
          methodName: 'chatMessageStream',
          arguments: {'chatRoomId': chatRoomId},
          requestedInputStreams: [],
          serializationManager: _serializationManager,
        );
        await _localTestStreamManager.callStreamMethod(
          _localCallContext,
          _localUniqueSession,
          {},
        );
      },
      _localTestStreamManager.outputStreamController,
    );
    return _localTestStreamManager.outputStreamController.stream;
  }
}

class _NotificationEndpoint {
  _NotificationEndpoint(
    this._endpointDispatch,
    this._serializationManager,
  );

  final _i2.EndpointDispatch _endpointDispatch;

  final _i2.SerializationManager _serializationManager;

  _i3.Future<_i24.NotificationListResponseDto> getNotifications(
    _i1.TestSessionBuilder sessionBuilder, {
    required int page,
    required int limit,
  }) async {
    return _i1.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _i1.InternalTestSessionBuilder).internalBuild(
        endpoint: 'notification',
        method: 'getNotifications',
      );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'notification',
          methodName: 'getNotifications',
          parameters: _i1.testObjectToJson({
            'page': page,
            'limit': limit,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _i3.Future<_i24.NotificationListResponseDto>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _i3.Future<bool> markAsRead(
    _i1.TestSessionBuilder sessionBuilder,
    int notificationId,
  ) async {
    return _i1.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _i1.InternalTestSessionBuilder).internalBuild(
        endpoint: 'notification',
        method: 'markAsRead',
      );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'notification',
          methodName: 'markAsRead',
          parameters: _i1.testObjectToJson({'notificationId': notificationId}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _i3.Future<bool>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _i3.Future<bool> deleteNotification(
    _i1.TestSessionBuilder sessionBuilder,
    int notificationId,
  ) async {
    return _i1.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _i1.InternalTestSessionBuilder).internalBuild(
        endpoint: 'notification',
        method: 'deleteNotification',
      );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'notification',
          methodName: 'deleteNotification',
          parameters: _i1.testObjectToJson({'notificationId': notificationId}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _i3.Future<bool>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _i3.Future<int> getUnreadCount(_i1.TestSessionBuilder sessionBuilder) async {
    return _i1.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _i1.InternalTestSessionBuilder).internalBuild(
        endpoint: 'notification',
        method: 'getUnreadCount',
      );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'notification',
          methodName: 'getUnreadCount',
          parameters: _i1.testObjectToJson({}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _i3.Future<int>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }
}

class _ProductEndpoint {
  _ProductEndpoint(
    this._endpointDispatch,
    this._serializationManager,
  );

  final _i2.EndpointDispatch _endpointDispatch;

  final _i2.SerializationManager _serializationManager;

  _i3.Future<_i25.Product> createProduct(
    _i1.TestSessionBuilder sessionBuilder,
    _i26.CreateProductRequestDto request,
  ) async {
    return _i1.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _i1.InternalTestSessionBuilder).internalBuild(
        endpoint: 'product',
        method: 'createProduct',
      );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'product',
          methodName: 'createProduct',
          parameters: _i1.testObjectToJson({'request': request}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _i3.Future<_i25.Product>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _i3.Future<_i25.Product> updateProduct(
    _i1.TestSessionBuilder sessionBuilder,
    _i27.UpdateProductRequestDto request,
  ) async {
    return _i1.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _i1.InternalTestSessionBuilder).internalBuild(
        endpoint: 'product',
        method: 'updateProduct',
      );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'product',
          methodName: 'updateProduct',
          parameters: _i1.testObjectToJson({'request': request}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _i3.Future<_i25.Product>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _i3.Future<_i25.Product> getProduct(
    _i1.TestSessionBuilder sessionBuilder,
    int id,
  ) async {
    return _i1.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _i1.InternalTestSessionBuilder).internalBuild(
        endpoint: 'product',
        method: 'getProduct',
      );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'product',
          methodName: 'getProduct',
          parameters: _i1.testObjectToJson({'id': id}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _i3.Future<_i25.Product>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _i3.Future<_i28.PaginatedProductsResponseDto> getPaginatedProducts(
    _i1.TestSessionBuilder sessionBuilder,
    _i12.PaginationDto pagination,
  ) async {
    return _i1.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _i1.InternalTestSessionBuilder).internalBuild(
        endpoint: 'product',
        method: 'getPaginatedProducts',
      );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'product',
          methodName: 'getPaginatedProducts',
          parameters: _i1.testObjectToJson({'pagination': pagination}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _i3.Future<_i28.PaginatedProductsResponseDto>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _i3.Future<bool> toggleFavorite(
    _i1.TestSessionBuilder sessionBuilder,
    int productId,
  ) async {
    return _i1.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _i1.InternalTestSessionBuilder).internalBuild(
        endpoint: 'product',
        method: 'toggleFavorite',
      );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'product',
          methodName: 'toggleFavorite',
          parameters: _i1.testObjectToJson({'productId': productId}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _i3.Future<bool>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _i3.Future<bool> isFavorite(
    _i1.TestSessionBuilder sessionBuilder,
    int productId,
  ) async {
    return _i1.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _i1.InternalTestSessionBuilder).internalBuild(
        endpoint: 'product',
        method: 'isFavorite',
      );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'product',
          methodName: 'isFavorite',
          parameters: _i1.testObjectToJson({'productId': productId}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _i3.Future<bool>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _i3.Future<void> deleteProduct(
    _i1.TestSessionBuilder sessionBuilder,
    int productId,
  ) async {
    return _i1.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _i1.InternalTestSessionBuilder).internalBuild(
        endpoint: 'product',
        method: 'deleteProduct',
      );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'product',
          methodName: 'deleteProduct',
          parameters: _i1.testObjectToJson({'productId': productId}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _i3.Future<void>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _i3.Future<_i28.PaginatedProductsResponseDto> getMyProducts(
    _i1.TestSessionBuilder sessionBuilder,
    _i12.PaginationDto pagination,
  ) async {
    return _i1.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _i1.InternalTestSessionBuilder).internalBuild(
        endpoint: 'product',
        method: 'getMyProducts',
      );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'product',
          methodName: 'getMyProducts',
          parameters: _i1.testObjectToJson({'pagination': pagination}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _i3.Future<_i28.PaginatedProductsResponseDto>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _i3.Future<_i28.PaginatedProductsResponseDto> getMyFavoriteProducts(
    _i1.TestSessionBuilder sessionBuilder,
    _i12.PaginationDto pagination,
  ) async {
    return _i1.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _i1.InternalTestSessionBuilder).internalBuild(
        endpoint: 'product',
        method: 'getMyFavoriteProducts',
      );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'product',
          methodName: 'getMyFavoriteProducts',
          parameters: _i1.testObjectToJson({'pagination': pagination}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _i3.Future<_i28.PaginatedProductsResponseDto>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _i3.Future<_i25.Product> updateProductStatus(
    _i1.TestSessionBuilder sessionBuilder,
    _i29.UpdateProductStatusRequestDto request,
  ) async {
    return _i1.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _i1.InternalTestSessionBuilder).internalBuild(
        endpoint: 'product',
        method: 'updateProductStatus',
      );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'product',
          methodName: 'updateProductStatus',
          parameters: _i1.testObjectToJson({'request': request}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _i3.Future<_i25.Product>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _i3.Future<_i30.ProductStatsDto> getProductStats(
      _i1.TestSessionBuilder sessionBuilder) async {
    return _i1.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _i1.InternalTestSessionBuilder).internalBuild(
        endpoint: 'product',
        method: 'getProductStats',
      );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'product',
          methodName: 'getProductStats',
          parameters: _i1.testObjectToJson({}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _i3.Future<_i30.ProductStatsDto>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _i3.Future<_i30.ProductStatsDto> getProductStatsByUserId(
    _i1.TestSessionBuilder sessionBuilder,
    int userId,
  ) async {
    return _i1.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _i1.InternalTestSessionBuilder).internalBuild(
        endpoint: 'product',
        method: 'getProductStatsByUserId',
      );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'product',
          methodName: 'getProductStatsByUserId',
          parameters: _i1.testObjectToJson({'userId': userId}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _i3.Future<_i30.ProductStatsDto>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _i3.Future<_i28.PaginatedProductsResponseDto> getProductsByUserId(
    _i1.TestSessionBuilder sessionBuilder,
    int userId,
    _i12.PaginationDto pagination,
  ) async {
    return _i1.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _i1.InternalTestSessionBuilder).internalBuild(
        endpoint: 'product',
        method: 'getProductsByUserId',
      );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'product',
          methodName: 'getProductsByUserId',
          parameters: _i1.testObjectToJson({
            'userId': userId,
            'pagination': pagination,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _i3.Future<_i28.PaginatedProductsResponseDto>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }
}

class _ReviewEndpoint {
  _ReviewEndpoint(
    this._endpointDispatch,
    this._serializationManager,
  );

  final _i2.EndpointDispatch _endpointDispatch;

  final _i2.SerializationManager _serializationManager;

  _i3.Future<_i31.TransactionReviewResponseDto> createTransactionReview(
    _i1.TestSessionBuilder sessionBuilder,
    _i32.CreateTransactionReviewRequestDto request,
  ) async {
    return _i1.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _i1.InternalTestSessionBuilder).internalBuild(
        endpoint: 'review',
        method: 'createTransactionReview',
      );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'review',
          methodName: 'createTransactionReview',
          parameters: _i1.testObjectToJson({'request': request}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _i3.Future<_i31.TransactionReviewResponseDto>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _i3.Future<_i33.TransactionReviewListResponseDto> getBuyerReviews(
    _i1.TestSessionBuilder sessionBuilder, {
    required int page,
    required int limit,
  }) async {
    return _i1.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _i1.InternalTestSessionBuilder).internalBuild(
        endpoint: 'review',
        method: 'getBuyerReviews',
      );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'review',
          methodName: 'getBuyerReviews',
          parameters: _i1.testObjectToJson({
            'page': page,
            'limit': limit,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _i3.Future<_i33.TransactionReviewListResponseDto>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _i3.Future<_i33.TransactionReviewListResponseDto> getSellerReviews(
    _i1.TestSessionBuilder sessionBuilder, {
    required int page,
    required int limit,
  }) async {
    return _i1.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _i1.InternalTestSessionBuilder).internalBuild(
        endpoint: 'review',
        method: 'getSellerReviews',
      );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'review',
          methodName: 'getSellerReviews',
          parameters: _i1.testObjectToJson({
            'page': page,
            'limit': limit,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _i3.Future<_i33.TransactionReviewListResponseDto>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _i3.Future<_i31.TransactionReviewResponseDto> createSellerReview(
    _i1.TestSessionBuilder sessionBuilder,
    _i32.CreateTransactionReviewRequestDto request,
  ) async {
    return _i1.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _i1.InternalTestSessionBuilder).internalBuild(
        endpoint: 'review',
        method: 'createSellerReview',
      );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'review',
          methodName: 'createSellerReview',
          parameters: _i1.testObjectToJson({'request': request}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _i3.Future<_i31.TransactionReviewResponseDto>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _i3.Future<int> deleteReviewsByProductId(
    _i1.TestSessionBuilder sessionBuilder,
    int productId,
  ) async {
    return _i1.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _i1.InternalTestSessionBuilder).internalBuild(
        endpoint: 'review',
        method: 'deleteReviewsByProductId',
      );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'review',
          methodName: 'deleteReviewsByProductId',
          parameters: _i1.testObjectToJson({'productId': productId}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _i3.Future<int>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _i3.Future<bool> checkReviewExists(
    _i1.TestSessionBuilder sessionBuilder,
    int productId,
    int chatRoomId,
    _i34.ReviewType reviewType,
  ) async {
    return _i1.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _i1.InternalTestSessionBuilder).internalBuild(
        endpoint: 'review',
        method: 'checkReviewExists',
      );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'review',
          methodName: 'checkReviewExists',
          parameters: _i1.testObjectToJson({
            'productId': productId,
            'chatRoomId': chatRoomId,
            'reviewType': reviewType,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _i3.Future<bool>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _i3.Future<_i33.TransactionReviewListResponseDto> getAllReviewsByUserId(
    _i1.TestSessionBuilder sessionBuilder,
    int userId, {
    required int page,
    required int limit,
  }) async {
    return _i1.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _i1.InternalTestSessionBuilder).internalBuild(
        endpoint: 'review',
        method: 'getAllReviewsByUserId',
      );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'review',
          methodName: 'getAllReviewsByUserId',
          parameters: _i1.testObjectToJson({
            'userId': userId,
            'page': page,
            'limit': limit,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _i3.Future<_i33.TransactionReviewListResponseDto>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }
}

class _FcmEndpoint {
  _FcmEndpoint(
    this._endpointDispatch,
    this._serializationManager,
  );

  final _i2.EndpointDispatch _endpointDispatch;

  final _i2.SerializationManager _serializationManager;

  _i3.Future<bool> registerFcmToken(
    _i1.TestSessionBuilder sessionBuilder,
    String token,
    String? deviceType,
  ) async {
    return _i1.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _i1.InternalTestSessionBuilder).internalBuild(
        endpoint: 'fcm',
        method: 'registerFcmToken',
      );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'fcm',
          methodName: 'registerFcmToken',
          parameters: _i1.testObjectToJson({
            'token': token,
            'deviceType': deviceType,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _i3.Future<bool>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _i3.Future<bool> deleteFcmToken(
    _i1.TestSessionBuilder sessionBuilder,
    String token,
  ) async {
    return _i1.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _i1.InternalTestSessionBuilder).internalBuild(
        endpoint: 'fcm',
        method: 'deleteFcmToken',
      );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'fcm',
          methodName: 'deleteFcmToken',
          parameters: _i1.testObjectToJson({'token': token}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _i3.Future<bool>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }
}

class _UserEndpoint {
  _UserEndpoint(
    this._endpointDispatch,
    this._serializationManager,
  );

  final _i2.EndpointDispatch _endpointDispatch;

  final _i2.SerializationManager _serializationManager;

  _i3.Future<_i6.User> getMe(_i1.TestSessionBuilder sessionBuilder) async {
    return _i1.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _i1.InternalTestSessionBuilder).internalBuild(
        endpoint: 'user',
        method: 'getMe',
      );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'user',
          methodName: 'getMe',
          parameters: _i1.testObjectToJson({}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _i3.Future<_i6.User>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _i3.Future<_i6.User> getUserById(
    _i1.TestSessionBuilder sessionBuilder,
    int id,
  ) async {
    return _i1.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _i1.InternalTestSessionBuilder).internalBuild(
        endpoint: 'user',
        method: 'getUserById',
      );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'user',
          methodName: 'getUserById',
          parameters: _i1.testObjectToJson({'id': id}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _i3.Future<_i6.User>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _i3.Future<List<String>> getUserScopes(
      _i1.TestSessionBuilder sessionBuilder) async {
    return _i1.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _i1.InternalTestSessionBuilder).internalBuild(
        endpoint: 'user',
        method: 'getUserScopes',
      );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'user',
          methodName: 'getUserScopes',
          parameters: _i1.testObjectToJson({}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _i3.Future<List<String>>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _i3.Future<_i6.User> updateUserProfile(
    _i1.TestSessionBuilder sessionBuilder,
    _i35.UpdateUserProfileRequestDto request,
  ) async {
    return _i1.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _i1.InternalTestSessionBuilder).internalBuild(
        endpoint: 'user',
        method: 'updateUserProfile',
      );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'user',
          methodName: 'updateUserProfile',
          parameters: _i1.testObjectToJson({'request': request}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue = await (_localCallContext.method.call(
          _localUniqueSession,
          _localCallContext.arguments,
        ) as _i3.Future<_i6.User>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }
}
