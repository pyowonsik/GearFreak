import 'package:flutter/material.dart';

/// Gear Freak 공통 로딩 뷰
/// 프로젝트에서 사용하는 모든 전체 화면 로딩 표시는 이 위젯을 사용합니다.
class GbLoadingView extends StatefulWidget {
  /// GbLoadingView 생성자
  ///
  /// [message]는 로딩 메시지입니다.
  const GbLoadingView({
    super.key,
    this.message,
  });

  /// 로딩 메시지 (선택사항)
  final String? message;

  @override
  State<GbLoadingView> createState() => _GbLoadingViewState();
}

class _GbLoadingViewState extends State<GbLoadingView>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late AnimationController _fadeController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // 펄스 애니메이션 (크기 변화)
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(
      begin: 0.85,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    // 회전 애니메이션
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();

    // 페이드 인 애니메이션
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: Curves.easeIn,
      ),
    );

    _fadeController.forward();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotationController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 애니메이션 로딩 인디케이터
            ScaleTransition(
              scale: _pulseAnimation,
              child: RotationTransition(
                turns: _rotationController,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF3B82F6), // Blue
                        Color(0xFF8B5CF6), // Purple
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF3B82F6).withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(12),
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // 애니메이션 도트
            _buildAnimatedDots(),
            if (widget.message != null) ...[
              const SizedBox(height: 16),
              Text(
                widget.message!,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF6B7280),
                  letterSpacing: 0.3,
                ),
                textAlign: TextAlign.center,
              ),
            ] else ...[
              const SizedBox(height: 8),
              const Text(
                '잠시만 기다려주세요',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF9CA3AF),
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedDots() {
    return SizedBox(
      height: 12,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (index) {
          return TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 600),
            tween: Tween(begin: 0, end: 1),
            builder: (context, value, child) {
              return AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  final offset = index * 0.33;
                  final animationValue =
                      (_pulseController.value + offset) % 1.0;
                  final scale = 0.5 + (animationValue * 0.5);
                  final opacity = 0.3 + (animationValue * 0.7);

                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF3B82F6).withValues(alpha: opacity),
                    ),
                    transform: Matrix4.identity()..scale(scale),
                  );
                },
              );
            },
          );
        }),
      ),
    );
  }
}
