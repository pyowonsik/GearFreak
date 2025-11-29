import 'package:flutter/material.dart';

/// 회원가입 화면에서 사용하는 약관 동의 체크박스 위젯
class TermsAgreementWidget extends StatelessWidget {
  /// TermsAgreementWidget 생성자
  ///
  /// [agreed]는 약관 동의 상태입니다.
  /// [onChanged]는 약관 동의 상태 변경 콜백입니다.
  /// [key]는 위젯의 키입니다.
  const TermsAgreementWidget({
    required this.agreed,
    required this.onChanged,
    super.key,
  });

  /// 약관 동의 상태
  final bool agreed;

  /// 약관 동의 상태 변경 콜백
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: agreed,
            onChanged: (value) {
              onChanged(value ?? false);
            },
            activeColor: const Color(0xFF2563EB),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Text.rich(
            TextSpan(
              text: '서비스 약관',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF2563EB),
                decoration: TextDecoration.underline,
              ),
              children: [
                TextSpan(
                  text: ' 및 ',
                  style: TextStyle(
                    color: Color(0xFF6B7280),
                    decoration: TextDecoration.none,
                  ),
                ),
                TextSpan(
                  text: '개인정보 처리방침',
                  style: TextStyle(
                    color: Color(0xFF2563EB),
                    decoration: TextDecoration.underline,
                  ),
                ),
                TextSpan(
                  text: '에 동의합니다',
                  style: TextStyle(
                    color: Color(0xFF6B7280),
                    decoration: TextDecoration.none,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
