import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kpostal/kpostal.dart';

class CreateProductScreen extends StatefulWidget {
  const CreateProductScreen({super.key});

  @override
  State<CreateProductScreen> createState() => _CreateProductScreenState();
}

class _CreateProductScreenState extends State<CreateProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _detailAddressController = TextEditingController();

  String _selectedCategory = '장비';
  String _selectedCondition = '중고 - 상';
  String _selectedTradeMethod = '직거래';
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('상품 등록'),
        actions: [
          TextButton(
            onPressed: _submitProduct,
            child: const Text(
              '완료',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
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
                          ..._selectedImages
                              .map((img) => _buildImagePreview(img)),
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
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: const InputDecoration(
                        labelText: '카테고리',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: '장비', child: Text('장비')),
                        DropdownMenuItem(value: '보충제', child: Text('보충제')),
                        DropdownMenuItem(value: '의류', child: Text('의류')),
                        DropdownMenuItem(value: '신발', child: Text('신발')),
                        DropdownMenuItem(value: '기타', child: Text('기타')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value!;
                        });
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
                    DropdownButtonFormField<String>(
                      value: _selectedCondition,
                      decoration: const InputDecoration(
                        labelText: '상품 상태',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: '새 제품', child: Text('새 제품')),
                        DropdownMenuItem(
                            value: '중고 - 상', child: Text('중고 - 상')),
                        DropdownMenuItem(
                            value: '중고 - 중', child: Text('중고 - 중')),
                        DropdownMenuItem(
                            value: '중고 - 하', child: Text('중고 - 하')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedCondition = value!;
                        });
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
                    DropdownButtonFormField<String>(
                      value: _selectedTradeMethod,
                      decoration: const InputDecoration(
                        labelText: '거래 방법',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: '직거래', child: Text('직거래')),
                        DropdownMenuItem(value: '택배', child: Text('택배')),
                        DropdownMenuItem(
                            value: '직거래/택배', child: Text('직거래/택배')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedTradeMethod = value!;
                        });
                      },
                    ),
                    if (_selectedTradeMethod.contains('직거래')) ...[
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
                          _selectedTradeMethod.contains('직거래'))
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
                          if (_selectedTradeMethod.contains('직거래') &&
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
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
      final Kpostal? result = await Navigator.push(
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
    if (_selectedImages.length >= 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이미지는 최대 10장까지 추가할 수 있습니다')),
      );
      return;
    }

    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImages.add(image);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('이미지를 선택하는 중 오류가 발생했습니다: $e')),
        );
      }
    }
  }

  void _submitProduct() {
    if (_formKey.currentState!.validate()) {
      if (_selectedImages.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('최소 1장의 이미지를 추가해주세요')),
        );
        return;
      }

      if (_selectedTradeMethod.contains('직거래') &&
          (_baseAddress == null || _baseAddress!.isEmpty)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('주소를 검색해주세요')),
        );
        return;
      }

      // 전체 주소 조합 (기본 주소 + 상세 주소)
      final fullAddress =
          _baseAddress != null && _detailAddressController.text.isNotEmpty
              ? '$_baseAddress ${_detailAddressController.text}'
              : _baseAddress ?? '';

      // TODO: 서버에 상품 등록 API 호출
      // fullAddress를 사용하여 주소 정보 전송

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('상품이 등록되었습니다')),
      );
      Navigator.of(context).pop();
    }
  }
}
