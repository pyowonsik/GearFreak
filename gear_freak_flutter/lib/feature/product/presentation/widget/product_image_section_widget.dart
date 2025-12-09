import 'package:flutter/material.dart';
import 'package:gear_freak_flutter/feature/product/presentation/widget/add_image_button_widget.dart';
import 'package:gear_freak_flutter/feature/product/presentation/widget/existing_image_preview_widget.dart';
import 'package:gear_freak_flutter/feature/product/presentation/widget/new_image_preview_widget.dart';
import 'package:image_picker/image_picker.dart';

/// 상품 이미지 섹션 위젯
///
/// 기존 이미지(URL)와 새로 추가한 이미지(XFile)를 모두 표시합니다.
class ProductImageSectionWidget extends StatelessWidget {
  /// 상품 이미지 섹션 위젯 생성자
  ///
  /// [existingImageUrls]는 기존 이미지 URL 목록입니다.
  /// [newImageFiles]는 새로 추가한 이미지 파일 목록입니다.
  /// [onAddImage]는 이미지 추가 버튼 클릭 시 호출되는 콜백입니다.
  /// [onRemoveExistingImage]는 기존 이미지 제거 시 호출되는 콜백입니다.
  /// [onRemoveNewImage]는 새 이미지 제거 시 호출되는 콜백입니다.
  const ProductImageSectionWidget({
    required this.existingImageUrls,
    required this.newImageFiles,
    required this.onAddImage,
    this.onRemoveExistingImage,
    this.onRemoveNewImage,
    super.key,
  });

  /// 기존 이미지 URL 목록
  final List<String> existingImageUrls;

  /// 새로 추가한 이미지 파일 목록
  final List<XFile> newImageFiles;

  /// 이미지 추가 버튼 클릭 시 호출되는 콜백
  final VoidCallback onAddImage;

  /// 기존 이미지 제거 시 호출되는 콜백 (인덱스 전달)
  final void Function(int index)? onRemoveExistingImage;

  /// 새 이미지 제거 시 호출되는 콜백 (인덱스 전달)
  final void Function(int index)? onRemoveNewImage;

  @override
  Widget build(BuildContext context) {
    final totalImageCount = existingImageUrls.length + newImageFiles.length;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '상품 이미지',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$totalImageCount/10',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF9CA3AF),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 100,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                if (totalImageCount < 10)
                  AddImageButtonWidget(
                    onTap: onAddImage,
                  ),
                ...existingImageUrls.asMap().entries.map((entry) {
                  return ExistingImagePreviewWidget(
                    imageUrl: entry.value,
                    index: entry.key,
                    onRemove: onRemoveExistingImage,
                  );
                }),
                ...newImageFiles.asMap().entries.map((entry) {
                  return NewImagePreviewWidget(
                    imageFile: entry.value,
                    index: entry.key,
                    onRemove: onRemoveNewImage,
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
