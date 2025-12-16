import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gear_freak_flutter/feature/chat/di/chat_providers.dart';
import 'package:gear_freak_flutter/feature/product/di/product_providers.dart';
import 'package:gear_freak_flutter/feature/review/data/data.dart';
import 'package:gear_freak_flutter/feature/review/domain/domain.dart';
import 'package:gear_freak_flutter/feature/review/domain/usecase/create_transaction_review_usecase.dart';
import 'package:gear_freak_flutter/feature/review/domain/usecase/get_buyers_by_product_id_usecase.dart';
import 'package:gear_freak_flutter/feature/review/domain/usecase/get_buyer_reviews_usecase.dart';
import 'package:gear_freak_flutter/feature/review/domain/usecase/get_seller_reviews_usecase.dart';
import 'package:gear_freak_flutter/feature/review/presentation/provider/buyer_selection_notifier.dart';
import 'package:gear_freak_flutter/feature/review/presentation/provider/review_list_notifier.dart';
import 'package:gear_freak_flutter/feature/review/presentation/provider/review_notifier.dart';

/// 리뷰 원격 데이터 소스 Provider
final reviewRemoteDataSourceProvider = Provider<ReviewRemoteDataSource>(
  (ref) => const ReviewRemoteDataSource(),
);

/// 리뷰 리포지토리 Provider
final reviewRepositoryProvider = Provider<ReviewRepository>(
  (ref) => ReviewRepositoryImpl(
    ref.read(reviewRemoteDataSourceProvider),
  ),
);

/// 구매자 목록 조회 UseCase Provider
final getBuyersByProductIdUseCaseProvider =
    Provider<GetBuyersByProductIdUseCase>((ref) {
  final getUserChatRoomsByProductIdUseCase =
      ref.watch(getUserChatRoomsByProductIdUseCaseProvider);
  final getChatParticipantsUseCase =
      ref.watch(getChatParticipantsUseCaseProvider);
  final getProductDetailUseCase = ref.watch(getProductDetailUseCaseProvider);
  return GetBuyersByProductIdUseCase(
    getUserChatRoomsByProductIdUseCase,
    getChatParticipantsUseCase,
    getProductDetailUseCase,
  );
});

/// 구매자 선택 Notifier Provider
final buyerSelectionNotifierProvider = StateNotifierProvider.autoDispose<
    BuyerSelectionNotifier, BuyerSelectionState>(
  (ref) {
    final getBuyersByProductIdUseCase =
        ref.watch(getBuyersByProductIdUseCaseProvider);
    return BuyerSelectionNotifier(getBuyersByProductIdUseCase);
  },
);

/// 구매자 후기 목록 조회 UseCase Provider
final getBuyerReviewsUseCaseProvider = Provider<GetBuyerReviewsUseCase>((ref) {
  final repository = ref.watch(reviewRepositoryProvider);
  return GetBuyerReviewsUseCase(repository);
});

/// 판매자 후기 목록 조회 UseCase Provider
final getSellerReviewsUseCaseProvider =
    Provider<GetSellerReviewsUseCase>((ref) {
  final repository = ref.watch(reviewRepositoryProvider);
  return GetSellerReviewsUseCase(repository);
});

/// 구매자 후기 목록 Notifier Provider
final buyerReviewListNotifierProvider =
    StateNotifierProvider.autoDispose<BuyerReviewListNotifier, ReviewListState>(
  (ref) {
    final getBuyerReviewsUseCase = ref.watch(getBuyerReviewsUseCaseProvider);
    return BuyerReviewListNotifier(getBuyerReviewsUseCase);
  },
);

/// 판매자 후기 목록 Notifier Provider
final sellerReviewListNotifierProvider = StateNotifierProvider.autoDispose<
    SellerReviewListNotifier, ReviewListState>(
  (ref) {
    final getSellerReviewsUseCase = ref.watch(getSellerReviewsUseCaseProvider);
    return SellerReviewListNotifier(getSellerReviewsUseCase);
  },
);

/// 거래 후기 작성 UseCase Provider
final createTransactionReviewUseCaseProvider =
    Provider<CreateTransactionReviewUseCase>((ref) {
  final repository = ref.watch(reviewRepositoryProvider);
  return CreateTransactionReviewUseCase(repository);
});

/// 리뷰 작성 Notifier Provider
final reviewNotifierProvider =
    StateNotifierProvider.autoDispose<ReviewNotifier, ReviewState>((ref) {
  final createTransactionReviewUseCase =
      ref.watch(createTransactionReviewUseCaseProvider);
  return ReviewNotifier(createTransactionReviewUseCase);
});
