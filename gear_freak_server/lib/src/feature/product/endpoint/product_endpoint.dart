import 'package:serverpod/serverpod.dart';

import 'package:gear_freak_server/src/generated/protocol.dart';

import 'package:gear_freak_server/src/common/authenticated_mixin.dart';

import 'package:gear_freak_server/src/feature/product/service/product_interaction_service.dart';
import 'package:gear_freak_server/src/feature/product/service/product_list_service.dart';
import 'package:gear_freak_server/src/feature/product/service/product_report_service.dart';
import 'package:gear_freak_server/src/feature/product/service/product_service.dart';
import 'package:gear_freak_server/src/feature/user/service/user_service.dart';

/// 상품 엔드포인트
class ProductEndpoint extends Endpoint with AuthenticatedMixin {
  final ProductService productService = ProductService();
  final ProductListService productListService = ProductListService();
  final ProductInteractionService productInteractionService =
      ProductInteractionService();
  final ProductReportService productReportService = ProductReportService();

  // ==================== Public Methods ====================

  /// 상품 생성
  ///
  /// [session]: Serverpod 세션
  /// [request]: 상품 생성 요청 DTO
  /// Returns: 생성된 상품
  Future<Product> createProduct(
    Session session,
    CreateProductRequestDto request,
  ) async {
    final user = await UserService.getMe(session);
    return await productService.createProduct(session, user.id!, request);
  }

  /// 상품 수정
  ///
  /// [session]: Serverpod 세션
  /// [request]: 상품 수정 요청 DTO
  /// Returns: 수정된 상품
  Future<Product> updateProduct(
    Session session,
    UpdateProductRequestDto request,
  ) async {
    final user = await UserService.getMe(session);
    return await productService.updateProduct(
      session,
      request.productId,
      user.id!,
      request,
    );
  }

  /// 상품 상세 조회
  ///
  /// [session]: Serverpod 세션
  /// [id]: 상품 ID
  /// Returns: 상품 정보
  Future<Product> getProduct(Session session, int id) async {
    return await productService.getProductById(session, id);
  }

  /// 페이지네이션된 상품 목록 조회
  ///
  /// [session]: Serverpod 세션
  /// [pagination]: 페이지네이션 정보
  /// Returns: 페이지네이션된 상품 목록
  Future<PaginatedProductsResponseDto> getPaginatedProducts(
    Session session,
    PaginationDto pagination,
  ) async {
    return await productListService.getPaginatedProducts(session, pagination);
  }

  /// 찜 추가/제거 (토글)
  ///
  /// [session]: Serverpod 세션
  /// [productId]: 상품 ID
  /// Returns: true = 찜 추가됨, false = 찜 제거됨
  Future<bool> toggleFavorite(Session session, int productId) async {
    final user = await UserService.getMe(session);
    return await productInteractionService.toggleFavorite(
      session,
      user.id!,
      productId,
    );
  }

  /// 찜 상태 조회
  ///
  /// [session]: Serverpod 세션
  /// [productId]: 상품 ID
  /// Returns: true = 찜함, false = 찜 안 함
  Future<bool> isFavorite(Session session, int productId) async {
    final user = await UserService.getMe(session);
    return await productInteractionService.isFavorite(
      session,
      user.id!,
      productId,
    );
  }

  /// 조회수 증가 (계정당 1회)
  ///
  /// 이미 조회한 경우에는 조회수를 증가시키지 않습니다.
  ///
  /// [session]: Serverpod 세션
  /// [productId]: 상품 ID
  /// Returns: true = 조회수 증가됨, false = 이미 조회함
  Future<bool> incrementViewCount(Session session, int productId) async {
    final user = await UserService.getMe(session);
    return await productInteractionService.incrementViewCount(
      session,
      user.id!,
      productId,
    );
  }

  /// 상품 삭제
  ///
  /// [session]: Serverpod 세션
  /// [productId]: 삭제할 상품 ID
  Future<void> deleteProduct(Session session, int productId) async {
    final user = await UserService.getMe(session);
    await productService.deleteProduct(session, productId, user.id!);
  }

  /// 내가 등록한 상품 목록 조회 (페이지네이션)
  ///
  /// [session]: Serverpod 세션
  /// [pagination]: 페이지네이션 정보
  /// Returns: 페이지네이션된 상품 목록
  Future<PaginatedProductsResponseDto> getMyProducts(
    Session session,
    PaginationDto pagination,
  ) async {
    final user = await UserService.getMe(session);
    return await productListService.getMyProducts(
      session,
      user.id!,
      pagination,
    );
  }

  /// 내가 관심목록에 추가한 상품 목록 조회 (페이지네이션)
  ///
  /// [session]: Serverpod 세션
  /// [pagination]: 페이지네이션 정보
  /// Returns: 페이지네이션된 상품 목록
  Future<PaginatedProductsResponseDto> getMyFavoriteProducts(
    Session session,
    PaginationDto pagination,
  ) async {
    final user = await UserService.getMe(session);
    return await productListService.getMyFavoriteProducts(
      session,
      user.id!,
      pagination,
    );
  }

  /// 상품 상태 변경
  ///
  /// [session]: Serverpod 세션
  /// [request]: 상태 변경 요청 DTO
  /// Returns: 수정된 상품
  Future<Product> updateProductStatus(
    Session session,
    UpdateProductStatusRequestDto request,
  ) async {
    final user = await UserService.getMe(session);
    return await productService.updateProductStatus(
      session,
      request.productId,
      user.id!,
      request.status,
    );
  }

  /// 상품 상단으로 올리기 (updatedAt 갱신)
  ///
  /// 상품의 updatedAt을 현재 시간으로 갱신하여 최신순 정렬에서 상단으로 올립니다.
  ///
  /// [session]: Serverpod 세션
  /// [productId]: 상품 ID
  /// Returns: 수정된 상품
  Future<Product> bumpProduct(Session session, int productId) async {
    final user = await UserService.getMe(session);
    return await productService.bumpProduct(
      session,
      productId,
      user.id!,
    );
  }

  /// 현재 로그인한 사용자의 상품 통계 조회
  ///
  /// 판매중, 거래완료, 관심목록 개수, 후기 개수를 조회합니다.
  ///
  /// [session]: Serverpod 세션
  /// Returns: 상품 통계 DTO
  Future<ProductStatsDto> getProductStats(Session session) async {
    final user = await UserService.getMe(session);
    return await productListService.getProductStats(session, user.id!);
  }

  /// 다른 사용자의 상품 통계 조회
  ///
  /// 판매중, 거래완료, 관심목록 개수, 후기 개수를 조회합니다.
  ///
  /// [session]: Serverpod 세션
  /// [userId]: 조회할 사용자 ID
  /// Returns: 상품 통계 DTO
  Future<ProductStatsDto> getProductStatsByUserId(
    Session session,
    int userId,
  ) async {
    return await productListService.getProductStats(session, userId);
  }

  /// 다른 사용자의 상품 목록 조회 (페이지네이션)
  ///
  /// [pagination.status]가 null이면 모든 상태의 상품을 반환합니다.
  /// [pagination.status]가 ProductStatus.selling이면 판매중인 상품만 반환합니다.
  ///
  /// [session]: Serverpod 세션
  /// [userId]: 조회할 사용자 ID
  /// [pagination]: 페이지네이션 정보
  /// Returns: 페이지네이션된 상품 목록
  Future<PaginatedProductsResponseDto> getProductsByUserId(
    Session session,
    int userId,
    PaginationDto pagination,
  ) async {
    return await productListService.getMyProducts(session, userId, pagination);
  }

  /// 상품 신고 여부 조회
  ///
  /// [session]: Serverpod 세션
  /// [productId]: 상품 ID
  /// Returns: true = 이미 신고함, false = 신고 안 함
  Future<bool> hasReportedProduct(
    Session session,
    int productId,
  ) async {
    final user = await UserService.getMe(session);
    return await productReportService.hasReportedProduct(
      session,
      user.id!,
      productId,
    );
  }

  /// 상품 신고하기
  ///
  /// 중복 신고 불가, 본인 상품 신고 불가
  ///
  /// [session]: Serverpod 세션
  /// [request]: 신고 요청 DTO
  /// Returns: 생성된 신고
  /// Throws: Exception - 중복 신고 또는 본인 상품 신고 시
  Future<ProductReport> createProductReport(
    Session session,
    CreateProductReportRequestDto request,
  ) async {
    final user = await UserService.getMe(session);
    return await productReportService.createProductReport(
      session,
      user.id!,
      request,
    );
  }
}
