import '../entity/product.dart';
import '../repository/home_repository.dart';

/// 최근 등록 상품 조회 UseCase
class GetRecentProductsUseCase {
  final HomeRepository repository;

  GetRecentProductsUseCase(this.repository);

  Future<List<Product>> call() async {
    return await repository.getRecentProducts();
  }
}

