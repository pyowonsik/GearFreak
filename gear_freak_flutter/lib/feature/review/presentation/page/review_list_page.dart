import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gear_freak_flutter/feature/review/presentation/presentation.dart';

/// 후기 관리 화면
/// Presentation Layer: UI
class ReviewListPage extends ConsumerStatefulWidget {
  /// ReviewListPage 생성자
  ///
  /// [initialTabIndex]는 초기 탭 인덱스입니다 (0: 구매자 후기, 1: 판매자 후기).
  const ReviewListPage({
    this.initialTabIndex = 0,
    super.key,
  });

  /// 초기 탭 인덱스 (0: 구매자 후기, 1: 판매자 후기)
  final int initialTabIndex;

  @override
  ConsumerState<ReviewListPage> createState() => _ReviewListPageState();
}

class _ReviewListPageState extends ConsumerState<ReviewListPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ScrollController _buyerScrollController;
  late ScrollController _sellerScrollController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTabIndex.clamp(0, 1),
    );
    _buyerScrollController = ScrollController();
    _sellerScrollController = ScrollController();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _buyerScrollController.dispose();
    _sellerScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('후기 관리'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF2563EB),
          unselectedLabelColor: const Color(0xFF9CA3AF),
          indicatorColor: const Color(0xFF2563EB),
          indicatorWeight: 2.5,
          labelStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
          tabs: const [
            Tab(text: '구매자 후기'),
            Tab(text: '판매자 후기'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          BuyerReviewListLoadedView(scrollController: _buyerScrollController),
          SellerReviewListLoadedView(scrollController: _sellerScrollController),
        ],
      ),
    );
  }
}
