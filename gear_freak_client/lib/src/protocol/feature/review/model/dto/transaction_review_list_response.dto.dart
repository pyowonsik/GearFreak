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
import '../../../../feature/review/model/dto/transaction_review_response.dto.dart'
    as _i2;
import '../../../../common/model/pagination_dto.dart' as _i3;

/// 거래 후기 목록 응답
abstract class TransactionReviewListResponseDto
    implements _i1.SerializableModel {
  TransactionReviewListResponseDto._({
    required this.reviews,
    required this.pagination,
  });

  factory TransactionReviewListResponseDto({
    required List<_i2.TransactionReviewResponseDto> reviews,
    required _i3.PaginationDto pagination,
  }) = _TransactionReviewListResponseDtoImpl;

  factory TransactionReviewListResponseDto.fromJson(
      Map<String, dynamic> jsonSerialization) {
    return TransactionReviewListResponseDto(
      reviews: (jsonSerialization['reviews'] as List)
          .map((e) => _i2.TransactionReviewResponseDto.fromJson(
              (e as Map<String, dynamic>)))
          .toList(),
      pagination: _i3.PaginationDto.fromJson(
          (jsonSerialization['pagination'] as Map<String, dynamic>)),
    );
  }

  /// 후기 목록
  List<_i2.TransactionReviewResponseDto> reviews;

  /// 페이지네이션 정보
  _i3.PaginationDto pagination;

  /// Returns a shallow copy of this [TransactionReviewListResponseDto]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  TransactionReviewListResponseDto copyWith({
    List<_i2.TransactionReviewResponseDto>? reviews,
    _i3.PaginationDto? pagination,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      'reviews': reviews.toJson(valueToJson: (v) => v.toJson()),
      'pagination': pagination.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _TransactionReviewListResponseDtoImpl
    extends TransactionReviewListResponseDto {
  _TransactionReviewListResponseDtoImpl({
    required List<_i2.TransactionReviewResponseDto> reviews,
    required _i3.PaginationDto pagination,
  }) : super._(
          reviews: reviews,
          pagination: pagination,
        );

  /// Returns a shallow copy of this [TransactionReviewListResponseDto]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  TransactionReviewListResponseDto copyWith({
    List<_i2.TransactionReviewResponseDto>? reviews,
    _i3.PaginationDto? pagination,
  }) {
    return TransactionReviewListResponseDto(
      reviews: reviews ?? this.reviews.map((e0) => e0.copyWith()).toList(),
      pagination: pagination ?? this.pagination.copyWith(),
    );
  }
}
