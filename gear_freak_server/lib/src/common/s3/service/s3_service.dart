import 'dart:io';
import 'package:serverpod/serverpod.dart';
import 'package:aws_signature_v4/aws_signature_v4.dart';
import 'package:aws_common/aws_common.dart' hide LogLevel;
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

  /// S3 파일 이동 (copy + delete)
  ///
  /// [session] - Serverpod 세션
  /// [sourceKey] - 원본 파일 키 (예: temp/product/1/xxx.png)
  /// [destinationKey] - 대상 파일 키 (예: product/123/xxx.png)
  /// [bucketType] - 버킷 타입 ('public' 또는 'private')
  ///
  /// 반환: 이동된 파일의 새로운 URL
  static Future<String> moveS3Object(
    Session session,
    String sourceKey,
    String destinationKey,
    String bucketType,
  ) async {
    final bucketName = getBucketName(session, bucketType);
    final region = Platform.environment['AWS_REGION'] ??
        Platform.environment['AWS_DEFAULT_REGION'] ??
        'ap-northeast-2';

    final awsAccessKeyId = Platform.environment['AWS_ACCESS_KEY_ID'] ?? '';
    final awsSecretAccessKey =
        Platform.environment['AWS_SECRET_ACCESS_KEY'] ?? '';

    final credentials = AWSCredentials(
      awsAccessKeyId,
      awsSecretAccessKey,
    );

    final signer = AWSSigV4Signer(
      credentialsProvider: AWSCredentialsProvider(credentials),
    );

    final serviceConfiguration = S3ServiceConfiguration();

    // 1. CopyObject: 원본을 새 위치로 복사
    final copyUri = Uri.parse(
        'https://$bucketName.s3.$region.amazonaws.com/$destinationKey');
    final copySource = '/$bucketName/$sourceKey';

    final copyRequest = AWSHttpRequest(
      method: AWSHttpMethod.put,
      uri: copyUri,
      headers: {
        AWSHeaders.host: copyUri.host,
        'x-amz-copy-source': copySource,
      },
    );

    final signedCopyRequest = await signer.sign(
      copyRequest,
      credentialScope: AWSCredentialScope(
        region: region,
        service: AWSService.s3,
      ),
      serviceConfiguration: serviceConfiguration,
    );

    final copyOperation = signedCopyRequest.send();
    final copyResponse = await copyOperation.response;
    if (copyResponse.statusCode != 200) {
      final responseBody = copyResponse.body;
      throw Exception(
          'Failed to copy S3 object: ${copyResponse.statusCode} - $responseBody');
    }

    // 2. DeleteObject: 원본 파일 삭제
    final deleteUri =
        Uri.parse('https://$bucketName.s3.$region.amazonaws.com/$sourceKey');

    final deleteRequest = AWSHttpRequest(
      method: AWSHttpMethod.delete,
      uri: deleteUri,
      headers: {
        AWSHeaders.host: deleteUri.host,
      },
    );

    final signedDeleteRequest = await signer.sign(
      deleteRequest,
      credentialScope: AWSCredentialScope(
        region: region,
        service: AWSService.s3,
      ),
      serviceConfiguration: serviceConfiguration,
    );

    final deleteOperation = signedDeleteRequest.send();
    final deleteResponse = await deleteOperation.response;
    if (deleteResponse.statusCode != 204 && deleteResponse.statusCode != 200) {
      // 복사는 성공했지만 삭제 실패 시 경고만 (복사본은 남아있음)
      session.log('Warning: Failed to delete source S3 object: $sourceKey',
          level: LogLevel.warning);
    }

    // 이동된 파일의 URL 반환
    return 'https://$bucketName.s3.$region.amazonaws.com/$destinationKey';
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

  /// S3 파일 삭제
  ///
  /// [session] - Serverpod 세션
  /// [fileKey] - 삭제할 파일 키 (예: temp/product/1/xxx.png)
  /// [bucketType] - 버킷 타입 ('public' 또는 'private')
  static Future<void> deleteS3Object(
    Session session,
    String fileKey,
    String bucketType,
  ) async {
    final bucketName = getBucketName(session, bucketType);
    final region = Platform.environment['AWS_REGION'] ??
        Platform.environment['AWS_DEFAULT_REGION'] ??
        'ap-northeast-2';

    final awsAccessKeyId = Platform.environment['AWS_ACCESS_KEY_ID'] ?? '';
    final awsSecretAccessKey =
        Platform.environment['AWS_SECRET_ACCESS_KEY'] ?? '';

    final credentials = AWSCredentials(
      awsAccessKeyId,
      awsSecretAccessKey,
    );

    final signer = AWSSigV4Signer(
      credentialsProvider: AWSCredentialsProvider(credentials),
    );

    final serviceConfiguration = S3ServiceConfiguration();

    // DeleteObject: 파일 삭제
    final deleteUri =
        Uri.parse('https://$bucketName.s3.$region.amazonaws.com/$fileKey');

    final deleteRequest = AWSHttpRequest(
      method: AWSHttpMethod.delete,
      uri: deleteUri,
      headers: {
        AWSHeaders.host: deleteUri.host,
      },
    );

    final signedDeleteRequest = await signer.sign(
      deleteRequest,
      credentialScope: AWSCredentialScope(
        region: region,
        service: AWSService.s3,
      ),
      serviceConfiguration: serviceConfiguration,
    );

    final deleteOperation = signedDeleteRequest.send();
    final deleteResponse = await deleteOperation.response;
    if (deleteResponse.statusCode != 204 && deleteResponse.statusCode != 200) {
      final responseBody = deleteResponse.body;
      throw Exception(
          'Failed to delete S3 object: ${deleteResponse.statusCode} - $responseBody');
    }
  }
}
