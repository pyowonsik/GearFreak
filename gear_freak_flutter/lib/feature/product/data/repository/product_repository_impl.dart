import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import 'package:gear_freak_flutter/feature/product/data/datasource/product_remote_datasource.dart';
import 'package:gear_freak_flutter/feature/product/domain/repository/product_repository.dart';

/// 상품 Repository 구현
class ProductRepositoryImpl implements ProductRepository {
  /// 상품 Repository 구현 생성자
  ///
  /// [remoteDataSource]는 상품 원격 데이터 소스 인스턴스입니다.
  const ProductRepositoryImpl(this.remoteDataSource);

  /// 상품 원격 데이터 소스
  final ProductRemoteDataSource remoteDataSource;

  @override
  Future<pod.PaginatedProductsResponseDto> getPaginatedProducts(
    pod.PaginationDto pagination,
  ) async {
    return remoteDataSource.getPaginatedProducts(pagination);
  }

  @override
  Future<pod.Product> getProductDetail(int id) async {
    return remoteDataSource.getProductDetail(id);
  }

  @override
  Future<bool> toggleFavorite(int productId) async {
    return remoteDataSource.toggleFavorite(productId);
  }

  @override
  Future<bool> isFavorite(int productId) async {
    return remoteDataSource.isFavorite(productId);
  }

  @override
  Future<pod.Product> createProduct(pod.CreateProductRequestDto request) async {
    return remoteDataSource.createProduct(request);
  }

  @override
  Future<pod.Product> updateProduct(pod.UpdateProductRequestDto request) async {
    return remoteDataSource.updateProduct(request);
  }

  @override
  Future<void> deleteProduct(int productId) async {
    return remoteDataSource.deleteProduct(productId);
  }

  @override
  Future<pod.PaginatedProductsResponseDto> getMyProducts(
    pod.PaginationDto pagination,
  ) async {
    return remoteDataSource.getMyProducts(pagination);
  }

  @override
  Future<pod.PaginatedProductsResponseDto> getMyFavoriteProducts(
    pod.PaginationDto pagination,
  ) async {
    return remoteDataSource.getMyFavoriteProducts(pagination);
  }

  @override
  Future<pod.Product> updateProductStatus(
    pod.UpdateProductStatusRequestDto request,
  ) async {
    return remoteDataSource.updateProductStatus(request);
  }

  @override
  Future<pod.ProductStatsDto> getProductStats() async {
    return remoteDataSource.getProductStats();
  }

  @override
  Future<pod.ProductStatsDto> getProductStatsByUserId(int userId) async {
    return remoteDataSource.getProductStatsByUserId(userId);
  }

  @override
  Future<pod.PaginatedProductsResponseDto> getProductsByUserId(
    int userId,
    pod.PaginationDto pagination,
  ) async {
    return remoteDataSource.getProductsByUserId(userId, pagination);
  }
}
