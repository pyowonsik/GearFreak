import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import '../../domain/repository/home_repository.dart';
import '../datasource/home_remote_datasource.dart';

/// 홈 Repository 구현
class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remoteDataSource;

  const HomeRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<pod.Product>> getRecentProducts() async {
    return await remoteDataSource.getRecentProducts();
  }

  @override
  Future<pod.Product> getProductDetail(int id) async {
    return await remoteDataSource.getProductDetail(id);
  }
}
