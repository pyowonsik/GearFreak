import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gear_freak_flutter/common/presentation/component/component.dart';
import 'package:gear_freak_flutter/feature/auth/di/auth_providers.dart';
import 'package:gear_freak_flutter/feature/auth/presentation/component/auth_loading_button.dart';
import 'package:gear_freak_flutter/feature/auth/presentation/component/auth_logo_section.dart';
import 'package:gear_freak_flutter/feature/auth/presentation/component/social_login_button.dart';
import 'package:gear_freak_flutter/feature/auth/presentation/provider/auth_state.dart';
import 'package:gear_freak_flutter/feature/auth/presentation/widget/signup_link_widget.dart';
import 'package:go_router/go_router.dart';

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
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authNotifier = ref.read(authNotifierProvider.notifier);

    await authNotifier.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;

    // 로그인 완료 후 상태 확인
    final authState = ref.read(authNotifierProvider);
    switch (authState) {
      case AuthAuthenticated():
        // 로그인 성공 후 리다이렉트 처리
        final redirectPath = Uri.base.queryParameters['redirect'];
        if (redirectPath != null && redirectPath.isNotEmpty) {
          // 딥링크에서 온 경우 원래 경로로 이동
          context.go(redirectPath);
        } else {
          // 일반 로그인인 경우 메인 화면으로 이동
          context.go('/main/home');
        }
      case AuthError(:final message):
        // 에러 메시지 표시
        GbSnackBar.showError(context, '로그인 실패: $message');
      case AuthInitial():
      case AuthLoading():
      case AuthUnauthenticated():
        // 예상치 못한 상태 (이론적으로는 발생하지 않아야 함)
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // 키보드 내리기
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 로고
                    const AuthLogoSection(),
                    const SizedBox(height: 48),

                    // 이메일 입력
                    GbTextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      labelText: '이메일',
                      hintText: 'example@email.com',
                      prefixIcon: const Icon(Icons.email_outlined),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '이메일을 입력해주세요';
                        }
                        if (!value.contains('@')) {
                          return '올바른 이메일 형식이 아닙니다';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // 비밀번호 입력
                    GbTextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      labelText: '비밀번호',
                      hintText: '비밀번호를 입력하세요',
                      prefixIcon: const Icon(Icons.lock_outlined),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '비밀번호를 입력해주세요';
                        }
                        if (value.length < 6) {
                          return '비밀번호는 6자 이상이어야 합니다';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // 로그인 버튼
                    Consumer(
                      builder: (context, ref, child) {
                        final authState = ref.watch(authNotifierProvider);
                        final isLoading = authState is AuthLoading;

                        return AuthLoadingButton(
                          text: '로그인',
                          isLoading: isLoading,
                          onPressed: _handleLogin,
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    // 구분선
                    Row(
                      children: [
                        Expanded(
                          child: Divider(
                            color: Colors.grey.shade300,
                            thickness: 1,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            '또는',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: Colors.grey.shade300,
                            thickness: 1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // 소셜 로그인 버튼들
                    Consumer(
                      builder: (context, ref, child) {
                        final authState = ref.watch(authNotifierProvider);
                        final isLoading = authState is AuthLoading;

                        return Column(
                          children: [
                            // 구글 로그인
                            SocialLoginButton(
                              type: SocialLoginType.google,
                              isLoading: isLoading,
                              onPressed: () {
                                // TODO: 구글 로그인 구현
                                debugPrint('구글 로그인 클릭');
                              },
                            ),
                            const SizedBox(height: 12),

                            // 카카오 로그인
                            SocialLoginButton(
                              type: SocialLoginType.kakao,
                              isLoading: isLoading,
                              onPressed: () {
                                // TODO: 카카오 로그인 구현
                                debugPrint('카카오 로그인 클릭');
                              },
                            ),
                            const SizedBox(height: 12),

                            // 애플 로그인 (iOS만 표시)
                            if (Theme.of(context).platform ==
                                TargetPlatform.iOS)
                              SocialLoginButton(
                                type: SocialLoginType.apple,
                                isLoading: isLoading,
                                onPressed: () {
                                  // TODO: 애플 로그인 구현
                                  debugPrint('애플 로그인 클릭');
                                },
                              ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    // 회원가입 링크
                    const SignupLinkWidget(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
