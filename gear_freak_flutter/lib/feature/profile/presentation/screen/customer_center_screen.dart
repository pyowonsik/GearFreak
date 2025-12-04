import 'package:flutter/material.dart';
import 'package:gear_freak_flutter/common/presentation/component/component.dart';
import 'package:gear_freak_flutter/feature/profile/presentation/widget/widget.dart';

/// 고객센터 화면
class CustomerCenterScreen extends StatelessWidget {
  /// CustomerCenterScreen 생성자
  const CustomerCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GbAppBar(
        title: Text('고객 센터'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 자주 묻는 질문 섹션
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '자주 묻는 질문',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  SizedBox(height: 16),
                  FAQItemWidget(
                    question: '상품을 등록하려면 어떻게 해야 하나요?',
                    answer: '홈 화면 하단의 등록 버튼을 눌러 상품을 등록할 수 있습니다.',
                  ),
                  GbDivider(),
                  FAQItemWidget(
                    question: '상품을 수정하거나 삭제할 수 있나요?',
                    answer: '내 상품 관리에서 등록한 상품을 수정하거나 삭제할 수 있습니다.',
                  ),
                  GbDivider(),
                  FAQItemWidget(
                    question: '거래는 어떻게 진행되나요?',
                    answer: '상품 상세 화면에서 판매자와 채팅으로 거래를 진행할 수 있습니다.',
                  ),
                  GbDivider(),
                  FAQItemWidget(
                    question: '계정을 삭제하려면 어떻게 해야 하나요?',
                    answer: '프로필 설정에서 계정 삭제를 요청할 수 있습니다.',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // 문의하기 섹션
            Column(
              children: [
                InfoItemWidget(
                  title: '1:1 문의하기',
                  icon: Icons.chat_bubble_outline,
                  onTap: () {
                    // 1:1 문의하기 화면으로 이동
                    GbSnackBar.showInfo(
                      context,
                      '1:1 문의하기 기능은 준비 중입니다.',
                    );
                  },
                ),
                const GbDivider(),
                InfoItemWidget(
                  title: '공지사항',
                  icon: Icons.notifications_outlined,
                  onTap: () {
                    // 공지사항 화면으로 이동
                    GbSnackBar.showInfo(
                      context,
                      '공지사항 기능은 준비 중입니다.',
                    );
                  },
                ),
                const GbDivider(),
                InfoItemWidget(
                  title: '이메일 문의',
                  icon: Icons.email_outlined,
                  onTap: () {
                    // 이메일 문의
                    _showEmailContact(context);
                  },
                ),
              ],
            ),

            const SizedBox(height: 8),

            // 운영 시간 안내
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '운영 시간',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '평일: 09:00 ~ 18:00',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '주말 및 공휴일: 휴무',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '문의사항이 있으시면 이메일로 문의해주세요.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showEmailContact(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('이메일 문의'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '문의사항이 있으시면 아래 이메일로 연락해주세요.',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 16),
            Text(
              '이메일:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 4),
            SelectableText(
              'support@gear-freak.com',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF2563EB),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }
}
