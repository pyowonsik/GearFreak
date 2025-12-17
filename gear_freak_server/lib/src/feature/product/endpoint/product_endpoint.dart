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
}
