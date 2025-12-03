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

    try {
      // 1. 파일 정보 가져오기
      final fileName = imageFile.path.split('/').last;
      final fileBytes = await imageFile.readAsBytes();
      final fileSize = fileBytes.length;

      // 2. Content-Type 결정
      var contentType = 'image/jpeg';
      if (fileName.toLowerCase().endsWith('.png')) {
        contentType = 'image/png';
      } else if (fileName.toLowerCase().endsWith('.webp')) {
        contentType = 'image/webp';
      }

      // 3. Presigned URL 요청 DTO 생성
      final request = pod.GeneratePresignedUploadUrlRequestDto(
        fileName: fileName,
        contentType: contentType,
        fileSize: fileSize,
        bucketType: bucketType,
        prefix: prefix,
      );

      // 4. 업로드 시작
      state = ProfileImageUploading(
        user: currentState.user,
        uploadedFileKey: currentState.uploadedFileKey,
        stats: currentState.stats,
        currentFileName: fileName,
      );

      // 5. UseCase 호출
      final result = await uploadImageUseCase(
        UploadImageParams(
          request: request,
          fileBytes: fileBytes,
        ),
      );

      result.fold(
        (failure) {
          state = ProfileImageUploadError(
            user: currentState.user,
            uploadedFileKey: currentState.uploadedFileKey,
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
      state = ProfileImageUploadError(
        user: currentState.user,
        uploadedFileKey: currentState.uploadedFileKey,
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
          state = ProfileLoaded(
            user: currentState.user,
            uploadedFileKey: updatedKeys,
            stats: currentState.stats,
          );
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
      // 업로드된 이미지 URL 생성
      String? profileImageUrl;
      if (removedExistingImage) {
        // 기존 이미지가 제거된 경우 null
        profileImageUrl = null;
      } else if (currentState.uploadedFileKey != null) {
        // 새로 업로드된 이미지가 있으면 사용
        final s3BaseUrl = dotenv.env['S3_PUBLIC_BASE_URL']!;
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

      result.fold(
        (failure) {
          state = ProfileUpdateError(
            user: currentState.user,
            uploadedFileKey: currentState.uploadedFileKey,
            stats: currentState.stats,
            error: failure.message,
          );
        },
        (updatedUser) {
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
