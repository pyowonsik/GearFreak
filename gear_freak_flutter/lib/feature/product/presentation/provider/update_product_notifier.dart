import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import 'package:gear_freak_flutter/common/s3/domain/usecase/delete_image_usecase.dart';
import 'package:gear_freak_flutter/common/s3/domain/usecase/upload_image_usecase.dart';
import 'package:gear_freak_flutter/feature/product/di/product_providers.dart';
import 'package:gear_freak_flutter/feature/product/domain/usecase/get_product_detail_usecase.dart';
import 'package:gear_freak_flutter/feature/product/domain/usecase/update_product_usecase.dart';
import 'package:gear_freak_flutter/feature/product/presentation/provider/update_product_state.dart';

/// 상품 수정 Notifier
class UpdateProductNotifier extends StateNotifier<UpdateProductState> {
  /// 상품 수정 Notifier 생성자
  ///
  /// [ref]는 Riverpod의 Ref 인스턴스입니다.
  /// [getProductDetailUseCase]는 상품 상세 조회 UseCase 인스턴스입니다.
  /// [uploadImageUseCase]는 이미지 업로드 UseCase 인스턴스입니다.
  /// [deleteImageUseCase]는 이미지 삭제 UseCase 인스턴스입니다.
  /// [updateProductUseCase]는 상품 수정 UseCase 인스턴스입니다.
  UpdateProductNotifier(
    this.ref,
    this.getProductDetailUseCase,
    this.uploadImageUseCase,
    this.deleteImageUseCase,
    this.updateProductUseCase,
  ) : super(const UpdateProductInitial());

  /// Riverpod Ref 인스턴스
  final Ref ref;

  /// 상품 상세 조회 UseCase
  final GetProductDetailUseCase getProductDetailUseCase;

  /// 이미지 업로드 UseCase
  final UploadImageUseCase uploadImageUseCase;

  /// 이미지 삭제 UseCase
  final DeleteImageUseCase deleteImageUseCase;

  /// 상품 수정 UseCase
  final UpdateProductUseCase updateProductUseCase;

  /// 상품 데이터 로딩
  Future<void> loadProduct(int productId) async {
    try {
      state = const UpdateProductLoading();

      final result = await getProductDetailUseCase(productId);

      result.fold(
        (failure) {
          debugPrint('❌ 상품 데이터 로딩 실패: ${failure.message}');
          state = UpdateProductLoadError(
            error: failure.message,
          );
        },
        (product) {
          debugPrint('✅ 상품 데이터 로딩 성공: ${product.id}');
          state = UpdateProductLoaded(
            product: product,
          );
        },
      );
    } catch (e) {
      debugPrint('❌ 상품 데이터 로딩 예외: $e');
      state = UpdateProductLoadError(
        error: '상품 데이터를 불러올 수 없습니다: $e',
      );
    }
  }

  /// 이미지 업로드
  Future<void> uploadImage({
    required File imageFile,
    required String prefix, // "product", "chatRoom", "profile" 등
    String bucketType = 'public',
  }) async {
    final currentState = state;
    if (currentState is! UpdateProductLoaded) {
      debugPrint('⚠️ 상품 데이터가 로딩되지 않았습니다');
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
        prefix: prefix, // product/chatRoom/profile 구분
      );

      // 4. 업로드 시작
      state = UpdateProductUploading(
        product: currentState.product,
        uploadedFileKeys: currentState.uploadedFileKeys,
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
          state = UpdateProductUploadError(
            product: currentState.product,
            uploadedFileKeys: currentState.uploadedFileKeys,
            error: errorMessage,
          );
        },
        (response) {
          debugPrint('✅ 이미지 업로드 성공: ${response.fileKey}');

          // 업로드 성공 시 fileKey 추가
          final updatedKeys = [
            ...currentState.uploadedFileKeys,
            response.fileKey,
          ];
          state = UpdateProductUploadSuccess(
            product: currentState.product,
            uploadedFileKeys: updatedKeys,
          );
        },
      );
    } catch (e) {
      debugPrint('❌ 이미지 업로드 예외: $e');

      state = UpdateProductUploadError(
        product: currentState.product,
        uploadedFileKeys: currentState.uploadedFileKeys,
        error: '이미지 업로드 중 오류가 발생했습니다: $e',
      );
    }
  }

  /// 업로드된 파일 키 제거 (S3에서도 삭제)
  Future<void> removeUploadedFileKey(String fileKey) async {
    final currentState = state;
    if (currentState is! UpdateProductLoaded) {
      debugPrint('⚠️ 상품 데이터가 로딩되지 않았습니다');
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
          debugPrint('❌ 이미지 삭제 실패: ${failure.message}');
          // S3 삭제 실패해도 로컬 상태는 제거 (사용자 경험)
          final updatedKeys = currentState.uploadedFileKeys
              .where((key) => key != fileKey)
              .toList();
          state = UpdateProductUploadError(
            product: currentState.product,
            uploadedFileKeys: updatedKeys,
            error: '이미지 삭제 중 오류가 발생했습니다: ${failure.message}',
          );
        },
        (_) {
          // 상태에서도 제거
          final updatedKeys = currentState.uploadedFileKeys
              .where((key) => key != fileKey)
              .toList();
          state = UpdateProductUploadSuccess(
            product: currentState.product,
            uploadedFileKeys: updatedKeys,
          );
          debugPrint('✅ 이미지 제거 성공: $fileKey');
        },
      );
    } catch (e) {
      debugPrint('❌ 이미지 제거 예외: $e');
      // 예외 발생 시에도 로컬 상태는 제거
      final updatedKeys =
          currentState.uploadedFileKeys.where((key) => key != fileKey).toList();
      state = UpdateProductUploadError(
        product: currentState.product,
        uploadedFileKeys: updatedKeys,
        error: '이미지 삭제 중 오류가 발생했습니다: $e',
      );
    }
  }

  /// 상품 수정
  Future<void> updateProduct({
    required int productId,
    required String title,
    required pod.ProductCategory category,
    required int price,
    required pod.ProductCondition condition,
    required String description,
    required pod.TradeMethod tradeMethod,
    required List<String> existingImageUrls,
    String? baseAddress,
    String? detailAddress,
  }) async {
    final currentState = state;
    if (currentState is! UpdateProductLoaded) {
      debugPrint('⚠️ 상품 데이터가 로딩되지 않았습니다');
      return;
    }

    try {
      // 업로드된 이미지 URL 목록 생성
      final uploadedImageUrls = currentState.uploadedFileKeys
          .map(
            (key) =>
                'https://gear-freak-public-storage-3059875.s3.ap-northeast-2.amazonaws.com/$key',
          )
          .toList();

      // 최종 이미지 URL 목록 (기존 이미지 + 새로 업로드한 이미지)
      final finalImageUrls = [...existingImageUrls, ...uploadedImageUrls];

      // UpdateProductRequestDto 생성
      final request = pod.UpdateProductRequestDto(
        productId: productId,
        title: title,
        category: category,
        price: price,
        condition: condition,
        description: description,
        tradeMethod: tradeMethod,
        baseAddress: baseAddress,
        detailAddress: detailAddress,
        imageUrls: finalImageUrls.isEmpty ? null : finalImageUrls,
      );

      // 수정 시작
      state = UpdateProductUpdating(
        product: currentState.product,
        uploadedFileKeys: currentState.uploadedFileKeys,
      );

      // UseCase 호출
      final result = await updateProductUseCase(request);

      result.fold(
        (failure) {
          debugPrint('❌ 상품 수정 실패: ${failure.message}');
          if (failure.exception != null) {
            debugPrint('❌ 상세: ${failure.exception}');
          }

          final errorMessage = failure.exception != null
              ? '${failure.message}\n상세: ${failure.exception}'
              : failure.message;
          state = UpdateProductUpdateError(
            product: currentState.product,
            uploadedFileKeys: currentState.uploadedFileKeys,
            error: errorMessage,
          );
        },
        (product) {
          debugPrint('✅ 상품 수정 성공: ${product.id}');
          state = UpdateProductUpdated(
            product: product,
            uploadedFileKeys: const [],
          );

          // 수정 성공 시 이벤트 발행 (모든 목록 Provider가 자동으로 반응)
          ref.read(updatedProductProvider.notifier).state = product;
          // 이벤트 처리 후 초기화 (다음 수정을 위해)
          Future.microtask(() {
            ref.read(updatedProductProvider.notifier).state = null;
          });
        },
      );
    } catch (e) {
      debugPrint('❌ 상품 수정 예외: $e');

      state = UpdateProductUpdateError(
        product: currentState.product,
        uploadedFileKeys: currentState.uploadedFileKeys,
        error: '상품 수정 중 오류가 발생했습니다: $e',
      );
    }
  }
}
