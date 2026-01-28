import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:share_plus/share_plus.dart';

/// 공유 유틸리티
/// 앱 내 콘텐츠를 외부로 공유하는 기능을 제공합니다.
class ShareUtils {
  /// 상품 공유
  ///
  /// [productId]는 상품 ID입니다.
  /// [title]는 상품 제목입니다.
  /// [price]는 상품 가격입니다.
  /// [imageUrl]는 상품 이미지 URL입니다 (선택).
  ///
  /// 공유 시 딥링크 URL이 포함되어 전달됩니다.
  /// 카카오톡, 문자, 이메일 등 다양한 앱에서 공유할 수 있습니다.
  static Future<void> shareProduct({
    required String productId,
    required String title,
    required int price,
    String? imageUrl,
  }) async {
    try {
      // 딥링크 URL 생성
      // Universal Links 사용 (프로덕션)
      final deepLinkBaseUrl = dotenv.env['DEEP_LINK_BASE_URL']!;
      final deepLinkUrl = '$deepLinkBaseUrl/product/$productId';

      // 공유 텍스트 생성
      final shareText = '''
운동은 장비빨!

[$title]
💰 ${_formatPrice(price)}원

$deepLinkUrl'''.trim();

      // 공유 실행
      // 카카오톡, 문자, 이메일 등 모든 공유 앱에서 선택 가능
      await Share.share(
        shareText,
        subject: title,
      );
    } catch (e) {
      // 공유 실패 시 에러 로그만 출력 (사용자에게는 에러 표시 안 함)
      // share_plus는 사용자가 공유를 취소할 수도 있으므로 에러로 처리하지 않음
      debugPrint('❌ 상품 공유 실패: $e');
    }
  }

  /// 가격 포맷팅
  /// 예: 10000 → "10,000"
  static String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }
}
