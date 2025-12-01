import 'package:flutter/material.dart';

/// Gear Freak 공통 로딩 뷰
/// 프로젝트에서 사용하는 모든 전체 화면 로딩 표시는 이 위젯을 사용합니다.
class GbLoadingView extends StatelessWidget {
  /// GbLoadingView 생성자
  ///
  /// [message]는 로딩 메시지입니다.
  const GbLoadingView({
    super.key,
    this.message,
  });

  /// 로딩 메시지 (선택사항)
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: message != null
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  message!,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
              ],
            )
          : const CircularProgressIndicator(),
    );
  }
}
