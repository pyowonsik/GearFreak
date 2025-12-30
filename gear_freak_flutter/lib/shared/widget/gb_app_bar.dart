import 'package:flutter/material.dart';

/// 공통 AppBar 위젯
///
/// prefix와 suffix를 통해 title 앞뒤에 위젯을 추가할 수 있습니다.
class GbAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// GbAppBar 생성자
  ///
  /// [title]는 AppBar의 제목입니다. (필수)
  /// [prefix]는 title 앞에 표시할 위젯입니다. (선택)
  /// [suffix]는 title 뒤에 표시할 위젯입니다. (선택)
  /// [leading]는 AppBar의 leading 위젯입니다. (선택, 기본값: 뒤로가기 버튼)
  /// [actions]는 AppBar의 actions 위젯 목록입니다. (선택)
  /// [automaticallyImplyLeading]는 자동으로 leading을 생성할지 여부입니다. (기본값: true)
  const GbAppBar({
    required this.title,
    this.prefix,
    this.suffix,
    this.leading,
    this.actions,
    this.automaticallyImplyLeading = true,
    super.key,
  });

  /// 제목
  final Widget title;

  /// title 앞에 표시할 위젯
  final Widget? prefix;

  /// title 뒤에 표시할 위젯
  final Widget? suffix;

  /// AppBar의 leading 위젯
  final Widget? leading;

  /// AppBar의 actions 위젯 목록
  final List<Widget>? actions;

  /// 자동으로 leading을 생성할지 여부
  final bool automaticallyImplyLeading;

  @override
  Widget build(BuildContext context) {
    var titleWidget = title;

    // prefix나 suffix가 있으면 Row로 감싸기
    if (prefix != null || suffix != null) {
      titleWidget = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (prefix != null) ...[
            prefix!,
            const SizedBox(width: 8),
          ],
          Flexible(child: title),
          if (suffix != null) ...[
            const SizedBox(width: 8),
            suffix!,
          ],
        ],
      );
    }

    return AppBar(
      title: titleWidget,
      leading: leading,
      actions: actions,
      automaticallyImplyLeading: automaticallyImplyLeading,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
