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
                    Icons.fitness_center,
                    size: 80,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 32),
                // 앱 이름 - 그라데이션 적용
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [
                      Color(0xFF2563EB),
                      Color(0xFF7C3AED),
                    ],
                  ).createShader(bounds),
                  child: const Text(
                    '장비빨',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -1.5,
                      height: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  '프리미엄 헬스 장비와 보충제를\n한 곳에서 만나보세요',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF6B7280),
                    height: 1.7,
                    fontWeight: FontWeight.w400,
                    letterSpacing: -0.2,
                  ),
                ),
                const Spacer(flex: 3),

                // 소셜 로그인 (원형 아이콘, 중앙 배치) - 로고 아이콘 버전
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Kakao logo
                    _CircleSocialButton(
                      onTap: isLoading
                          ? null
                          : () async {
                              final authNotifier =
                                  ref.read(authNotifierProvider.notifier);
                              await authNotifier.loginWithKakao();
                            },
                      backgroundColor: const Color(0xFFFEE500),
                      child: Image.asset(
                        'assets/images/kakao_logo.png',
                        width: 32,
                        height: 32,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(width: 24),

                    // Google logo
                    _CircleSocialButton(
                      onTap: isLoading
                          ? null
                          : () async {
                              final authNotifier =
                                  ref.read(authNotifierProvider.notifier);
                              await authNotifier.loginWithGoogle();
                            },
                      child: Image.asset(
                        'assets/images/google_logo.png',
                        width: 32,
                        height: 32,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(width: 24),

                    // Naver logo
                    _CircleSocialButton(
                      onTap: isLoading
                          ? null
                          : () async {
                              final authNotifier =
                                  ref.read(authNotifierProvider.notifier);
                              await authNotifier.loginWithNaver();
                              // 라우팅은 AppRouteGuard에서 처리
                            },
                      backgroundColor: const Color(0xFF03C75A),
                      child: Image.asset(
                        'assets/images/naver_logo.png',
                        width: 32,
                        height: 32,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(width: 24),

                    // Apple logo (iOS만 노출)
                    if (Theme.of(context).platform == TargetPlatform.iOS)
                      _CircleSocialButton(
                        onTap: isLoading
                            ? null
                            : () async {
                                final authNotifier =
                                    ref.read(authNotifierProvider.notifier);
                                await authNotifier.loginWithApple();
                              },
                        child: Image.asset(
                          'assets/images/apple_logo.png',
                          width: 32,
                          height: 32,
                          fit: BoxFit.contain,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 32),

                // 소셜 로그인 안내 문구
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [
                          Color(0xFF2563EB),
                          Color(0xFF7C3AED),
                        ],
                      ).createShader(bounds),
                      child: const Text(
                        '소셜 로그인으로 간편하게 시작하세요',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                  ],
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

class _CircleSocialButton extends StatelessWidget {
  const _CircleSocialButton({
    required this.onTap,
    required this.child,
    this.backgroundColor = Colors.white,
  });

  final VoidCallback? onTap;
  final Widget child;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 56,
          height: 56,
          child: Center(child: child),
        ),
      ),
    );
  }
}
