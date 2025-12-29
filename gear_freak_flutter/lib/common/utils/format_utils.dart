/// 포맷 유틸리티 함수들
library;

/// 가격을 천 단위 콤마로 포맷팅
String formatPrice(int price) {
  return price.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]},',
      );
}

/// 날짜/시간을 상대 시간으로 포맷팅
/// 예: "방금 전", "5분 전", "2시간 전", "1일 전", "1주일 전", "1개월 전", "1년 전"
String formatRelativeTime(DateTime? dateTime) {
  if (dateTime == null) return '시간 정보 없음';

  final now = DateTime.now();
  final difference = now.difference(dateTime);

  // 방금 전 (1분 미만)
  if (difference.inMinutes < 1) {
    return '방금 전';
  }
  // 분 단위 (1분 이상, 60분 미만)
  else if (difference.inMinutes < 60) {
    return '${difference.inMinutes}분 전';
  }
  // 시간 단위 (1시간 이상, 24시간 미만)
  else if (difference.inHours < 24) {
    return '${difference.inHours}시간 전';
  }
  // 일 단위 (1일 이상, 7일 미만)
  else if (difference.inDays < 7) {
    return '${difference.inDays}일 전';
  }
  // 주 단위 (1주 이상, 4주 이하, 즉 28일 이하)
  else if (difference.inDays <= 28) {
    final weeks = (difference.inDays / 7).floor();
    return '${weeks}주일 전';
  }
  // 개월 단위 (29일 이상, 365일 미만, 즉 약 1개월 이상)
  else if (difference.inDays < 365) {
    // 대략적인 개월 수 계산 (30일 기준)
    final months = (difference.inDays / 30).floor();
    // months가 0이 되는 경우 방지 (29일 이상이므로 최소 1개월)
    final displayMonths = months.clamp(1, 12);
    return '${displayMonths}개월 전';
  }
  // 년 단위 (1년 이상)
  else {
    final years = (difference.inDays / 365).floor();
    return '${years}년 전';
  }
}
