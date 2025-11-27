import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
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
                if (totalImageCount < 10) _buildAddImageButton(),
                ...existingImageUrls.asMap().entries.map((entry) {
                  return _buildExistingImagePreview(
                    entry.value,
                    entry.key,
                  );
                }),
                ...newImageFiles.asMap().entries.map((entry) {
                  return _buildNewImagePreview(
                    entry.value,
                    entry.key,
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddImageButton() {
    return GestureDetector(
      onTap: onAddImage,
      child: Container(
        width: 100,
        height: 100,
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.camera_alt,
              size: 32,
              color: Color(0xFF9CA3AF),
            ),
            SizedBox(height: 4),
            Text(
              '사진 추가',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExistingImagePreview(String imageUrl, int index) {
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
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
              placeholder: (context, url) => const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF9CA3AF)),
                ),
              ),
              errorWidget: (context, url, error) => const Center(
                child: Icon(
                  Icons.image,
                  size: 48,
                  color: Color(0xFF9CA3AF),
                ),
              ),
            ),
          ),
          if (onRemoveExistingImage != null)
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: () => onRemoveExistingImage!(index),
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

  Widget _buildNewImagePreview(XFile imageFile, int index) {
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
          if (onRemoveNewImage != null)
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: () => onRemoveNewImage!(index),
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
