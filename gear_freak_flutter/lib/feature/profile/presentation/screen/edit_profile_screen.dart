import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gear_freak_flutter/common/presentation/component/component.dart';
import 'package:gear_freak_flutter/common/presentation/view/view.dart';
import 'package:gear_freak_flutter/feature/profile/di/profile_providers.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

/// 프로필 편집 화면
class EditProfileScreen extends ConsumerStatefulWidget {
  /// EditProfileScreen 생성자
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nicknameController;
  File? _selectedImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // 프로필 정보는 build에서 가져오므로 초기값은 빈 문자열
    _nicknameController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 프로필 정보가 로드되면 컨트롤러 업데이트
    final profileState = ref.read(profileNotifierProvider);
    if (profileState.profile != null && _nicknameController.text.isEmpty) {
      _nicknameController.text = profileState.profile!.nickname;
    }
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  /// 이미지 선택
  Future<void> _pickImage() async {
    final picker = ImagePicker();

    if (!mounted) return;

    await showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              // ListTile(
              //   leading: const Icon(Icons.photo_camera),
              //   title: const Text('카메라로 촬영'),
              //   onTap: () async {
              //     Navigator.pop(context);
              //     final image = await picker.pickImage(
              //       source: ImageSource.camera,
              //       maxWidth: 512,
              //       maxHeight: 512,
              //     );
              //     if (image != null && mounted) {
              //       setState(() {
              //         _selectedImage = File(image.path);
              //       });
              //     }
              //   },
              // ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('갤러리에서 선택'),
                onTap: () async {
                  Navigator.pop(context);
                  final image = await picker.pickImage(
                    source: ImageSource.gallery,
                    maxWidth: 512,
                    maxHeight: 512,
                  );
                  if (image != null && mounted) {
                    setState(() {
                      _selectedImage = File(image.path);
                    });
                  }
                },
              ),
              if (_selectedImage != null)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text(
                    '프로필 이미지 삭제',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    if (mounted) {
                      setState(() {
                        _selectedImage = null;
                      });
                    }
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  /// 프로필 저장
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: 실제 프로필 저장 로직 구현
      // 1. 이미지가 있으면 S3에 업로드
      // 2. 프로필 업데이트 API 호출
      await Future<void>.delayed(const Duration(seconds: 1));

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      GbSnackBar.showSuccess(context, '프로필이 저장되었습니다');
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      GbSnackBar.showError(context, '프로필 저장에 실패했습니다: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileNotifierProvider);

    // 프로필이 로딩 중이거나 없으면 에러 표시
    if (profileState.isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('프로필 편집')),
        body: const GbLoadingView(),
      );
    }

    final profile = profileState.profile;
    if (profile == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('프로필 편집')),
        body: GbErrorView(
          message: '프로필 정보를 불러올 수 없습니다',
          onRetry: () {
            ref.read(profileNotifierProvider.notifier).loadProfile();
          },
          showBackButton: true,
          onBack: () => context.pop(),
        ),
      );
    }

    // 프로필 정보가 있으면 컨트롤러 업데이트
    if (_nicknameController.text != profile.nickname) {
      _nicknameController.text = profile.nickname;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('프로필 편집'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveProfile,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    '완료',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2563EB),
                    ),
                  ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 32),
              // 프로필 이미지
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: const Color(0xFFF3F4F6),
                      backgroundImage: _selectedImage != null
                          ? FileImage(_selectedImage!)
                          : null,
                      child: _selectedImage == null
                          ? Icon(
                              Icons.person,
                              size: 64,
                              color: Colors.grey.shade500,
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2563EB),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 3,
                            ),
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              // 닉네임 입력
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '닉네임',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF374151),
                      ),
                    ),
                    const SizedBox(height: 8),
                    GbTextFormField(
                      controller: _nicknameController,
                      hintText: '닉네임을 입력하세요',
                      filled: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '닉네임을 입력해주세요';
                        }
                        if (value.length < 2) {
                          return '닉네임은 2글자 이상이어야 합니다';
                        }
                        if (value.length > 10) {
                          return '닉네임은 10글자 이하여야 합니다';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '2-10자의 한글, 영문, 숫자를 사용할 수 있습니다',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
