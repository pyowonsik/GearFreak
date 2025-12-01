import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import 'package:gear_freak_flutter/common/presentation/component/component.dart';
import 'package:gear_freak_flutter/feature/product/di/product_providers.dart';
import 'package:gear_freak_flutter/feature/product/presentation/provider/create_product_state.dart';
import 'package:gear_freak_flutter/feature/product/presentation/utils/product_enum_helper.dart';
import 'package:gear_freak_flutter/feature/product/presentation/widget/widget.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

/// 상품 등록 화면
class CreateProductScreen extends ConsumerStatefulWidget {
  /// 상품 등록 화면 생성자
  ///
  /// [key]는 상품 등록 화면의 키입니다.
  const CreateProductScreen({super.key});

  @override
  ConsumerState<CreateProductScreen> createState() =>
      _CreateProductScreenState();
}

class _CreateProductScreenState extends ConsumerState<CreateProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _detailAddressController = TextEditingController();

  pod.ProductCategory _selectedCategory = pod.ProductCategory.equipment;
  pod.ProductCondition _selectedCondition = pod.ProductCondition.usedExcellent;
  pod.TradeMethod _selectedTradeMethod = pod.TradeMethod.direct;
  final List<XFile> _selectedImages = [];
  String? _baseAddress; // 기본 주소 (kpostal에서 가져온 주소)

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _detailAddressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 상태 변화 감시하여 스낵바 표시
    ref.listen<CreateProductState>(
      createProductNotifierProvider,
      (previous, next) {
        if (!mounted) return;

        if (next is CreateProductUploadError) {
          // 업로드 에러 상태일 때만 스낵바 표시
          GbSnackBar.showError(context, next.error);
        } else if (next is CreateProductCreateError) {
          // 상품 생성 에러 상태일 때 스낵바 표시
          GbSnackBar.showError(context, next.error);
        } else if (next is CreateProductCreated) {
          // 상품 생성 성공 시 생성된 상품의 상세 페이지로 이동
          final product = next.product;
          if (product.id != null) {
            context.go('/product/${product.id}');
            GbSnackBar.showSuccess(context, '상품이 등록되었습니다');
          } else {
            // id가 없으면 홈으로
            context.pop();
          }
        }
      },
    );

    return GestureDetector(
      onTap: () {
        // 키보드 내리기
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('상품 등록'),
          actions: [
            Consumer(
              builder: (context, ref, child) {
                final state = ref.watch(createProductNotifierProvider);
                final isCreating = state is CreateProductCreating;
                return TextButton(
                  onPressed: isCreating ? null : _submitProduct,
                  child: isCreating
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          '완료',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                );
              },
            ),
          ],
        ),
        body: ProductEditorForm(
          formKey: _formKey,
          titleController: _titleController,
          priceController: _priceController,
          descriptionController: _descriptionController,
          detailAddressController: _detailAddressController,
          selectedCategory: _selectedCategory,
          selectedCondition: _selectedCondition,
          selectedTradeMethod: _selectedTradeMethod,
          newImageFiles: _selectedImages,
          baseAddress: _baseAddress,
          onCategoryChanged: (category) {
            setState(() {
              _selectedCategory = category;
            });
          },
          onConditionChanged: (condition) {
            setState(() {
              _selectedCondition = condition;
            });
          },
          onTradeMethodChanged: (method) {
            setState(() {
              _selectedTradeMethod = method;
            });
          },
          onBaseAddressChanged: (address) {
            setState(() {
              _baseAddress = address;
            });
          },
          onAddImage: _addImage,
          onRemoveNewImage: _removeNewImage,
          getUploadedFileKeys: () {
            final currentState = ref.read(createProductNotifierProvider);
            return currentState.uploadedFileKeys;
          },
        ),
      ),
    );
  }

  /// 이미지 추가 (선택 및 업로드)
  Future<void> _addImage(List<XFile> images) async {
    // 선택한 이미지들을 순차적으로 업로드
    final notifier = ref.read(createProductNotifierProvider.notifier);
    for (final image in images) {
      await notifier.uploadImage(
        imageFile: File(image.path),
        prefix: 'product',
      );

      // 업로드 성공 시 이미지 목록에 추가
      final currentState = ref.read(createProductNotifierProvider);
      if (currentState is CreateProductUploadSuccess) {
        setState(() {
          _selectedImages.add(image);
        });
      } else if (currentState is CreateProductUploadError) {
        if (!mounted) return;
        // 업로드 실패 시 해당 이미지 건너뛰기
        GbSnackBar.showError(
          context,
          '${image.name} 업로드 실패: ${currentState.error}',
        );
        break; // 실패 시 중단
      }
    }
  }

  /// 새 이미지 제거
  Future<void> _removeNewImage(int index) async {
    // 이미지 인덱스 찾기
    if (index >= _selectedImages.length) {
      return;
    }

    // S3에서 파일 삭제
    final currentState = ref.read(createProductNotifierProvider);
    if (index < currentState.uploadedFileKeys.length) {
      final fileKey = currentState.uploadedFileKeys[index];
      final notifier = ref.read(createProductNotifierProvider.notifier);
      await notifier.removeUploadedFileKey(fileKey);
    }

    // 로컬 이미지 목록에서 제거
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _submitProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedImages.isEmpty) {
      GbSnackBar.showWarning(context, '최소 1장의 이미지를 추가해주세요');
      return;
    }

    if (isDirectTrade(_selectedTradeMethod) &&
        (_baseAddress == null || _baseAddress!.isEmpty)) {
      GbSnackBar.showWarning(context, '주소를 검색해주세요');
      return;
    }

    // 가격 파싱
    final price = int.tryParse(_priceController.text);
    if (price == null || price <= 0) {
      GbSnackBar.showWarning(context, '올바른 가격을 입력해주세요');
      return;
    }

    // 업로드된 이미지가 있는지 확인
    final currentState = ref.read(createProductNotifierProvider);
    if (currentState.uploadedFileKeys.isEmpty) {
      GbSnackBar.showWarning(context, '이미지 업로드를 완료해주세요');
      return;
    }

    // 상품 생성 API 호출
    final notifier = ref.read(createProductNotifierProvider.notifier);
    await notifier.createProduct(
      title: _titleController.text,
      category: _selectedCategory,
      price: price,
      condition: _selectedCondition,
      description: _descriptionController.text,
      tradeMethod: _selectedTradeMethod,
      baseAddress: _baseAddress,
      detailAddress: _detailAddressController.text.isEmpty
          ? null
          : _detailAddressController.text,
    );
  }
}
