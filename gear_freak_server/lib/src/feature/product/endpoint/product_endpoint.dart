import 'package:gear_freak_server/src/common/authenticated_mixin.dart';
import 'package:gear_freak_server/src/feature/product/service/product_service.dart';
import 'package:gear_freak_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';

/// 인증 엔드포인트
class ProductEndpoint extends Endpoint with AuthenticatedMixin {
  final ProductService productService = ProductService();

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
}
