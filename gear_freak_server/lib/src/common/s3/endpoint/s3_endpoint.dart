import 'package:gear_freak_server/src/common/authenticated_mixin.dart';
import 'package:gear_freak_server/src/common/s3/service/s3_service.dart';
import 'package:gear_freak_server/src/feature/user/service/user_service.dart';
import 'package:gear_freak_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';

/// S3 엔드포인트 (공통 사용)
class S3Endpoint extends Endpoint with AuthenticatedMixin {
  /// Presigned URL 생성 (업로드용)
  ///
  /// [session] - Serverpod 세션
  /// [request] - 업로드 요청 정보
  ///
  /// 반환: Presigned URL 및 파일 키
  Future<GeneratePresignedUploadUrlResponseDto> generatePresignedUploadUrl(
    Session session,
    GeneratePresignedUploadUrlRequestDto request,
  ) async {
    // 사용자 인증 확인 (AuthenticatedMixin으로 자동 처리)
    final user = await UserService.getMe(session);

    // Service에서 전체 로직 처리
    return await S3Service.generatePresignedUploadUrlForRequest(
      session,
      request,
      user.id!,
    );
  }
}
