import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import '../../../../common/service/pod_service.dart';

/// 상품 원격 데이터 소스
class ProductRemoteDataSource {
  const ProductRemoteDataSource();

  pod.Client get _client => PodService.instance.client;

  /// 페이지네이션된 상품 목록 조회
  Future<pod.PaginatedProductsResponseDto> getPaginatedProducts(
    pod.PaginationDto pagination,
  ) async {
    try {
      return await _client.product.getPaginatedProducts(pagination);
    } catch (e) {
      throw Exception('상품 목록을 불러오는데 실패했습니다: $e');
    }
  }

  /// 상품 상세 조회
  Future<pod.Product> getProductDetail(int id) async {
    try {
      return await _client.product.getProduct(id);
    } catch (e) {
      throw Exception('상품 상세를 불러오는데 실패했습니다: $e');
    }
  }

  /// 찜 추가/제거 (토글)
  /// 반환값: true = 찜 추가됨, false = 찜 제거됨
  Future<bool> toggleFavorite(int productId) async {
    try {
      return await _client.product.toggleFavorite(productId);
    } catch (e) {
      throw Exception('찜 상태를 변경하는데 실패했습니다: $e');
    }
  }

  /// 찜 상태 조회
  Future<bool> isFavorite(int productId) async {
    try {
      return await _client.product.isFavorite(productId);
    } catch (e) {
      throw Exception('찜 상태를 조회하는데 실패했습니다: $e');
    }
  }
}
