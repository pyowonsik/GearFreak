import 'package:flutter/material.dart';

/// 바텀 시트 옵션 아이템
class GbBottomSheetItem {
  /// GbBottomSheetItem 생성자
  ///
  /// [title]는 옵션 제목입니다.
  /// [onTap]는 옵션 선택 시 콜백입니다.
  /// [leading]는 옵션 앞에 표시할 아이콘입니다. (선택)
  /// [textColor]는 텍스트 색상입니다. (선택, 기본값: null)
  const GbBottomSheetItem({
    required this.title,
    required this.onTap,
    this.leading,
    this.textColor,
  });

  /// 옵션 제목
  final String title;

  /// 옵션 선택 시 콜백
  final VoidCallback onTap;

  /// 옵션 앞에 표시할 아이콘
  final IconData? leading;

  /// 텍스트 색상
  final Color? textColor;
}

/// Gear Freak 공통 바텀 시트
class GbBottomSheet {
  /// 바텀 시트 표시
  ///
  /// [context]는 BuildContext입니다.
  /// [items]는 표시할 옵션 목록입니다.
  static Future<void> show({
    required BuildContext context,
    required List<GbBottomSheetItem> items,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: items.map((item) {
              return ListTile(
                leading: item.leading != null
                    ? Icon(
                        item.leading,
                        color: item.textColor,
                      )
                    : null,
                title: Text(
                  item.title,
                  style: TextStyle(
                    color: item.textColor,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  item.onTap();
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
