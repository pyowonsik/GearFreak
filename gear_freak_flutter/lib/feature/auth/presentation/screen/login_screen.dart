import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gear_freak_flutter/common/presentation/component/component.dart';
import 'package:gear_freak_flutter/feature/auth/di/auth_providers.dart';
import 'package:gear_freak_flutter/feature/auth/presentation/component/auth_loading_button.dart';
import 'package:gear_freak_flutter/feature/auth/presentation/component/auth_logo_section.dart';
import 'package:gear_freak_flutter/feature/auth/presentation/component/social_login_button.dart';
import 'package:gear_freak_flutter/feature/auth/presentation/provider/auth_state.dart';
import 'package:gear_freak_flutter/feature/auth/presentation/widget/signup_link_widget.dart';

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
    // 상태 처리는 ref.listen()에서 자동으로 처리됨
  }

  @override
  Widget build(BuildContext context) {
    // 상태 변경 감지: 에러만 처리 (성공은 가드에서 처리)
    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      if (next is AuthError && mounted) {
        // 에러 메시지에 로그인 타입 구분이 필요하면 추가 가능
        GbSnackBar.showError(context, '로그인 실패: ${next.message}');
      }
    });

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
                              onPressed: () async {
                                final authNotifier =
                                    ref.read(authNotifierProvider.notifier);
                                await authNotifier.loginWithGoogle();
                                // 상태 처리는 ref.listen()에서 자동으로 처리됨
                              },
                            ),
                            const SizedBox(height: 12),

                            // 카카오 로그인
                            SocialLoginButton(
                              type: SocialLoginType.kakao,
                              isLoading: isLoading,
                              onPressed: () async {
                                final authNotifier =
                                    ref.read(authNotifierProvider.notifier);
                                await authNotifier.loginWithKakao();
                                // 상태 처리는 ref.listen()에서 자동으로 처리됨
                              },
                            ),
                            const SizedBox(height: 12),

                            // 애플 로그인 (iOS만 표시)
                            if (Theme.of(context).platform ==
                                TargetPlatform.iOS)
                              SocialLoginButton(
                                type: SocialLoginType.apple,
                                isLoading: isLoading,
                                onPressed: () async {
                                  final authNotifier =
                                      ref.read(authNotifierProvider.notifier);
                                  await authNotifier.loginWithApple();
                                  // 상태 처리는 ref.listen()에서 자동으로 처리됨
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
