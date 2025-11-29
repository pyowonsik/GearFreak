import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 회원가입 화면에서 사용하는 로그인 링크 위젯
class LoginLinkWidget extends StatelessWidget {
  /// LoginLinkWidget 생성자
  ///
  /// [key]는 위젯의 키입니다.
  const LoginLinkWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          '이미 계정이 있으신가요? ',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF6B7280),
          ),
        ),
        GestureDetector(
          onTap: () => context.pop(),
          child: const Text(
            '로그인',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF2563EB),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
