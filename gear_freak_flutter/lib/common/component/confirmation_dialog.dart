import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String content;
  final String? cancelText;
  final String confirmText;
  final Color? confirmColor;
  final VoidCallback? onCancel;
  final VoidCallback? onConfirm;

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.content,
    this.cancelText,
    required this.confirmText,
    this.confirmColor,
    this.onCancel,
    this.onConfirm,
  });

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
    String? cancelText = '취소',
    required String confirmText,
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
