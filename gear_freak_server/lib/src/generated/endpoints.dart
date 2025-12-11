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
import '../feature/chat/endpoint/chat_endpoint.dart' as _i4;
import '../feature/chat/endpoint/chat_stream_endpoint.dart' as _i5;
import '../feature/product/endpoint/product_endpoint.dart' as _i6;
import '../feature/user/endpoint/user_endpoint.dart' as _i7;
import 'package:gear_freak_server/src/generated/common/s3/model/dto/generate_presigned_upload_url_request.dto.dart'
    as _i8;
import 'package:gear_freak_server/src/generated/feature/chat/model/dto/create_chat_room_request.dto.dart'
    as _i9;
import 'package:gear_freak_server/src/generated/common/model/pagination_dto.dart'
    as _i10;
import 'package:gear_freak_server/src/generated/feature/chat/model/dto/join_chat_room_request.dto.dart'
    as _i11;
import 'package:gear_freak_server/src/generated/feature/chat/model/dto/leave_chat_room_request.dto.dart'
    as _i12;
import 'package:gear_freak_server/src/generated/feature/chat/model/dto/send_message_request.dto.dart'
    as _i13;
import 'package:gear_freak_server/src/generated/feature/chat/model/dto/get_chat_messages_request.dto.dart'
    as _i14;
import 'package:gear_freak_server/src/generated/feature/product/model/dto/create_product_request.dto.dart'
    as _i15;
import 'package:gear_freak_server/src/generated/feature/product/model/dto/update_product_request.dto.dart'
    as _i16;
import 'package:gear_freak_server/src/generated/feature/product/model/dto/update_product_status_request.dto.dart'
    as _i17;
import 'package:gear_freak_server/src/generated/feature/user/model/dto/update_user_profile_request.dto.dart'
    as _i18;
import 'package:serverpod_auth_server/serverpod_auth_server.dart' as _i19;

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
      'chat': _i4.ChatEndpoint()
        ..initialize(
          server,
          'chat',
          null,
        ),
      'chatStream': _i5.ChatStreamEndpoint()
        ..initialize(
          server,
          'chatStream',
          null,
        ),
      'product': _i6.ProductEndpoint()
        ..initialize(
          server,
          'product',
          null,
        ),
      'user': _i7.UserEndpoint()
        ..initialize(
          server,
          'user',
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
              type: _i1.getType<_i8.GeneratePresignedUploadUrlRequestDto>(),
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
        ),
        'deleteS3File': _i1.MethodConnector(
          name: 'deleteS3File',
          params: {
            'fileKey': _i1.ParameterDescription(
              name: 'fileKey',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'bucketType': _i1.ParameterDescription(
              name: 'bucketType',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['s3'] as _i2.S3Endpoint).deleteS3File(
            session,
            params['fileKey'],
            params['bucketType'],
          ),
        ),
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
    connectors['chat'] = _i1.EndpointConnector(
      name: 'chat',
      endpoint: endpoints['chat']!,
      methodConnectors: {
        'createOrGetChatRoom': _i1.MethodConnector(
          name: 'createOrGetChatRoom',
          params: {
            'request': _i1.ParameterDescription(
              name: 'request',
              type: _i1.getType<_i9.CreateChatRoomRequestDto>(),
              nullable: false,
            )
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['chat'] as _i4.ChatEndpoint).createOrGetChatRoom(
            session,
            params['request'],
          ),
        ),
        'getChatRoomById': _i1.MethodConnector(
          name: 'getChatRoomById',
          params: {
            'chatRoomId': _i1.ParameterDescription(
              name: 'chatRoomId',
              type: _i1.getType<int>(),
              nullable: false,
            )
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['chat'] as _i4.ChatEndpoint).getChatRoomById(
            session,
            params['chatRoomId'],
          ),
        ),
        'getChatRoomsByProductId': _i1.MethodConnector(
          name: 'getChatRoomsByProductId',
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
              (endpoints['chat'] as _i4.ChatEndpoint).getChatRoomsByProductId(
            session,
            params['productId'],
          ),
        ),
        'getUserChatRoomsByProductId': _i1.MethodConnector(
          name: 'getUserChatRoomsByProductId',
          params: {
            'productId': _i1.ParameterDescription(
              name: 'productId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'pagination': _i1.ParameterDescription(
              name: 'pagination',
              type: _i1.getType<_i10.PaginationDto>(),
              nullable: false,
            ),
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['chat'] as _i4.ChatEndpoint)
                  .getUserChatRoomsByProductId(
            session,
            params['productId'],
            params['pagination'],
          ),
        ),
        'getMyChatRooms': _i1.MethodConnector(
          name: 'getMyChatRooms',
          params: {
            'pagination': _i1.ParameterDescription(
              name: 'pagination',
              type: _i1.getType<_i10.PaginationDto>(),
              nullable: false,
            )
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['chat'] as _i4.ChatEndpoint).getMyChatRooms(
            session,
            params['pagination'],
          ),
        ),
        'joinChatRoom': _i1.MethodConnector(
          name: 'joinChatRoom',
          params: {
            'request': _i1.ParameterDescription(
              name: 'request',
              type: _i1.getType<_i11.JoinChatRoomRequestDto>(),
              nullable: false,
            )
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['chat'] as _i4.ChatEndpoint).joinChatRoom(
            session,
            params['request'],
          ),
        ),
        'leaveChatRoom': _i1.MethodConnector(
          name: 'leaveChatRoom',
          params: {
            'request': _i1.ParameterDescription(
              name: 'request',
              type: _i1.getType<_i12.LeaveChatRoomRequestDto>(),
              nullable: false,
            )
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['chat'] as _i4.ChatEndpoint).leaveChatRoom(
            session,
            params['request'],
          ),
        ),
        'getChatParticipants': _i1.MethodConnector(
          name: 'getChatParticipants',
          params: {
            'chatRoomId': _i1.ParameterDescription(
              name: 'chatRoomId',
              type: _i1.getType<int>(),
              nullable: false,
            )
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['chat'] as _i4.ChatEndpoint).getChatParticipants(
            session,
            params['chatRoomId'],
          ),
        ),
        'sendMessage': _i1.MethodConnector(
          name: 'sendMessage',
          params: {
            'request': _i1.ParameterDescription(
              name: 'request',
              type: _i1.getType<_i13.SendMessageRequestDto>(),
              nullable: false,
            )
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['chat'] as _i4.ChatEndpoint).sendMessage(
            session,
            params['request'],
          ),
        ),
        'getChatMessagesPaginated': _i1.MethodConnector(
          name: 'getChatMessagesPaginated',
          params: {
            'request': _i1.ParameterDescription(
              name: 'request',
              type: _i1.getType<_i14.GetChatMessagesRequestDto>(),
              nullable: false,
            )
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['chat'] as _i4.ChatEndpoint).getChatMessagesPaginated(
            session,
            params['request'],
          ),
        ),
        'getLastMessageByChatRoomId': _i1.MethodConnector(
          name: 'getLastMessageByChatRoomId',
          params: {
            'chatRoomId': _i1.ParameterDescription(
              name: 'chatRoomId',
              type: _i1.getType<int>(),
              nullable: false,
            )
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['chat'] as _i4.ChatEndpoint)
                  .getLastMessageByChatRoomId(
            session,
            params['chatRoomId'],
          ),
        ),
        'generateChatRoomImageUploadUrl': _i1.MethodConnector(
          name: 'generateChatRoomImageUploadUrl',
          params: {
            'chatRoomId': _i1.ParameterDescription(
              name: 'chatRoomId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'fileName': _i1.ParameterDescription(
              name: 'fileName',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'contentType': _i1.ParameterDescription(
              name: 'contentType',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'fileSize': _i1.ParameterDescription(
              name: 'fileSize',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['chat'] as _i4.ChatEndpoint)
                  .generateChatRoomImageUploadUrl(
            session,
            params['chatRoomId'],
            params['fileName'],
            params['contentType'],
            params['fileSize'],
          ),
        ),
      },
    );
    connectors['chatStream'] = _i1.EndpointConnector(
      name: 'chatStream',
      endpoint: endpoints['chatStream']!,
      methodConnectors: {
        'chatMessageStream': _i1.MethodStreamConnector(
          name: 'chatMessageStream',
          params: {
            'chatRoomId': _i1.ParameterDescription(
              name: 'chatRoomId',
              type: _i1.getType<int>(),
              nullable: false,
            )
          },
          streamParams: {},
          returnType: _i1.MethodStreamReturnType.streamType,
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
            Map<String, Stream> streamParams,
          ) =>
              (endpoints['chatStream'] as _i5.ChatStreamEndpoint)
                  .chatMessageStream(
            session,
            params['chatRoomId'],
          ),
        )
      },
    );
    connectors['product'] = _i1.EndpointConnector(
      name: 'product',
      endpoint: endpoints['product']!,
      methodConnectors: {
        'createProduct': _i1.MethodConnector(
          name: 'createProduct',
          params: {
            'request': _i1.ParameterDescription(
              name: 'request',
              type: _i1.getType<_i15.CreateProductRequestDto>(),
              nullable: false,
            )
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['product'] as _i6.ProductEndpoint).createProduct(
            session,
            params['request'],
          ),
        ),
        'updateProduct': _i1.MethodConnector(
          name: 'updateProduct',
          params: {
            'request': _i1.ParameterDescription(
              name: 'request',
              type: _i1.getType<_i16.UpdateProductRequestDto>(),
              nullable: false,
            )
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['product'] as _i6.ProductEndpoint).updateProduct(
            session,
            params['request'],
          ),
        ),
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
              (endpoints['product'] as _i6.ProductEndpoint).getProduct(
            session,
            params['id'],
          ),
        ),
        'getPaginatedProducts': _i1.MethodConnector(
          name: 'getPaginatedProducts',
          params: {
            'pagination': _i1.ParameterDescription(
              name: 'pagination',
              type: _i1.getType<_i10.PaginationDto>(),
              nullable: false,
            )
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['product'] as _i6.ProductEndpoint)
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
              (endpoints['product'] as _i6.ProductEndpoint).toggleFavorite(
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
              (endpoints['product'] as _i6.ProductEndpoint).isFavorite(
            session,
            params['productId'],
          ),
        ),
        'deleteProduct': _i1.MethodConnector(
          name: 'deleteProduct',
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
              (endpoints['product'] as _i6.ProductEndpoint).deleteProduct(
            session,
            params['productId'],
          ),
        ),
        'getMyProducts': _i1.MethodConnector(
          name: 'getMyProducts',
          params: {
            'pagination': _i1.ParameterDescription(
              name: 'pagination',
              type: _i1.getType<_i10.PaginationDto>(),
              nullable: false,
            )
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['product'] as _i6.ProductEndpoint).getMyProducts(
            session,
            params['pagination'],
          ),
        ),
        'getMyFavoriteProducts': _i1.MethodConnector(
          name: 'getMyFavoriteProducts',
          params: {
            'pagination': _i1.ParameterDescription(
              name: 'pagination',
              type: _i1.getType<_i10.PaginationDto>(),
              nullable: false,
            )
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['product'] as _i6.ProductEndpoint)
                  .getMyFavoriteProducts(
            session,
            params['pagination'],
          ),
        ),
        'updateProductStatus': _i1.MethodConnector(
          name: 'updateProductStatus',
          params: {
            'request': _i1.ParameterDescription(
              name: 'request',
              type: _i1.getType<_i17.UpdateProductStatusRequestDto>(),
              nullable: false,
            )
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['product'] as _i6.ProductEndpoint).updateProductStatus(
            session,
            params['request'],
          ),
        ),
        'getProductStats': _i1.MethodConnector(
          name: 'getProductStats',
          params: {},
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['product'] as _i6.ProductEndpoint)
                  .getProductStats(session),
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
              (endpoints['user'] as _i7.UserEndpoint).getMe(session),
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
              (endpoints['user'] as _i7.UserEndpoint).getUserById(
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
              (endpoints['user'] as _i7.UserEndpoint).getUserScopes(session),
        ),
        'updateUserProfile': _i1.MethodConnector(
          name: 'updateUserProfile',
          params: {
            'request': _i1.ParameterDescription(
              name: 'request',
              type: _i1.getType<_i18.UpdateUserProfileRequestDto>(),
              nullable: false,
            )
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['user'] as _i7.UserEndpoint).updateUserProfile(
            session,
            params['request'],
          ),
        ),
      },
    );
    modules['serverpod_auth'] = _i19.Endpoints()..initializeEndpoints(server);
  }
}
