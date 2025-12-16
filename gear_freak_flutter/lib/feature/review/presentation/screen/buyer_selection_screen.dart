import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 구매자 선택 화면
/// Presentation Layer: UI
class BuyerSelectionScreen extends ConsumerStatefulWidget {
  /// BuyerSelectionScreen 생성자
  ///
  /// [productId]는 상품 ID입니다.
  const BuyerSelectionScreen({
    required this.productId,
    super.key,
  });

  /// 상품 ID
  final int productId;

  @override
  ConsumerState<BuyerSelectionScreen> createState() =>
      _BuyerSelectionScreenState();
}

class _BuyerSelectionScreenState extends ConsumerState<BuyerSelectionScreen> {
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

