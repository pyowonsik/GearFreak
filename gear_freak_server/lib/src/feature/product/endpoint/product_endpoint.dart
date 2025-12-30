import 'package:gear_freak_server/src/common/authenticated_mixin.dart';
import 'package:gear_freak_server/src/feature/product/service/product_service.dart';
import 'package:gear_freak_server/src/feature/user/service/user_service.dart';
import 'package:gear_freak_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';

/// 상품 엔드포인트
class ProductEndpoint extends Endpoint with AuthenticatedMixin {
  final ProductService productService = ProductService();

  /// 상품 생성
  Future<Product> createProduct(
    Session session,
    CreateProductRequestDto request,
  ) async {
    final user = await UserService.getMe(session);
    return await productService.createProduct(session, user.id!, request);
  }

  /// 상품 수정
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

  Future<Product> getProduct(Session session, int id) async {
    return await productService.getProductById(session, id);
  }

  /// 페이지네이션된 상품 목록 조회
  Future<PaginatedProductsResponseDto> getPaginatedProducts(
    Session session,
    PaginationDto pagination,
  ) async {
    return await productService.getPaginatedProducts(session, pagination);
  }

  /// 찜 추가/제거 (토글)
  /// 반환값: true = 찜 추가됨, false = 찜 제거됨
  Future<bool> toggleFavorite(Session session, int productId) async {
    final user = await UserService.getMe(session);
    return await productService.toggleFavorite(session, user.id!, productId);
  }

  /// 찜 상태 조회
  Future<bool> isFavorite(Session session, int productId) async {
    final user = await UserService.getMe(session);
    return await productService.isFavorite(session, user.id!, productId);
  }

  /// 조회수 증가 (계정당 1회)
  /// 이미 조회한 경우에는 조회수를 증가시키지 않습니다.
  /// 반환값: true = 조회수 증가됨, false = 이미 조회함 (증가 안 됨)
  Future<bool> incrementViewCount(Session session, int productId) async {
    final user = await UserService.getMe(session);
    return await productService.incrementViewCount(
      session,
      user.id!,
      productId,
    );
  }

  /// 상품 삭제
  Future<void> deleteProduct(Session session, int productId) async {
    final user = await UserService.getMe(session);
    await productService.deleteProduct(session, productId, user.id!);
  }

  /// 내가 등록한 상품 목록 조회 (페이지네이션)
  Future<PaginatedProductsResponseDto> getMyProducts(
    Session session,
    PaginationDto pagination,
  ) async {
    final user = await UserService.getMe(session);
    return await productService.getMyProducts(session, user.id!, pagination);
  }

  /// 내가 관심목록한 상품 목록 조회 (페이지네이션)
  Future<PaginatedProductsResponseDto> getMyFavoriteProducts(
    Session session,
    PaginationDto pagination,
  ) async {
    final user = await UserService.getMe(session);
    return await productService.getMyFavoriteProducts(
      session,
      user.id!,
      pagination,
    );
  }

  /// 상품 상태 변경
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
  /// 상품의 updatedAt을 현재 시간으로 갱신하여 최신순 정렬에서 상단으로 올립니다.
  Future<Product> bumpProduct(Session session, int productId) async {
    final user = await UserService.getMe(session);
    return await productService.bumpProduct(
      session,
      productId,
      user.id!,
    );
  }

  /// 상품 통계 조회 (판매중, 거래완료, 관심목록 개수, 후기 개수)
  /// 현재 로그인한 사용자의 통계를 조회합니다.
  Future<ProductStatsDto> getProductStats(Session session) async {
    final user = await UserService.getMe(session);
    return await productService.getProductStats(session, user.id!);
  }

  /// 다른 사용자의 상품 통계 조회 (판매중, 거래완료, 관심목록 개수, 후기 개수)
  /// [userId]는 조회할 사용자의 ID입니다.
  Future<ProductStatsDto> getProductStatsByUserId(
    Session session,
    int userId,
  ) async {
    return await productService.getProductStats(session, userId);
  }

  /// 다른 사용자의 상품 목록 조회 (페이지네이션)
  /// [userId]는 조회할 사용자의 ID입니다.
  /// [pagination.status]가 null이면 모든 상태의 상품을 반환합니다.
  /// [pagination.status]가 ProductStatus.selling이면 판매중인 상품만 반환합니다 (selling + reserved 포함).
  Future<PaginatedProductsResponseDto> getProductsByUserId(
    Session session,
    int userId,
    PaginationDto pagination,
  ) async {
    return await productService.getMyProducts(session, userId, pagination);
  }

  /// 상품 신고 여부 조회
  /// 반환값: true = 이미 신고함, false = 신고 안 함
  Future<bool> hasReportedProduct(
    Session session,
    int productId,
  ) async {
    final user = await UserService.getMe(session);
    return await productService.hasReportedProduct(
      session,
      user.id!,
      productId,
    );
  }

  /// 상품 신고하기
  /// 중복 신고 체크: 같은 사용자가 같은 상품을 이미 신고한 경우 Exception 발생
  /// 본인 상품 신고 불가
  Future<ProductReport> createProductReport(
    Session session,
    CreateProductReportRequestDto request,
  ) async {
    final user = await UserService.getMe(session);
    return await productService.createProductReport(
      session,
      user.id!,
      request,
    );
  }
}
