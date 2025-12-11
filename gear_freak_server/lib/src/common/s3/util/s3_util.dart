import 'dart:io';
import 'package:serverpod/serverpod.dart';

/// S3 유틸리티 클래스
class S3Util {
  /// 고유한 파일 키 생성
  /// 형식: {prefix}/{userId}/{timestamp}-{random}.{extension}
  static String generateFileKey({
    required int userId,
    required String fileName,
    String? prefix,
  }) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = DateTime.now().microsecondsSinceEpoch % 100000;

    // 파일 확장자 추출
    final extension = fileName.split('.').last;

    // prefix가 있으면 추가
    final prefixPath = prefix != null ? '$prefix/' : '';

    return '$prefixPath$userId/$timestamp-$random.$extension';
  }

  /// 버킷 이름 가져오기 (.envrc로 관리)
  static String getBucketName(Session session, String bucketType) {
    if (bucketType == 'public') {
      return Platform.environment['S3_PUBLIC_BUCKET_NAME'] ??
          'gear-freak-public-storage-3059875';
    } else if (bucketType == 'private') {
      return Platform.environment['S3_PRIVATE_BUCKET_NAME'] ??
          'gear-freak-private-storage-3059875';
    } else {
      throw Exception(
          'Invalid bucket type: $bucketType. Use "public" or "private"');
    }
  }

  /// URL에서 파일 키 추출
  ///
  /// 예: https://bucket.s3.region.amazonaws.com/temp/product/1/xxx.png
  /// -> temp/product/1/xxx.png
  static String extractKeyFromUrl(String url) {
    final uri = Uri.parse(url);
    // path에서 첫 번째 '/' 제거
    return uri.path.startsWith('/') ? uri.path.substring(1) : uri.path;
  }

  /// 파일 키에서 temp 경로를 실제 경로로 변환
  ///
  /// 예: temp/product/1/xxx.png, productId=123
  /// -> product/123/xxx.png
  static String convertTempKeyToProductKey(
    String tempKey,
    int productId,
  ) {
    // temp/product/1/xxx.png -> product/123/xxx.png
    if (tempKey.startsWith('temp/product/')) {
      final parts = tempKey.split('/');
      if (parts.length >= 4) {
        // temp, product, userId, filename
        final filename = parts.sublist(3).join('/');
        return 'product/$productId/$filename';
      }
    }
    throw Exception('Invalid temp key format: $tempKey');
  }

  /// 파일 키에서 temp 경로를 프로필 경로로 변환
  ///
  /// 예: temp/profile/1/xxx.png, userId=1
  /// -> profile/1/xxx.png
  static String convertTempKeyToProfileKey(
    String tempKey,
    int userId,
  ) {
    // temp/profile/1/xxx.png -> profile/1/xxx.png
    if (tempKey.startsWith('temp/profile/')) {
      final parts = tempKey.split('/');
      if (parts.length >= 4) {
        // temp, profile, userId, filename
        final filename = parts.sublist(3).join('/');
        return 'profile/$userId/$filename';
      }
    }
    throw Exception('Invalid temp key format: $tempKey');
  }

  /// 채팅방 이미지 파일 키 생성 (temp 없이 바로 chatRoom 경로)
  /// 형식: chatRoom/{chatRoomId}/{userId}/{timestamp}-{random}.{extension}
  static String generateChatRoomFileKey({
    required int chatRoomId,
    required int userId,
    required String fileName,
  }) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = DateTime.now().microsecondsSinceEpoch % 100000;

    // 파일 확장자 추출
    final extension = fileName.split('.').last;

    return 'chatRoom/$chatRoomId/$userId/$timestamp-$random.$extension';
  }
}
