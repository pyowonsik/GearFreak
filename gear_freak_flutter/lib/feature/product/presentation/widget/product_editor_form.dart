import 'package:flutter/material.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import 'package:gear_freak_flutter/feature/product/presentation/utils/product_enum_helper.dart';
import 'package:gear_freak_flutter/feature/product/presentation/widget/product_basic_info_section_widget.dart';
import 'package:gear_freak_flutter/feature/product/presentation/widget/product_image_section_widget.dart';
import 'package:gear_freak_flutter/feature/product/presentation/widget/product_trade_info_section_widget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kpostal/kpostal.dart';

/// 상품 편집 폼 위젯 (생성/수정 공통)
class ProductEditorForm extends StatefulWidget {
  /// ProductEditorForm 생성자
  ///
  /// [formKey]는 폼의 GlobalKey입니다.
  /// [titleController]는 상품명 입력 컨트롤러입니다.
  /// [priceController]는 가격 입력 컨트롤러입니다.
  /// [descriptionController]는 상품 설명 입력 컨트롤러입니다.
  /// [detailAddressController]는 상세 주소 입력 컨트롤러입니다.
  /// [selectedCategory]는 선택된 카테고리입니다.
  /// [selectedCondition]는 선택된 상품 상태입니다.
  /// [selectedTradeMethod]는 선택된 거래 방법입니다.
  /// [existingImageUrls]는 기존 이미지 URL 목록입니다 (수정 모드에서만 사용).
  /// [newImageFiles]는 새로 추가한 이미지 파일 목록입니다.
  /// [baseAddress]는 기본 주소입니다.
  /// [onCategoryChanged]는 카테고리 변경 시 호출되는 콜백입니다.
  /// [onConditionChanged]는 상품 상태 변경 시 호출되는 콜백입니다.
  /// [onTradeMethodChanged]는 거래 방법 변경 시 호출되는 콜백입니다.
  /// [onBaseAddressChanged]는 기본 주소 변경 시 호출되는 콜백입니다.
  /// [onAddImage]는 이미지 추가 시 호출되는 콜백입니다.
  /// [onRemoveExistingImage]는 기존 이미지 제거 시 호출되는 콜백입니다 (수정 모드에서만 사용).
  /// [onRemoveNewImage]는 새 이미지 제거 시 호출되는 콜백입니다.
  /// [getUploadedFileKeys]는 업로드된 파일 키 목록을 가져오는 콜백입니다.
  const ProductEditorForm({
    required this.formKey,
    required this.titleController,
    required this.priceController,
    required this.descriptionController,
    required this.detailAddressController,
    required this.selectedCategory,
    required this.selectedCondition,
    required this.selectedTradeMethod,
    required this.newImageFiles,
    required this.onCategoryChanged,
    required this.onConditionChanged,
    required this.onTradeMethodChanged,
    required this.onBaseAddressChanged,
    required this.onAddImage,
    required this.onRemoveNewImage,
    required this.getUploadedFileKeys,
    this.onRemoveExistingImage,
    this.baseAddress,
    this.existingImageUrls = const [],
    super.key,
  });

  /// 폼의 GlobalKey
  final GlobalKey<FormState> formKey;

  /// 상품명 입력 컨트롤러
  final TextEditingController titleController;

  /// 가격 입력 컨트롤러
  final TextEditingController priceController;

  /// 상품 설명 입력 컨트롤러
  final TextEditingController descriptionController;

  /// 상세 주소 입력 컨트롤러
  final TextEditingController detailAddressController;

  /// 선택된 카테고리
  final pod.ProductCategory selectedCategory;

  /// 선택된 상품 상태
  final pod.ProductCondition selectedCondition;

  /// 선택된 거래 방법
  final pod.TradeMethod selectedTradeMethod;

  /// 기존 이미지 URL 목록 (수정 모드에서만 사용)
  final List<String> existingImageUrls;

  /// 새로 추가한 이미지 파일 목록
  final List<XFile> newImageFiles;

  /// 기본 주소
  final String? baseAddress;

  /// 카테고리 변경 시 호출되는 콜백
  final void Function(pod.ProductCategory) onCategoryChanged;

  /// 상품 상태 변경 시 호출되는 콜백
  final void Function(pod.ProductCondition) onConditionChanged;

  /// 거래 방법 변경 시 호출되는 콜백
  final void Function(pod.TradeMethod) onTradeMethodChanged;

  /// 기본 주소 변경 시 호출되는 콜백
  final void Function(String?) onBaseAddressChanged;

  /// 이미지 추가 시 호출되는 콜백 (선택된 이미지 파일 목록 전달)
  final Future<void> Function(List<XFile> images) onAddImage;

  /// 기존 이미지 제거 시 호출되는 콜백 (수정 모드에서만 사용)
  final void Function(int index)? onRemoveExistingImage;

  /// 새 이미지 제거 시 호출되는 콜백
  final Future<void> Function(int index) onRemoveNewImage;

  /// 업로드된 파일 키 목록을 가져오는 콜백
  final List<String> Function() getUploadedFileKeys;

  @override
  State<ProductEditorForm> createState() => _ProductEditorFormState();
}

class _ProductEditorFormState extends State<ProductEditorForm> {
  final ImagePicker _imagePicker = ImagePicker();

  /// 주소 검색
  Future<void> _searchAddress() async {
    try {
      final result = await Navigator.push<Kpostal?>(
        context,
        MaterialPageRoute(
          builder: (_) => KpostalView(),
        ),
      );

      if (result != null && mounted) {
        widget.onBaseAddressChanged(result.address);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('주소 검색 중 오류가 발생했습니다: $e')),
        );
      }
    }
  }

  /// 이미지 추가
  Future<void> _addImage() async {
    final totalImageCount =
        widget.existingImageUrls.length + widget.newImageFiles.length;
    final remainingSlots = 10 - totalImageCount;
    if (remainingSlots <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이미지는 최대 10장까지 추가할 수 있습니다')),
      );
      return;
    }

    try {
      // 여러 이미지 선택
      final images = await _imagePicker.pickMultiImage(
        imageQuality: 85,
      );

      if (images.isEmpty) {
        return;
      }

      // 남은 슬롯만큼만 선택
      final imagesToAdd = images.take(remainingSlots).toList();
      if (images.length > remainingSlots) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '이미지는 최대 10장까지 추가할 수 있습니다. $remainingSlots장만 추가됩니다.',
            ),
          ),
        );
      }

      // 이미지 추가 콜백 호출 (선택된 이미지 목록 전달)
      await widget.onAddImage(imagesToAdd);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('이미지를 선택하는 중 오류가 발생했습니다: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 이미지 업로드 섹션
            ProductImageSectionWidget(
              existingImageUrls: widget.existingImageUrls,
              newImageFiles: widget.newImageFiles,
              onAddImage: _addImage,
              onRemoveExistingImage: widget.onRemoveExistingImage,
              onRemoveNewImage: widget.onRemoveNewImage,
            ),

            const SizedBox(height: 8),

            // 기본 정보 섹션
            ProductBasicInfoSectionWidget(
              titleController: widget.titleController,
              priceController: widget.priceController,
              descriptionController: widget.descriptionController,
              selectedCategory: widget.selectedCategory,
              selectedCondition: widget.selectedCondition,
              onCategoryChanged: widget.onCategoryChanged,
              onConditionChanged: widget.onConditionChanged,
            ),

            const SizedBox(height: 8),

            // 거래 정보 섹션
            ProductTradeInfoSectionWidget(
              selectedTradeMethod: widget.selectedTradeMethod,
              baseAddress: widget.baseAddress,
              detailAddressController: widget.detailAddressController,
              onTradeMethodChanged: widget.onTradeMethodChanged,
              onSearchAddress: _searchAddress,
              isBaseAddressRequired: isDirectTrade(widget.selectedTradeMethod),
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}
