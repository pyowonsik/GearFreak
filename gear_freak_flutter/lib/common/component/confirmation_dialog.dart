import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 확인 대화 상자
class ConfirmationDialog extends StatelessWidget {
  /// ConfirmationDialog 생성자
  ///
  /// [title]은 대화 상잸의 제목입니다.
  /// [content]은 대화 상자의 내용입니다.
  /// [cancelText]은 취소 버튼의 텍스트입니다.
  /// [confirmText]은 확인 버튼의 텍스트입니다.
  /// [confirmColor]은 확인 버튼의 색상입니다.
  /// [onCancel]은 취소 버튼의 콜백입니다.
  /// [onConfirm]은 확인 버튼의 콜백입니다.
  const ConfirmationDialog({
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
        if (cancelText != null)
          TextButton(
            onPressed: onCancel ?? () => context.pop(false),
            child: Text(cancelText!),
          ),
        TextButton(
          onPressed: onConfirm ?? () => context.pop(true),
          style: TextButton.styleFrom(
            foregroundColor: confirmColor ?? Theme.of(context).primaryColor,
          ),
          child: Text(confirmText),
        ),
      ],
    );
  }

  /// 간편하게 사용할 수 있는 static method
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
      builder: (context) => ConfirmationDialog(
        title: title,
        content: content,
        cancelText: cancelText,
        confirmText: confirmText,
        confirmColor: confirmColor,
      ),
    );
  }
}
