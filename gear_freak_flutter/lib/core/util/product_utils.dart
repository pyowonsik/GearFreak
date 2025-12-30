import 'package:gear_freak_client/gear_freak_client.dart' as pod;

/// Product 관련 유틸리티 함수들

/// Product의 주소 정보를 조합하여 반환 (baseAddress + detailAddress)
String getProductLocation(pod.Product product) {
  final location = [
    product.baseAddress,
    product.detailAddress,
  ].where((e) => e != null && e.isNotEmpty).join(' ');
  return location.isNotEmpty ? location : '';
}
