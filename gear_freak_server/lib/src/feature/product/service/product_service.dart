import 'package:gear_freak_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';

class ProductService {
  Future<Product> getProductById(Session session, int id) async {
    final product = await Product.db.findById(session, id);

    if (product == null) {
      throw Exception('Product not found');
    }

    return product;
  }

  /// 최근 등록 상품 조회 (5개)
  Future<List<Product>> getRecentProducts(Session session) async {
    final products = await Product.db.find(
      session,
      orderBy: (p) => p.createdAt,
      orderDescending: true,
      limit: 5,
    );

    return products;
  }

  /// 전체 상품 조회
  Future<List<Product>> getAllProducts(Session session) async {
    final products = await Product.db.find(
      session,
      orderBy: (p) => p.createdAt,
      orderDescending: true,
    );

    return products;
  }

  // Future<bool> deleteProduct(Session session, int id) async {
  //   final product = await Product.db.findById(session, id);
  //   if (product == null) {
  //     throw Exception('Product not found');
  //   }
  //   await Product.db.deleteRow(session, product);
  //   return true;
  // }
}
