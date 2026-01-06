import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/group_splash_background_logo.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            // 상단 텍스트
            Positioned(
              top: 150,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  '장 비 충',
                  style: GoogleFonts.gasoekOne(
                    fontSize: 110,
                    color: const Color(0xFF1E3A5F),
                    letterSpacing: -12,
                  ),
                ),
              ),
            ),

            // 중앙 인디케이터
            Positioned(
              top: 340,
              left: 0,
              right: 0,
              child: Center(
                child: SizedBox(
                  width: 60,
                  height: 60,
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return CustomPaint(
                        painter: DotIndicatorPainter(
                          progress: _controller.value,
                          color: const Color(0xFF5F5F5F),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DotIndicatorPainter extends CustomPainter {
  final double progress;
  final Color color;
  final int dotCount = 12;

  DotIndicatorPainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;

    for (int i = 0; i < dotCount; i++) {
      final angle = (i * 2 * 3.14159) / dotCount - 3.14159 / 2;
      final dotProgress = (progress + i / dotCount) % 1.0;
      final opacity =
          (dotProgress < 0.5) ? dotProgress * 2 : 2 - (dotProgress * 2);
      final dotRadius = 4.0 * (0.5 + opacity * 0.5);

      final x = center.dx + radius * cos(angle);
      final y = center.dy + radius * sin(angle);

      final paint = Paint()
        ..color = color.withOpacity(opacity.clamp(0.2, 1.0))
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(x, y), dotRadius, paint);
    }
  }

  @override
  bool shouldRepaint(DotIndicatorPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }

  double cos(double angle) => math.cos(angle);
  double sin(double angle) => math.sin(angle);
}
