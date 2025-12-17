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
import 'package:gear_freak_client/src/protocol/feature/chat/model/dto/create_chat_room_response.dto.dart'
    as _i6;
import 'package:gear_freak_client/src/protocol/feature/chat/model/dto/create_chat_room_request.dto.dart'
    as _i7;
import 'package:gear_freak_client/src/protocol/feature/chat/model/chat_room.dart'
    as _i8;
import 'package:gear_freak_client/src/protocol/feature/chat/model/dto/paginated_chat_rooms_response.dto.dart'
    as _i9;
import 'package:gear_freak_client/src/protocol/common/model/pagination_dto.dart'
    as _i10;
import 'package:gear_freak_client/src/protocol/feature/chat/model/dto/join_chat_room_response.dto.dart'
    as _i11;
import 'package:gear_freak_client/src/protocol/feature/chat/model/dto/join_chat_room_request.dto.dart'
    as _i12;
import 'package:gear_freak_client/src/protocol/feature/chat/model/dto/leave_chat_room_response.dto.dart'
    as _i13;
import 'package:gear_freak_client/src/protocol/feature/chat/model/dto/leave_chat_room_request.dto.dart'
    as _i14;
import 'package:gear_freak_client/src/protocol/feature/chat/model/dto/chat_participant_info.dto.dart'
    as _i15;
import 'package:gear_freak_client/src/protocol/feature/chat/model/dto/chat_message_response.dto.dart'
    as _i16;
import 'package:gear_freak_client/src/protocol/feature/chat/model/dto/send_message_request.dto.dart'
    as _i17;
import 'package:gear_freak_client/src/protocol/feature/chat/model/dto/paginated_chat_messages_response.dto.dart'
    as _i18;
import 'package:gear_freak_client/src/protocol/feature/chat/model/dto/get_chat_messages_request.dto.dart'
    as _i19;
import 'package:gear_freak_client/src/protocol/feature/chat/model/chat_message.dart'
    as _i20;
import 'package:gear_freak_client/src/protocol/feature/chat/model/dto/update_chat_room_notification_request.dto.dart'
    as _i21;
import 'package:gear_freak_client/src/protocol/feature/notification/model/dto/notification_list_response.dto.dart'
    as _i22;
import 'package:gear_freak_client/src/protocol/feature/product/model/product.dart'
    as _i23;
import 'package:gear_freak_client/src/protocol/feature/product/model/dto/create_product_request.dto.dart'
    as _i24;
import 'package:gear_freak_client/src/protocol/feature/product/model/dto/update_product_request.dto.dart'
    as _i25;
import 'package:gear_freak_client/src/protocol/feature/product/model/dto/paginated_products_response.dto.dart'
    as _i26;
import 'package:gear_freak_client/src/protocol/feature/product/model/dto/update_product_status_request.dto.dart'
    as _i27;
import 'package:gear_freak_client/src/protocol/feature/product/model/dto/product_stats.dto.dart'
    as _i28;
import 'package:gear_freak_client/src/protocol/feature/review/model/dto/transaction_review_response.dto.dart'
    as _i29;
import 'package:gear_freak_client/src/protocol/feature/review/model/dto/create_transaction_review_request.dto.dart'
    as _i30;
import 'package:gear_freak_client/src/protocol/feature/review/model/dto/transaction_review_list_response.dto.dart'
    as _i31;
import 'package:gear_freak_client/src/protocol/feature/review/model/review_type.dart'
    as _i32;
import 'package:gear_freak_client/src/protocol/feature/user/model/dto/update_user_profile_request.dto.dart'
    as _i33;
import 'package:serverpod_auth_client/serverpod_auth_client.dart' as _i34;
import 'protocol.dart' as _i35;

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

/// 채팅 엔드포인트
/// {@category Endpoint}
class EndpointChat extends _i1.EndpointRef {
  EndpointChat(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'chat';

  /// 채팅방 생성 또는 조회
  /// 상품 ID와 상대방 사용자 ID로 기존 채팅방을 찾거나 새로 생성합니다.
  _i2.Future<_i6.CreateChatRoomResponseDto> createOrGetChatRoom(
          _i7.CreateChatRoomRequestDto request) =>
      caller.callServerEndpoint<_i6.CreateChatRoomResponseDto>(
        'chat',
        'createOrGetChatRoom',
        {'request': request},
      );

  /// 채팅방 정보 조회
  /// 현재 사용자의 unreadCount도 함께 계산하여 반환
  _i2.Future<_i8.ChatRoom?> getChatRoomById(int chatRoomId) =>
      caller.callServerEndpoint<_i8.ChatRoom?>(
        'chat',
        'getChatRoomById',
        {'chatRoomId': chatRoomId},
      );

  /// 상품 ID로 채팅방 목록 조회
  _i2.Future<List<_i8.ChatRoom>?> getChatRoomsByProductId(int productId) =>
      caller.callServerEndpoint<List<_i8.ChatRoom>?>(
        'chat',
        'getChatRoomsByProductId',
        {'productId': productId},
      );

  /// 사용자가 참여한 채팅방 목록 조회 (상품 ID 기준, 페이지네이션)
  _i2.Future<_i9.PaginatedChatRoomsResponseDto> getUserChatRoomsByProductId(
    int productId,
    _i10.PaginationDto pagination,
  ) =>
      caller.callServerEndpoint<_i9.PaginatedChatRoomsResponseDto>(
        'chat',
        'getUserChatRoomsByProductId',
        {
          'productId': productId,
          'pagination': pagination,
        },
      );

  /// 사용자가 참여한 모든 채팅방 목록 조회 (페이지네이션)
  _i2.Future<_i9.PaginatedChatRoomsResponseDto> getMyChatRooms(
          _i10.PaginationDto pagination) =>
      caller.callServerEndpoint<_i9.PaginatedChatRoomsResponseDto>(
        'chat',
        'getMyChatRooms',
        {'pagination': pagination},
      );

  /// 채팅방 참여
  _i2.Future<_i11.JoinChatRoomResponseDto> joinChatRoom(
          _i12.JoinChatRoomRequestDto request) =>
      caller.callServerEndpoint<_i11.JoinChatRoomResponseDto>(
        'chat',
        'joinChatRoom',
        {'request': request},
      );

  /// 채팅방 나가기
  _i2.Future<_i13.LeaveChatRoomResponseDto> leaveChatRoom(
          _i14.LeaveChatRoomRequestDto request) =>
      caller.callServerEndpoint<_i13.LeaveChatRoomResponseDto>(
        'chat',
        'leaveChatRoom',
        {'request': request},
      );

  /// 채팅방 참여자 목록 조회
  _i2.Future<List<_i15.ChatParticipantInfoDto>> getChatParticipants(
          int chatRoomId) =>
      caller.callServerEndpoint<List<_i15.ChatParticipantInfoDto>>(
        'chat',
        'getChatParticipants',
        {'chatRoomId': chatRoomId},
      );

  /// 메시지 전송
  _i2.Future<_i16.ChatMessageResponseDto> sendMessage(
          _i17.SendMessageRequestDto request) =>
      caller.callServerEndpoint<_i16.ChatMessageResponseDto>(
        'chat',
        'sendMessage',
        {'request': request},
      );

  /// 페이지네이션된 메시지 조회
  _i2.Future<_i18.PaginatedChatMessagesResponseDto> getChatMessagesPaginated(
          _i19.GetChatMessagesRequestDto request) =>
      caller.callServerEndpoint<_i18.PaginatedChatMessagesResponseDto>(
        'chat',
        'getChatMessagesPaginated',
        {'request': request},
      );

  /// 채팅방의 마지막 메시지 조회
  _i2.Future<_i20.ChatMessage?> getLastMessageByChatRoomId(int chatRoomId) =>
      caller.callServerEndpoint<_i20.ChatMessage?>(
        'chat',
        'getLastMessageByChatRoomId',
        {'chatRoomId': chatRoomId},
      );

  /// 채팅방 이미지 업로드를 위한 Presigned URL 생성
  /// Private 버킷의 chatRoom/{chatRoomId}/ 경로에 바로 업로드
  _i2.Future<_i3.GeneratePresignedUploadUrlResponseDto>
      generateChatRoomImageUploadUrl(
    int chatRoomId,
    String fileName,
    String contentType,
    int fileSize,
  ) =>
          caller.callServerEndpoint<_i3.GeneratePresignedUploadUrlResponseDto>(
            'chat',
            'generateChatRoomImageUploadUrl',
            {
              'chatRoomId': chatRoomId,
              'fileName': fileName,
              'contentType': contentType,
              'fileSize': fileSize,
            },
          );

  /// 채팅방 읽음 처리
  /// 채팅방의 모든 메시지를 읽음 처리합니다.
  _i2.Future<void> markChatRoomAsRead(int chatRoomId) =>
      caller.callServerEndpoint<void>(
        'chat',
        'markChatRoomAsRead',
        {'chatRoomId': chatRoomId},
      );

  /// 채팅방 알림 설정 변경
  /// 사용자가 특정 채팅방의 알림을 켜거나 끕니다.
  _i2.Future<void> updateChatRoomNotification(
          _i21.UpdateChatRoomNotificationRequestDto request) =>
      caller.callServerEndpoint<void>(
        'chat',
        'updateChatRoomNotification',
        {'request': request},
      );
}

/// Redis 기반 실시간 채팅 스트림 관리 엔드포인트
/// {@category Endpoint}
class EndpointChatStream extends _i1.EndpointRef {
  EndpointChatStream(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'chatStream';

  /// 채팅방 메시지 스트림 구독 (Redis 기반)
  /// 특정 채팅방의 실시간 메시지를 받기 위한 스트림
  _i2.Stream<_i16.ChatMessageResponseDto> chatMessageStream(int chatRoomId) =>
      caller.callStreamingServerEndpoint<
          _i2.Stream<_i16.ChatMessageResponseDto>, _i16.ChatMessageResponseDto>(
        'chatStream',
        'chatMessageStream',
        {'chatRoomId': chatRoomId},
        {},
      );
}

/// 알림 엔드포인트
/// {@category Endpoint}
class EndpointNotification extends _i1.EndpointRef {
  EndpointNotification(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'notification';

  /// 알림 목록 조회 (페이지네이션)
  ///
  /// [session]은 Serverpod 세션입니다.
  /// [page]는 페이지 번호입니다 (기본값: 1).
  /// [limit]는 페이지당 항목 수입니다 (기본값: 10).
  /// 반환: 알림 목록 응답 DTO
  _i2.Future<_i22.NotificationListResponseDto> getNotifications({
    required int page,
    required int limit,
  }) =>
      caller.callServerEndpoint<_i22.NotificationListResponseDto>(
        'notification',
        'getNotifications',
        {
          'page': page,
          'limit': limit,
        },
      );

  /// 알림 읽음 처리
  ///
  /// [session]은 Serverpod 세션입니다.
  /// [notificationId]는 읽음 처리할 알림 ID입니다.
  /// 반환: 읽음 처리 성공 여부
  _i2.Future<bool> markAsRead(int notificationId) =>
      caller.callServerEndpoint<bool>(
        'notification',
        'markAsRead',
        {'notificationId': notificationId},
      );

  /// 알림 삭제
  ///
  /// [session]은 Serverpod 세션입니다.
  /// [notificationId]는 삭제할 알림 ID입니다.
  /// 반환: 삭제 성공 여부
  _i2.Future<bool> deleteNotification(int notificationId) =>
      caller.callServerEndpoint<bool>(
        'notification',
        'deleteNotification',
        {'notificationId': notificationId},
      );

  /// 읽지 않은 알림 개수 조회
  ///
  /// [session]은 Serverpod 세션입니다.
  /// 반환: 읽지 않은 알림 개수
  _i2.Future<int> getUnreadCount() => caller.callServerEndpoint<int>(
        'notification',
        'getUnreadCount',
        {},
      );
}

/// 상품 엔드포인트
/// {@category Endpoint}
class EndpointProduct extends _i1.EndpointRef {
  EndpointProduct(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'product';

  /// 상품 생성
  _i2.Future<_i23.Product> createProduct(
          _i24.CreateProductRequestDto request) =>
      caller.callServerEndpoint<_i23.Product>(
        'product',
        'createProduct',
        {'request': request},
      );

  /// 상품 수정
  _i2.Future<_i23.Product> updateProduct(
          _i25.UpdateProductRequestDto request) =>
      caller.callServerEndpoint<_i23.Product>(
        'product',
        'updateProduct',
        {'request': request},
      );

  _i2.Future<_i23.Product> getProduct(int id) =>
      caller.callServerEndpoint<_i23.Product>(
        'product',
        'getProduct',
        {'id': id},
      );

  /// 페이지네이션된 상품 목록 조회
  _i2.Future<_i26.PaginatedProductsResponseDto> getPaginatedProducts(
          _i10.PaginationDto pagination) =>
      caller.callServerEndpoint<_i26.PaginatedProductsResponseDto>(
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

  /// 내가 등록한 상품 목록 조회 (페이지네이션)
  _i2.Future<_i26.PaginatedProductsResponseDto> getMyProducts(
          _i10.PaginationDto pagination) =>
      caller.callServerEndpoint<_i26.PaginatedProductsResponseDto>(
        'product',
        'getMyProducts',
        {'pagination': pagination},
      );

  /// 내가 관심목록한 상품 목록 조회 (페이지네이션)
  _i2.Future<_i26.PaginatedProductsResponseDto> getMyFavoriteProducts(
          _i10.PaginationDto pagination) =>
      caller.callServerEndpoint<_i26.PaginatedProductsResponseDto>(
        'product',
        'getMyFavoriteProducts',
        {'pagination': pagination},
      );

  /// 상품 상태 변경
  _i2.Future<_i23.Product> updateProductStatus(
          _i27.UpdateProductStatusRequestDto request) =>
      caller.callServerEndpoint<_i23.Product>(
        'product',
        'updateProductStatus',
        {'request': request},
      );

  /// 상품 통계 조회 (판매중, 거래완료, 관심목록 개수, 후기 개수)
  /// 현재 로그인한 사용자의 통계를 조회합니다.
  _i2.Future<_i28.ProductStatsDto> getProductStats() =>
      caller.callServerEndpoint<_i28.ProductStatsDto>(
        'product',
        'getProductStats',
        {},
      );

  /// 다른 사용자의 상품 통계 조회 (판매중, 거래완료, 관심목록 개수, 후기 개수)
  /// [userId]는 조회할 사용자의 ID입니다.
  _i2.Future<_i28.ProductStatsDto> getProductStatsByUserId(int userId) =>
      caller.callServerEndpoint<_i28.ProductStatsDto>(
        'product',
        'getProductStatsByUserId',
        {'userId': userId},
      );
}

/// 리뷰 엔드포인트
/// {@category Endpoint}
class EndpointReview extends _i1.EndpointRef {
  EndpointReview(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'review';

  /// 거래 후기 작성
  ///
  /// [session]은 Serverpod 세션입니다.
  /// [request]는 후기 작성 요청 정보입니다.
  /// 반환: 생성된 후기 응답 DTO
  _i2.Future<_i29.TransactionReviewResponseDto> createTransactionReview(
          _i30.CreateTransactionReviewRequestDto request) =>
      caller.callServerEndpoint<_i29.TransactionReviewResponseDto>(
        'review',
        'createTransactionReview',
        {'request': request},
      );

  /// 구매자 후기 목록 조회 (페이지네이션)
  /// 구매자가 나에게 쓴 후기 (reviewType = buyer_to_seller)
  ///
  /// [session]은 Serverpod 세션입니다.
  /// [page]는 페이지 번호입니다 (기본값: 1).
  /// [limit]는 페이지당 항목 수입니다 (기본값: 10).
  /// 반환: 후기 목록 응답 DTO
  _i2.Future<_i31.TransactionReviewListResponseDto> getBuyerReviews({
    required int page,
    required int limit,
  }) =>
      caller.callServerEndpoint<_i31.TransactionReviewListResponseDto>(
        'review',
        'getBuyerReviews',
        {
          'page': page,
          'limit': limit,
        },
      );

  /// 판매자 후기 목록 조회 (페이지네이션)
  /// 판매자가 나에게 쓴 후기 (reviewType = seller_to_buyer)
  ///
  /// [session]은 Serverpod 세션입니다.
  /// [page]는 페이지 번호입니다 (기본값: 1).
  /// [limit]는 페이지당 항목 수입니다 (기본값: 10).
  /// 반환: 후기 목록 응답 DTO
  _i2.Future<_i31.TransactionReviewListResponseDto> getSellerReviews({
    required int page,
    required int limit,
  }) =>
      caller.callServerEndpoint<_i31.TransactionReviewListResponseDto>(
        'review',
        'getSellerReviews',
        {
          'page': page,
          'limit': limit,
        },
      );

  /// 판매자에 대한 후기 작성 (구매자 → 판매자)
  ///
  /// [session]은 Serverpod 세션입니다.
  /// [request]는 후기 작성 요청 정보입니다.
  /// 반환: 생성된 후기 응답 DTO
  _i2.Future<_i29.TransactionReviewResponseDto> createSellerReview(
          _i30.CreateTransactionReviewRequestDto request) =>
      caller.callServerEndpoint<_i29.TransactionReviewResponseDto>(
        'review',
        'createSellerReview',
        {'request': request},
      );

  /// 상품 ID로 후기 삭제 (상품 상태 변경 시 사용)
  ///
  /// [session]은 Serverpod 세션입니다.
  /// [productId]는 상품 ID입니다.
  /// 반환: 삭제된 후기 개수
  _i2.Future<int> deleteReviewsByProductId(int productId) =>
      caller.callServerEndpoint<int>(
        'review',
        'deleteReviewsByProductId',
        {'productId': productId},
      );

  /// 리뷰 존재 여부 확인
  ///
  /// [session]은 Serverpod 세션입니다.
  /// [productId]는 상품 ID입니다.
  /// [chatRoomId]는 채팅방 ID입니다.
  /// [reviewType]는 리뷰 타입입니다.
  /// 반환: 리뷰가 존재하면 true, 없으면 false
  _i2.Future<bool> checkReviewExists(
    int productId,
    int chatRoomId,
    _i32.ReviewType reviewType,
  ) =>
      caller.callServerEndpoint<bool>(
        'review',
        'checkReviewExists',
        {
          'productId': productId,
          'chatRoomId': chatRoomId,
          'reviewType': reviewType,
        },
      );
}

/// FCM 엔드포인트
/// FCM 토큰 등록 및 삭제를 처리합니다.
/// {@category Endpoint}
class EndpointFcm extends _i1.EndpointRef {
  EndpointFcm(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'fcm';

  /// FCM 토큰 등록
  ///
  /// [token]은 FCM 토큰입니다.
  /// [deviceType]은 디바이스 타입입니다 (ios, android).
  _i2.Future<bool> registerFcmToken(
    String token,
    String? deviceType,
  ) =>
      caller.callServerEndpoint<bool>(
        'fcm',
        'registerFcmToken',
        {
          'token': token,
          'deviceType': deviceType,
        },
      );

  /// FCM 토큰 삭제
  ///
  /// [token]은 FCM 토큰입니다.
  _i2.Future<bool> deleteFcmToken(String token) =>
      caller.callServerEndpoint<bool>(
        'fcm',
        'deleteFcmToken',
        {'token': token},
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

  /// 사용자 프로필 수정
  _i2.Future<_i5.User> updateUserProfile(
          _i33.UpdateUserProfileRequestDto request) =>
      caller.callServerEndpoint<_i5.User>(
        'user',
        'updateUserProfile',
        {'request': request},
      );
}

class Modules {
  Modules(Client client) {
    auth = _i34.Caller(client);
  }

  late final _i34.Caller auth;
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
          _i35.Protocol(),
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
    chat = EndpointChat(this);
    chatStream = EndpointChatStream(this);
    notification = EndpointNotification(this);
    product = EndpointProduct(this);
    review = EndpointReview(this);
    fcm = EndpointFcm(this);
    user = EndpointUser(this);
    modules = Modules(this);
  }

  late final EndpointS3 s3;

  late final EndpointAuth auth;

  late final EndpointChat chat;

  late final EndpointChatStream chatStream;

  late final EndpointNotification notification;

  late final EndpointProduct product;

  late final EndpointReview review;

  late final EndpointFcm fcm;

  late final EndpointUser user;

  late final Modules modules;

  @override
  Map<String, _i1.EndpointRef> get endpointRefLookup => {
        's3': s3,
        'auth': auth,
        'chat': chat,
        'chatStream': chatStream,
        'notification': notification,
        'product': product,
        'review': review,
        'fcm': fcm,
        'user': user,
      };

  @override
  Map<String, _i1.ModuleEndpointCaller> get moduleLookup =>
      {'auth': modules.auth};
}
