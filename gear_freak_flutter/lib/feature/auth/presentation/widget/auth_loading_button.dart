import 'package:flutter/material.dart';

/// 인증 화면에서 사용하는 로딩 상태 버튼 컴포넌트
class AuthLoadingButton extends StatelessWidget {
  /// AuthLoadingButton 생성자
  ///
  /// [text]는 버튼 텍스트입니다.
  /// [isLoading]는 로딩 상태입니다.
  /// [onPressed]는 버튼 클릭 콜백입니다.
  /// [backgroundColor]는 버튼 배경색입니다.
  /// [foregroundColor]는 버튼 전경색 (텍스트 색상)입니다.
  /// [height]는 버튼 높이입니다.
  const AuthLoadingButton({
    required this.text,
    required this.isLoading,
    this.onPressed,
    super.key,
    this.backgroundColor,
    this.foregroundColor,
    this.height,
  });

  /// 버튼 텍스트
  final String text;

  /// 로딩 상태
  final bool isLoading;

  /// 버튼 클릭 콜백
  final VoidCallback? onPressed;

  /// 버튼 배경색
  final Color? backgroundColor;

  /// 버튼 전경색 (텍스트 색상)
  final Color? foregroundColor;

  /// 버튼 높이
  final double? height;

  @override
  Widget build(BuildContext context) {
    final defaultBackgroundColor =
        backgroundColor ?? Theme.of(context).colorScheme.primary;
    final defaultForegroundColor = foregroundColor ?? Colors.white;

    final button = ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: defaultBackgroundColor,
        foregroundColor: defaultForegroundColor,
        disabledBackgroundColor: const Color(0xFF9CA3AF),
        elevation: height != null ? 0 : null,
        shadowColor: height != null ? Colors.transparent : null,
        padding: EdgeInsets.symmetric(vertical: height != null ? 0 : 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: isLoading
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  defaultForegroundColor,
                ),
              ),
            )
          : Text(
              text,
              style: TextStyle(
                fontSize: 16,
                fontWeight: height != null ? FontWeight.w600 : FontWeight.bold,
              ),
            ),
    );

    if (height != null) {
      return SizedBox(
        width: double.infinity,
        height: height,
        child: button,
      );
    }

    return button;
  }
}
