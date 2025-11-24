import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import 'package:gear_freak_flutter/feature/product/di/product_providers.dart';
import 'package:gear_freak_flutter/feature/product/presentation/provider/create_product_state.dart';
import 'package:gear_freak_flutter/feature/product/presentation/utils/product_enum_helper.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kpostal/kpostal.dart';

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
  final ImagePicker _imagePicker = ImagePicker();
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(next.error),
              backgroundColor: Colors.red,
            ),
          );
        } else if (next is CreateProductCreateError) {
          // 상품 생성 에러 상태일 때 스낵바 표시
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(next.error),
              backgroundColor: Colors.red,
            ),
          );
        } else if (next is CreateProductCreated) {
          // 상품 생성 성공 시 화면 닫기 (화면 전환 자체가 피드백)
          context.pop();
        }
      },
    );

    return Scaffold(
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
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 이미지 업로드 섹션
              Container(
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
                      '${_selectedImages.length}/10',
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
                          _buildAddImageButton(),
                          ..._selectedImages.map(_buildImagePreview),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // 기본 정보 섹션
              Container(
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
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: '상품명',
                        hintText: '상품명을 입력해주세요',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '상품명을 입력해주세요';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<pod.ProductCategory>(
                      value: _selectedCategory,
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
                          setState(() {
                            _selectedCategory = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(
                        labelText: '가격',
                        hintText: '가격을 입력해주세요',
                        border: OutlineInputBorder(),
                        suffixText: '원',
                      ),
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
                      value: _selectedCondition,
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
                          setState(() {
                            _selectedCondition = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: '상품 설명',
                        hintText: '상품에 대한 설명을 입력해주세요',
                        border: OutlineInputBorder(),
                      ),
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
              ),

              const SizedBox(height: 8),

              // 거래 정보 섹션
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '거래 정보',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<pod.TradeMethod>(
                      value: _selectedTradeMethod,
                      decoration: const InputDecoration(
                        labelText: '거래 방법',
                        border: OutlineInputBorder(),
                      ),
                      items: pod.TradeMethod.values.map((method) {
                        return DropdownMenuItem<pod.TradeMethod>(
                          value: method,
                          child: Text(getTradeMethodLabel(method)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedTradeMethod = value;
                          });
                        }
                      },
                    ),
                    if (isDirectTrade(_selectedTradeMethod)) ...[
                      const SizedBox(height: 16),
                      // 기본 주소 검색
                      InkWell(
                        onTap: _searchAddress,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFFE5E7EB)),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                color: Color(0xFF6B7280),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _baseAddress ?? '주소 검색',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: _baseAddress == null
                                        ? const Color(0xFF9CA3AF)
                                        : const Color(0xFF1F2937),
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.search,
                                color: Color(0xFF9CA3AF),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (_baseAddress == null &&
                          isDirectTrade(_selectedTradeMethod))
                        Padding(
                          padding: const EdgeInsets.only(top: 8, left: 12),
                          child: Text(
                            '주소를 검색해주세요',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.red.shade700,
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),
                      // 상세 주소 입력
                      TextFormField(
                        controller: _detailAddressController,
                        decoration: const InputDecoration(
                          labelText: '상세 주소',
                          hintText: '예: 101동 201호',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.home),
                        ),
                        validator: (value) {
                          if (isDirectTrade(_selectedTradeMethod) &&
                              _baseAddress != null &&
                              (value == null || value.isEmpty)) {
                            return '상세 주소를 입력해주세요';
                          }
                          return null;
                        },
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddImageButton() {
    return GestureDetector(
      onTap: _addImage,
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

  Widget _buildImagePreview(XFile imageFile) {
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
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedImages.remove(imageFile);
                });
              },
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
        setState(() {
          _baseAddress = result.address;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('주소 검색 중 오류가 발생했습니다: $e')),
        );
      }
    }
  }

  Future<void> _addImage() async {
    final remainingSlots = 10 - _selectedImages.length;
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

      // 선택한 이미지들을 순차적으로 업로드
      final notifier = ref.read(createProductNotifierProvider.notifier);
      for (final image in imagesToAdd) {
        await notifier.uploadImage(
          imageFile: File(image.path),
          prefix: 'product',
          bucketType: 'public',
        );

        // 업로드 성공 시 이미지 목록에 추가
        final currentState = ref.read(createProductNotifierProvider);
        if (currentState is CreateProductUploadSuccess) {
          setState(() {
            _selectedImages.add(image);
          });
        } else if (currentState is CreateProductUploadError) {
          // 업로드 실패 시 해당 이미지 건너뛰기
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${image.name} 업로드 실패: ${currentState.error}'),
              backgroundColor: Colors.red,
            ),
          );
          break; // 실패 시 중단
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('이미지를 선택하는 중 오류가 발생했습니다: $e')),
        );
      }
    }
  }

  Future<void> _submitProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('최소 1장의 이미지를 추가해주세요')),
      );
      return;
    }

    if (isDirectTrade(_selectedTradeMethod) &&
        (_baseAddress == null || _baseAddress!.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('주소를 검색해주세요')),
      );
      return;
    }

    // 가격 파싱
    final price = int.tryParse(_priceController.text);
    if (price == null || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('올바른 가격을 입력해주세요')),
      );
      return;
    }

    // 업로드된 이미지가 있는지 확인
    final currentState = ref.read(createProductNotifierProvider);
    if (currentState.uploadedFileKeys.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이미지 업로드를 완료해주세요')),
      );
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
