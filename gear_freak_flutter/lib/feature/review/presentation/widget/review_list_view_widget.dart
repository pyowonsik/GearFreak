import 'package:flutter/material.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import 'package:gear_freak_flutter/feature/review/presentation/presentation.dart';

/// 후기 목록 뷰 위젯
class ReviewListViewWidget extends StatelessWidget {
  /// ReviewListViewWidget 생성자
  const ReviewListViewWidget({
    required this.reviews,
    required this.onRefresh,
    this.scrollController,
    super.key,
  });

  /// 후기 목록
  final List<pod.TransactionReviewResponseDto> reviews;

  /// 새로고침 콜백
  final Future<void> Function() onRefresh;

  /// 스크롤 컨트롤러
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.separated(
        controller: scrollController,
        padding: const EdgeInsets.symmetric(vertical: 8),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: reviews.length,
        separatorBuilder: (context, index) {
          return const Divider(
            height: 1,
            thickness: 8,
            color: Color(0xFFF3F4F6),
          );
        },
        itemBuilder: (context, index) {
          final review = reviews[index];
          return ReviewItemWidget(review: review);
        },
      ),
    );
  }
}
