/// 포맷 유틸리티 함수들

/// 가격을 천 단위 콤마로 포맷팅
String formatPrice(int price) {
  return price.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]},',
      );
}

/// 날짜/시간을 상대 시간으로 포맷팅 (예: "5분 전", "2시간 전")
String formatRelativeTime(DateTime? dateTime) {
  if (dateTime == null) return '시간 정보 없음';

  final now = DateTime.now();
  final difference = now.difference(dateTime);

  if (difference.inMinutes < 1) {
    return '방금 전';
  } else if (difference.inMinutes < 60) {
    return '${difference.inMinutes}분 전';
  } else if (difference.inHours < 24) {
    return '${difference.inHours}시간 전';
  } else {
    return '${difference.inDays}일 전';
  }
}

/// 채팅용 시간 포맷팅 (예: "오전 10:30", "어제", "3일 전")
String formatChatTime(DateTime timestamp) {
  final now = DateTime.now();
  final difference = now.difference(timestamp);

  if (difference.inDays == 0) {
    final hour = timestamp.hour;
    final minute = timestamp.minute;
    final period = hour >= 12 ? '오후' : '오전';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$period $displayHour:${minute.toString().padLeft(2, '0')}';
  } else if (difference.inDays == 1) {
    return '어제';
  } else {
    return '${difference.inDays}일 전';
  }
}
