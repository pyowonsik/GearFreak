import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gear_freak_flutter/feature/review/domain/usecase/get_buyers_by_product_id_usecase.dart';
import 'package:gear_freak_flutter/feature/review/presentation/provider/buyer_selection_state.dart';

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
