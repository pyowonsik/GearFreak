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

  /// 최근 등록 상품 조회 (5개)
  Future<List<Product>> getRecentProducts(Session session) async {
    return await productService.getRecentProducts(session);
  }

  /// 전체 상품 조회
  Future<List<Product>> getAllProducts(Session session) async {
    return await productService.getAllProducts(session);
  }
}
