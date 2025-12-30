import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gear_freak_flutter/feature/review/presentation/presentation.dart';

/// 다른 사용자의 모든 후기 목록 화면
class OtherUserReviewListPage extends ConsumerStatefulWidget {
  /// OtherUserReviewListPage 생성자
  ///
  /// [userId]는 조회할 사용자의 ID입니다.
  const OtherUserReviewListPage({
    required this.userId,
    super.key,
  });

  /// 조회할 사용자 ID
  final String userId;

  @override
  ConsumerState<OtherUserReviewListPage> createState() =>
      _OtherUserReviewListPageState();
}

class _OtherUserReviewListPageState
    extends ConsumerState<OtherUserReviewListPage> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userId = int.tryParse(widget.userId);
    if (userId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('후기 목록')),
        body: const Center(child: Text('잘못된 사용자 ID입니다.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('거래 후기'),
      ),
      body: OtherUserReviewListLoadedView(
        userId: userId,
        scrollController: _scrollController,
      ),
    );
  }
}
