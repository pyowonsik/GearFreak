import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 메인 화면 (탭 네비게이션)
/// StatefulShellRoute의 builder에서 사용되는 페이지
class AppRouterPage extends StatelessWidget {
  /// AppRouterPage 생성자
  ///
  /// [navigationShell]는 네비게이션 쉘입니다.
  const AppRouterPage({
    required this.navigationShell,
    super.key,
  });

  /// 네비게이션 쉘
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: navigationShell.currentIndex,
          onTap: (index) {
            navigationShell.goBranch(
              index,
              // 탭 전환 시 초기 경로로 이동
              initialLocation: index == navigationShell.currentIndex,
            );
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: '홈',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search_outlined),
              activeIcon: Icon(Icons.search),
              label: '검색',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_circle_outline, size: 32),
              activeIcon: Icon(Icons.add_circle, size: 32),
              label: '등록',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline),
              activeIcon: Icon(Icons.chat_bubble),
              label: '채팅',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: '내 정보',
            ),
          ],
        ),
      ),
    );
  }
}
