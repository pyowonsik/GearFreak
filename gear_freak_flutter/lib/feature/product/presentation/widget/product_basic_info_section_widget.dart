import 'package:flutter/material.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import 'package:gear_freak_flutter/common/presentation/component/component.dart';
import 'package:gear_freak_flutter/feature/product/presentation/utils/product_enum_helper.dart';

/// 상품 기본 정보 섹션 위젯
class ProductBasicInfoSectionWidget extends StatelessWidget {
  /// 상품 기본 정보 섹션 위젯 생성자
  const ProductBasicInfoSectionWidget({
    required this.titleController,
    required this.priceController,
    required this.descriptionController,
    required this.selectedCategory,
    required this.selectedCondition,
    required this.onCategoryChanged,
    required this.onConditionChanged,
    super.key,
  });

  /// 상품명 컨트롤러
  final TextEditingController titleController;

  /// 가격 컨트롤러
  final TextEditingController priceController;

  /// 상품 설명 컨트롤러
  final TextEditingController descriptionController;

  /// 선택된 카테고리
  final pod.ProductCategory selectedCategory;

  /// 선택된 상품 상태
  final pod.ProductCondition selectedCondition;

  /// 카테고리 변경 콜백
  final void Function(pod.ProductCategory) onCategoryChanged;

  /// 상품 상태 변경 콜백
  final void Function(pod.ProductCondition) onConditionChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '기본 정보',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 16),
          GbTextFormField(
            controller: titleController,
            labelText: '상품명',
            hintText: '상품명을 입력해주세요',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '상품명을 입력해주세요';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<pod.ProductCategory>(
            initialValue: selectedCategory,
            decoration: const InputDecoration(
              labelText: '카테고리',
              border: OutlineInputBorder(),
            ),
            items: pod.ProductCategory.values.map((category) {
              return DropdownMenuItem<pod.ProductCategory>(
                value: category,
                child: Text(getProductCategoryLabel(category)),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                onCategoryChanged(value);
              }
            },
          ),
          const SizedBox(height: 16),
          GbTextFormField(
            controller: priceController,
            labelText: '가격',
            hintText: '가격을 입력해주세요',
            suffixText: '원',
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '가격을 입력해주세요';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<pod.ProductCondition>(
            initialValue: selectedCondition,
            decoration: const InputDecoration(
              labelText: '상품 상태',
              border: OutlineInputBorder(),
            ),
            items: pod.ProductCondition.values.map((condition) {
              return DropdownMenuItem<pod.ProductCondition>(
                value: condition,
                child: Text(getProductConditionLabel(condition)),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                onConditionChanged(value);
              }
            },
          ),
          const SizedBox(height: 16),
          GbTextFormField(
            controller: descriptionController,
            labelText: '상품 설명',
            hintText: '상품에 대한 설명을 입력해주세요',
            maxLines: 5,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '상품 설명을 입력해주세요';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}
