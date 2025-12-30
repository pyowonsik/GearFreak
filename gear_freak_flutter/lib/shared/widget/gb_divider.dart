import 'package:flutter/material.dart';

/// 공통 Divider 컴포넌트
///
/// 프로젝트 전반에서 사용하는 일관된 스타일의 Divider입니다.
class GbDivider extends StatelessWidget {
  /// GbDivider 생성자
  ///
  /// [height]는 Divider의 높이입니다. (기본값: 1)
  /// [thickness]는 Divider의 두께입니다. (기본값: 1)
  /// [color]는 Divider의 색상입니다. (기본값: Colors.grey.shade200)
  /// [indent]는 Divider의 시작 들여쓰기입니다. (기본값: 16)
  /// [endIndent]는 Divider의 끝 들여쓰기입니다. (기본값: 16)
  const GbDivider({
    this.height = 1,
    this.thickness = 1,
    this.color,
    this.indent = 16,
    this.endIndent = 16,
    super.key,
  });

  /// Divider의 높이
  final double height;

  /// Divider의 두께
  final double thickness;

  /// Divider의 색상
  final Color? color;

  /// Divider의 시작 들여쓰기
  final double indent;

  /// Divider의 끝 들여쓰기
  final double endIndent;

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: height,
      thickness: thickness,
      color: color ?? Colors.grey.shade200,
      indent: indent,
      endIndent: endIndent,
    );
  }
}
