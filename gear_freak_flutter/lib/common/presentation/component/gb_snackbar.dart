import 'package:flutter/material.dart';

/// 스낵바 타입
enum GbSnackBarType {
  /// 성공 메시지 (초록색)
  success,

  /// 에러 메시지 (빨간색)
  error,

  /// 정보 메시지 (파란색)
  info,

  /// 경고 메시지 (주황색)
  warning,
}

/// Gear Freak 공통 스낵바
/// 프로젝트에서 사용하는 모든 스낵바는 이 클래스를 사용합니다.
class GbSnackBar {
  /// 스낵바 표시
  ///
  /// [context]는 BuildContext입니다.
  /// [message]는 표시할 메시지입니다.
  /// [type]은 스낵바 타입입니다. (기본값: info)
  /// [duration]은 표시 시간입니다. (기본값: 2초)
  static void show(
    BuildContext context,
    String message, {
    GbSnackBarType type = GbSnackBarType.info,
    Duration duration = const Duration(seconds: 2),
  }) {
    if (!context.mounted) return;

    final backgroundColor = _getBackgroundColor(type);
    final icon = _getIcon(type);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  /// 성공 메시지 표시
  ///
  /// [context]는 BuildContext입니다.
  /// [message]는 표시할 메시지입니다.
  /// [duration]은 표시 시간입니다. (기본값: 2초)
  static void showSuccess(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 2),
  }) {
    show(context, message, type: GbSnackBarType.success, duration: duration);
  }

  /// 에러 메시지 표시
  ///
  /// [context]는 BuildContext입니다.
  /// [message]는 표시할 메시지입니다.
  /// [duration]은 표시 시간입니다. (기본값: 3초)
  static void showError(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    show(context, message, type: GbSnackBarType.error, duration: duration);
  }

  /// 정보 메시지 표시
  ///
  /// [context]는 BuildContext입니다.
  /// [message]는 표시할 메시지입니다.
  /// [duration]은 표시 시간입니다. (기본값: 2초)
  static void showInfo(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 2),
  }) {
    show(context, message, duration: duration);
  }

  /// 경고 메시지 표시
  ///
  /// [context]는 BuildContext입니다.
  /// [message]는 표시할 메시지입니다.
  /// [duration]은 표시 시간입니다. (기본값: 2초)
  static void showWarning(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 2),
  }) {
    show(context, message, type: GbSnackBarType.warning, duration: duration);
  }

  /// 타입에 따른 배경색 반환
  static Color _getBackgroundColor(GbSnackBarType type) {
    switch (type) {
      case GbSnackBarType.success:
        return const Color(0xFF10B981); // 초록색
      case GbSnackBarType.error:
        return const Color(0xFFEF4444); // 빨간색
      case GbSnackBarType.info:
        return const Color(0xFF2563EB); // 파란색
      case GbSnackBarType.warning:
        return const Color(0xFFF59E0B); // 주황색
    }
  }

  /// 타입에 따른 아이콘 반환
  static IconData? _getIcon(GbSnackBarType type) {
    switch (type) {
      case GbSnackBarType.success:
        return Icons.check_circle_outline;
      case GbSnackBarType.error:
        return Icons.error_outline;
      case GbSnackBarType.info:
        return Icons.info_outline;
      case GbSnackBarType.warning:
        return Icons.warning_amber_rounded;
    }
  }
}
