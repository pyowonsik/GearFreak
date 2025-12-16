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
import '../../../../feature/review/model/review_type.dart' as _i2;

/// 거래 후기 응답
abstract class TransactionReviewResponseDto implements _i1.SerializableModel {
  TransactionReviewResponseDto._({
    required this.id,
    required this.productId,
    required this.chatRoomId,
    required this.reviewerId,
    this.reviewerNickname,
    this.reviewerProfileImageUrl,
    required this.revieweeId,
    this.revieweeNickname,
    required this.rating,
    this.content,
    required this.reviewType,
    this.createdAt,
  });

  factory TransactionReviewResponseDto({
    required int id,
    required int productId,
    required int chatRoomId,
    required int reviewerId,
    String? reviewerNickname,
    String? reviewerProfileImageUrl,
    required int revieweeId,
    String? revieweeNickname,
    required int rating,
    String? content,
    required _i2.ReviewType reviewType,
    DateTime? createdAt,
  }) = _TransactionReviewResponseDtoImpl;

  factory TransactionReviewResponseDto.fromJson(
      Map<String, dynamic> jsonSerialization) {
    return TransactionReviewResponseDto(
      id: jsonSerialization['id'] as int,
      productId: jsonSerialization['productId'] as int,
      chatRoomId: jsonSerialization['chatRoomId'] as int,
      reviewerId: jsonSerialization['reviewerId'] as int,
      reviewerNickname: jsonSerialization['reviewerNickname'] as String?,
      reviewerProfileImageUrl:
          jsonSerialization['reviewerProfileImageUrl'] as String?,
      revieweeId: jsonSerialization['revieweeId'] as int,
      revieweeNickname: jsonSerialization['revieweeNickname'] as String?,
      rating: jsonSerialization['rating'] as int,
      content: jsonSerialization['content'] as String?,
      reviewType:
          _i2.ReviewType.fromJson((jsonSerialization['reviewType'] as int)),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  /// 후기 ID
  int id;

  /// 상품 ID
  int productId;

  /// 채팅방 ID
  int chatRoomId;

  /// 리뷰 작성자 ID
  int reviewerId;

  /// 리뷰 작성자 닉네임
  String? reviewerNickname;

  /// 리뷰 작성자 프로필 이미지
  String? reviewerProfileImageUrl;

  /// 리뷰 대상자 ID
  int revieweeId;

  /// 리뷰 대상자 닉네임
  String? revieweeNickname;

  /// 평점 (1~5)
  int rating;

  /// 후기 내용
  String? content;

  /// 리뷰 타입
  _i2.ReviewType reviewType;

  /// 생성일
  DateTime? createdAt;

  /// Returns a shallow copy of this [TransactionReviewResponseDto]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  TransactionReviewResponseDto copyWith({
    int? id,
    int? productId,
    int? chatRoomId,
    int? reviewerId,
    String? reviewerNickname,
    String? reviewerProfileImageUrl,
    int? revieweeId,
    String? revieweeNickname,
    int? rating,
    String? content,
    _i2.ReviewType? reviewType,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'chatRoomId': chatRoomId,
      'reviewerId': reviewerId,
      if (reviewerNickname != null) 'reviewerNickname': reviewerNickname,
      if (reviewerProfileImageUrl != null)
        'reviewerProfileImageUrl': reviewerProfileImageUrl,
      'revieweeId': revieweeId,
      if (revieweeNickname != null) 'revieweeNickname': revieweeNickname,
      'rating': rating,
      if (content != null) 'content': content,
      'reviewType': reviewType.toJson(),
      if (createdAt != null) 'createdAt': createdAt?.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _TransactionReviewResponseDtoImpl extends TransactionReviewResponseDto {
  _TransactionReviewResponseDtoImpl({
    required int id,
    required int productId,
    required int chatRoomId,
    required int reviewerId,
    String? reviewerNickname,
    String? reviewerProfileImageUrl,
    required int revieweeId,
    String? revieweeNickname,
    required int rating,
    String? content,
    required _i2.ReviewType reviewType,
    DateTime? createdAt,
  }) : super._(
          id: id,
          productId: productId,
          chatRoomId: chatRoomId,
          reviewerId: reviewerId,
          reviewerNickname: reviewerNickname,
          reviewerProfileImageUrl: reviewerProfileImageUrl,
          revieweeId: revieweeId,
          revieweeNickname: revieweeNickname,
          rating: rating,
          content: content,
          reviewType: reviewType,
          createdAt: createdAt,
        );

  /// Returns a shallow copy of this [TransactionReviewResponseDto]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  TransactionReviewResponseDto copyWith({
    int? id,
    int? productId,
    int? chatRoomId,
    int? reviewerId,
    Object? reviewerNickname = _Undefined,
    Object? reviewerProfileImageUrl = _Undefined,
    int? revieweeId,
    Object? revieweeNickname = _Undefined,
    int? rating,
    Object? content = _Undefined,
    _i2.ReviewType? reviewType,
    Object? createdAt = _Undefined,
  }) {
    return TransactionReviewResponseDto(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      chatRoomId: chatRoomId ?? this.chatRoomId,
      reviewerId: reviewerId ?? this.reviewerId,
      reviewerNickname: reviewerNickname is String?
          ? reviewerNickname
          : this.reviewerNickname,
      reviewerProfileImageUrl: reviewerProfileImageUrl is String?
          ? reviewerProfileImageUrl
          : this.reviewerProfileImageUrl,
      revieweeId: revieweeId ?? this.revieweeId,
      revieweeNickname: revieweeNickname is String?
          ? revieweeNickname
          : this.revieweeNickname,
      rating: rating ?? this.rating,
      content: content is String? ? content : this.content,
      reviewType: reviewType ?? this.reviewType,
      createdAt: createdAt is DateTime? ? createdAt : this.createdAt,
    );
  }
}
