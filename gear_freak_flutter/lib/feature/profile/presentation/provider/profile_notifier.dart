import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import 'package:gear_freak_flutter/common/s3/domain/usecase/delete_image_usecase.dart';
import 'package:gear_freak_flutter/common/s3/domain/usecase/upload_image_usecase.dart';
import 'package:gear_freak_flutter/feature/auth/domain/usecase/get_me_usecase.dart';
import 'package:gear_freak_flutter/feature/product/di/product_providers.dart';
import 'package:gear_freak_flutter/feature/product/domain/usecase/get_product_stats_usecase.dart';
import 'package:gear_freak_flutter/feature/profile/domain/usecase/get_user_by_id_usecase.dart';
import 'package:gear_freak_flutter/feature/profile/domain/usecase/update_user_profile_usecase.dart';
import 'package:gear_freak_flutter/feature/profile/presentation/provider/profile_state.dart';

/// 프로필 Notifier
class ProfileNotifier extends StateNotifier<ProfileState> {
  /// ProfileNotifier 생성자
  ///
  /// [ref]는 Riverpod의 Ref 인스턴스입니다.
  /// [getMeUseCase]는 현재 사용자 정보 조회 UseCase 인스턴스입니다.
  /// [getUserByIdUseCase]는 사용자 ID로 사용자 정보 조회 UseCase 인스턴스입니다.
  /// [uploadImageUseCase]는 이미지 업로드 UseCase 인스턴스입니다.
  /// [deleteImageUseCase]는 이미지 삭제 UseCase 인스턴스입니다.
  /// [updateUserProfileUseCase]는 사용자 프로필 수정 UseCase 인스턴스입니다.
  /// [getProductStatsUseCase]는 상품 통계 조회 UseCase 인스턴스입니다.
  ProfileNotifier(
    this.ref,
    this.getMeUseCase,
    this.getUserByIdUseCase,
    this.uploadImageUseCase,
    this.deleteImageUseCase,
    this.updateUserProfileUseCase,
    this.getProductStatsUseCase,
  ) : super(const ProfileInitial()) {
    // 상품 삭제/수정 이벤트 감지하여 stats 자동 갱신
    ref
      ..listen<int?>(deletedProductIdProvider, (previous, next) {
        if (next != null) {
          _refreshStats();
        }
      })
      ..listen<pod.Product?>(updatedProductProvider, (previous, next) {
        if (next != null) {
          _refreshStats();
        }
      });
  }

  /// Riverpod Ref 인스턴스
  final Ref ref;

  /// 현재 사용자 정보 조회 UseCase 인스턴스
  final GetMeUseCase getMeUseCase;

  /// 사용자 ID로 사용자 정보 조회 UseCase 인스턴스
  final GetUserByIdUseCase getUserByIdUseCase;

  /// 이미지 업로드 UseCase
  final UploadImageUseCase uploadImageUseCase;

  /// 이미지 삭제 UseCase
  final DeleteImageUseCase deleteImageUseCase;

  /// 사용자 프로필 수정 UseCase
  final UpdateUserProfileUseCase updateUserProfileUseCase;

  /// 상품 통계 조회 UseCase
  final GetProductStatsUseCase getProductStatsUseCase;

  // ==================== Public Methods (UseCase 호출) ====================

  /// 프로필 로드
  Future<void> loadProfile() async {
    state = const ProfileLoading();

    final result = await getMeUseCase(null);

    await result.fold(
      (failure) {
        state = ProfileError(failure.message);
      },
      (user) async {
        if (user != null) {
          // 사용자 정보와 통계를 동시에 로드
          final statsResult = await getProductStatsUseCase(null);
          final stats = statsResult.fold(
            (failure) => null,
            (stats) => stats,
          );

          state = ProfileLoaded(
            user: user,
            stats: stats,
          );
        } else {
          state = const ProfileError(
            '사용자 정보를 불러올 수 없습니다. 로그인 상태를 확인해주세요.',
          );
        }
      },
    );
  }

  /// 프로필 이미지 업로드
  Future<void> uploadProfileImage({
    required File imageFile,
    required String prefix, // "product", "chatRoom", "profile" 등
    String bucketType = 'public',
  }) async {
    final currentState = state;
    if (currentState is! ProfileLoaded) {
      return;
    }

    // 기존에 업로드된 파일 키 저장 (업로드 실패 시 복원용)
    final previousUploadedFileKey = currentState.uploadedFileKey;

    try {
      // 1. 기존에 업로드된 파일이 있으면 먼저 삭제 (S3 정리)
      if (previousUploadedFileKey != null) {
        try {
          await deleteImageUseCase(
            DeleteImageParams(
              fileKey: previousUploadedFileKey,
              bucketType: bucketType,
            ),
          );
        } catch (e) {
          // 삭제 실패해도 계속 진행 (로깅만)
          debugPrint(
            '⚠️ 기존 업로드 파일 S3 삭제 실패 (계속 진행): $previousUploadedFileKey - $e',
          );
        }
      }

      // 2. 파일 정보 가져오기
      final fileName = imageFile.path.split('/').last;
      final fileBytes = await imageFile.readAsBytes();
      final fileSize = fileBytes.length;

      // 3. Content-Type 결정
      var contentType = 'image/jpeg';
      if (fileName.toLowerCase().endsWith('.png')) {
        contentType = 'image/png';
      } else if (fileName.toLowerCase().endsWith('.webp')) {
        contentType = 'image/webp';
      }

      // 4. Presigned URL 요청 DTO 생성
      final request = pod.GeneratePresignedUploadUrlRequestDto(
        fileName: fileName,
        contentType: contentType,
        fileSize: fileSize,
        bucketType: bucketType,
        prefix: prefix,
      );

      // 5. 업로드 시작
      state = ProfileImageUploading(
        user: currentState.user,
        stats: currentState.stats,
        currentFileName: fileName,
      );

      // 6. UseCase 호출
      final result = await uploadImageUseCase(
        UploadImageParams(
          request: request,
          fileBytes: fileBytes,
        ),
      );

      result.fold(
        (failure) {
          // 업로드 실패 시 이전 상태로 복원 불가 (이미 삭제됨)
          state = ProfileImageUploadError(
            user: currentState.user,
            stats: currentState.stats,
            error: failure.message,
          );
        },
        (response) {
          state = ProfileImageUploadSuccess(
            user: currentState.user,
            uploadedFileKey: response.fileKey,
            stats: currentState.stats,
          );
        },
      );
    } catch (e) {
      // 예외 발생 시에도 이전 상태로 복원 불가 (이미 삭제됨)
      state = ProfileImageUploadError(
        user: currentState.user,
        stats: currentState.stats,
        error: '이미지 업로드 중 오류가 발생했습니다: $e',
      );
    }
  }

  /// 업로드된 파일 키 제거 (S3에서도 삭제)
  Future<void> removeUploadedFileKey(String fileKey) async {
    final currentState = state;
    if (currentState is! ProfileLoaded) {
      return;
    }

    try {
      // S3에서 파일 삭제
      final result = await deleteImageUseCase(
        DeleteImageParams(
          fileKey: fileKey,
          bucketType: 'public',
        ),
      );

      result.fold(
        (failure) {
          // S3 삭제 실패해도 로컬 상태는 제거 (사용자 경험)
          final updatedKeys = currentState.uploadedFileKey == fileKey
              ? null
              : currentState.uploadedFileKey;
          state = ProfileImageUploadError(
            user: currentState.user,
            uploadedFileKey: updatedKeys,
            stats: currentState.stats,
            error: '이미지 삭제 중 오류가 발생했습니다: ${failure.message}',
          );
        },
        (_) {
          // 상태에서도 제거
          final updatedKeys = currentState.uploadedFileKey == fileKey
              ? null
              : currentState.uploadedFileKey;
          state = currentState.copyWith(uploadedFileKey: updatedKeys);
        },
      );
    } catch (e) {
      // 예외 발생 시에도 로컬 상태는 제거
      final updatedKeys = currentState.uploadedFileKey == fileKey
          ? null
          : currentState.uploadedFileKey;
      state = ProfileImageUploadError(
        user: currentState.user,
        uploadedFileKey: updatedKeys,
        stats: currentState.stats,
        error: '이미지 삭제 중 오류가 발생했습니다: $e',
      );
    }
  }

  /// 프로필 업데이트
  Future<void> updateProfile({
    required String nickname,
    bool removedExistingImage = false,
  }) async {
    final currentState = state;
    if (currentState is! ProfileLoaded) {
      return;
    }

    try {
      // 기존 이미지 URL에서 파일 키 추출 (S3 삭제용)
      String? existingImageFileKey;
      final s3BaseUrl = dotenv.env['S3_PUBLIC_BASE_URL']!;

      // 기존 이미지가 있고, 다음 중 하나의 경우에 삭제:
      // 1. removedExistingImage = true (사용자가 명시적으로 삭제)
      // 2. uploadedFileKey가 있고 기존 이미지가 있음 (새 이미지로 교체)
      if (currentState.user.profileImageUrl != null &&
          currentState.user.profileImageUrl!.isNotEmpty) {
        final shouldDeleteExistingImage = removedExistingImage ||
            (currentState.uploadedFileKey != null); // 새 이미지로 교체되는 경우

        if (shouldDeleteExistingImage) {
          final existingImageUrl = currentState.user.profileImageUrl!;
          if (existingImageUrl.startsWith(s3BaseUrl)) {
            // URL에서 파일 키 추출: https://bucket.s3.region.amazonaws.com/path/to/file.jpg -> path/to/file.jpg
            existingImageFileKey = existingImageUrl.substring(s3BaseUrl.length);
            if (existingImageFileKey.startsWith('/')) {
              existingImageFileKey = existingImageFileKey.substring(1);
            }
          }
        }
      }

      // 업로드된 이미지 URL 생성
      String? profileImageUrl;
      if (removedExistingImage) {
        // 기존 이미지가 제거된 경우 null
        profileImageUrl = null;
      } else if (currentState.uploadedFileKey != null) {
        // 새로 업로드된 이미지가 있으면 사용
        profileImageUrl = '$s3BaseUrl/${currentState.uploadedFileKey}';
      } else if (currentState.user.profileImageUrl != null &&
          currentState.user.profileImageUrl!.isNotEmpty) {
        // 기존 프로필 이미지가 있으면 유지
        profileImageUrl = currentState.user.profileImageUrl;
      }

      // UpdateUserProfileRequestDto 생성
      final request = pod.UpdateUserProfileRequestDto(
        nickname: nickname,
        profileImageUrl: profileImageUrl,
      );

      // 업데이트 시작
      state = ProfileUpdating(
        user: currentState.user,
        uploadedFileKey: currentState.uploadedFileKey,
        stats: currentState.stats,
      );

      // UseCase 호출
      final result = await updateUserProfileUseCase(request);

      await result.fold(
        (failure) {
          state = ProfileUpdateError(
            user: currentState.user,
            uploadedFileKey: currentState.uploadedFileKey,
            stats: currentState.stats,
            error: failure.message,
          );
        },
        (updatedUser) async {
          // 프로필 업데이트 성공 후, 기존 이미지가 제거되거나 교체된 경우 S3에서도 삭제
          if (existingImageFileKey != null) {
            try {
              debugPrint('🗑️ 기존 프로필 이미지 S3 삭제 시작: $existingImageFileKey');
              await deleteImageUseCase(
                DeleteImageParams(
                  fileKey: existingImageFileKey,
                  bucketType: 'public',
                ),
              );
              debugPrint('✅ 기존 프로필 이미지 S3 삭제 성공: $existingImageFileKey');
            } catch (e) {
              // S3 삭제 실패해도 프로필 업데이트는 성공했으므로 계속 진행
              debugPrint('❌ 기존 프로필 이미지 S3 삭제 실패: $e');
            }
          }

          state = ProfileUpdated(
            user: updatedUser,
            stats: currentState.stats,
          );
        },
      );
    } catch (e) {
      state = ProfileUpdateError(
        user: currentState.user,
        uploadedFileKey: currentState.uploadedFileKey,
        stats: currentState.stats,
        error: '프로필 업데이트 중 오류가 발생했습니다: $e',
      );
    }
  }

  /// 사용자 ID로 사용자 정보 조회
  Future<pod.User?> getUserById(int id) async {
    final result = await getUserByIdUseCase(id);
    return result.fold(
      (failure) {
        // 에러 발생 시 null 반환
        return null;
      },
      (user) => user,
    );
  }

  // ==================== Public Methods (Service 호출) ====================

  // ==================== Private Helper Methods ====================

  /// Stats만 새로고침 (상품 삭제/수정 시 호출)
  Future<void> _refreshStats() async {
    final currentState = state;
    if (currentState is! ProfileLoaded) {
      return;
    }

    // Stats만 다시 로드
    final statsResult = await getProductStatsUseCase(null);
    final stats = statsResult.fold(
      (failure) {
        debugPrint('Stats 갱신 실패: ${failure.message}');
        return currentState.stats; // 실패 시 기존 stats 유지
      },
      (newStats) => newStats,
    );

    // Stats만 업데이트
    state = currentState.copyWith(stats: stats);
  }
}
