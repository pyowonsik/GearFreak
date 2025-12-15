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
import 'feature/chat/model/dto/join_chat_room_response.dto.dart' as _i2;
import 'common/s3/model/dto/generate_presigned_upload_url_request.dto.dart'
    as _i3;
import 'common/s3/model/dto/generate_presigned_upload_url_response.dto.dart'
    as _i4;
import 'feature/chat/model/chat_message.dart' as _i5;
import 'feature/chat/model/chat_participant.dart' as _i6;
import 'feature/chat/model/chat_room.dart' as _i7;
import 'feature/chat/model/dto/chat_message_response.dto.dart' as _i8;
import 'feature/chat/model/dto/chat_participant_info.dto.dart' as _i9;
import 'feature/chat/model/dto/create_chat_room_request.dto.dart' as _i10;
import 'feature/chat/model/dto/create_chat_room_response.dto.dart' as _i11;
import 'feature/chat/model/dto/get_chat_messages_request.dto.dart' as _i12;
import 'feature/chat/model/dto/join_chat_room_request.dto.dart' as _i13;
import 'common/model/pagination_dto.dart' as _i14;
import 'feature/chat/model/dto/leave_chat_room_request.dto.dart' as _i15;
import 'feature/chat/model/dto/leave_chat_room_response.dto.dart' as _i16;
import 'feature/chat/model/dto/paginated_chat_messages_response.dto.dart'
    as _i17;
import 'feature/chat/model/dto/paginated_chat_rooms_response.dto.dart' as _i18;
import 'feature/chat/model/dto/send_message_request.dto.dart' as _i19;
import 'feature/chat/model/dto/update_chat_room_notification_request.dto.dart'
    as _i20;
import 'feature/chat/model/enum/chat_room_type.dart' as _i21;
import 'feature/chat/model/enum/message_type.dart' as _i22;
import 'feature/product/model/dto/create_product_request.dto.dart' as _i23;
import 'feature/product/model/dto/paginated_products_response.dto.dart' as _i24;
import 'feature/product/model/dto/product_stats.dto.dart' as _i25;
import 'greeting.dart' as _i26;
import 'feature/product/model/dto/update_product_status_request.dto.dart'
    as _i27;
import 'feature/product/model/favorite.dart' as _i28;
import 'feature/product/model/product.dart' as _i29;
import 'feature/product/model/product_category.dart' as _i30;
import 'feature/product/model/product_condition.dart' as _i31;
import 'feature/product/model/product_sort_by.dart' as _i32;
import 'feature/product/model/product_status.dart' as _i33;
import 'feature/product/model/trade_method.dart' as _i34;
import 'feature/user/model/dto/update_user_profile_request.dto.dart' as _i35;
import 'feature/user/model/fcm_token.dart' as _i36;
import 'feature/user/model/user.dart' as _i37;
import 'feature/product/model/dto/update_product_request.dto.dart' as _i38;
import 'package:gear_freak_client/src/protocol/feature/chat/model/chat_room.dart'
    as _i39;
import 'package:gear_freak_client/src/protocol/feature/chat/model/dto/chat_participant_info.dto.dart'
    as _i40;
import 'package:serverpod_auth_client/serverpod_auth_client.dart' as _i41;
export 'common/model/pagination_dto.dart';
export 'common/s3/model/dto/generate_presigned_upload_url_request.dto.dart';
export 'common/s3/model/dto/generate_presigned_upload_url_response.dto.dart';
export 'feature/chat/model/chat_message.dart';
export 'feature/chat/model/chat_participant.dart';
export 'feature/chat/model/chat_room.dart';
export 'feature/chat/model/dto/chat_message_response.dto.dart';
export 'feature/chat/model/dto/chat_participant_info.dto.dart';
export 'feature/chat/model/dto/create_chat_room_request.dto.dart';
export 'feature/chat/model/dto/create_chat_room_response.dto.dart';
export 'feature/chat/model/dto/get_chat_messages_request.dto.dart';
export 'feature/chat/model/dto/join_chat_room_request.dto.dart';
export 'feature/chat/model/dto/join_chat_room_response.dto.dart';
export 'feature/chat/model/dto/leave_chat_room_request.dto.dart';
export 'feature/chat/model/dto/leave_chat_room_response.dto.dart';
export 'feature/chat/model/dto/paginated_chat_messages_response.dto.dart';
export 'feature/chat/model/dto/paginated_chat_rooms_response.dto.dart';
export 'feature/chat/model/dto/send_message_request.dto.dart';
export 'feature/chat/model/dto/update_chat_room_notification_request.dto.dart';
export 'feature/chat/model/enum/chat_room_type.dart';
export 'feature/chat/model/enum/message_type.dart';
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
export 'feature/user/model/fcm_token.dart';
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
    if (t == _i2.JoinChatRoomResponseDto) {
      return _i2.JoinChatRoomResponseDto.fromJson(data) as T;
    }
    if (t == _i3.GeneratePresignedUploadUrlRequestDto) {
      return _i3.GeneratePresignedUploadUrlRequestDto.fromJson(data) as T;
    }
    if (t == _i4.GeneratePresignedUploadUrlResponseDto) {
      return _i4.GeneratePresignedUploadUrlResponseDto.fromJson(data) as T;
    }
    if (t == _i5.ChatMessage) {
      return _i5.ChatMessage.fromJson(data) as T;
    }
    if (t == _i6.ChatParticipant) {
      return _i6.ChatParticipant.fromJson(data) as T;
    }
    if (t == _i7.ChatRoom) {
      return _i7.ChatRoom.fromJson(data) as T;
    }
    if (t == _i8.ChatMessageResponseDto) {
      return _i8.ChatMessageResponseDto.fromJson(data) as T;
    }
    if (t == _i9.ChatParticipantInfoDto) {
      return _i9.ChatParticipantInfoDto.fromJson(data) as T;
    }
    if (t == _i10.CreateChatRoomRequestDto) {
      return _i10.CreateChatRoomRequestDto.fromJson(data) as T;
    }
    if (t == _i11.CreateChatRoomResponseDto) {
      return _i11.CreateChatRoomResponseDto.fromJson(data) as T;
    }
    if (t == _i12.GetChatMessagesRequestDto) {
      return _i12.GetChatMessagesRequestDto.fromJson(data) as T;
    }
    if (t == _i13.JoinChatRoomRequestDto) {
      return _i13.JoinChatRoomRequestDto.fromJson(data) as T;
    }
    if (t == _i14.PaginationDto) {
      return _i14.PaginationDto.fromJson(data) as T;
    }
    if (t == _i15.LeaveChatRoomRequestDto) {
      return _i15.LeaveChatRoomRequestDto.fromJson(data) as T;
    }
    if (t == _i16.LeaveChatRoomResponseDto) {
      return _i16.LeaveChatRoomResponseDto.fromJson(data) as T;
    }
    if (t == _i17.PaginatedChatMessagesResponseDto) {
      return _i17.PaginatedChatMessagesResponseDto.fromJson(data) as T;
    }
    if (t == _i18.PaginatedChatRoomsResponseDto) {
      return _i18.PaginatedChatRoomsResponseDto.fromJson(data) as T;
    }
    if (t == _i19.SendMessageRequestDto) {
      return _i19.SendMessageRequestDto.fromJson(data) as T;
    }
    if (t == _i20.UpdateChatRoomNotificationRequestDto) {
      return _i20.UpdateChatRoomNotificationRequestDto.fromJson(data) as T;
    }
    if (t == _i21.ChatRoomType) {
      return _i21.ChatRoomType.fromJson(data) as T;
    }
    if (t == _i22.MessageType) {
      return _i22.MessageType.fromJson(data) as T;
    }
    if (t == _i23.CreateProductRequestDto) {
      return _i23.CreateProductRequestDto.fromJson(data) as T;
    }
    if (t == _i24.PaginatedProductsResponseDto) {
      return _i24.PaginatedProductsResponseDto.fromJson(data) as T;
    }
    if (t == _i25.ProductStatsDto) {
      return _i25.ProductStatsDto.fromJson(data) as T;
    }
    if (t == _i26.Greeting) {
      return _i26.Greeting.fromJson(data) as T;
    }
    if (t == _i27.UpdateProductStatusRequestDto) {
      return _i27.UpdateProductStatusRequestDto.fromJson(data) as T;
    }
    if (t == _i28.Favorite) {
      return _i28.Favorite.fromJson(data) as T;
    }
    if (t == _i29.Product) {
      return _i29.Product.fromJson(data) as T;
    }
    if (t == _i30.ProductCategory) {
      return _i30.ProductCategory.fromJson(data) as T;
    }
    if (t == _i31.ProductCondition) {
      return _i31.ProductCondition.fromJson(data) as T;
    }
    if (t == _i32.ProductSortBy) {
      return _i32.ProductSortBy.fromJson(data) as T;
    }
    if (t == _i33.ProductStatus) {
      return _i33.ProductStatus.fromJson(data) as T;
    }
    if (t == _i34.TradeMethod) {
      return _i34.TradeMethod.fromJson(data) as T;
    }
    if (t == _i35.UpdateUserProfileRequestDto) {
      return _i35.UpdateUserProfileRequestDto.fromJson(data) as T;
    }
    if (t == _i36.FcmToken) {
      return _i36.FcmToken.fromJson(data) as T;
    }
    if (t == _i37.User) {
      return _i37.User.fromJson(data) as T;
    }
    if (t == _i38.UpdateProductRequestDto) {
      return _i38.UpdateProductRequestDto.fromJson(data) as T;
    }
    if (t == _i1.getType<_i2.JoinChatRoomResponseDto?>()) {
      return (data != null ? _i2.JoinChatRoomResponseDto.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i3.GeneratePresignedUploadUrlRequestDto?>()) {
      return (data != null
          ? _i3.GeneratePresignedUploadUrlRequestDto.fromJson(data)
          : null) as T;
    }
    if (t == _i1.getType<_i4.GeneratePresignedUploadUrlResponseDto?>()) {
      return (data != null
          ? _i4.GeneratePresignedUploadUrlResponseDto.fromJson(data)
          : null) as T;
    }
    if (t == _i1.getType<_i5.ChatMessage?>()) {
      return (data != null ? _i5.ChatMessage.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i6.ChatParticipant?>()) {
      return (data != null ? _i6.ChatParticipant.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i7.ChatRoom?>()) {
      return (data != null ? _i7.ChatRoom.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i8.ChatMessageResponseDto?>()) {
      return (data != null ? _i8.ChatMessageResponseDto.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i9.ChatParticipantInfoDto?>()) {
      return (data != null ? _i9.ChatParticipantInfoDto.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i10.CreateChatRoomRequestDto?>()) {
      return (data != null
          ? _i10.CreateChatRoomRequestDto.fromJson(data)
          : null) as T;
    }
    if (t == _i1.getType<_i11.CreateChatRoomResponseDto?>()) {
      return (data != null
          ? _i11.CreateChatRoomResponseDto.fromJson(data)
          : null) as T;
    }
    if (t == _i1.getType<_i12.GetChatMessagesRequestDto?>()) {
      return (data != null
          ? _i12.GetChatMessagesRequestDto.fromJson(data)
          : null) as T;
    }
    if (t == _i1.getType<_i13.JoinChatRoomRequestDto?>()) {
      return (data != null ? _i13.JoinChatRoomRequestDto.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i14.PaginationDto?>()) {
      return (data != null ? _i14.PaginationDto.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i15.LeaveChatRoomRequestDto?>()) {
      return (data != null ? _i15.LeaveChatRoomRequestDto.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i16.LeaveChatRoomResponseDto?>()) {
      return (data != null
          ? _i16.LeaveChatRoomResponseDto.fromJson(data)
          : null) as T;
    }
    if (t == _i1.getType<_i17.PaginatedChatMessagesResponseDto?>()) {
      return (data != null
          ? _i17.PaginatedChatMessagesResponseDto.fromJson(data)
          : null) as T;
    }
    if (t == _i1.getType<_i18.PaginatedChatRoomsResponseDto?>()) {
      return (data != null
          ? _i18.PaginatedChatRoomsResponseDto.fromJson(data)
          : null) as T;
    }
    if (t == _i1.getType<_i19.SendMessageRequestDto?>()) {
      return (data != null ? _i19.SendMessageRequestDto.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i20.UpdateChatRoomNotificationRequestDto?>()) {
      return (data != null
          ? _i20.UpdateChatRoomNotificationRequestDto.fromJson(data)
          : null) as T;
    }
    if (t == _i1.getType<_i21.ChatRoomType?>()) {
      return (data != null ? _i21.ChatRoomType.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i22.MessageType?>()) {
      return (data != null ? _i22.MessageType.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i23.CreateProductRequestDto?>()) {
      return (data != null ? _i23.CreateProductRequestDto.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i24.PaginatedProductsResponseDto?>()) {
      return (data != null
          ? _i24.PaginatedProductsResponseDto.fromJson(data)
          : null) as T;
    }
    if (t == _i1.getType<_i25.ProductStatsDto?>()) {
      return (data != null ? _i25.ProductStatsDto.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i26.Greeting?>()) {
      return (data != null ? _i26.Greeting.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i27.UpdateProductStatusRequestDto?>()) {
      return (data != null
          ? _i27.UpdateProductStatusRequestDto.fromJson(data)
          : null) as T;
    }
    if (t == _i1.getType<_i28.Favorite?>()) {
      return (data != null ? _i28.Favorite.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i29.Product?>()) {
      return (data != null ? _i29.Product.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i30.ProductCategory?>()) {
      return (data != null ? _i30.ProductCategory.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i31.ProductCondition?>()) {
      return (data != null ? _i31.ProductCondition.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i32.ProductSortBy?>()) {
      return (data != null ? _i32.ProductSortBy.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i33.ProductStatus?>()) {
      return (data != null ? _i33.ProductStatus.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i34.TradeMethod?>()) {
      return (data != null ? _i34.TradeMethod.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i35.UpdateUserProfileRequestDto?>()) {
      return (data != null
          ? _i35.UpdateUserProfileRequestDto.fromJson(data)
          : null) as T;
    }
    if (t == _i1.getType<_i36.FcmToken?>()) {
      return (data != null ? _i36.FcmToken.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i37.User?>()) {
      return (data != null ? _i37.User.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i38.UpdateProductRequestDto?>()) {
      return (data != null ? _i38.UpdateProductRequestDto.fromJson(data) : null)
          as T;
    }
    if (t == List<_i8.ChatMessageResponseDto>) {
      return (data as List)
          .map((e) => deserialize<_i8.ChatMessageResponseDto>(e))
          .toList() as T;
    }
    if (t == List<_i7.ChatRoom>) {
      return (data as List).map((e) => deserialize<_i7.ChatRoom>(e)).toList()
          as T;
    }
    if (t == _i1.getType<List<String>?>()) {
      return (data != null
          ? (data as List).map((e) => deserialize<String>(e)).toList()
          : null) as T;
    }
    if (t == List<_i29.Product>) {
      return (data as List).map((e) => deserialize<_i29.Product>(e)).toList()
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
    if (t == _i1.getType<List<_i39.ChatRoom>?>()) {
      return (data != null
          ? (data as List).map((e) => deserialize<_i39.ChatRoom>(e)).toList()
          : null) as T;
    }
    if (t == List<_i40.ChatParticipantInfoDto>) {
      return (data as List)
          .map((e) => deserialize<_i40.ChatParticipantInfoDto>(e))
          .toList() as T;
    }
    if (t == List<String>) {
      return (data as List).map((e) => deserialize<String>(e)).toList() as T;
    }
    try {
      return _i41.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  @override
  String? getClassNameForObject(Object? data) {
    String? className = super.getClassNameForObject(data);
    if (className != null) return className;
    if (data is _i2.JoinChatRoomResponseDto) {
      return 'JoinChatRoomResponseDto';
    }
    if (data is _i3.GeneratePresignedUploadUrlRequestDto) {
      return 'GeneratePresignedUploadUrlRequestDto';
    }
    if (data is _i4.GeneratePresignedUploadUrlResponseDto) {
      return 'GeneratePresignedUploadUrlResponseDto';
    }
    if (data is _i5.ChatMessage) {
      return 'ChatMessage';
    }
    if (data is _i6.ChatParticipant) {
      return 'ChatParticipant';
    }
    if (data is _i7.ChatRoom) {
      return 'ChatRoom';
    }
    if (data is _i8.ChatMessageResponseDto) {
      return 'ChatMessageResponseDto';
    }
    if (data is _i9.ChatParticipantInfoDto) {
      return 'ChatParticipantInfoDto';
    }
    if (data is _i10.CreateChatRoomRequestDto) {
      return 'CreateChatRoomRequestDto';
    }
    if (data is _i11.CreateChatRoomResponseDto) {
      return 'CreateChatRoomResponseDto';
    }
    if (data is _i12.GetChatMessagesRequestDto) {
      return 'GetChatMessagesRequestDto';
    }
    if (data is _i13.JoinChatRoomRequestDto) {
      return 'JoinChatRoomRequestDto';
    }
    if (data is _i14.PaginationDto) {
      return 'PaginationDto';
    }
    if (data is _i15.LeaveChatRoomRequestDto) {
      return 'LeaveChatRoomRequestDto';
    }
    if (data is _i16.LeaveChatRoomResponseDto) {
      return 'LeaveChatRoomResponseDto';
    }
    if (data is _i17.PaginatedChatMessagesResponseDto) {
      return 'PaginatedChatMessagesResponseDto';
    }
    if (data is _i18.PaginatedChatRoomsResponseDto) {
      return 'PaginatedChatRoomsResponseDto';
    }
    if (data is _i19.SendMessageRequestDto) {
      return 'SendMessageRequestDto';
    }
    if (data is _i20.UpdateChatRoomNotificationRequestDto) {
      return 'UpdateChatRoomNotificationRequestDto';
    }
    if (data is _i21.ChatRoomType) {
      return 'ChatRoomType';
    }
    if (data is _i22.MessageType) {
      return 'MessageType';
    }
    if (data is _i23.CreateProductRequestDto) {
      return 'CreateProductRequestDto';
    }
    if (data is _i24.PaginatedProductsResponseDto) {
      return 'PaginatedProductsResponseDto';
    }
    if (data is _i25.ProductStatsDto) {
      return 'ProductStatsDto';
    }
    if (data is _i26.Greeting) {
      return 'Greeting';
    }
    if (data is _i27.UpdateProductStatusRequestDto) {
      return 'UpdateProductStatusRequestDto';
    }
    if (data is _i28.Favorite) {
      return 'Favorite';
    }
    if (data is _i29.Product) {
      return 'Product';
    }
    if (data is _i30.ProductCategory) {
      return 'ProductCategory';
    }
    if (data is _i31.ProductCondition) {
      return 'ProductCondition';
    }
    if (data is _i32.ProductSortBy) {
      return 'ProductSortBy';
    }
    if (data is _i33.ProductStatus) {
      return 'ProductStatus';
    }
    if (data is _i34.TradeMethod) {
      return 'TradeMethod';
    }
    if (data is _i35.UpdateUserProfileRequestDto) {
      return 'UpdateUserProfileRequestDto';
    }
    if (data is _i36.FcmToken) {
      return 'FcmToken';
    }
    if (data is _i37.User) {
      return 'User';
    }
    if (data is _i38.UpdateProductRequestDto) {
      return 'UpdateProductRequestDto';
    }
    className = _i41.Protocol().getClassNameForObject(data);
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
    if (dataClassName == 'JoinChatRoomResponseDto') {
      return deserialize<_i2.JoinChatRoomResponseDto>(data['data']);
    }
    if (dataClassName == 'GeneratePresignedUploadUrlRequestDto') {
      return deserialize<_i3.GeneratePresignedUploadUrlRequestDto>(
          data['data']);
    }
    if (dataClassName == 'GeneratePresignedUploadUrlResponseDto') {
      return deserialize<_i4.GeneratePresignedUploadUrlResponseDto>(
          data['data']);
    }
    if (dataClassName == 'ChatMessage') {
      return deserialize<_i5.ChatMessage>(data['data']);
    }
    if (dataClassName == 'ChatParticipant') {
      return deserialize<_i6.ChatParticipant>(data['data']);
    }
    if (dataClassName == 'ChatRoom') {
      return deserialize<_i7.ChatRoom>(data['data']);
    }
    if (dataClassName == 'ChatMessageResponseDto') {
      return deserialize<_i8.ChatMessageResponseDto>(data['data']);
    }
    if (dataClassName == 'ChatParticipantInfoDto') {
      return deserialize<_i9.ChatParticipantInfoDto>(data['data']);
    }
    if (dataClassName == 'CreateChatRoomRequestDto') {
      return deserialize<_i10.CreateChatRoomRequestDto>(data['data']);
    }
    if (dataClassName == 'CreateChatRoomResponseDto') {
      return deserialize<_i11.CreateChatRoomResponseDto>(data['data']);
    }
    if (dataClassName == 'GetChatMessagesRequestDto') {
      return deserialize<_i12.GetChatMessagesRequestDto>(data['data']);
    }
    if (dataClassName == 'JoinChatRoomRequestDto') {
      return deserialize<_i13.JoinChatRoomRequestDto>(data['data']);
    }
    if (dataClassName == 'PaginationDto') {
      return deserialize<_i14.PaginationDto>(data['data']);
    }
    if (dataClassName == 'LeaveChatRoomRequestDto') {
      return deserialize<_i15.LeaveChatRoomRequestDto>(data['data']);
    }
    if (dataClassName == 'LeaveChatRoomResponseDto') {
      return deserialize<_i16.LeaveChatRoomResponseDto>(data['data']);
    }
    if (dataClassName == 'PaginatedChatMessagesResponseDto') {
      return deserialize<_i17.PaginatedChatMessagesResponseDto>(data['data']);
    }
    if (dataClassName == 'PaginatedChatRoomsResponseDto') {
      return deserialize<_i18.PaginatedChatRoomsResponseDto>(data['data']);
    }
    if (dataClassName == 'SendMessageRequestDto') {
      return deserialize<_i19.SendMessageRequestDto>(data['data']);
    }
    if (dataClassName == 'UpdateChatRoomNotificationRequestDto') {
      return deserialize<_i20.UpdateChatRoomNotificationRequestDto>(
          data['data']);
    }
    if (dataClassName == 'ChatRoomType') {
      return deserialize<_i21.ChatRoomType>(data['data']);
    }
    if (dataClassName == 'MessageType') {
      return deserialize<_i22.MessageType>(data['data']);
    }
    if (dataClassName == 'CreateProductRequestDto') {
      return deserialize<_i23.CreateProductRequestDto>(data['data']);
    }
    if (dataClassName == 'PaginatedProductsResponseDto') {
      return deserialize<_i24.PaginatedProductsResponseDto>(data['data']);
    }
    if (dataClassName == 'ProductStatsDto') {
      return deserialize<_i25.ProductStatsDto>(data['data']);
    }
    if (dataClassName == 'Greeting') {
      return deserialize<_i26.Greeting>(data['data']);
    }
    if (dataClassName == 'UpdateProductStatusRequestDto') {
      return deserialize<_i27.UpdateProductStatusRequestDto>(data['data']);
    }
    if (dataClassName == 'Favorite') {
      return deserialize<_i28.Favorite>(data['data']);
    }
    if (dataClassName == 'Product') {
      return deserialize<_i29.Product>(data['data']);
    }
    if (dataClassName == 'ProductCategory') {
      return deserialize<_i30.ProductCategory>(data['data']);
    }
    if (dataClassName == 'ProductCondition') {
      return deserialize<_i31.ProductCondition>(data['data']);
    }
    if (dataClassName == 'ProductSortBy') {
      return deserialize<_i32.ProductSortBy>(data['data']);
    }
    if (dataClassName == 'ProductStatus') {
      return deserialize<_i33.ProductStatus>(data['data']);
    }
    if (dataClassName == 'TradeMethod') {
      return deserialize<_i34.TradeMethod>(data['data']);
    }
    if (dataClassName == 'UpdateUserProfileRequestDto') {
      return deserialize<_i35.UpdateUserProfileRequestDto>(data['data']);
    }
    if (dataClassName == 'FcmToken') {
      return deserialize<_i36.FcmToken>(data['data']);
    }
    if (dataClassName == 'User') {
      return deserialize<_i37.User>(data['data']);
    }
    if (dataClassName == 'UpdateProductRequestDto') {
      return deserialize<_i38.UpdateProductRequestDto>(data['data']);
    }
    if (dataClassName.startsWith('serverpod_auth.')) {
      data['className'] = dataClassName.substring(15);
      return _i41.Protocol().deserializeByClassName(data);
    }
    return super.deserializeByClassName(data);
  }
}
