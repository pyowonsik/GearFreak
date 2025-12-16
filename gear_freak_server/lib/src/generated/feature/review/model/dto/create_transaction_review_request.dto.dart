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

/// 거래 후기 작성 요청
abstract class CreateTransactionReviewRequestDto
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  CreateTransactionReviewRequestDto._({
    required this.productId,
    required this.chatRoomId,
    required this.revieweeId,
    required this.rating,
    this.content,
  });

  factory CreateTransactionReviewRequestDto({
    required int productId,
    required int chatRoomId,
    required int revieweeId,
    required int rating,
    String? content,
  }) = _CreateTransactionReviewRequestDtoImpl;

  factory CreateTransactionReviewRequestDto.fromJson(
      Map<String, dynamic> jsonSerialization) {
    return CreateTransactionReviewRequestDto(
      productId: jsonSerialization['productId'] as int,
      chatRoomId: jsonSerialization['chatRoomId'] as int,
      revieweeId: jsonSerialization['revieweeId'] as int,
      rating: jsonSerialization['rating'] as int,
      content: jsonSerialization['content'] as String?,
    );
  }

  /// 상품 ID
  int productId;

  /// 채팅방 ID
  int chatRoomId;

  /// 리뷰 대상자 ID (구매자 ID)
  int revieweeId;

  /// 평점 (1~5)
  int rating;

  /// 후기 내용
  String? content;

  /// Returns a shallow copy of this [CreateTransactionReviewRequestDto]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  CreateTransactionReviewRequestDto copyWith({
    int? productId,
    int? chatRoomId,
    int? revieweeId,
    int? rating,
    String? content,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'chatRoomId': chatRoomId,
      'revieweeId': revieweeId,
      'rating': rating,
      if (content != null) 'content': content,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      'productId': productId,
      'chatRoomId': chatRoomId,
      'revieweeId': revieweeId,
      'rating': rating,
      if (content != null) 'content': content,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CreateTransactionReviewRequestDtoImpl
    extends CreateTransactionReviewRequestDto {
  _CreateTransactionReviewRequestDtoImpl({
    required int productId,
    required int chatRoomId,
    required int revieweeId,
    required int rating,
    String? content,
  }) : super._(
          productId: productId,
          chatRoomId: chatRoomId,
          revieweeId: revieweeId,
          rating: rating,
          content: content,
        );

  /// Returns a shallow copy of this [CreateTransactionReviewRequestDto]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  CreateTransactionReviewRequestDto copyWith({
    int? productId,
    int? chatRoomId,
    int? revieweeId,
    int? rating,
    Object? content = _Undefined,
  }) {
    return CreateTransactionReviewRequestDto(
      productId: productId ?? this.productId,
      chatRoomId: chatRoomId ?? this.chatRoomId,
      revieweeId: revieweeId ?? this.revieweeId,
      rating: rating ?? this.rating,
      content: content is String? ? content : this.content,
    );
  }
}
