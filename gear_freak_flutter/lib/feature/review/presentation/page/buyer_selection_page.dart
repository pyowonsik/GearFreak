import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 구매자 선택 화면
/// Presentation Layer: UI
class BuyerSelectionPage extends ConsumerStatefulWidget {
  /// BuyerSelectionPage 생성자
  ///
  /// [productId]는 상품 ID입니다.
  const BuyerSelectionPage({
    required this.productId,
    super.key,
  });

  /// 상품 ID
  final int productId;

  @override
  ConsumerState<BuyerSelectionPage> createState() =>
      _BuyerSelectionPageState();
}

class _BuyerSelectionPageState extends ConsumerState<BuyerSelectionPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('구매자 선택'),
      ),
      body: const Center(
        child: Text('구매자 선택 화면'),
      ),
    );
  }
}
