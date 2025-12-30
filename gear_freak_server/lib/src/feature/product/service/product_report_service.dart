import 'package:gear_freak_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';

/// 상품 신고 서비스
/// 상품 신고 관련 비즈니스 로직을 처리합니다.
class ProductReportService {
  /// 상품 신고 여부 조회
  /// 반환값: true = 이미 신고함, false = 신고 안 함
  Future<bool> hasReportedProduct(
    Session session,
    int reporterId,
    int productId,
  ) async {
    final existingReport = await ProductReport.db.findFirstRow(
      session,
      where: (r) =>
          r.productId.equals(productId) & r.reporterId.equals(reporterId),
    );
    return existingReport != null;
  }

  /// 상품 신고하기
  /// 중복 신고 체크: 같은 사용자가 같은 상품을 이미 신고한 경우 Exception
  /// 본인 상품 신고 불가
  Future<ProductReport> createProductReport(
    Session session,
    int reporterId,
    CreateProductReportRequestDto request,
  ) async {
    // 1. 상품 존재 확인
    final product = await Product.db.findById(session, request.productId);
    if (product == null) {
      throw Exception('Product not found');
    }

    // 2. 본인 상품 신고 불가
    if (product.sellerId == reporterId) {
      throw Exception('Cannot report your own product');
    }

    // 3. 중복 신고 체크
    final existingReport = await ProductReport.db.findFirstRow(
      session,
      where: (r) =>
          r.productId.equals(request.productId) &
          r.reporterId.equals(reporterId),
    );

    if (existingReport != null) {
      throw Exception('You have already reported this product');
    }

    // 4. 신고 생성
    final now = DateTime.now().toUtc();
    final report = ProductReport(
      productId: request.productId,
      reporterId: reporterId,
      reason: request.reason,
      description: request.description,
      status: ReportStatus.pending, // 신고 접수 상태
      createdAt: now,
      updatedAt: now,
    );

    final createdReport = await ProductReport.db.insertRow(session, report);

    session.log(
      'Product report created: reportId=${createdReport.id}, '
      'productId=${request.productId}, reporterId=$reporterId, '
      'reason=${request.reason}',
      level: LogLevel.info,
    );

    return createdReport;
  }
}

