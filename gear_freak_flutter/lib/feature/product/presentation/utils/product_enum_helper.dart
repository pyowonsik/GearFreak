import 'package:gear_freak_client/gear_freak_client.dart' as pod;

/// ProductCategory enum을 한국어로 변환
String getProductCategoryLabel(pod.ProductCategory category) {
  switch (category) {
    case pod.ProductCategory.equipment:
      return '장비';
    case pod.ProductCategory.supplement:
      return '보충제';
    case pod.ProductCategory.clothing:
      return '의류';
    case pod.ProductCategory.shoes:
      return '신발';
    case pod.ProductCategory.etc:
      return '기타';
  }
}

/// ProductCondition enum을 한국어로 변환
String getProductConditionLabel(pod.ProductCondition condition) {
  switch (condition) {
    case pod.ProductCondition.brandNew:
      return '새 제품';
    case pod.ProductCondition.usedExcellent:
      return '중고 - 상';
    case pod.ProductCondition.usedGood:
      return '중고 - 중';
    case pod.ProductCondition.usedFair:
      return '중고 - 하';
  }
}

/// TradeMethod enum을 한국어로 변환
String getTradeMethodLabel(pod.TradeMethod method) {
  switch (method) {
    case pod.TradeMethod.direct:
      return '직거래';
    case pod.TradeMethod.delivery:
      return '택배';
    case pod.TradeMethod.both:
      return '직거래/택배';
  }
}

/// 한국어 카테고리명을 enum으로 변환
pod.ProductCategory? parseProductCategory(String label) {
  switch (label) {
    case '장비':
      return pod.ProductCategory.equipment;
    case '보충제':
      return pod.ProductCategory.supplement;
    case '의류':
      return pod.ProductCategory.clothing;
    case '신발':
      return pod.ProductCategory.shoes;
    case '기타':
      return pod.ProductCategory.etc;
    default:
      return null;
  }
}

/// 한국어 상태명을 enum으로 변환
pod.ProductCondition? parseProductCondition(String label) {
  switch (label) {
    case '새 제품':
      return pod.ProductCondition.brandNew;
    case '중고 - 상':
      return pod.ProductCondition.usedExcellent;
    case '중고 - 중':
      return pod.ProductCondition.usedGood;
    case '중고 - 하':
      return pod.ProductCondition.usedFair;
    default:
      return null;
  }
}

/// 한국어 거래방법명을 enum으로 변환
pod.TradeMethod? parseTradeMethod(String label) {
  switch (label) {
    case '직거래':
      return pod.TradeMethod.direct;
    case '택배':
      return pod.TradeMethod.delivery;
    case '직거래/택배':
      return pod.TradeMethod.both;
    default:
      return null;
  }
}

/// TradeMethod가 직거래를 포함하는지 확인
bool isDirectTrade(pod.TradeMethod method) {
  return method == pod.TradeMethod.direct || method == pod.TradeMethod.both;
}

/// ProductStatus enum을 한국어로 변환
String getProductStatusLabel(pod.ProductStatus? status) {
  if (status == null) return '판매중';
  switch (status) {
    case pod.ProductStatus.selling:
      return '판매중';
    case pod.ProductStatus.reserved:
      return '예약';
    case pod.ProductStatus.sold:
      return '판매완료';
  }
}
