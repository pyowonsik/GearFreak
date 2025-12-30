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
import 'feature/chat/model/dto/send_message_request.dto.dart' as _i2;
import 'common/s3/model/dto/generate_presigned_upload_url_request.dto.dart'
    as _i3;
import 'common/s3/model/dto/generate_presigned_upload_url_response.dto.dart'
    as _i4;
import 'feature/auth/model/dto/kakao_auth_response.dto.dart' as _i5;
import 'feature/chat/model/chat_message.dart' as _i6;
import 'feature/chat/model/chat_participant.dart' as _i7;
import 'feature/chat/model/chat_room.dart' as _i8;
import 'feature/chat/model/dto/chat_message_response.dto.dart' as _i9;
import 'feature/chat/model/dto/chat_participant_info.dto.dart' as _i10;
import 'feature/chat/model/dto/create_chat_room_request.dto.dart' as _i11;
import 'feature/chat/model/dto/create_chat_room_response.dto.dart' as _i12;
import 'feature/chat/model/dto/get_chat_messages_request.dto.dart' as _i13;
import 'feature/chat/model/dto/join_chat_room_request.dto.dart' as _i14;
import 'feature/chat/model/dto/join_chat_room_response.dto.dart' as _i15;
import 'feature/chat/model/dto/leave_chat_room_request.dto.dart' as _i16;
import 'feature/chat/model/dto/leave_chat_room_response.dto.dart' as _i17;
import 'feature/chat/model/dto/paginated_chat_messages_response.dto.dart'
    as _i18;
import 'feature/chat/model/dto/paginated_chat_rooms_response.dto.dart' as _i19;
import 'common/model/pagination_dto.dart' as _i20;
import 'feature/chat/model/dto/update_chat_room_notification_request.dto.dart'
    as _i21;
import 'feature/chat/model/enum/chat_room_type.dart' as _i22;
import 'feature/chat/model/enum/message_type.dart' as _i23;
import 'feature/notification/model/dto/notification_list_response.dto.dart'
    as _i24;
import 'feature/notification/model/dto/notification_response.dto.dart' as _i25;
import 'feature/notification/model/notification.dart' as _i26;
import 'feature/notification/model/notification_type.dart' as _i27;
import 'feature/product/model/dto/create_product_report_request.dto.dart'
    as _i28;
import 'feature/product/model/dto/create_product_request.dto.dart' as _i29;
import 'feature/product/model/dto/paginated_product_reports_response.dto.dart'
    as _i30;
import 'feature/product/model/dto/paginated_products_response.dto.dart' as _i31;
import 'feature/product/model/dto/process_product_report_request.dto.dart'
    as _i32;
import 'feature/product/model/dto/product_report_response.dto.dart' as _i33;
import 'feature/product/model/dto/product_stats.dto.dart' as _i34;
import 'feature/product/model/dto/update_product_request.dto.dart' as _i35;
import 'feature/product/model/dto/update_product_status_request.dto.dart'
    as _i36;
import 'feature/product/model/favorite.dart' as _i37;
import 'greeting.dart' as _i38;
import 'feature/product/model/product_category.dart' as _i39;
import 'feature/product/model/product_condition.dart' as _i40;
import 'feature/product/model/product_report.dart' as _i41;
import 'feature/product/model/product_sort_by.dart' as _i42;
import 'feature/product/model/product_status.dart' as _i43;
import 'feature/product/model/product_view.dart' as _i44;
import 'feature/product/model/report_reason.dart' as _i45;
import 'feature/product/model/report_status.dart' as _i46;
import 'feature/product/model/trade_method.dart' as _i47;
import 'feature/review/model/dto/create_transaction_review_request.dto.dart'
    as _i48;
import 'feature/review/model/dto/transaction_review_list_response.dto.dart'
    as _i49;
import 'feature/review/model/dto/transaction_review_response.dto.dart' as _i50;
import 'feature/review/model/review_type.dart' as _i51;
import 'feature/review/model/transaction_review.dart' as _i52;
import 'feature/user/model/dto/update_user_profile_request.dto.dart' as _i53;
import 'feature/user/model/fcm_token.dart' as _i54;
import 'feature/user/model/user.dart' as _i55;
import 'feature/product/model/product.dart' as _i56;
import 'package:gear_freak_client/src/protocol/feature/chat/model/chat_room.dart'
    as _i57;
import 'package:gear_freak_client/src/protocol/feature/chat/model/dto/chat_participant_info.dto.dart'
    as _i58;
import 'package:serverpod_auth_client/serverpod_auth_client.dart' as _i59;
export 'common/model/pagination_dto.dart';
export 'common/s3/model/dto/generate_presigned_upload_url_request.dto.dart';
export 'common/s3/model/dto/generate_presigned_upload_url_response.dto.dart';
export 'feature/auth/model/dto/kakao_auth_response.dto.dart';
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
export 'feature/notification/model/dto/notification_list_response.dto.dart';
export 'feature/notification/model/dto/notification_response.dto.dart';
export 'feature/notification/model/notification.dart';
export 'feature/notification/model/notification_type.dart';
export 'feature/product/model/dto/create_product_report_request.dto.dart';
export 'feature/product/model/dto/create_product_request.dto.dart';
export 'feature/product/model/dto/paginated_product_reports_response.dto.dart';
export 'feature/product/model/dto/paginated_products_response.dto.dart';
export 'feature/product/model/dto/process_product_report_request.dto.dart';
export 'feature/product/model/dto/product_report_response.dto.dart';
export 'feature/product/model/dto/product_stats.dto.dart';
export 'feature/product/model/dto/update_product_request.dto.dart';
export 'feature/product/model/dto/update_product_status_request.dto.dart';
export 'feature/product/model/favorite.dart';
export 'feature/product/model/product.dart';
export 'feature/product/model/product_category.dart';
export 'feature/product/model/product_condition.dart';
export 'feature/product/model/product_report.dart';
export 'feature/product/model/product_sort_by.dart';
export 'feature/product/model/product_status.dart';
export 'feature/product/model/product_view.dart';
export 'feature/product/model/report_reason.dart';
export 'feature/product/model/report_status.dart';
export 'feature/product/model/trade_method.dart';
export 'feature/review/model/dto/create_transaction_review_request.dto.dart';
export 'feature/review/model/dto/transaction_review_list_response.dto.dart';
export 'feature/review/model/dto/transaction_review_response.dto.dart';
export 'feature/review/model/review_type.dart';
export 'feature/review/model/transaction_review.dart';
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
    if (t == _i2.SendMessageRequestDto) {
      return _i2.SendMessageRequestDto.fromJson(data) as T;
    }
    if (t == _i3.GeneratePresignedUploadUrlRequestDto) {
      return _i3.GeneratePresignedUploadUrlRequestDto.fromJson(data) as T;
    }
    if (t == _i4.GeneratePresignedUploadUrlResponseDto) {
      return _i4.GeneratePresignedUploadUrlResponseDto.fromJson(data) as T;
    }
    if (t == _i5.KakaoAuthResponseDto) {
      return _i5.KakaoAuthResponseDto.fromJson(data) as T;
    }
    if (t == _i6.ChatMessage) {
      return _i6.ChatMessage.fromJson(data) as T;
    }
    if (t == _i7.ChatParticipant) {
      return _i7.ChatParticipant.fromJson(data) as T;
    }
    if (t == _i8.ChatRoom) {
      return _i8.ChatRoom.fromJson(data) as T;
    }
    if (t == _i9.ChatMessageResponseDto) {
      return _i9.ChatMessageResponseDto.fromJson(data) as T;
    }
    if (t == _i10.ChatParticipantInfoDto) {
      return _i10.ChatParticipantInfoDto.fromJson(data) as T;
    }
    if (t == _i11.CreateChatRoomRequestDto) {
      return _i11.CreateChatRoomRequestDto.fromJson(data) as T;
    }
    if (t == _i12.CreateChatRoomResponseDto) {
      return _i12.CreateChatRoomResponseDto.fromJson(data) as T;
    }
    if (t == _i13.GetChatMessagesRequestDto) {
      return _i13.GetChatMessagesRequestDto.fromJson(data) as T;
    }
    if (t == _i14.JoinChatRoomRequestDto) {
      return _i14.JoinChatRoomRequestDto.fromJson(data) as T;
    }
    if (t == _i15.JoinChatRoomResponseDto) {
      return _i15.JoinChatRoomResponseDto.fromJson(data) as T;
    }
    if (t == _i16.LeaveChatRoomRequestDto) {
      return _i16.LeaveChatRoomRequestDto.fromJson(data) as T;
    }
    if (t == _i17.LeaveChatRoomResponseDto) {
      return _i17.LeaveChatRoomResponseDto.fromJson(data) as T;
    }
    if (t == _i18.PaginatedChatMessagesResponseDto) {
      return _i18.PaginatedChatMessagesResponseDto.fromJson(data) as T;
    }
    if (t == _i19.PaginatedChatRoomsResponseDto) {
      return _i19.PaginatedChatRoomsResponseDto.fromJson(data) as T;
    }
    if (t == _i20.PaginationDto) {
      return _i20.PaginationDto.fromJson(data) as T;
    }
    if (t == _i21.UpdateChatRoomNotificationRequestDto) {
      return _i21.UpdateChatRoomNotificationRequestDto.fromJson(data) as T;
    }
    if (t == _i22.ChatRoomType) {
      return _i22.ChatRoomType.fromJson(data) as T;
    }
    if (t == _i23.MessageType) {
      return _i23.MessageType.fromJson(data) as T;
    }
    if (t == _i24.NotificationListResponseDto) {
      return _i24.NotificationListResponseDto.fromJson(data) as T;
    }
    if (t == _i25.NotificationResponseDto) {
      return _i25.NotificationResponseDto.fromJson(data) as T;
    }
    if (t == _i26.Notification) {
      return _i26.Notification.fromJson(data) as T;
    }
    if (t == _i27.NotificationType) {
      return _i27.NotificationType.fromJson(data) as T;
    }
    if (t == _i28.CreateProductReportRequestDto) {
      return _i28.CreateProductReportRequestDto.fromJson(data) as T;
    }
    if (t == _i29.CreateProductRequestDto) {
      return _i29.CreateProductRequestDto.fromJson(data) as T;
    }
    if (t == _i30.PaginatedProductReportsResponseDto) {
      return _i30.PaginatedProductReportsResponseDto.fromJson(data) as T;
    }
    if (t == _i31.PaginatedProductsResponseDto) {
      return _i31.PaginatedProductsResponseDto.fromJson(data) as T;
    }
    if (t == _i32.ProcessProductReportRequestDto) {
      return _i32.ProcessProductReportRequestDto.fromJson(data) as T;
    }
    if (t == _i33.ProductReportResponseDto) {
      return _i33.ProductReportResponseDto.fromJson(data) as T;
    }
    if (t == _i34.ProductStatsDto) {
      return _i34.ProductStatsDto.fromJson(data) as T;
    }
    if (t == _i35.UpdateProductRequestDto) {
      return _i35.UpdateProductRequestDto.fromJson(data) as T;
    }
    if (t == _i36.UpdateProductStatusRequestDto) {
      return _i36.UpdateProductStatusRequestDto.fromJson(data) as T;
    }
    if (t == _i37.Favorite) {
      return _i37.Favorite.fromJson(data) as T;
    }
    if (t == _i38.Greeting) {
      return _i38.Greeting.fromJson(data) as T;
    }
    if (t == _i39.ProductCategory) {
      return _i39.ProductCategory.fromJson(data) as T;
    }
    if (t == _i40.ProductCondition) {
      return _i40.ProductCondition.fromJson(data) as T;
    }
    if (t == _i41.ProductReport) {
      return _i41.ProductReport.fromJson(data) as T;
    }
    if (t == _i42.ProductSortBy) {
      return _i42.ProductSortBy.fromJson(data) as T;
    }
    if (t == _i43.ProductStatus) {
      return _i43.ProductStatus.fromJson(data) as T;
    }
    if (t == _i44.ProductView) {
      return _i44.ProductView.fromJson(data) as T;
    }
    if (t == _i45.ReportReason) {
      return _i45.ReportReason.fromJson(data) as T;
    }
    if (t == _i46.ReportStatus) {
      return _i46.ReportStatus.fromJson(data) as T;
    }
    if (t == _i47.TradeMethod) {
      return _i47.TradeMethod.fromJson(data) as T;
    }
    if (t == _i48.CreateTransactionReviewRequestDto) {
      return _i48.CreateTransactionReviewRequestDto.fromJson(data) as T;
    }
    if (t == _i49.TransactionReviewListResponseDto) {
      return _i49.TransactionReviewListResponseDto.fromJson(data) as T;
    }
    if (t == _i50.TransactionReviewResponseDto) {
      return _i50.TransactionReviewResponseDto.fromJson(data) as T;
    }
    if (t == _i51.ReviewType) {
      return _i51.ReviewType.fromJson(data) as T;
    }
    if (t == _i52.TransactionReview) {
      return _i52.TransactionReview.fromJson(data) as T;
    }
    if (t == _i53.UpdateUserProfileRequestDto) {
      return _i53.UpdateUserProfileRequestDto.fromJson(data) as T;
    }
    if (t == _i54.FcmToken) {
      return _i54.FcmToken.fromJson(data) as T;
    }
    if (t == _i55.User) {
      return _i55.User.fromJson(data) as T;
    }
    if (t == _i56.Product) {
      return _i56.Product.fromJson(data) as T;
    }
    if (t == _i1.getType<_i2.SendMessageRequestDto?>()) {
      return (data != null ? _i2.SendMessageRequestDto.fromJson(data) : null)
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
    if (t == _i1.getType<_i5.KakaoAuthResponseDto?>()) {
      return (data != null ? _i5.KakaoAuthResponseDto.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i6.ChatMessage?>()) {
      return (data != null ? _i6.ChatMessage.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i7.ChatParticipant?>()) {
      return (data != null ? _i7.ChatParticipant.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i8.ChatRoom?>()) {
      return (data != null ? _i8.ChatRoom.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i9.ChatMessageResponseDto?>()) {
      return (data != null ? _i9.ChatMessageResponseDto.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i10.ChatParticipantInfoDto?>()) {
      return (data != null ? _i10.ChatParticipantInfoDto.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i11.CreateChatRoomRequestDto?>()) {
      return (data != null
          ? _i11.CreateChatRoomRequestDto.fromJson(data)
          : null) as T;
    }
    if (t == _i1.getType<_i12.CreateChatRoomResponseDto?>()) {
      return (data != null
          ? _i12.CreateChatRoomResponseDto.fromJson(data)
          : null) as T;
    }
    if (t == _i1.getType<_i13.GetChatMessagesRequestDto?>()) {
      return (data != null
          ? _i13.GetChatMessagesRequestDto.fromJson(data)
          : null) as T;
    }
    if (t == _i1.getType<_i14.JoinChatRoomRequestDto?>()) {
      return (data != null ? _i14.JoinChatRoomRequestDto.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i15.JoinChatRoomResponseDto?>()) {
      return (data != null ? _i15.JoinChatRoomResponseDto.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i16.LeaveChatRoomRequestDto?>()) {
      return (data != null ? _i16.LeaveChatRoomRequestDto.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i17.LeaveChatRoomResponseDto?>()) {
      return (data != null
          ? _i17.LeaveChatRoomResponseDto.fromJson(data)
          : null) as T;
    }
    if (t == _i1.getType<_i18.PaginatedChatMessagesResponseDto?>()) {
      return (data != null
          ? _i18.PaginatedChatMessagesResponseDto.fromJson(data)
          : null) as T;
    }
    if (t == _i1.getType<_i19.PaginatedChatRoomsResponseDto?>()) {
      return (data != null
          ? _i19.PaginatedChatRoomsResponseDto.fromJson(data)
          : null) as T;
    }
    if (t == _i1.getType<_i20.PaginationDto?>()) {
      return (data != null ? _i20.PaginationDto.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i21.UpdateChatRoomNotificationRequestDto?>()) {
      return (data != null
          ? _i21.UpdateChatRoomNotificationRequestDto.fromJson(data)
          : null) as T;
    }
    if (t == _i1.getType<_i22.ChatRoomType?>()) {
      return (data != null ? _i22.ChatRoomType.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i23.MessageType?>()) {
      return (data != null ? _i23.MessageType.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i24.NotificationListResponseDto?>()) {
      return (data != null
          ? _i24.NotificationListResponseDto.fromJson(data)
          : null) as T;
    }
    if (t == _i1.getType<_i25.NotificationResponseDto?>()) {
      return (data != null ? _i25.NotificationResponseDto.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i26.Notification?>()) {
      return (data != null ? _i26.Notification.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i27.NotificationType?>()) {
      return (data != null ? _i27.NotificationType.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i28.CreateProductReportRequestDto?>()) {
      return (data != null
          ? _i28.CreateProductReportRequestDto.fromJson(data)
          : null) as T;
    }
    if (t == _i1.getType<_i29.CreateProductRequestDto?>()) {
      return (data != null ? _i29.CreateProductRequestDto.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i30.PaginatedProductReportsResponseDto?>()) {
      return (data != null
          ? _i30.PaginatedProductReportsResponseDto.fromJson(data)
          : null) as T;
    }
    if (t == _i1.getType<_i31.PaginatedProductsResponseDto?>()) {
      return (data != null
          ? _i31.PaginatedProductsResponseDto.fromJson(data)
          : null) as T;
    }
    if (t == _i1.getType<_i32.ProcessProductReportRequestDto?>()) {
      return (data != null
          ? _i32.ProcessProductReportRequestDto.fromJson(data)
          : null) as T;
    }
    if (t == _i1.getType<_i33.ProductReportResponseDto?>()) {
      return (data != null
          ? _i33.ProductReportResponseDto.fromJson(data)
          : null) as T;
    }
    if (t == _i1.getType<_i34.ProductStatsDto?>()) {
      return (data != null ? _i34.ProductStatsDto.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i35.UpdateProductRequestDto?>()) {
      return (data != null ? _i35.UpdateProductRequestDto.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i36.UpdateProductStatusRequestDto?>()) {
      return (data != null
          ? _i36.UpdateProductStatusRequestDto.fromJson(data)
          : null) as T;
    }
    if (t == _i1.getType<_i37.Favorite?>()) {
      return (data != null ? _i37.Favorite.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i38.Greeting?>()) {
      return (data != null ? _i38.Greeting.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i39.ProductCategory?>()) {
      return (data != null ? _i39.ProductCategory.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i40.ProductCondition?>()) {
      return (data != null ? _i40.ProductCondition.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i41.ProductReport?>()) {
      return (data != null ? _i41.ProductReport.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i42.ProductSortBy?>()) {
      return (data != null ? _i42.ProductSortBy.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i43.ProductStatus?>()) {
      return (data != null ? _i43.ProductStatus.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i44.ProductView?>()) {
      return (data != null ? _i44.ProductView.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i45.ReportReason?>()) {
      return (data != null ? _i45.ReportReason.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i46.ReportStatus?>()) {
      return (data != null ? _i46.ReportStatus.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i47.TradeMethod?>()) {
      return (data != null ? _i47.TradeMethod.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i48.CreateTransactionReviewRequestDto?>()) {
      return (data != null
          ? _i48.CreateTransactionReviewRequestDto.fromJson(data)
          : null) as T;
    }
    if (t == _i1.getType<_i49.TransactionReviewListResponseDto?>()) {
      return (data != null
          ? _i49.TransactionReviewListResponseDto.fromJson(data)
          : null) as T;
    }
    if (t == _i1.getType<_i50.TransactionReviewResponseDto?>()) {
      return (data != null
          ? _i50.TransactionReviewResponseDto.fromJson(data)
          : null) as T;
    }
    if (t == _i1.getType<_i51.ReviewType?>()) {
      return (data != null ? _i51.ReviewType.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i52.TransactionReview?>()) {
      return (data != null ? _i52.TransactionReview.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i53.UpdateUserProfileRequestDto?>()) {
      return (data != null
          ? _i53.UpdateUserProfileRequestDto.fromJson(data)
          : null) as T;
    }
    if (t == _i1.getType<_i54.FcmToken?>()) {
      return (data != null ? _i54.FcmToken.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i55.User?>()) {
      return (data != null ? _i55.User.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i56.Product?>()) {
      return (data != null ? _i56.Product.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<List<String>?>()) {
      return (data != null
          ? (data as List).map((e) => deserialize<String>(e)).toList()
          : null) as T;
    }
    if (t == List<_i9.ChatMessageResponseDto>) {
      return (data as List)
          .map((e) => deserialize<_i9.ChatMessageResponseDto>(e))
          .toList() as T;
    }
    if (t == List<_i8.ChatRoom>) {
      return (data as List).map((e) => deserialize<_i8.ChatRoom>(e)).toList()
          as T;
    }
    if (t == List<_i25.NotificationResponseDto>) {
      return (data as List)
          .map((e) => deserialize<_i25.NotificationResponseDto>(e))
          .toList() as T;
    }
    if (t == _i1.getType<Map<String, String>?>()) {
      return (data != null
          ? (data as Map).map((k, v) =>
              MapEntry(deserialize<String>(k), deserialize<String>(v)))
          : null) as T;
    }
    if (t == _i1.getType<List<String>?>()) {
      return (data != null
          ? (data as List).map((e) => deserialize<String>(e)).toList()
          : null) as T;
    }
    if (t == List<_i33.ProductReportResponseDto>) {
      return (data as List)
          .map((e) => deserialize<_i33.ProductReportResponseDto>(e))
          .toList() as T;
    }
    if (t == List<_i56.Product>) {
      return (data as List).map((e) => deserialize<_i56.Product>(e)).toList()
          as T;
    }
    if (t == _i1.getType<List<String>?>()) {
      return (data != null
          ? (data as List).map((e) => deserialize<String>(e)).toList()
          : null) as T;
    }
    if (t == List<_i50.TransactionReviewResponseDto>) {
      return (data as List)
          .map((e) => deserialize<_i50.TransactionReviewResponseDto>(e))
          .toList() as T;
    }
    if (t == _i1.getType<List<String>?>()) {
      return (data != null
          ? (data as List).map((e) => deserialize<String>(e)).toList()
          : null) as T;
    }
    if (t == _i1.getType<List<_i57.ChatRoom>?>()) {
      return (data != null
          ? (data as List).map((e) => deserialize<_i57.ChatRoom>(e)).toList()
          : null) as T;
    }
    if (t == List<_i58.ChatParticipantInfoDto>) {
      return (data as List)
          .map((e) => deserialize<_i58.ChatParticipantInfoDto>(e))
          .toList() as T;
    }
    if (t == List<String>) {
      return (data as List).map((e) => deserialize<String>(e)).toList() as T;
    }
    try {
      return _i59.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  @override
  String? getClassNameForObject(Object? data) {
    String? className = super.getClassNameForObject(data);
    if (className != null) return className;
    if (data is _i2.SendMessageRequestDto) {
      return 'SendMessageRequestDto';
    }
    if (data is _i3.GeneratePresignedUploadUrlRequestDto) {
      return 'GeneratePresignedUploadUrlRequestDto';
    }
    if (data is _i4.GeneratePresignedUploadUrlResponseDto) {
      return 'GeneratePresignedUploadUrlResponseDto';
    }
    if (data is _i5.KakaoAuthResponseDto) {
      return 'KakaoAuthResponseDto';
    }
    if (data is _i6.ChatMessage) {
      return 'ChatMessage';
    }
    if (data is _i7.ChatParticipant) {
      return 'ChatParticipant';
    }
    if (data is _i8.ChatRoom) {
      return 'ChatRoom';
    }
    if (data is _i9.ChatMessageResponseDto) {
      return 'ChatMessageResponseDto';
    }
    if (data is _i10.ChatParticipantInfoDto) {
      return 'ChatParticipantInfoDto';
    }
    if (data is _i11.CreateChatRoomRequestDto) {
      return 'CreateChatRoomRequestDto';
    }
    if (data is _i12.CreateChatRoomResponseDto) {
      return 'CreateChatRoomResponseDto';
    }
    if (data is _i13.GetChatMessagesRequestDto) {
      return 'GetChatMessagesRequestDto';
    }
    if (data is _i14.JoinChatRoomRequestDto) {
      return 'JoinChatRoomRequestDto';
    }
    if (data is _i15.JoinChatRoomResponseDto) {
      return 'JoinChatRoomResponseDto';
    }
    if (data is _i16.LeaveChatRoomRequestDto) {
      return 'LeaveChatRoomRequestDto';
    }
    if (data is _i17.LeaveChatRoomResponseDto) {
      return 'LeaveChatRoomResponseDto';
    }
    if (data is _i18.PaginatedChatMessagesResponseDto) {
      return 'PaginatedChatMessagesResponseDto';
    }
    if (data is _i19.PaginatedChatRoomsResponseDto) {
      return 'PaginatedChatRoomsResponseDto';
    }
    if (data is _i20.PaginationDto) {
      return 'PaginationDto';
    }
    if (data is _i21.UpdateChatRoomNotificationRequestDto) {
      return 'UpdateChatRoomNotificationRequestDto';
    }
    if (data is _i22.ChatRoomType) {
      return 'ChatRoomType';
    }
    if (data is _i23.MessageType) {
      return 'MessageType';
    }
    if (data is _i24.NotificationListResponseDto) {
      return 'NotificationListResponseDto';
    }
    if (data is _i25.NotificationResponseDto) {
      return 'NotificationResponseDto';
    }
    if (data is _i26.Notification) {
      return 'Notification';
    }
    if (data is _i27.NotificationType) {
      return 'NotificationType';
    }
    if (data is _i28.CreateProductReportRequestDto) {
      return 'CreateProductReportRequestDto';
    }
    if (data is _i29.CreateProductRequestDto) {
      return 'CreateProductRequestDto';
    }
    if (data is _i30.PaginatedProductReportsResponseDto) {
      return 'PaginatedProductReportsResponseDto';
    }
    if (data is _i31.PaginatedProductsResponseDto) {
      return 'PaginatedProductsResponseDto';
    }
    if (data is _i32.ProcessProductReportRequestDto) {
      return 'ProcessProductReportRequestDto';
    }
    if (data is _i33.ProductReportResponseDto) {
      return 'ProductReportResponseDto';
    }
    if (data is _i34.ProductStatsDto) {
      return 'ProductStatsDto';
    }
    if (data is _i35.UpdateProductRequestDto) {
      return 'UpdateProductRequestDto';
    }
    if (data is _i36.UpdateProductStatusRequestDto) {
      return 'UpdateProductStatusRequestDto';
    }
    if (data is _i37.Favorite) {
      return 'Favorite';
    }
    if (data is _i38.Greeting) {
      return 'Greeting';
    }
    if (data is _i39.ProductCategory) {
      return 'ProductCategory';
    }
    if (data is _i40.ProductCondition) {
      return 'ProductCondition';
    }
    if (data is _i41.ProductReport) {
      return 'ProductReport';
    }
    if (data is _i42.ProductSortBy) {
      return 'ProductSortBy';
    }
    if (data is _i43.ProductStatus) {
      return 'ProductStatus';
    }
    if (data is _i44.ProductView) {
      return 'ProductView';
    }
    if (data is _i45.ReportReason) {
      return 'ReportReason';
    }
    if (data is _i46.ReportStatus) {
      return 'ReportStatus';
    }
    if (data is _i47.TradeMethod) {
      return 'TradeMethod';
    }
    if (data is _i48.CreateTransactionReviewRequestDto) {
      return 'CreateTransactionReviewRequestDto';
    }
    if (data is _i49.TransactionReviewListResponseDto) {
      return 'TransactionReviewListResponseDto';
    }
    if (data is _i50.TransactionReviewResponseDto) {
      return 'TransactionReviewResponseDto';
    }
    if (data is _i51.ReviewType) {
      return 'ReviewType';
    }
    if (data is _i52.TransactionReview) {
      return 'TransactionReview';
    }
    if (data is _i53.UpdateUserProfileRequestDto) {
      return 'UpdateUserProfileRequestDto';
    }
    if (data is _i54.FcmToken) {
      return 'FcmToken';
    }
    if (data is _i55.User) {
      return 'User';
    }
    if (data is _i56.Product) {
      return 'Product';
    }
    className = _i59.Protocol().getClassNameForObject(data);
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
    if (dataClassName == 'SendMessageRequestDto') {
      return deserialize<_i2.SendMessageRequestDto>(data['data']);
    }
    if (dataClassName == 'GeneratePresignedUploadUrlRequestDto') {
      return deserialize<_i3.GeneratePresignedUploadUrlRequestDto>(
          data['data']);
    }
    if (dataClassName == 'GeneratePresignedUploadUrlResponseDto') {
      return deserialize<_i4.GeneratePresignedUploadUrlResponseDto>(
          data['data']);
    }
    if (dataClassName == 'KakaoAuthResponseDto') {
      return deserialize<_i5.KakaoAuthResponseDto>(data['data']);
    }
    if (dataClassName == 'ChatMessage') {
      return deserialize<_i6.ChatMessage>(data['data']);
    }
    if (dataClassName == 'ChatParticipant') {
      return deserialize<_i7.ChatParticipant>(data['data']);
    }
    if (dataClassName == 'ChatRoom') {
      return deserialize<_i8.ChatRoom>(data['data']);
    }
    if (dataClassName == 'ChatMessageResponseDto') {
      return deserialize<_i9.ChatMessageResponseDto>(data['data']);
    }
    if (dataClassName == 'ChatParticipantInfoDto') {
      return deserialize<_i10.ChatParticipantInfoDto>(data['data']);
    }
    if (dataClassName == 'CreateChatRoomRequestDto') {
      return deserialize<_i11.CreateChatRoomRequestDto>(data['data']);
    }
    if (dataClassName == 'CreateChatRoomResponseDto') {
      return deserialize<_i12.CreateChatRoomResponseDto>(data['data']);
    }
    if (dataClassName == 'GetChatMessagesRequestDto') {
      return deserialize<_i13.GetChatMessagesRequestDto>(data['data']);
    }
    if (dataClassName == 'JoinChatRoomRequestDto') {
      return deserialize<_i14.JoinChatRoomRequestDto>(data['data']);
    }
    if (dataClassName == 'JoinChatRoomResponseDto') {
      return deserialize<_i15.JoinChatRoomResponseDto>(data['data']);
    }
    if (dataClassName == 'LeaveChatRoomRequestDto') {
      return deserialize<_i16.LeaveChatRoomRequestDto>(data['data']);
    }
    if (dataClassName == 'LeaveChatRoomResponseDto') {
      return deserialize<_i17.LeaveChatRoomResponseDto>(data['data']);
    }
    if (dataClassName == 'PaginatedChatMessagesResponseDto') {
      return deserialize<_i18.PaginatedChatMessagesResponseDto>(data['data']);
    }
    if (dataClassName == 'PaginatedChatRoomsResponseDto') {
      return deserialize<_i19.PaginatedChatRoomsResponseDto>(data['data']);
    }
    if (dataClassName == 'PaginationDto') {
      return deserialize<_i20.PaginationDto>(data['data']);
    }
    if (dataClassName == 'UpdateChatRoomNotificationRequestDto') {
      return deserialize<_i21.UpdateChatRoomNotificationRequestDto>(
          data['data']);
    }
    if (dataClassName == 'ChatRoomType') {
      return deserialize<_i22.ChatRoomType>(data['data']);
    }
    if (dataClassName == 'MessageType') {
      return deserialize<_i23.MessageType>(data['data']);
    }
    if (dataClassName == 'NotificationListResponseDto') {
      return deserialize<_i24.NotificationListResponseDto>(data['data']);
    }
    if (dataClassName == 'NotificationResponseDto') {
      return deserialize<_i25.NotificationResponseDto>(data['data']);
    }
    if (dataClassName == 'Notification') {
      return deserialize<_i26.Notification>(data['data']);
    }
    if (dataClassName == 'NotificationType') {
      return deserialize<_i27.NotificationType>(data['data']);
    }
    if (dataClassName == 'CreateProductReportRequestDto') {
      return deserialize<_i28.CreateProductReportRequestDto>(data['data']);
    }
    if (dataClassName == 'CreateProductRequestDto') {
      return deserialize<_i29.CreateProductRequestDto>(data['data']);
    }
    if (dataClassName == 'PaginatedProductReportsResponseDto') {
      return deserialize<_i30.PaginatedProductReportsResponseDto>(data['data']);
    }
    if (dataClassName == 'PaginatedProductsResponseDto') {
      return deserialize<_i31.PaginatedProductsResponseDto>(data['data']);
    }
    if (dataClassName == 'ProcessProductReportRequestDto') {
      return deserialize<_i32.ProcessProductReportRequestDto>(data['data']);
    }
    if (dataClassName == 'ProductReportResponseDto') {
      return deserialize<_i33.ProductReportResponseDto>(data['data']);
    }
    if (dataClassName == 'ProductStatsDto') {
      return deserialize<_i34.ProductStatsDto>(data['data']);
    }
    if (dataClassName == 'UpdateProductRequestDto') {
      return deserialize<_i35.UpdateProductRequestDto>(data['data']);
    }
    if (dataClassName == 'UpdateProductStatusRequestDto') {
      return deserialize<_i36.UpdateProductStatusRequestDto>(data['data']);
    }
    if (dataClassName == 'Favorite') {
      return deserialize<_i37.Favorite>(data['data']);
    }
    if (dataClassName == 'Greeting') {
      return deserialize<_i38.Greeting>(data['data']);
    }
    if (dataClassName == 'ProductCategory') {
      return deserialize<_i39.ProductCategory>(data['data']);
    }
    if (dataClassName == 'ProductCondition') {
      return deserialize<_i40.ProductCondition>(data['data']);
    }
    if (dataClassName == 'ProductReport') {
      return deserialize<_i41.ProductReport>(data['data']);
    }
    if (dataClassName == 'ProductSortBy') {
      return deserialize<_i42.ProductSortBy>(data['data']);
    }
    if (dataClassName == 'ProductStatus') {
      return deserialize<_i43.ProductStatus>(data['data']);
    }
    if (dataClassName == 'ProductView') {
      return deserialize<_i44.ProductView>(data['data']);
    }
    if (dataClassName == 'ReportReason') {
      return deserialize<_i45.ReportReason>(data['data']);
    }
    if (dataClassName == 'ReportStatus') {
      return deserialize<_i46.ReportStatus>(data['data']);
    }
    if (dataClassName == 'TradeMethod') {
      return deserialize<_i47.TradeMethod>(data['data']);
    }
    if (dataClassName == 'CreateTransactionReviewRequestDto') {
      return deserialize<_i48.CreateTransactionReviewRequestDto>(data['data']);
    }
    if (dataClassName == 'TransactionReviewListResponseDto') {
      return deserialize<_i49.TransactionReviewListResponseDto>(data['data']);
    }
    if (dataClassName == 'TransactionReviewResponseDto') {
      return deserialize<_i50.TransactionReviewResponseDto>(data['data']);
    }
    if (dataClassName == 'ReviewType') {
      return deserialize<_i51.ReviewType>(data['data']);
    }
    if (dataClassName == 'TransactionReview') {
      return deserialize<_i52.TransactionReview>(data['data']);
    }
    if (dataClassName == 'UpdateUserProfileRequestDto') {
      return deserialize<_i53.UpdateUserProfileRequestDto>(data['data']);
    }
    if (dataClassName == 'FcmToken') {
      return deserialize<_i54.FcmToken>(data['data']);
    }
    if (dataClassName == 'User') {
      return deserialize<_i55.User>(data['data']);
    }
    if (dataClassName == 'Product') {
      return deserialize<_i56.Product>(data['data']);
    }
    if (dataClassName.startsWith('serverpod_auth.')) {
      data['className'] = dataClassName.substring(15);
      return _i59.Protocol().deserializeByClassName(data);
    }
    return super.deserializeByClassName(data);
  }
}
