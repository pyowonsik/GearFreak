import '../../domain/entity/product.dart';
import '../../domain/repository/home_repository.dart';
import '../datasource/home_remote_datasource.dart';

/// 홈 Repository 구현
class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remoteDataSource;

  const HomeRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<Product>> getRecentProducts() async {
    final data = await remoteDataSource.getRecentProducts();
    return data.map((json) => _toProduct(json)).toList();
  }

  @override
  Future<List<Category>> getCategories() async {
    final data = await remoteDataSource.getCategories();
    return data
        .map((json) => Category(
              id: json['id'] as String,
              name: json['name'] as String,
              icon: json['icon'] as String,
            ))
        .toList();
  }

  Product _toProduct(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      title: json['title'] as String,
      price: json['price'] as int,
      location: json['location'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      favoriteCount: json['favoriteCount'] as int? ?? 0,
      category: json['category'] as String? ?? '',
    );
  }
}
