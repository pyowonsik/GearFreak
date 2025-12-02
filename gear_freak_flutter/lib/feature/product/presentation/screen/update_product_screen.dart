import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import 'package:gear_freak_flutter/common/presentation/component/component.dart';
import 'package:gear_freak_flutter/common/presentation/view/view.dart';
import 'package:gear_freak_flutter/feature/product/di/product_providers.dart';
import 'package:gear_freak_flutter/feature/product/presentation/provider/update_product_state.dart';
import 'package:gear_freak_flutter/feature/product/presentation/utils/product_enum_helper.dart';
import 'package:gear_freak_flutter/feature/product/presentation/widget/widget.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

/// 상품 수정 화면
class UpdateProductScreen extends ConsumerStatefulWidget {
  /// 상품 수정 화면 생성자
  ///
  /// [productId]는 수정할 상품의 ID입니다.
  const UpdateProductScreen({
    required this.productId,
    super.key,
  });

  /// 수정할 상품의 ID
  final String productId;

  @override
  ConsumerState<UpdateProductScreen> createState() =>
      _UpdateProductScreenState();
}

class _UpdateProductScreenState extends ConsumerState<UpdateProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _detailAddressController = TextEditingController();

  pod.ProductCategory _selectedCategory = pod.ProductCategory.equipment;
  pod.ProductCondition _selectedCondition = pod.ProductCondition.usedExcellent;
  pod.TradeMethod _selectedTradeMethod = pod.TradeMethod.direct;
  final List<XFile> _newImageFiles = [];
  String? _baseAddress;

  // 기존 이미지 URL 목록 (서버에서 가져온 이미지)
  List<String> _existingImageUrls = [];

  bool _isDataLoaded = false;

  @override
  void initState() {
    super.initState();
    // 화면 진입 시 상품 데이터 로딩
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final productId = int.tryParse(widget.productId);
      if (productId != null) {
        ref.read(updateProductNotifierProvider.notifier).loadProduct(productId);
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _detailAddressController.dispose();
    super.dispose();
  }

  /// 상품 데이터를 폼에 채우기
  void _fillFormWithProductData(pod.Product product) {
    if (_isDataLoaded) return; // 이미 채워진 경우 중복 방지

    _titleController.text = product.title;
    _priceController.text = product.price.toString();
    _descriptionController.text = product.description;
    _selectedCategory = product.category;
    _selectedCondition = product.condition;
    _selectedTradeMethod = product.tradeMethod;
    _baseAddress = product.baseAddress;
    _detailAddressController.text = product.detailAddress ?? '';
    _existingImageUrls = product.imageUrls ?? [];

    setState(() {
      _isDataLoaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(updateProductNotifierProvider);

    // 상태 변화 감시하여 스낵바 표시
    ref.listen<UpdateProductState>(
      updateProductNotifierProvider,
      (previous, next) {
        if (!mounted) return;

        if (next is UpdateProductUploadError) {
          // 업로드 에러 상태일 때만 스낵바 표시
          GbSnackBar.showError(context, next.error);
        } else if (next is UpdateProductUpdateError) {
          // 수정 에러 상태일 때 스낵바 표시
          GbSnackBar.showError(context, next.error);
        } else if (next is UpdateProductUpdated) {
          // 상품 수정 성공 시 상세 화면 상태 새로고침 후 화면 닫기
          final productId = int.tryParse(widget.productId);
          if (productId != null) {
            // 상세 화면의 notifier를 다시 로드하여 최신 데이터 반영
            ref
                .read(productDetailNotifierProvider.notifier)
                .loadProductDetail(productId);
          }
          // 화면 닫기 (화면 전환 자체가 피드백)
          context.pop();
        }
      },
    );

    // 데이터 로딩 성공 시 폼에 데이터 채우기
    if (state is UpdateProductLoaded) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _fillFormWithProductData(state.product);
      });
    }

    return GestureDetector(
      onTap: () {
        // 키보드 내리기
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('상품 수정'),
          actions: [
            Consumer(
              builder: (context, ref, child) {
                final state = ref.watch(updateProductNotifierProvider);
                final isUploading = state is UpdateProductUploading;
                final isUpdating = state is UpdateProductUpdating;
                final isLoading = isUploading || isUpdating;
                return TextButton(
                  onPressed: isLoading ? null : _submitProduct,
                  child: isLoading
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
        body: switch (state) {
          UpdateProductInitial() => const GbLoadingView(),
          UpdateProductLoading() => const GbLoadingView(),
          UpdateProductLoadError(:final error) => GbErrorView(
              title: '오류가 발생했습니다',
              message: error,
              onRetry: () {
                final productId = int.tryParse(widget.productId);
                if (productId != null) {
                  ref
                      .read(updateProductNotifierProvider.notifier)
                      .loadProduct(productId);
                }
              },
              showBackButton: true,
              onBack: () => context.pop(),
            ),
          UpdateProductLoaded() => ProductEditorForm(
              formKey: _formKey,
              titleController: _titleController,
              priceController: _priceController,
              descriptionController: _descriptionController,
              detailAddressController: _detailAddressController,
              selectedCategory: _selectedCategory,
              selectedCondition: _selectedCondition,
              selectedTradeMethod: _selectedTradeMethod,
              existingImageUrls: _existingImageUrls,
              newImageFiles: _newImageFiles,
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
              onRemoveExistingImage: _removeExistingImage,
              onRemoveNewImage: _removeNewImage,
              getUploadedFileKeys: () {
                final currentState = ref.read(updateProductNotifierProvider);
                if (currentState is UpdateProductLoaded) {
                  return currentState.uploadedFileKeys;
                }
                return [];
              },
            ),
        },
      ),
    );
  }

  /// 이미지 추가 (선택 및 업로드)
  Future<void> _addImage(List<XFile> images) async {
    // 선택한 이미지들을 순차적으로 업로드
    final notifier = ref.read(updateProductNotifierProvider.notifier);
    for (final image in images) {
      await notifier.uploadImage(
        imageFile: File(image.path),
        prefix: 'product',
      );

      // 업로드 성공 시 이미지 목록에 추가
      final currentState = ref.read(updateProductNotifierProvider);
      if (currentState is UpdateProductUploadSuccess) {
        setState(() {
          _newImageFiles.add(image);
        });
      } else if (currentState is UpdateProductUploadError) {
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

  /// 기존 이미지 제거
  ///
  /// 주의: S3에서의 실제 삭제는 최종 updateProduct 엔드포인트에서 처리됩니다.
  /// 이유:
  /// 1. 사용자가 수정을 취소하거나 뒤로 가기를 누를 수 있음
  /// 2. 사용자가 이미지를 제거했다가 다시 추가할 수 있음
  /// 3. 최종 제출 시점에만 삭제하면 데이터 무결성 보장
  void _removeExistingImage(int index) {
    setState(() {
      _existingImageUrls.removeAt(index);
    });
    // S3 삭제는 최종 updateProduct 엔드포인트에서 처리
    // - 제거된 이미지 URL 목록을 서버에 전달
    // - 서버에서 원본 이미지 목록과 비교하여 삭제할 이미지 식별
    // - 삭제할 이미지만 S3에서 삭제
  }

  /// 새 이미지 제거
  Future<void> _removeNewImage(int index) async {
    if (index >= _newImageFiles.length) {
      return;
    }

    // S3에서 파일 삭제
    final currentState = ref.read(updateProductNotifierProvider);
    if (currentState is UpdateProductLoaded) {
      if (index < currentState.uploadedFileKeys.length) {
        final fileKey = currentState.uploadedFileKeys[index];
        final notifier = ref.read(updateProductNotifierProvider.notifier);
        await notifier.removeUploadedFileKey(fileKey);
      }
    }

    // 로컬 이미지 목록에서 제거
    setState(() {
      _newImageFiles.removeAt(index);
    });
  }

  /// 상품 수정 제출
  Future<void> _submitProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final totalImageCount = _existingImageUrls.length + _newImageFiles.length;
    if (totalImageCount == 0) {
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

    // 상품 수정 API 호출
    final productId = int.tryParse(widget.productId);
    if (productId == null) {
      GbSnackBar.showError(context, '상품 ID가 유효하지 않습니다');
      return;
    }

    final notifier = ref.read(updateProductNotifierProvider.notifier);
    await notifier.updateProduct(
      productId: productId,
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
      existingImageUrls: _existingImageUrls,
    );
  }
}
