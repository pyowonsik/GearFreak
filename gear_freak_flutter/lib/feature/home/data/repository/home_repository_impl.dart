import 'package:gear_freak_client/gear_freak_client.dart' as pod;
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
  Future<List<pod.ProductCategory>> getCategories() async {
    return await remoteDataSource.getCategories();
  }

  Product _toProduct(Map<String, dynamic> json) {
    final categoryString = json['category'] as String? ?? 'equipment';
    final category = pod.ProductCategory.values.firstWhere(
      (e) => e.name == categoryString,
      orElse: () => pod.ProductCategory.equipment,
    );

    return Product(
      id: json['id'] as String,
      title: json['title'] as String,
      price: json['price'] as int,
      location: json['location'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      favoriteCount: json['favoriteCount'] as int? ?? 0,
      category: category,
    );
  }
}
