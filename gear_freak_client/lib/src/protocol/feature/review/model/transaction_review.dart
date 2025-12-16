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
import '../../../feature/review/model/review_type.dart' as _i2;

/// 거래 후기
abstract class TransactionReview implements _i1.SerializableModel {
  TransactionReview._({
    this.id,
    required this.productId,
    required this.chatRoomId,
    required this.reviewerId,
    required this.revieweeId,
    required this.rating,
    this.content,
    required this.reviewType,
    this.createdAt,
    this.updatedAt,
  });

  factory TransactionReview({
    int? id,
    required int productId,
    required int chatRoomId,
    required int reviewerId,
    required int revieweeId,
    required int rating,
    String? content,
    required _i2.ReviewType reviewType,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _TransactionReviewImpl;

  factory TransactionReview.fromJson(Map<String, dynamic> jsonSerialization) {
    return TransactionReview(
      id: jsonSerialization['id'] as int?,
      productId: jsonSerialization['productId'] as int,
      chatRoomId: jsonSerialization['chatRoomId'] as int,
      reviewerId: jsonSerialization['reviewerId'] as int,
      revieweeId: jsonSerialization['revieweeId'] as int,
      rating: jsonSerialization['rating'] as int,
      content: jsonSerialization['content'] as String?,
      reviewType:
          _i2.ReviewType.fromJson((jsonSerialization['reviewType'] as int)),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  /// 상품 ID
  int productId;

  /// 채팅방 ID
  int chatRoomId;

  /// 리뷰 작성자 ID
  int reviewerId;

  /// 리뷰 대상자 ID
  int revieweeId;

  /// 평점 (1~5)
  int rating;

  /// 후기 내용
  String? content;

  /// 리뷰 타입
  _i2.ReviewType reviewType;

  /// 생성일
  DateTime? createdAt;

  /// 수정일
  DateTime? updatedAt;

  /// Returns a shallow copy of this [TransactionReview]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  TransactionReview copyWith({
    int? id,
    int? productId,
    int? chatRoomId,
    int? reviewerId,
    int? revieweeId,
    int? rating,
    String? content,
    _i2.ReviewType? reviewType,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'productId': productId,
      'chatRoomId': chatRoomId,
      'reviewerId': reviewerId,
      'revieweeId': revieweeId,
      'rating': rating,
      if (content != null) 'content': content,
      'reviewType': reviewType.toJson(),
      if (createdAt != null) 'createdAt': createdAt?.toJson(),
      if (updatedAt != null) 'updatedAt': updatedAt?.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _TransactionReviewImpl extends TransactionReview {
  _TransactionReviewImpl({
    int? id,
    required int productId,
    required int chatRoomId,
    required int reviewerId,
    required int revieweeId,
    required int rating,
    String? content,
    required _i2.ReviewType reviewType,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : super._(
          id: id,
          productId: productId,
          chatRoomId: chatRoomId,
          reviewerId: reviewerId,
          revieweeId: revieweeId,
          rating: rating,
          content: content,
          reviewType: reviewType,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

  /// Returns a shallow copy of this [TransactionReview]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  TransactionReview copyWith({
    Object? id = _Undefined,
    int? productId,
    int? chatRoomId,
    int? reviewerId,
    int? revieweeId,
    int? rating,
    Object? content = _Undefined,
    _i2.ReviewType? reviewType,
    Object? createdAt = _Undefined,
    Object? updatedAt = _Undefined,
  }) {
    return TransactionReview(
      id: id is int? ? id : this.id,
      productId: productId ?? this.productId,
      chatRoomId: chatRoomId ?? this.chatRoomId,
      reviewerId: reviewerId ?? this.reviewerId,
      revieweeId: revieweeId ?? this.revieweeId,
      rating: rating ?? this.rating,
      content: content is String? ? content : this.content,
      reviewType: reviewType ?? this.reviewType,
      createdAt: createdAt is DateTime? ? createdAt : this.createdAt,
      updatedAt: updatedAt is DateTime? ? updatedAt : this.updatedAt,
    );
  }
}
