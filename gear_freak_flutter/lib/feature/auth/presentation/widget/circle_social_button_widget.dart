import 'package:flutter/material.dart';

/// 원형 소셜 로그인 버튼 위젯
class CircleSocialButtonWidget extends StatelessWidget {
  /// CircleSocialButtonWidget 생성자
  ///
  /// [onTap]는 버튼 클릭 콜백입니다.
  /// [child]는 버튼 내부 위젯입니다.
  /// [backgroundColor]는 버튼 배경색입니다 (기본값: Colors.white).
  const CircleSocialButtonWidget({
    required this.onTap,
    required this.child,
    this.backgroundColor = Colors.white,
    super.key,
  });

  /// 버튼 클릭 콜백
  final VoidCallback? onTap;

  /// 버튼 내부 위젯
  final Widget child;

  /// 버튼 배경색
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 56,
          height: 56,
          child: Center(child: child),
        ),
      ),
    );
  }
}
