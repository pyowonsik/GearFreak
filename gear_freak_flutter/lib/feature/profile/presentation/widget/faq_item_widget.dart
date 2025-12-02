import 'package:flutter/material.dart';

/// FAQ 항목 위젯
class FAQItemWidget extends StatelessWidget {
  /// FAQItemWidget 생성자
  ///
  /// [question]는 질문입니다.
  /// [answer]는 답변입니다.
  const FAQItemWidget({
    required this.question,
    required this.answer,
    super.key,
  });

  /// 질문
  final String question;

  /// 답변
  final String answer;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(
        question,
        style: const TextStyle(
          fontSize: 15,
          color: Color(0xFF1F2937),
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Text(
            answer,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
        ),
      ],
    );
  }
}
