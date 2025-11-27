import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import 'package:gear_freak_flutter/common/s3/domain/usecase/delete_image_usecase.dart';
import 'package:gear_freak_flutter/common/s3/domain/usecase/upload_image_usecase.dart';
import 'package:gear_freak_flutter/feature/product/domain/usecase/create_product_usecase.dart';
import 'package:gear_freak_flutter/feature/product/presentation/provider/create_product_state.dart';

/// 상품 등록 Notifier
class CreateProductNotifier extends StateNotifier<CreateProductState> {
  /// 상품 등록 Notifier 생성자
  ///
  /// [uploadImageUseCase]는 이미지 업로드 UseCase 인스턴스입니다.
  /// [deleteImageUseCase]는 이미지 삭제 UseCase 인스턴스입니다.
  /// [createProductUseCase]는 상품 생성 UseCase 인스턴스입니다.
  CreateProductNotifier(
    this.uploadImageUseCase,
    this.deleteImageUseCase,
    this.createProductUseCase,
  ) : super(const CreateProductInitial());

  /// 이미지 업로드 UseCase
  final UploadImageUseCase uploadImageUseCase;

  /// 이미지 삭제 UseCase
  final DeleteImageUseCase deleteImageUseCase;

  /// 상품 생성 UseCase
  final CreateProductUseCase createProductUseCase;

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

  /// 업로드된 파일 키 제거 (S3에서도 삭제)
  Future<void> removeUploadedFileKey(String fileKey) async {
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
          debugPrint('❌ 이미지 삭제 실패: ${failure.message}');
          // S3 삭제 실패해도 로컬 상태는 제거 (사용자 경험)
          final updatedKeys =
              state.uploadedFileKeys.where((key) => key != fileKey).toList();
          state = CreateProductUploadError(
            uploadedFileKeys: updatedKeys,
            error: '이미지 삭제 중 오류가 발생했습니다: ${failure.message}',
          );
        },
        (_) {
          // 상태에서도 제거
          final updatedKeys =
              state.uploadedFileKeys.where((key) => key != fileKey).toList();
          state = CreateProductUploadSuccess(
            uploadedFileKeys: updatedKeys,
          );
          debugPrint('✅ 이미지 제거 성공: $fileKey');
        },
      );
    } catch (e) {
      debugPrint('❌ 이미지 제거 예외: $e');
      // 예외 발생 시에도 로컬 상태는 제거
      final updatedKeys =
          state.uploadedFileKeys.where((key) => key != fileKey).toList();
      state = CreateProductUploadError(
        uploadedFileKeys: updatedKeys,
        error: '이미지 삭제 중 오류가 발생했습니다: $e',
      );
    }
  }

  /// 상품 생성
  Future<void> createProduct({
    required String title,
    required pod.ProductCategory category,
    required int price,
    required pod.ProductCondition condition,
    required String description,
    required pod.TradeMethod tradeMethod,
    String? baseAddress,
    String? detailAddress,
  }) async {
    try {
      // 업로드된 이미지 URL 목록 생성
      final imageUrls = state.uploadedFileKeys
          .map(
            (key) =>
                'https://gear-freak-public-storage-3059875.s3.ap-northeast-2.amazonaws.com/$key',
          )
          .toList();

      // CreateProductRequestDto 생성
      final request = pod.CreateProductRequestDto(
        title: title,
        category: category,
        price: price,
        condition: condition,
        description: description,
        tradeMethod: tradeMethod,
        baseAddress: baseAddress,
        detailAddress: detailAddress,
        imageUrls: imageUrls.isEmpty ? null : imageUrls,
      );

      // 생성 시작
      state = CreateProductCreating(
        uploadedFileKeys: state.uploadedFileKeys,
      );

      // UseCase 호출
      final result = await createProductUseCase(request);

      result.fold(
        (failure) {
          debugPrint('❌ 상품 생성 실패: ${failure.message}');
          if (failure.exception != null) {
            debugPrint('❌ 상세: ${failure.exception}');
          }

          final errorMessage = failure.exception != null
              ? '${failure.message}\n상세: ${failure.exception}'
              : failure.message;
          state = CreateProductCreateError(
            uploadedFileKeys: state.uploadedFileKeys,
            error: errorMessage,
          );
        },
        (product) {
          debugPrint('✅ 상품 생성 성공: ${product.id}');
          state = CreateProductCreated(
            uploadedFileKeys: state.uploadedFileKeys,
          );
        },
      );
    } catch (e) {
      debugPrint('❌ 상품 생성 예외: $e');

      state = CreateProductCreateError(
        uploadedFileKeys: state.uploadedFileKeys,
        error: '상품 생성 중 오류가 발생했습니다: $e',
      );
    }
  }

  /// 상태 초기화
  void reset() {
    state = const CreateProductInitial();
  }
}
