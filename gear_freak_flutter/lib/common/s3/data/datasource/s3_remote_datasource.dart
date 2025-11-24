import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import 'package:http/http.dart' as http;
import '../../../../common/service/pod_service.dart';

/// S3 원격 데이터 소스
class S3RemoteDataSource {
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
      final headers = <String, String>{
        'Content-Type': contentType,
      };

      final response = await http.put(
        uri,
        headers: headers,
        body: Uint8List.fromList(fileBytes),
      );

      // S3 presigned URL PUT 요청은 200 OK를 반환
      if (response.statusCode != 200) {
        debugPrint('❌ S3 업로드 실패: 상태 코드 ${response.statusCode}');
        throw Exception('파일 업로드에 실패했습니다. 상태 코드: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ S3 업로드 실패: $e');
      if (e is Exception) {
        rethrow;
      }
      throw Exception('파일 업로드에 실패했습니다: $e');
    }
  }
}
