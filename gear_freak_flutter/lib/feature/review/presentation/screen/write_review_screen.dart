import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gear_freak_flutter/common/presentation/component/component.dart';
import 'package:gear_freak_flutter/feature/review/di/review_providers.dart';
import 'package:gear_freak_flutter/feature/review/presentation/provider/review_notifier.dart';
import 'package:gear_freak_flutter/feature/review/presentation/widget/star_rating_widget.dart';
import 'package:go_router/go_router.dart';

/// 후기 작성 화면 (구매자 후기)
/// Presentation Layer: UI
class WriteReviewScreen extends ConsumerStatefulWidget {
  /// WriteReviewScreen 생성자
  ///
  /// [productId]는 상품 ID입니다.
  /// [buyerId]는 구매자 ID입니다.
  /// [chatRoomId]는 채팅방 ID입니다.
  const WriteReviewScreen({
    required this.productId,
    required this.buyerId,
    required this.chatRoomId,
    super.key,
  });

  /// 상품 ID
  final int productId;

  /// 구매자 ID
  final int buyerId;

  /// 채팅방 ID
  final int chatRoomId;

  @override
  ConsumerState<WriteReviewScreen> createState() => _WriteReviewScreenState();
}

class _WriteReviewScreenState extends ConsumerState<WriteReviewScreen> {
  final TextEditingController _contentController = TextEditingController();
  double _rating = 0.0;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  /// 후기 작성 완료
  Future<void> _handleSubmit() async {
    if (_rating == 0) {
      if (!mounted) return;
      GbSnackBar.showError(context, '평점을 선택해주세요');
      return;
    }

    if (_rating < 1 || _rating > 5) {
      if (!mounted) return;
      GbSnackBar.showError(context, '평점은 1~5점 사이로 선택해주세요');
      return;
    }

    if (_contentController.text.length > 500) {
      if (!mounted) return;
      GbSnackBar.showError(context, '후기 내용은 최대 500자까지 입력 가능합니다');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final success =
          await ref.read(reviewNotifierProvider.notifier).createBuyerReview(
                productId: widget.productId,
                chatRoomId: widget.chatRoomId,
                revieweeId: widget.buyerId,
                rating: _rating.toInt(),
                content: _contentController.text.isEmpty
                    ? null
                    : _contentController.text,
              );

      if (!mounted) return;

      if (success) {
        GbSnackBar.showSuccess(context, '후기가 작성되었습니다');
        // 스낵바 표시 후 약간의 딜레이를 주고 화면 닫기
        await Future<void>.delayed(const Duration(milliseconds: 300));
        if (!mounted) return;
        context.pop();
      } else {
        // ReviewNotifier의 상태를 확인하기 전에 mounted 체크
        if (!mounted) return;
        final state = ref.read(reviewNotifierProvider);
        if (state is ReviewError) {
          GbSnackBar.showError(context, state.message);
        } else {
          GbSnackBar.showError(context, '후기 작성에 실패했습니다');
        }
      }
    } catch (e) {
      if (!mounted) return;
      GbSnackBar.showError(context, '후기 작성에 실패했습니다: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GbAppBar(
        title: Text('구매자 후기 작성'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 안내 문구
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  '거래하신 구매자에 대한 솔직한 후기를 작성해주세요.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // 평점 선택
              const Text(
                '평점',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: StarRatingWidget(
                  rating: _rating,
                  onRatingChanged: (newRating) {
                    setState(() {
                      _rating = newRating;
                    });
                  },
                  starSize: 48,
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  _rating == 0 ? '평점을 선택해주세요' : '${_rating.toInt()}점',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _rating == 0
                        ? const Color(0xFF9CA3AF)
                        : const Color(0xFF2563EB),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // 후기 내용 입력
              const Text(
                '후기 내용 (선택사항)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _contentController,
                maxLength: 500,
                maxLines: 8,
                decoration: InputDecoration(
                  hintText: '거래 경험을 자유롭게 작성해주세요.',
                  hintStyle: const TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFFE5E7EB),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFFE5E7EB),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF2563EB),
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.all(16),
                  counterStyle: const TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 12,
                  ),
                ),
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF1F2937),
                  height: 1.5,
                ),
                onChanged: (value) {
                  setState(() {});
                },
              ),
              const SizedBox(height: 32),

              // 작성 완료 버튼
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                    disabledBackgroundColor: const Color(0xFFE5E7EB),
                    disabledForegroundColor: const Color(0xFF9CA3AF),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text(
                          '작성 완료',
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
