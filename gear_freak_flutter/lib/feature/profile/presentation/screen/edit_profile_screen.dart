import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gear_freak_flutter/common/presentation/component/component.dart';
import 'package:gear_freak_flutter/common/presentation/view/view.dart';
import 'package:gear_freak_flutter/feature/profile/di/profile_providers.dart';
import 'package:gear_freak_flutter/feature/profile/presentation/provider/profile_state.dart';
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
  bool _removedExistingImage = false;

  @override
  void initState() {
    super.initState();
    _nicknameController = TextEditingController();
    // 화면 진입 시 프로필 데이터 로딩
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(profileNotifierProvider.notifier).loadProfile();
    });
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

    // 현재 상태에서 프로필 이미지가 있는지 확인
    final profileState = ref.read(profileNotifierProvider);
    var hasProfileImage = false;
    if (profileState is ProfileLoaded) {
      hasProfileImage = profileState.uploadedFileKey != null ||
          (!_removedExistingImage &&
              (profileState.user.profileImageUrl?.isNotEmpty ?? false));
    }

    await showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
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
                    final imageFile = File(image.path);
                    // 이미지 선택 시 즉시 업로드
                    await ref
                        .read(profileNotifierProvider.notifier)
                        .uploadProfileImage(
                          imageFile: imageFile,
                          prefix: 'profile',
                        );
                    // 새 이미지 업로드 시 기존 이미지 삭제 플래그 초기화
                    if (_removedExistingImage) {
                      setState(() {
                        _removedExistingImage = false;
                      });
                    }
                  }
                },
              ),
              if (hasProfileImage)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text(
                    '프로필 이미지 삭제',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () async {
                    Navigator.pop(context);
                    if (!mounted) return;

                    final currentState = ref.read(profileNotifierProvider);
                    final notifier = ref.read(profileNotifierProvider.notifier);

                    // ProfileLoaded 또는 그 하위 클래스인 경우 user와 uploadedFileKey 접근 가능
                    if (currentState is ProfileLoaded) {
                      if (currentState.uploadedFileKey != null) {
                        // 새로 업로드된 이미지가 있으면 S3에서 삭제
                        await notifier.removeUploadedFileKey(
                          currentState.uploadedFileKey!,
                        );
                        // 새로 업로드한 이미지를 삭제한 경우, 기존 이미지가 있으면 그것도 제거
                        if (currentState.user.profileImageUrl != null &&
                            currentState.user.profileImageUrl!.isNotEmpty) {
                          setState(() {
                            _removedExistingImage = true;
                          });
                        }
                      } else if (currentState.user.profileImageUrl != null &&
                          currentState.user.profileImageUrl!.isNotEmpty) {
                        // 기존 프로필 이미지가 있으면 제거 표시 (로컬 상태만 변경)
                        // S3 삭제는 최종 updateProfile 엔드포인트에서 처리
                        setState(() {
                          _removedExistingImage = true;
                        });
                      }
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

    await ref.read(profileNotifierProvider.notifier).updateProfile(
          nickname: _nicknameController.text,
          removedExistingImage: _removedExistingImage,
        );
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileNotifierProvider);

    // 상태 변화 감시하여 스낵바 표시 및 화면 닫기
    ref.listen<ProfileState>(
      profileNotifierProvider,
      (previous, next) {
        if (!mounted) return;

        // 업데이트 완료 확인 (ProfileUpdating -> ProfileUpdated)
        if (next is ProfileUpdated) {
          GbSnackBar.showSuccess(context, '프로필이 저장되었습니다');
          if (mounted) {
            // 프로필 화면 새로고침을 위해 프로필 다시 로드
            ref.read(profileNotifierProvider.notifier).loadProfile();
            context.pop();
          }
        }

        // 이미지 업로드 실패 확인
        else if (next is ProfileImageUploadError) {
          GbSnackBar.showError(context, next.error);
        }
        // 프로필 업데이트 실패 확인
        else if (next is ProfileUpdateError) {
          GbSnackBar.showError(context, next.error);
        }
        // 일반 에러
        else if (next is ProfileError) {
          GbSnackBar.showError(context, next.message);
        }
      },
    );

    final isUploading = profileState is ProfileImageUploading;
    final isUpdating = profileState is ProfileUpdating;

    // 프로필 데이터가 로드되었을 때 닉네임 컨트롤러 초기화
    if (profileState is ProfileLoaded) {
      final user = profileState.user;
      if (_nicknameController.text.isEmpty && user.nickname != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _nicknameController.text = user.nickname ?? '';
          }
        });
      }
    }

    return Scaffold(
      appBar: GbAppBar(
        title: const Text('프로필 편집'),
        actions: [
          TextButton(
            onPressed: isUpdating ? null : _saveProfile,
            child: isUpdating
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
      body: () {
        switch (profileState) {
          case ProfileInitial() || ProfileLoading():
            return const GbLoadingView();
          case ProfileError(:final message):
            return GbErrorView(
              message: message,
              onRetry: () {
                ref.read(profileNotifierProvider.notifier).loadProfile();
              },
              showBackButton: true,
              onBack: () => context.pop(),
            );
          case ProfileLoaded(:final user, :final uploadedFileKey):
            // 업로드된 이미지 URL이 있으면 표시
            String? uploadedImageUrl;
            if (uploadedFileKey != null) {
              final s3BaseUrl = dotenv.env['S3_PUBLIC_BASE_URL']!;
              uploadedImageUrl = '$s3BaseUrl/$uploadedFileKey';
            } else if (!_removedExistingImage &&
                user.profileImageUrl != null &&
                user.profileImageUrl!.isNotEmpty) {
              // 기존 프로필 이미지가 있고 제거되지 않았으면 표시
              uploadedImageUrl = user.profileImageUrl;
            }

            return Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 32),
                    // 프로필 이미지
                    Center(
                      child: GestureDetector(
                        onTap: isUploading ? null : _pickImage,
                        child: Stack(
                          children: [
                            ClipOval(
                              child: Container(
                                width: 120,
                                height: 120,
                                color: const Color(0xFFF3F4F6),
                                child: uploadedImageUrl != null
                                    ? CachedNetworkImage(
                                        imageUrl: uploadedImageUrl,
                                        width: 120,
                                        height: 120,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) =>
                                            const Center(
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                              Color(0xFF9CA3AF),
                                            ),
                                          ),
                                        ),
                                        errorWidget: (context, url, error) =>
                                            Icon(
                                          Icons.person,
                                          size: 64,
                                          color: Colors.grey.shade500,
                                        ),
                                      )
                                    : isUploading
                                        ? const Center(
                                            child: CircularProgressIndicator(),
                                          )
                                        : Icon(
                                            Icons.person,
                                            size: 64,
                                            color: Colors.grey.shade500,
                                          ),
                              ),
                            ),
                            if (!isUploading)
                              Positioned(
                                bottom: 0,
                                right: 0,
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
                          ],
                        ),
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
            );
        }
      }(),
    );
  }
}
