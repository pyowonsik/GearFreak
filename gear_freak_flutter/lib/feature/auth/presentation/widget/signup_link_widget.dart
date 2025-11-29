import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 로그인 화면에서 사용하는 회원가입 링크 위젯
class SignupLinkWidget extends StatelessWidget {
  /// SignupLinkWidget 생성자
  ///
  /// [key]는 위젯의 키입니다.
  const SignupLinkWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          '계정이 없으신가요? ',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF6B7280),
          ),
        ),
        TextButton(
          onPressed: () {
            context.push('/signup');
          },
          child: const Text(
            '회원가입',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
