import 'package:flutter/foundation.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import 'package:gear_freak_flutter/common/service/pod_service.dart';
import 'package:http/http.dart' as http;

/// S3 원격 데이터 소스
class S3RemoteDataSource {
  /// S3RemoteDataSource 생성자
  const S3RemoteDataSource();

  pod.Client get _client => PodService.instance.client;

  /// Presigned URL 생성
  Future<pod.GeneratePresignedUploadUrlResponseDto> generatePresignedUploadUrl(
    pod.GeneratePresignedUploadUrlRequestDto request,
  ) async {
    try {
      final response = await _client.s3.generatePresignedUploadUrl(request);
      return response;
    } catch (e) {
      debugPrint('❌ Presigned URL 생성 실패: $e');
      throw Exception('Presigned URL 생성에 실패했습니다: $e');
    }
  }

  /// 파일 업로드 (Presigned URL 사용)
  /// 해당 작업은 Presigned URL로 처리 하기 때문에 엔드포인트가 존재하지 않는다.
  Future<void> uploadFile({
    required String presignedUrl,
    required List<int> fileBytes,
    required String contentType,
  }) async {
    try {
      final uri = Uri.parse(presignedUrl);

      // S3 presigned URL은 서명에 Content-Type이 포함되어 있으므로
      // 반드시 헤더에 Content-Type을 포함해야 합니다.
      final headers = <String, String>{
        'Content-Type': contentType,
      };

      debugPrint('📤 S3 업로드 시작:');
      debugPrint(
          '   - URL: ${uri.toString().substring(0, uri.toString().indexOf('?'))}...');
      debugPrint('   - Content-Type: $contentType');
      debugPrint('   - 파일 크기: ${fileBytes.length} bytes');

      final response = await http.put(
        uri,
        headers: headers,
        body: fileBytes, // Uint8List.fromList 대신 직접 사용
      );

      debugPrint('📥 S3 업로드 응답:');
      debugPrint('   - 상태 코드: ${response.statusCode}');
      debugPrint('   - 응답 본문: ${response.body}');

      // S3 presigned URL PUT 요청은 200 OK를 반환
      if (response.statusCode != 200) {
        debugPrint('❌ S3 업로드 실패: 상태 코드 ${response.statusCode}');
        debugPrint('❌ 응답 본문: ${response.body}');
        throw Exception(
          '파일 업로드에 실패했습니다. 상태 코드: ${response.statusCode}, 응답: ${response.body}',
        );
      }

      debugPrint('✅ S3 업로드 성공');
    } catch (e, stackTrace) {
      debugPrint('❌ S3 업로드 실패: $e');
      debugPrint('❌ 스택 트레이스: $stackTrace');
      if (e is Exception) {
        rethrow;
      }
      throw Exception('파일 업로드에 실패했습니다: $e');
    }
  }
}
