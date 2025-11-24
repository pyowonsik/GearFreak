import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import 'package:gear_freak_flutter/common/s3/domain/usecase/upload_image_usecase.dart';
import 'package:gear_freak_flutter/feature/product/presentation/provider/create_product_state.dart';

/// 상품 등록 Notifier
class CreateProductNotifier extends StateNotifier<CreateProductState> {
  /// 상품 등록 Notifier 생성자
  ///
  /// [uploadImageUseCase]는 이미지 업로드 UseCase 인스턴스입니다.
  CreateProductNotifier(this.uploadImageUseCase)
      : super(const CreateProductInitial());

  /// 이미지 업로드 UseCase
  final UploadImageUseCase uploadImageUseCase;

  /// 이미지 업로드
  Future<void> uploadImage({
    required File imageFile,
    required String prefix, // "product", "chatRoom", "profile" 등
    String bucketType = 'public',
  }) async {
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
        prefix: prefix, // product/chatRoom/profile 구분
      );

      // 4. 업로드 시작
      state = CreateProductUploading(
        uploadedFileKeys: state.uploadedFileKeys,
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
          debugPrint('❌ 이미지 업로드 실패: ${failure.message}');
          if (failure.exception != null) {
            debugPrint('❌ 상세: ${failure.exception}');
          }

          final errorMessage = failure.exception != null
              ? '${failure.message}\n상세: ${failure.exception}'
              : failure.message;
          state = CreateProductUploadError(
            uploadedFileKeys: state.uploadedFileKeys,
            error: errorMessage,
          );
        },
        (response) {
          debugPrint('✅ 이미지 업로드 성공: ${response.fileKey}');

          // 업로드 성공 시 fileKey 추가
          final updatedKeys = [...state.uploadedFileKeys, response.fileKey];
          state = CreateProductUploadSuccess(
            uploadedFileKeys: updatedKeys,
          );
        },
      );
    } catch (e) {
      debugPrint('❌ 이미지 업로드 예외: $e');

      state = CreateProductUploadError(
        uploadedFileKeys: state.uploadedFileKeys,
        error: '이미지 업로드 중 오류가 발생했습니다: $e',
      );
    }
  }

  /// 업로드된 파일 키 제거
  void removeUploadedFileKey(String fileKey) {
    final updatedKeys =
        state.uploadedFileKeys.where((key) => key != fileKey).toList();
    state = CreateProductUploadSuccess(
      uploadedFileKeys: updatedKeys,
    );
  }

  /// 상태 초기화
  void reset() {
    state = const CreateProductInitial();
  }
}
