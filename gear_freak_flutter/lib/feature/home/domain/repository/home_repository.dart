import '../entity/product.dart';

/// 홈 Repository 인터페이스
abstract class HomeRepository {
  /// 최근 등록 상품 조회
  Future<List<Product>> getRecentProducts();

  /// 카테고리 목록 조회
  Future<List<Category>> getCategories();
}

