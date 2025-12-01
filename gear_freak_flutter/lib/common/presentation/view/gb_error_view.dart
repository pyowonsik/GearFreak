import 'package:flutter/material.dart';

/// Gear Freak 공통 에러 뷰
/// 프로젝트에서 사용하는 모든 에러 상태 표시는 이 위젯을 사용합니다.
class GbErrorView extends StatelessWidget {
  /// GbErrorView 생성자
  ///
  /// [message]는 에러 메시지입니다.
  /// [onRetry]는 다시 시도 버튼 클릭 시 호출되는 콜백입니다.
  /// [title]는 에러 제목입니다.
  /// [showBackButton]는 뒤로 가기 버튼 표시 여부입니다.
  /// [onBack]는 뒤로 가기 버튼 클릭 시 호출되는 콜백입니다.
  /// [icon]는 에러 아이콘입니다.
  /// [iconSize]는 아이콘 크기입니다.
  /// [iconColor]는 아이콘 색상입니다.
  const GbErrorView({
    required this.message,
    required this.onRetry,
    super.key,
    this.title,
    this.showBackButton = false,
    this.onBack,
    this.icon = Icons.error_outline,
    this.iconSize = 64,
    this.iconColor = Colors.red,
  }) : assert(
          !showBackButton || onBack != null,
          'showBackButton이 true일 때는 onBack을 제공해야 합니다.',
        );

  /// 에러 메시지
  final String message;

  /// 다시 시도 버튼 클릭 시 호출되는 콜백
  final VoidCallback onRetry;

  /// 에러 제목 (선택사항)
  final String? title;

  /// 뒤로 가기 버튼 표시 여부
  final bool showBackButton;

  /// 뒤로 가기 버튼 클릭 시 호출되는 콜백
  final VoidCallback? onBack;

  /// 에러 아이콘
  final IconData icon;

  /// 아이콘 크기
  final double iconSize;

  /// 아이콘 색상
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: iconSize,
            color: iconColor,
          ),
          const SizedBox(height: 16),
          if (title != null) ...[
            Text(
              title!,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
          ],
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.red,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text('다시 시도'),
          ),
          if (showBackButton) ...[
            const SizedBox(height: 8),
            TextButton(
              onPressed: onBack,
              child: const Text('뒤로 가기'),
            ),
          ],
        ],
      ),
    );
  }
}
