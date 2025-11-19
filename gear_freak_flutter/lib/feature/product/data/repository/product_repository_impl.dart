import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import '../../domain/repository/product_repository.dart';
import '../datasource/product_remote_datasource.dart';

/// 상품 Repository 구현
class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;

  const ProductRepositoryImpl(this.remoteDataSource);

  @override
  Future<pod.PaginatedProductsResponseDto> getPaginatedProducts(
    pod.PaginationDto pagination,
  ) async {
    return await remoteDataSource.getPaginatedProducts(pagination);
  }

  @override
  Future<pod.Product> getProductDetail(int id) async {
    return await remoteDataSource.getProductDetail(id);
  }
}
