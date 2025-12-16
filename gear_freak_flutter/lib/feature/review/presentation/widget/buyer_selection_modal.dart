import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gear_freak_flutter/feature/review/di/review_providers.dart';
import 'package:gear_freak_flutter/feature/review/presentation/provider/buyer_selection_notifier.dart';

/// 구매자 선택 모달
/// Presentation Layer: UI
class BuyerSelectionModal extends ConsumerStatefulWidget {
  /// BuyerSelectionModal 생성자
  ///
  /// [productId]는 상품 ID입니다.
  /// [productName]는 상품명입니다.
  /// [onBuyerSelected]는 구매자 선택 시 호출되는 콜백입니다.
  /// [onCancel]는 선택하지 않기 클릭 시 호출되는 콜백입니다.
  const BuyerSelectionModal({
    super.key,
    required this.productId,
    required this.productName,
    required this.onBuyerSelected,
    required this.onCancel,
  });

  /// 상품 ID
  final int productId;

  /// 상품명
  final String productName;

  /// 구매자 선택 시 호출되는 콜백
  final VoidCallback onBuyerSelected;

  /// 선택하지 않기 클릭 시 호출되는 콜백
  final VoidCallback onCancel;

  /// 모달 표시
  ///
  /// [context]는 BuildContext입니다.
  /// [productId]는 상품 ID입니다.
  /// [productName]는 상품명입니다.
  /// [onBuyerSelected]는 구매자 선택 시 호출되는 콜백입니다.
  /// [onCancel]는 선택하지 않기 클릭 시 호출되는 콜백입니다.
  static Future<void> show(
    BuildContext context, {
    required int productId,
    required String productName,
    required VoidCallback onBuyerSelected,
    required VoidCallback onCancel,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false, // 바깥쪽 클릭 방지
      enableDrag: false, // 드래그로 닫기 방지
      builder: (context) => BuyerSelectionModal(
        productId: productId,
        productName: productName,
        onBuyerSelected: onBuyerSelected,
        onCancel: onCancel,
      ),
    );
  }

  @override
  ConsumerState<BuyerSelectionModal> createState() =>
      _BuyerSelectionModalState();
}

class _BuyerSelectionModalState extends ConsumerState<BuyerSelectionModal> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(buyerSelectionNotifierProvider.notifier)
          .loadBuyers(widget.productId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final buyerSelectionState = ref.watch(buyerSelectionNotifierProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // 드래그 핸들
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // 헤더
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Spacer(),
                const Text(
                  '구매자 선택',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.black),
                  onPressed: () {
                    // 닫기 버튼 클릭 시 상태 변경 없이 모달만 닫기
                    context.pop();
                  },
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // 상품 정보 카드
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade100),
            ),
            child: Row(
              children: [
                Icon(Icons.shopping_bag, color: Colors.blue.shade700, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '거래한 상품',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.productName,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue.shade900,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 안내 문구
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '후기를 작성할 구매자를 선택해주세요',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 구매자 목록
          Flexible(
            child: switch (buyerSelectionState) {
              BuyerSelectionInitial() ||
              BuyerSelectionLoading() =>
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(),
                  ),
                ),
              BuyerSelectionError(:final message) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          message,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B7280),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            ref
                                .read(buyerSelectionNotifierProvider.notifier)
                                .loadBuyers(widget.productId);
                          },
                          child: const Text('다시 시도'),
                        ),
                      ],
                    ),
                  ),
                ),
              BuyerSelectionLoaded(:final buyers) => buyers.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Text(
                          '구매자가 없습니다',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: buyers.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final buyer = buyers[index];

                        return InkWell(
                          onTap: () {
                            context.pop();
                            widget.onBuyerSelected();
                            context.push(
                              '/product/${widget.productId}/review/write?buyerId=${buyer.userId}&chatRoomId=${buyer.chatRoomId}',
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Row(
                              children: [
                                // 프로필 이미지
                                CircleAvatar(
                                  radius: 28,
                                  backgroundColor: const Color(0xFFF3F4F6),
                                  backgroundImage: buyer.profileImageUrl != null
                                      ? CachedNetworkImageProvider(
                                          buyer.profileImageUrl!,
                                        )
                                      : null,
                                  child: buyer.profileImageUrl == null
                                      ? Icon(
                                          Icons.person,
                                          size: 28,
                                          color: Colors.grey.shade500,
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 12),

                                // 닉네임
                                Expanded(
                                  child: Text(
                                    buyer.nickname ?? '사용자',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),

                                // 화살표 아이콘
                                Icon(
                                  Icons.chevron_right,
                                  color: Colors.grey.shade400,
                                  size: 24,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            },
          ),

          // 선택하지 않기 버튼
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  context.pop();
                  widget.onCancel();
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Color(0xFFE5E7EB)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  '선택하지 않기',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
