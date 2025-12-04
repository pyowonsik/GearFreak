import 'package:flutter/material.dart';
import 'package:gear_freak_flutter/common/presentation/component/component.dart';
import 'package:gear_freak_flutter/feature/profile/presentation/widget/widget.dart';

/// 앱 정보 화면
class AppInfoScreen extends StatelessWidget {
  /// AppInfoScreen 생성자
  const AppInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GbAppBar(
        title: Text('앱 정보'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 앱 로고 및 버전
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2563EB), Color(0xFF7C3AED)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.shopping_bag,
                        size: 48,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '운동은 장비충',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Version 1.0.0',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 8),

            // 앱 정보 메뉴
            Column(
              children: [
                InfoItemWidget(
                  title: '이용약관',
                  onTap: () {
                    // 이용약관 화면으로 이동
                  },
                ),
                const GbDivider(),
                InfoItemWidget(
                  title: '개인정보 처리방침',
                  onTap: () {
                    // 개인정보 처리방침 화면으로 이동
                  },
                ),
                const GbDivider(),
                InfoItemWidget(
                  title: '오픈소스 라이선스',
                  onTap: () {
                    // 오픈소스 라이선스 화면으로 이동
                  },
                ),
              ],
            ),

            const SizedBox(height: 8),

            // 개발자 정보
            Column(
              children: [
                InfoItemWidget(
                  title: '개발자 정보',
                  onTap: () {
                    // 개발자 정보 다이얼로그 표시
                    _showDeveloperInfo(context);
                  },
                ),
                const GbDivider(),
                InfoItemWidget(
                  title: '문의하기',
                  onTap: () {
                    // 문의하기 화면으로 이동
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            // 저작권 정보
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                '© 2025 운동은 장비충. All rights reserved.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeveloperInfo(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('개발자 정보'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '회사명: 운동은 장비충',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 8),
            Text(
              '대표자: 홍길동',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 8),
            Text(
              '사업자등록번호: 123-45-67890',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 8),
            Text(
              '주소: 서울특별시 강남구',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 8),
            Text(
              '이메일: contact@gear-freak.com',
              style: TextStyle(fontSize: 14),
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
