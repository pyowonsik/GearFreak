import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Gear Freak 공통 대화 상자
/// 프로젝트에서 사용하는 모든 다이얼로그는 이 클래스를 사용합니다.
class GbDialog extends StatelessWidget {
  /// GbDialog 생성자
  ///
  /// [title]은 대화 상자의 제목입니다.
  /// [content]은 대화 상자의 내용입니다.
  /// [cancelText]은 취소 버튼의 텍스트입니다.
  /// [confirmText]은 확인 버튼의 텍스트입니다.
  /// [confirmColor]은 확인 버튼의 색상입니다.
  /// [onCancel]은 취소 버튼의 콜백입니다.
  /// [onConfirm]은 확인 버튼의 콜백입니다.
  const GbDialog({
    required this.title,
    required this.content,
    required this.confirmText,
    super.key,
    this.cancelText,
    this.confirmColor,
    this.onCancel,
    this.onConfirm,
  });

  /// 대화 상자의 제목
  final String title;

  /// 대화 상자의 내용
  final String content;

  /// 취소 버튼의 텍스트
  final String? cancelText;

  /// 확인 버튼의 텍스트
  final String confirmText;

  /// 확인 버튼의 색상
  final Color? confirmColor;

  /// 취소 버튼의 콜백
  final VoidCallback? onCancel;

  /// 확인 버튼의 콜백
  final VoidCallback? onConfirm;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: onConfirm ?? () => context.pop(true),
          style: TextButton.styleFrom(
            foregroundColor: confirmColor ?? Theme.of(context).primaryColor,
          ),
          child: Text(confirmText),
        ),
        if (cancelText != null)
          TextButton(
            onPressed: onCancel ?? () => context.pop(false),
            child: Text(cancelText!),
          ),
      ],
    );
  }

  /// 간편하게 사용할 수 있는 static method
  ///
  /// [context]는 BuildContext입니다.
  /// [title]은 대화 상자의 제목입니다.
  /// [content]은 대화 상자의 내용입니다.
  /// [confirmText]은 확인 버튼의 텍스트입니다.
  /// [cancelText]은 취소 버튼의 텍스트입니다. (기본값: '취소')
  /// [confirmColor]은 확인 버튼의 색상입니다.
  ///
  /// 반환값: Future<bool?> - 확인 버튼을 누르면 true, 취소 버튼을 누르면 false, null은 다이얼로그가 닫힌 경우
  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required String content,
    required String confirmText,
    String? cancelText = '취소',
    Color? confirmColor,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => GbDialog(
        title: title,
        content: content,
        cancelText: cancelText,
        confirmText: confirmText,
        confirmColor: confirmColor,
      ),
    );
  }
}
