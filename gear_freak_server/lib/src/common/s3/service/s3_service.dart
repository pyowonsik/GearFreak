import 'dart:io';
import 'package:serverpod/serverpod.dart';
import 'package:aws_signature_v4/aws_signature_v4.dart';
import 'package:aws_common/aws_common.dart';
import 'package:gear_freak_server/src/generated/protocol.dart';

/// S3 서비스 (Presigned URL 생성)
class S3Service {
  /// Presigned URL 생성 (업로드용) - 전체 프로세스 처리
  ///
  /// [session] - Serverpod 세션
  /// [request] - 업로드 요청 정보
  /// [userId] - 사용자 ID
  ///
  /// 반환: Presigned URL 응답 DTO
  static Future<GeneratePresignedUploadUrlResponseDto>
      generatePresignedUploadUrlForRequest(
    Session session,
    GeneratePresignedUploadUrlRequestDto request,
    int userId,
  ) async {
    // 파일 타입 검증 (이미지만 허용)
    final allowedContentTypes = [
      'image/jpeg',
      'image/jpg',
      'image/png',
      'image/webp',
    ];
    if (!allowedContentTypes.contains(request.contentType.toLowerCase())) {
      throw Exception('Invalid file type. Only images are allowed.');
    }

    // 버킷 타입 검증
    if (request.bucketType != 'public' && request.bucketType != 'private') {
      throw Exception('Invalid bucket type. Use "public" or "private"');
    }

    // 버킷 이름 가져오기
    final bucketName = getBucketName(session, request.bucketType);

    // 파일 키 생성 (업로드 시 temp/{prefix}/... 형태로 저장)
    // 예: temp/product/1/..., temp/chatRoom/1/..., temp/profile/1/...
    final tempPrefix =
        request.prefix != null ? 'temp/${request.prefix}' : 'temp';
    final fileKey = generateFileKey(
      userId: userId,
      fileName: request.fileName,
      prefix: tempPrefix,
    );

    // Presigned URL 생성
    final presignedUrl = await generatePresignedUploadUrl(
      session,
      bucketName,
      fileKey,
      request.contentType,
      expiresIn: 3600, // 1시간
    );

    return GeneratePresignedUploadUrlResponseDto(
      presignedUrl: presignedUrl,
      fileKey: fileKey,
      expiresIn: 3600,
    );
  }

  /// Presigned URL 생성 (업로드용)
  ///
  /// [session] - Serverpod 세션
  /// [bucketName] - S3 버킷 이름
  /// [objectKey] - S3 객체 키 (파일 경로)
  /// [contentType] - 파일의 Content-Type
  /// [expiresIn] - URL 만료 시간 (초 단위, 기본 1시간)
  ///
  /// 반환: Presigned URL
  static Future<String> generatePresignedUploadUrl(
    Session session,
    String bucketName,
    String objectKey,
    String contentType, {
    int expiresIn = 3600, // 1시간
  }) async {
    // 환경변수에서 AWS 정보 가져오기 (.envrc로 관리)
    // EC2 인스턴스에서는 IAM 역할을 사용하므로 Access Key가 없을 수 있음
    final awsAccessKeyId = Platform.environment['AWS_ACCESS_KEY_ID'] ?? '';
    final awsSecretAccessKey =
        Platform.environment['AWS_SECRET_ACCESS_KEY'] ?? '';
    final region = Platform.environment['AWS_REGION'] ??
        Platform.environment['AWS_DEFAULT_REGION'] ??
        'ap-northeast-2';

    // 로컬 개발 환경에서만 Access Key 필요
    // 프로덕션(EC2)에서는 IAM 역할 사용
    final credentials = AWSCredentials(
      awsAccessKeyId,
      awsSecretAccessKey,
    );

    // S3 엔드포인트
    final uri =
        Uri.parse('https://$bucketName.s3.$region.amazonaws.com/$objectKey');

    // Presigned URL 생성 (aws_signature_v4 0.5.2 API)
    final signer = AWSSigV4Signer(
      credentialsProvider: AWSCredentialsProvider(credentials),
    );

    // S3 서비스 설정 (S3ServiceConfiguration 사용)
    final serviceConfiguration = S3ServiceConfiguration();

    // aws_signature_v4 0.5.2에서는 headers를 직접 지정
    // host 헤더는 자동으로 추가되지만, Content-Type은 명시적으로 지정
    final request = AWSHttpRequest(
      method: AWSHttpMethod.put,
      uri: uri,
      headers: {
        AWSHeaders.host: uri.host,
        AWSHeaders.contentType: contentType,
      },
    );

    final presignedUrl = await signer.presign(
      request,
      credentialScope: AWSCredentialScope(
        region: region,
        service: AWSService.s3,
      ),
      serviceConfiguration: serviceConfiguration,
      expiresIn: Duration(seconds: expiresIn),
    );

    // presignedUrl이 Uri 객체이므로 toString()으로 변환
    return presignedUrl.toString();
  }

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
}
