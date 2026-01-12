import 'package:serverpod/serverpod.dart';

import 'package:gear_freak_server/src/generated/protocol.dart';

/// 상품 신고 서비스
/// 상품 신고 관련 비즈니스 로직을 처리합니다.
class ProductReportService {
  // ==================== Public Methods ====================

  /// 상품 신고 여부 조회
  ///
  /// 사용자가 특정 상품을 이미 신고했는지 확인합니다.
  ///
  /// [session]: Serverpod 세션
  /// [reporterId]: 신고자 ID
  /// [productId]: 상품 ID
  /// Returns: true = 이미 신고함, false = 신고 안 함
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
  ///
  /// 상품을 신고합니다. 중복 신고와 본인 상품 신고는 불가합니다.
  ///
  /// [session]: Serverpod 세션
  /// [reporterId]: 신고자 ID
  /// [request]: 신고 요청 DTO
  /// Returns: 생성된 신고
  /// Throws: Exception - 상품을 찾을 수 없거나, 본인 상품이거나, 중복 신고인 경우
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

