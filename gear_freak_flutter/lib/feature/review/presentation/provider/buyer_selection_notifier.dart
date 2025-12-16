import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gear_freak_flutter/feature/review/domain/usecase/get_buyers_by_product_id_usecase.dart';

/// 구매자 선택 Notifier
/// Presentation Layer: Riverpod 상태 관리
class BuyerSelectionNotifier extends StateNotifier<BuyerSelectionState> {
  /// BuyerSelectionNotifier 생성자
  ///
  /// [getBuyersByProductIdUseCase]는 구매자 목록 조회 UseCase입니다.
  BuyerSelectionNotifier(
    this.getBuyersByProductIdUseCase,
  ) : super(const BuyerSelectionInitial());

  /// 구매자 목록 조회 UseCase
  final GetBuyersByProductIdUseCase getBuyersByProductIdUseCase;

  /// 구매자 목록 로드
  Future<void> loadBuyers(int productId) async {
    state = const BuyerSelectionLoading();

    final result = await getBuyersByProductIdUseCase(
      GetBuyersByProductIdParams(productId: productId),
    );

    result.fold(
      (failure) {
        state = BuyerSelectionError(failure.message);
      },
      (buyers) {
        state = BuyerSelectionLoaded(buyers: buyers);
      },
    );
  }
}

/// 구매자 선택 상태
sealed class BuyerSelectionState {
  /// BuyerSelectionState 생성자
  const BuyerSelectionState();
}

/// 초기 상태
class BuyerSelectionInitial extends BuyerSelectionState {
  /// BuyerSelectionInitial 생성자
  const BuyerSelectionInitial();
}

/// 로딩 중 상태
class BuyerSelectionLoading extends BuyerSelectionState {
  /// BuyerSelectionLoading 생성자
  const BuyerSelectionLoading();
}

/// 구매자 목록 로드 성공 상태
class BuyerSelectionLoaded extends BuyerSelectionState {
  /// BuyerSelectionLoaded 생성자
  ///
  /// [buyers]는 구매자 목록입니다.
  const BuyerSelectionLoaded({
    required this.buyers,
  });

  /// 구매자 목록
  final List<BuyerInfo> buyers;
}

/// 구매자 목록 로드 실패 상태
class BuyerSelectionError extends BuyerSelectionState {
  /// BuyerSelectionError 생성자
  ///
  /// [message]는 에러 메시지입니다.
  const BuyerSelectionError(this.message);

  /// 에러 메시지
  final String message;
}
