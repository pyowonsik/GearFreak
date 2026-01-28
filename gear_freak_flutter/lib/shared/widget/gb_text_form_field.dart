import 'package:flutter/material.dart';

/// Gear Freak 공통 TextFormField
/// 프로젝트에서 사용하는 모든 TextFormField는 이 위젯을 사용합니다.
class GbTextFormField extends StatelessWidget {
  /// GbTextFormField 생성자
  ///
  /// [controller]는 컨트롤러입니다.
  /// [labelText]는 라벨 텍스트입니다.
  /// [hintText]는 힌트 텍스트입니다.
  /// [hintStyle]는 힌트 스타일입니다.
  /// [prefixIcon]는 접두사 아이콘입니다.
  /// [suffixIcon]는 접미사 아이콘입니다.
  /// [suffixText]는 접미사 텍스트입니다.
  /// [keyboardType]는 키보드 타입입니다.
  /// [obscureText]는 비밀번호 모드입니다.
  /// [maxLines]는 최대 라인 수입니다.
  /// [minLines]는 최소 라인 수입니다.
  /// [validator]는 유효성 검사 함수입니다.
  /// [onChanged]는 입력 변경 콜백입니다.
  /// [focusNode]는 포커스 노드입니다.
  /// [readOnly]는 읽기 전용 여부입니다.
  /// [filled]는 채워진 스타일 사용 여부입니다.
  /// [fillColor]는 채워진 색상입니다.
  /// [contentPadding]는 컨텐츠 패딩입니다.
  /// [decoration]는 커스텀 InputDecoration입니다.
  const GbTextFormField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.hintStyle,
    this.prefixIcon,
    this.suffixIcon,
    this.suffixText,
    this.keyboardType,
    this.obscureText = false,
    this.maxLines = 1,
    this.minLines,
    this.validator,
    this.onChanged,
    this.focusNode,
    this.readOnly = false,
    this.filled = false,
    this.fillColor,
    this.contentPadding,
    this.decoration,
  });

  /// 컨트롤러
  final TextEditingController? controller;

  /// 라벨 텍스트
  final String? labelText;

  /// 힌트 텍스트
  final String? hintText;

  /// 힌트 스타일
  final TextStyle? hintStyle;

  /// 접두사 아이콘
  final Widget? prefixIcon;

  /// 접미사 아이콘
  final Widget? suffixIcon;

  /// 접미사 텍스트
  final String? suffixText;

  /// 키보드 타입
  final TextInputType? keyboardType;

  /// 비밀번호 모드
  final bool obscureText;

  /// 최대 라인 수
  final int? maxLines;

  /// 최소 라인 수
  final int? minLines;

  /// 유효성 검사 함수
  final String? Function(String?)? validator;

  /// 입력 변경 콜백
  final void Function(String)? onChanged;

  /// 포커스 노드
  final FocusNode? focusNode;

  /// 읽기 전용 여부
  final bool readOnly;

  /// 채워진 스타일 사용 여부 (signup 스타일)
  final bool filled;

  /// 채워진 색상
  final Color? fillColor;

  /// 컨텐츠 패딩
  final EdgeInsetsGeometry? contentPadding;

  /// 커스텀 InputDecoration (기본 스타일을 덮어씀)
  final InputDecoration? decoration;

  @override
  Widget build(BuildContext context) {
    // 커스텀 decoration이 제공되면 그대로 사용
    if (decoration != null) {
      return TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        maxLines: maxLines,
        minLines: minLines,
        validator: validator,
        onChanged: onChanged,
        focusNode: focusNode,
        readOnly: readOnly,
        decoration: decoration,
      );
    }

    // 기본 스타일 적용
    final defaultHintStyle = hintStyle ??
        const TextStyle(
          color: Color(0xFF9CA3AF),
        );

    final defaultFillColor = fillColor ?? const Color(0xFFF9FAFB);
    final defaultContentPadding = contentPadding ??
        const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        );

    // maxLines > 1인 경우 힌트 텍스트를 상단에 배치
    final isMultiLine = maxLines != null && maxLines! > 1;

    // filled 스타일 (signup 스타일)
    if (filled) {
      return TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        maxLines: maxLines,
        minLines: minLines,
        validator: validator,
        onChanged: onChanged,
        focusNode: focusNode,
        readOnly: readOnly,
        textAlignVertical:
            isMultiLine ? TextAlignVertical.top : TextAlignVertical.center,
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          hintStyle: defaultHintStyle,
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          suffixText: suffixText,
          filled: true,
          fillColor: defaultFillColor,
          contentPadding: defaultContentPadding,
          alignLabelWithHint: isMultiLine,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color(0xFF2563EB),
              width: 2,
            ),
          ),
        ),
      );
    }

    // 기본 스타일 (login, product 스타일)
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLines: maxLines,
      minLines: minLines,
      validator: validator,
      onChanged: onChanged,
      focusNode: focusNode,
      readOnly: readOnly,
      textAlignVertical:
          isMultiLine ? TextAlignVertical.top : TextAlignVertical.center,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        hintStyle: defaultHintStyle,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        suffixText: suffixText,
        alignLabelWithHint: isMultiLine,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
