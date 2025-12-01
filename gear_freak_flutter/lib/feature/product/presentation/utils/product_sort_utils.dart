import 'package:gear_freak_client/gear_freak_client.dart' as pod;

/// 상품 정렬 관련 유틸리티
class ProductSortUtils {
  /// 정렬 옵션 문자열을 ProductSortBy enum으로 변환
  static pod.ProductSortBy? getSortByFromString(String sortString) {
    switch (sortString) {
      case '최신순':
        return pod.ProductSortBy.latest;
      case '인기순':
        return pod.ProductSortBy.popular;
      case '낮은 가격순':
        return pod.ProductSortBy.priceAsc;
      case '높은 가격순':
        return pod.ProductSortBy.priceDesc;
      default:
        return null;
    }
  }

  /// ProductSortBy enum을 문자열로 변환
  static String getStringFromSortBy(pod.ProductSortBy? sortBy) {
    switch (sortBy) {
      case pod.ProductSortBy.latest:
        return '최신순';
      case pod.ProductSortBy.popular:
        return '인기순';
      case pod.ProductSortBy.priceAsc:
        return '낮은 가격순';
      case pod.ProductSortBy.priceDesc:
        return '높은 가격순';
      default:
        return '최신순';
    }
  }
}

