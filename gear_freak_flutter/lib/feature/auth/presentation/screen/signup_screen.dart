import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gear_freak_flutter/feature/auth/di/auth_providers.dart';
import 'package:gear_freak_flutter/feature/auth/presentation/component/component.dart';
import 'package:gear_freak_flutter/feature/auth/presentation/provider/auth_state.dart';
import 'package:gear_freak_flutter/feature/auth/presentation/widget/widget.dart';
import 'package:gear_freak_flutter/shared/widget/widget.dart';
import 'package:go_router/go_router.dart';

/// 회원가입 화면
class SignupScreen extends ConsumerStatefulWidget {
  /// SignupScreen 생성자
  ///
  /// [key]는 위젯의 키입니다.
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _agreeToTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_agreeToTerms) {
      GbSnackBar.showWarning(
        context,
        '서비스 약관 및 개인정보 처리방침에 동의해주세요',
      );
      return;
    }

    final authNotifier = ref.read(authNotifierProvider.notifier);
    await authNotifier.signup(
      userName: _nameController.text.trim(),
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
        GbSnackBar.showError(context, '회원가입 실패: ${next.message}');
      }
    });

    return GestureDetector(
      onTap: () {
        // 키보드 내리기
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: GbAppBar(
          title: const Text(
            '회원가입',
            style: TextStyle(
              color: Color(0xFF1F2937),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF1F2937)),
            onPressed: () => context.pop(),
          ),
          automaticallyImplyLeading: false,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  const Text(
                    '환영합니다!',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '헬스 용품을 사고 팔 수 있는 FitMarket에\n가입하세요',
                    style: TextStyle(
                      fontSize: 15,
                      color: Color(0xFF6B7280),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Name Field
                  const Text(
                    '닉네임',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF374151),
                    ),
                  ),
                  const SizedBox(height: 8),
                  GbTextFormField(
                    controller: _nameController,
                    hintText: '사용할 닉네임을 입력하세요',
                    filled: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '닉네임을 입력해주세요';
                      }
                      if (value.length < 2) {
                        return '닉네임은 2자 이상이어야 합니다';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Email Field
                  const Text(
                    '이메일',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF374151),
                    ),
                  ),
                  const SizedBox(height: 8),
                  GbTextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    hintText: 'example@email.com',
                    filled: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '이메일을 입력해주세요';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                          .hasMatch(value)) {
                        return '올바른 이메일 형식이 아닙니다';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Password Field
                  const Text(
                    '비밀번호',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF374151),
                    ),
                  ),
                  const SizedBox(height: 8),
                  GbTextFormField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    hintText: '8자 이상 입력하세요',
                    filled: true,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: const Color(0xFF9CA3AF),
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '비밀번호를 입력해주세요';
                      }
                      if (value.length < 8) {
                        return '비밀번호는 8자 이상이어야 합니다';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Confirm Password Field
                  const Text(
                    '비밀번호 확인',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF374151),
                    ),
                  ),
                  const SizedBox(height: 8),
                  GbTextFormField(
                    controller: _confirmPasswordController,
                    obscureText: !_isConfirmPasswordVisible,
                    hintText: '비밀번호를 다시 입력하세요',
                    filled: true,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isConfirmPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: const Color(0xFF9CA3AF),
                      ),
                      onPressed: () {
                        setState(() {
                          _isConfirmPasswordVisible =
                              !_isConfirmPasswordVisible;
                        });
                      },
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '비밀번호를 다시 입력해주세요';
                      }
                      if (value != _passwordController.text) {
                        return '비밀번호가 일치하지 않습니다';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Terms Agreement
                  TermsAgreementWidget(
                    agreed: _agreeToTerms,
                    onChanged: (value) {
                      setState(() {
                        _agreeToTerms = value;
                      });
                    },
                  ),
                  const SizedBox(height: 32),

                  // Signup Button
                  Consumer(
                    builder: (context, ref, child) {
                      final authState = ref.watch(authNotifierProvider);
                      final isLoading = authState is AuthLoading;

                      return AuthLoadingButton(
                        text: '회원가입',
                        isLoading: isLoading,
                        onPressed: _handleSignup,
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        height: 56,
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // Login Link
                  const LoginLinkWidget(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
