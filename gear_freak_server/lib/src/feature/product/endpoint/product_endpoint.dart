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
}
