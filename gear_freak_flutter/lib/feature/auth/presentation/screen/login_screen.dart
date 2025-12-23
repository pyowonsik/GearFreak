import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gear_freak_flutter/common/presentation/component/component.dart';
import 'package:gear_freak_flutter/feature/auth/di/auth_providers.dart';
import 'package:gear_freak_flutter/feature/auth/presentation/provider/auth_state.dart';

/// 로그인 화면
class LoginScreen extends ConsumerStatefulWidget {
  /// LoginScreen 생성자
  ///
  /// [key]는 위젯의 키입니다.
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    // 상태 변경 감지: 에러만 처리 (성공은 가드에서 처리)
    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      if (next is AuthError && mounted) {
        // 에러 메시지에 로그인 타입 구분이 필요하면 추가 가능
        GbSnackBar.showError(context, '로그인 실패: ${next.message}');
      }
    });

    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState is AuthLoading;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF2563EB).withValues(alpha: 0.05),
              Colors.white,
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                const Spacer(flex: 3),
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF2563EB),
                        Color(0xFF7C3AED),
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2563EB).withValues(alpha: 0.3),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.shopping_bag,
                    size: 80,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'FitMarket',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  '헬스 장비부터 보충제까지\n모든 것을 한곳에서',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 17,
                    color: Color(0xFF6B7280),
                    height: 1.6,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(flex: 3),

                // 카카오 로그인
                _SocialLoginButton(
                  onTap: isLoading
                      ? null
                      : () async {
                          final authNotifier =
                              ref.read(authNotifierProvider.notifier);
                          await authNotifier.loginWithKakao();
                          // 라우팅은 AppRouteGuard에서 처리
                        },
                  icon: Icons.chat_bubble_rounded,
                  label: '카카오로 3초만에 시작하기',
                  backgroundColor: const Color(0xFFFFE812),
                  textColor: const Color(0xFF1F2937),
                ),
                const SizedBox(height: 14),

                // 네이버 로그인
                _SocialLoginButton(
                  onTap: isLoading
                      ? null
                      : () async {
                          final authNotifier =
                              ref.read(authNotifierProvider.notifier);
                          await authNotifier.loginWithNaver();
                          // 라우팅은 AppRouteGuard에서 처리
                        },
                  icon: Icons.north, // 임시 아이콘, 나중에 교체 가능
                  label: '네이버로 계속하기',
                  backgroundColor: const Color(0xFF03C75A),
                  textColor: Colors.white,
                ),
                const SizedBox(height: 14),

                // 애플 로그인 (iOS만)
                if (Theme.of(context).platform == TargetPlatform.iOS) ...[
                  _SocialLoginButton(
                    onTap: isLoading
                        ? null
                        : () async {
                            final authNotifier =
                                ref.read(authNotifierProvider.notifier);
                            await authNotifier.loginWithApple();
                          },
                    icon: Icons.apple,
                    label: 'Apple로 계속하기',
                    backgroundColor: const Color(0xFF1F2937),
                    textColor: Colors.white,
                  ),
                  const SizedBox(height: 14),
                ],

                // 구글 로그인
                _SocialLoginButton(
                  onTap: isLoading
                      ? null
                      : () async {
                          final authNotifier =
                              ref.read(authNotifierProvider.notifier);
                          await authNotifier.loginWithGoogle();
                        },
                  icon: Icons.g_mobiledata,
                  label: 'Google로 계속하기',
                  backgroundColor: Colors.white,
                  textColor: const Color(0xFF1F2937),
                  hasBorder: true,
                ),
                const Spacer(flex: 2),
                const Padding(
                  padding: EdgeInsets.only(bottom: 32),
                  child: Text.rich(
                    TextSpan(
                      text: '로그인 시 ',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF9CA3AF),
                        height: 1.5,
                      ),
                      children: [
                        TextSpan(
                          text: '서비스 약관',
                          style: TextStyle(
                            color: Color(0xFF6B7280),
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        TextSpan(text: ' 및 '),
                        TextSpan(
                          text: '개인정보 처리방침',
                          style: TextStyle(
                            color: Color(0xFF6B7280),
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        TextSpan(text: '에\n동의하게 됩니다.'),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SocialLoginButton extends StatelessWidget {
  const _SocialLoginButton({
    required this.onTap,
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    this.hasBorder = false,
  });

  final VoidCallback? onTap;
  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final bool hasBorder;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          elevation: hasBorder ? 0 : 1,
          shadowColor: Colors.black.withValues(alpha: 0.1),
          side: hasBorder
              ? const BorderSide(color: Color(0xFFD1D5DB), width: 2)
              : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 26, color: textColor),
            const SizedBox(width: 14),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: textColor,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
