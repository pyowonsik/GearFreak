import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// 새 이미지 미리보기 위젯
class NewImagePreviewWidget extends StatelessWidget {
  /// NewImagePreviewWidget 생성자
  ///
  /// [imageFile]는 표시할 이미지 파일입니다.
  /// [index]는 이미지의 인덱스입니다.
  /// [onRemove]는 이미지 제거 시 호출되는 콜백입니다.
  const NewImagePreviewWidget({
    required this.imageFile,
    required this.index,
    this.onRemove,
    super.key,
  });

  /// 표시할 이미지 파일
  final XFile imageFile;

  /// 이미지의 인덱스
  final int index;

  /// 이미지 제거 시 호출되는 콜백
  final void Function(int index)? onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              File(imageFile.path),
              width: 100,
              height: 100,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Center(
                  child: Icon(
                    Icons.image,
                    size: 48,
                    color: Color(0xFF9CA3AF),
                  ),
                );
              },
            ),
          ),
          if (onRemove != null)
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: () => onRemove!(index),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
