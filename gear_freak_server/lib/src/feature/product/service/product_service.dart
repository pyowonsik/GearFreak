import 'package:serverpod/serverpod.dart';

import 'package:gear_freak_server/src/generated/protocol.dart';

import 'package:gear_freak_server/src/common/s3/service/s3_service.dart';
import 'package:gear_freak_server/src/common/s3/util/s3_util.dart';

/// 상품 서비스
/// 상품 기본 CRUD 및 상태 관리 관련 비즈니스 로직을 처리합니다.
class ProductService {
  // ==================== Public Methods ====================

  /// 상품 생성
  ///
  /// 새로운 상품을 생성하고 임시 이미지를 정식 경로로 이동합니다.
  ///
  /// [session]: Serverpod 세션
  /// [sellerId]: 판매자 ID
  /// [request]: 상품 생성 요청 DTO
  /// Returns: 생성된 상품
  Future<Product> createProduct(
    Session session,
    int sellerId,
    CreateProductRequestDto request,
  ) async {
    final now = DateTime.now().toUtc();

    // 1. 상품 먼저 생성하여 productId 획득
    final product = Product(
      sellerId: sellerId,
      title: request.title,
      category: request.category,
      price: request.price,
      condition: request.condition,
      description: request.description,
      tradeMethod: request.tradeMethod,
      baseAddress: request.baseAddress,
      detailAddress: request.detailAddress,
      imageUrls: request.imageUrls, // 임시로 원본 URL 저장
      status: ProductStatus.selling, // 기본값: 판매중
      viewCount: 0,
      favoriteCount: 0,
      chatCount: 0,
      createdAt: now,
      updatedAt: now,
    );

    final createdProduct = await Product.db.insertRow(session, product);
    final productId = createdProduct.id!;

    // 2. 이미지 파일들을 temp에서 실제 경로로 이동
    if (request.imageUrls != null && request.imageUrls!.isNotEmpty) {
      final movedImageUrls = <String>[];

      for (final imageUrl in request.imageUrls!) {
        try {
          // URL에서 파일 키 추출
          final sourceKey = S3Util.extractKeyFromUrl(imageUrl);

          // temp 경로인지 확인
          if (sourceKey.startsWith('temp/product/')) {
            // temp/product/{userId}/{file} -> product/{productId}/{file}
            final destinationKey =
                S3Util.convertTempKeyToProductKey(sourceKey, productId);

            // S3에서 파일 이동
            final movedUrl = await S3Service.moveS3Object(
              session,
              sourceKey,
              destinationKey,
              'public', // 상품 이미지는 public 버킷
            );

            movedImageUrls.add(movedUrl);
          } else {
            // 이미 이동된 파일이거나 다른 경로면 그대로 사용
            movedImageUrls.add(imageUrl);
          }
        } catch (e) {
          session.log(
            'Failed to move image: $imageUrl - $e',
            level: LogLevel.warning,
          );
          // 이동 실패 시 원본 URL 유지
          movedImageUrls.add(imageUrl);
        }
      }

      // 3. 이동된 URL로 상품 업데이트
      if (movedImageUrls.isNotEmpty) {
        await Product.db.updateRow(
          session,
          createdProduct.copyWith(imageUrls: movedImageUrls),
          columns: (t) => [t.imageUrls],
        );
      }

      // 이동된 URL로 반환
      return createdProduct.copyWith(imageUrls: movedImageUrls);
    }

    return createdProduct;
  }

  /// 상품 수정
  ///
  /// 상품 정보를 수정하고 이미지 변경 사항을 S3에 반영합니다.
  /// 삭제된 이미지는 S3에서 제거하고, 새 이미지는 정식 경로로 이동합니다.
  ///
  /// [session]: Serverpod 세션
  /// [productId]: 수정할 상품 ID
  /// [sellerId]: 요청자 ID (권한 확인용)
  /// [request]: 상품 수정 요청 DTO
  /// Returns: 수정된 상품
  /// Throws: Exception - 상품을 찾을 수 없거나 권한이 없는 경우
  Future<Product> updateProduct(
    Session session,
    int productId,
    int sellerId,
    UpdateProductRequestDto request,
  ) async {
    // 1. 기존 상품 조회
    final existingProduct = await Product.db.findById(session, productId);
    if (existingProduct == null) {
      throw Exception('Product not found');
    }

    // 2. 권한 확인 (판매자만 수정 가능)
    if (existingProduct.sellerId != sellerId) {
      throw Exception('Unauthorized: Only the seller can update this product');
    }

    final now = DateTime.now().toUtc();
    final originalImageUrls = existingProduct.imageUrls ?? [];
    final finalImageUrls = request.imageUrls ?? [];

    // 3. 삭제할 이미지 식별 (원본에 있지만 최종 목록에 없는 것)
    final imagesToDelete = originalImageUrls
        .where((url) => !finalImageUrls.contains(url))
        .toList();

    // 4. 삭제할 이미지들을 S3에서 삭제
    for (final imageUrl in imagesToDelete) {
      try {
        final fileKey = S3Util.extractKeyFromUrl(imageUrl);
        // product 경로의 이미지만 삭제 (temp 경로는 나중에 이동 처리)
        if (fileKey.startsWith('product/')) {
          await S3Service.deleteS3Object(session, fileKey, 'public');
          session.log('Deleted image: $fileKey', level: LogLevel.info);
        }
      } catch (e) {
        session.log(
          'Failed to delete image: $imageUrl - $e',
          level: LogLevel.warning,
        );
        // 삭제 실패해도 계속 진행
      }
    }

    // 5. 새로 추가한 이미지 (temp 경로)를 product 경로로 이동
    final movedImageUrls = <String>[];
    for (final imageUrl in finalImageUrls) {
      try {
        final sourceKey = S3Util.extractKeyFromUrl(imageUrl);

        if (sourceKey.startsWith('temp/product/')) {
          // temp/product/{userId}/{file} -> product/{productId}/{file}
          final destinationKey =
              S3Util.convertTempKeyToProductKey(sourceKey, productId);

          // S3에서 파일 이동
          final movedUrl = await S3Service.moveS3Object(
            session,
            sourceKey,
            destinationKey,
            'public',
          );

          movedImageUrls.add(movedUrl);
        } else {
          // 이미 product 경로에 있거나 다른 경로면 그대로 사용
          movedImageUrls.add(imageUrl);
        }
      } catch (e) {
        session.log(
          'Failed to move image: $imageUrl - $e',
          level: LogLevel.warning,
        );
        // 이동 실패 시 원본 URL 유지
        movedImageUrls.add(imageUrl);
      }
    }

    // 6. 상품 정보 업데이트
    final updatedProduct = existingProduct.copyWith(
      title: request.title,
      category: request.category,
      price: request.price,
      condition: request.condition,
      description: request.description,
      tradeMethod: request.tradeMethod,
      baseAddress: request.baseAddress,
      detailAddress: request.detailAddress,
      imageUrls: movedImageUrls.isEmpty ? null : movedImageUrls,
      updatedAt: now,
    );

    final result = await Product.db.updateRow(
      session,
      updatedProduct,
      columns: (t) => [
        t.title,
        t.category,
        t.price,
        t.condition,
        t.description,
        t.tradeMethod,
        t.baseAddress,
        t.detailAddress,
        t.imageUrls,
        t.updatedAt,
      ],
    );

    return result;
  }

  /// 상품 조회
  ///
  /// ID로 상품을 조회합니다.
  ///
  /// [session]: Serverpod 세션
  /// [id]: 조회할 상품 ID
  /// Returns: 상품 정보
  /// Throws: Exception - 상품을 찾을 수 없는 경우
  Future<Product> getProductById(Session session, int id) async {
    final product = await Product.db.findById(session, id);

    if (product == null) {
      throw Exception('Product not found');
    }

    return product;
  }

  /// 상품 상태 변경
  ///
  /// 상품의 판매 상태를 변경합니다 (판매중, 예약중, 거래완료).
  ///
  /// [session]: Serverpod 세션
  /// [productId]: 상품 ID
  /// [userId]: 요청자 ID (권한 확인용)
  /// [status]: 변경할 상태
  /// Returns: 수정된 상품
  /// Throws: Exception - 상품을 찾을 수 없거나 권한이 없는 경우
  Future<Product> updateProductStatus(
    Session session,
    int productId,
    int userId,
    ProductStatus status,
  ) async {
    // 1. 기존 상품 조회
    final product = await Product.db.findById(session, productId);
    if (product == null) {
      throw Exception('Product not found');
    }

    // 2. 권한 확인 (판매자만 상태 변경 가능)
    if (product.sellerId != userId) {
      throw Exception(
        'Unauthorized: Only the seller can update product status',
      );
    }

    // 3. 상태 업데이트
    final now = DateTime.now().toUtc();
    final updatedProduct = product.copyWith(
      status: status,
      updatedAt: now,
    );

    final result = await Product.db.updateRow(
      session,
      updatedProduct,
      columns: (t) => [
        t.status,
        t.updatedAt,
      ],
    );

    return result;
  }

  /// 상품 상단으로 올리기 (updatedAt 갱신)
  ///
  /// 상품의 updatedAt을 현재 시간으로 갱신하여 최신순 정렬에서 상단으로 올립니다.
  ///
  /// [session]: Serverpod 세션
  /// [productId]: 상품 ID
  /// [userId]: 요청자 ID (권한 확인용)
  /// Returns: 수정된 상품
  /// Throws: Exception - 상품을 찾을 수 없거나 권한이 없는 경우
  Future<Product> bumpProduct(
    Session session,
    int productId,
    int userId,
  ) async {
    // 1. 기존 상품 조회
    final product = await Product.db.findById(session, productId);
    if (product == null) {
      throw Exception('Product not found');
    }

    // 2. 권한 확인 (판매자만 상단으로 올리기 가능)
    if (product.sellerId != userId) {
      throw Exception('Unauthorized: Only the seller can bump this product');
    }

    // 3. updatedAt을 현재 시간으로 갱신
    final now = DateTime.now().toUtc();
    final updatedProduct = product.copyWith(updatedAt: now);

    await Product.db.updateRow(
      session,
      updatedProduct,
      columns: (t) => [t.updatedAt],
    );

    return updatedProduct;
  }

  /// 상품 삭제
  ///
  /// 상품과 관련된 모든 데이터를 삭제합니다.
  /// S3 이미지, 찜 데이터, 조회 기록도 함께 삭제됩니다.
  ///
  /// [session]: Serverpod 세션
  /// [productId]: 삭제할 상품 ID
  /// [userId]: 요청자 ID (권한 확인용)
  /// Throws: Exception - 상품을 찾을 수 없거나 권한이 없는 경우
  Future<void> deleteProduct(
    Session session,
    int productId,
    int userId,
  ) async {
    // 1. 기존 상품 조회
    final product = await Product.db.findById(session, productId);
    if (product == null) {
      throw Exception('Product not found');
    }

    // 2. 권한 확인 (판매자만 삭제 가능)
    if (product.sellerId != userId) {
      throw Exception('Unauthorized: Only the seller can delete this product');
    }

    // 3. 상품 이미지들을 S3에서 삭제
    if (product.imageUrls != null && product.imageUrls!.isNotEmpty) {
      for (final imageUrl in product.imageUrls!) {
        try {
          final fileKey = S3Util.extractKeyFromUrl(imageUrl);
          // product 경로의 이미지만 삭제
          if (fileKey.startsWith('product/')) {
            await S3Service.deleteS3Object(session, fileKey, 'public');
            session.log('Deleted image: $fileKey', level: LogLevel.info);
          }
        } catch (e) {
          session.log(
            'Failed to delete image: $imageUrl - $e',
            level: LogLevel.warning,
          );
          // 삭제 실패해도 계속 진행
        }
      }
    }

    // 4. 관련된 찜 데이터 삭제
    final favorites = await Favorite.db.find(
      session,
      where: (f) => f.productId.equals(productId),
    );

    for (final favorite in favorites) {
      await Favorite.db.deleteRow(session, favorite);
    }

    // 4-1. 관련된 조회 데이터 삭제
    final productViews = await ProductView.db.find(
      session,
      where: (v) => v.productId.equals(productId),
    );

    for (final productView in productViews) {
      await ProductView.db.deleteRow(session, productView);
    }

    // 5. 상품 삭제
    await Product.db.deleteRow(session, product);
  }
}
