import 'package:flutter/material.dart';
import 'package:gear_freak_flutter/shared/widget/widget.dart';
import 'package:go_router/go_router.dart';

/// 이미 작성한 리뷰 화면
/// Presentation Layer: UI
class ReviewAlreadyWrittenPage extends StatelessWidget {
  /// ReviewAlreadyWrittenPage 생성자
  ///
  /// [reviewType]는 리뷰 타입입니다 ('seller' 또는 'buyer').
  const ReviewAlreadyWrittenPage({
    this.reviewType = 'seller',
    super.key,
  });

  /// 리뷰 타입 ('seller': 판매자 리뷰, 'buyer': 구매자 리뷰)
  final String reviewType;

  @override
  Widget build(BuildContext context) {
    final title =
        reviewType == 'seller' ? '이미 작성한 판매자 리뷰입니다' : '이미 작성한 구매자 리뷰입니다';
    final message = reviewType == 'seller'
        ? '이미 해당 판매자에 대한 리뷰를 작성하셨습니다.'
        : '이미 해당 구매자에 대한 리뷰를 작성하셨습니다.';

    return Scaffold(
      appBar: const GbAppBar(
        title: Text('리뷰 작성'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 80,
                color: Colors.grey.shade300,
              ),
              const SizedBox(height: 24),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                message,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF9CA3AF),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    context.pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    '확인',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
