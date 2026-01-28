import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import 'package:gear_freak_flutter/feature/auth/di/auth_providers.dart';
import 'package:gear_freak_flutter/feature/auth/presentation/provider/auth_state.dart';
import 'package:gear_freak_flutter/feature/product/di/product_providers.dart';
import 'package:gear_freak_flutter/feature/product/presentation/presentation.dart';
import 'package:gear_freak_flutter/feature/review/presentation/presentation.dart';
import 'package:gear_freak_flutter/shared/widget/widget.dart';
import 'package:go_router/go_router.dart';

/// 상품 상세 화면
class ProductDetailPage extends ConsumerStatefulWidget {
  /// ProductDetailPage 생성자
  ///
  /// [key]는 위젯의 키입니다.
  /// [productId]는 상품 ID입니다.
  const ProductDetailPage({
    required this.productId,
    super.key,
  });

  /// 상품 ID
  final String productId;

  @override
  ConsumerState<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends ConsumerState<ProductDetailPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final id = int.parse(widget.productId);
      unawaited(
        ref.read(productDetailNotifierProvider.notifier).loadProductDetail(id),
      );
    });
  }

  /// 본인이 등록한 상품인지 확인
  bool _isMyProduct(pod.Product productData) {
    final authState = ref.read(authNotifierProvider);
    if (authState is! AuthAuthenticated) {
      return false;
    }
    final currentUserId = authState.user.id;
    // sellerId는 항상 존재하므로 직접 사용
    return currentUserId == productData.sellerId;
  }

  /// 수정 처리
  void _handleEdit(pod.Product productData) {
    if (productData.id != null) {
      context.push('/product/edit/${productData.id}');
    }
  }

  /// 상단으로 올리기 처리
  Future<void> _handleBump(pod.Product productData) async {
    if (!mounted) return;

    if (productData.id == null) {
      if (!mounted) return;
      GbSnackBar.showError(context, '상품 ID가 유효하지 않습니다');
      return;
    }

    // 쿨다운 사전 체크 (API 호출 전)
    if (productData.lastBumpedAt != null) {
      final now = DateTime.now().toUtc();
      final timeSinceLastBump = now.difference(productData.lastBumpedAt!);

      if (timeSinceLastBump.inHours < 24) {
        final remainingMinutes = (24 * 60) - timeSinceLastBump.inMinutes;
        final remainingHours = remainingMinutes ~/ 60;
        final displayMinutes = remainingMinutes % 60;

        if (!mounted) return;

        // 남은 시간 비율 계산 (24시간 중)
        final totalMinutes = 24 * 60;
        final elapsedMinutes = timeSinceLastBump.inMinutes;
        final progress = elapsedMinutes / totalMinutes;

        // 예쁜 커스텀 모달로 안내 메시지 표시
        await showDialog<void>(
          context: context,
          builder: (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 타이머 아이콘과 프로그레스
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 80,
                        height: 80,
                        child: CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 6,
                          backgroundColor: const Color(0xFFE5E7EB),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFF2563EB),
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.timer_outlined,
                        size: 36,
                        color: Color(0xFF2563EB),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // 제목
                  const Text(
                    '아직 올릴 수 없어요',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // 설명
                  const Text(
                    '끌어올리기는 24시간마다 가능합니다',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // 남은 시간 박스
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 20,
                          color: Color(0xFF2563EB),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$remainingHours시간 $displayMinutes분 후 가능',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2563EB),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // 확인 버튼
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        '확인',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
        return;
      }
    }

    // 상단으로 올리기 API 호출
    final errorMessage = await ref
        .read(productDetailNotifierProvider.notifier)
        .bumpProduct(productData.id!);

    if (!mounted) return;

    if (errorMessage == null) {
      // 성공
      GbSnackBar.showSuccess(context, '상품이 상단으로 올라갔습니다');
    } else {
      // 실패 (쿨다운 또는 일반 에러)
      if (errorMessage.contains('wait') ||
          errorMessage.contains('시간') ||
          errorMessage.contains('Bump cooldown active')) {
        // 쿨다운 메시지
        GbSnackBar.showWarning(context, errorMessage);
      } else {
        // 일반 에러
        GbSnackBar.showError(context, errorMessage);
      }
    }
  }

  /// 신고하기 처리
  Future<void> _handleReport(pod.Product productData) async {
    if (productData.id == null) {
      return;
    }

    // 1. 먼저 신고 내역 조회
    final hasReported = await ref
        .read(productDetailNotifierProvider.notifier)
        .hasReportedProduct(productData.id!);

    if (!mounted) return;

    if (hasReported) {
      // 이미 신고한 경우 바로 메시지 표시
      GbSnackBar.showError(context, '이미 신고한 상품입니다.');
      return;
    }

    // 2. 신고 내역이 없으면 모달 표시
    await ProductReportModal.show(
      context: context,
      productId: productData.id!,
      productTitle: productData.title,
      onReport: (reason, description) async {
        if (!mounted) return;

        final reportResult = await ref
            .read(productDetailNotifierProvider.notifier)
            .reportProduct(productData.id!, reason, description);

        if (!mounted) return;

        if (reportResult) {
          GbSnackBar.showSuccess(
            context,
            '신고가 접수되었습니다. 검토 후 처리하겠습니다.',
          );
        } else {
          GbSnackBar.showError(
            context,
            '신고 접수에 실패했습니다. 다시 시도해주세요.',
          );
        }
      },
    );
  }

  /// 삭제 처리
  Future<void> _handleDelete(pod.Product productData) async {
    if (!mounted) return;

    final shouldDelete = await GbDialog.show(
      context: context,
      title: '상품 삭제',
      content: '정말로 이 상품을 삭제하시겠습니까?',
      confirmText: '삭제',
      confirmColor: Colors.red,
    );

    if (shouldDelete != true) {
      return;
    }

    if (productData.id == null) {
      if (!mounted) return;
      GbSnackBar.showError(context, '상품 ID가 유효하지 않습니다');
      return;
    }

    // 삭제 API 호출
    final deleteResult = await ref
        .read(productDetailNotifierProvider.notifier)
        .deleteProduct(productData.id!);

    if (!mounted) return;

    if (deleteResult) {
      // 삭제 성공 시 이벤트는 ProductDetailNotifier에서 자동 발행됨
      // 모든 목록 Provider가 자동으로 해당 상품을 제거합니다

      if (!mounted) return;
      GbSnackBar.showSuccess(context, '상품이 삭제되었습니다');

      // 상품 상세 화면 닫기
      if (!mounted) return;
      if (context.canPop()) {
        context.pop();
      } else {
        // 스택에 이전 화면이 없으면 홈으로 이동
        context.go('/main/home');
      }
    } else {
      // 삭제 실패
      if (!mounted) return;
      GbSnackBar.showError(context, '상품 삭제에 실패했습니다');
    }
  }

  @override
  Widget build(BuildContext context) {
    final productDetailState = ref.watch(productDetailNotifierProvider);

    return switch (productDetailState) {
      ProductDetailLoading() => const Scaffold(
          appBar: GbAppBar(title: Text('')),
          body: GbLoadingView(),
        ),
      ProductDetailError(:final message) => Scaffold(
          appBar: const GbAppBar(title: Text('')),
          body: GbErrorView(
            message: message,
            onRetry: () {
              final id = int.parse(widget.productId);
              ref
                  .read(productDetailNotifierProvider.notifier)
                  .loadProductDetail(id);
            },
          ),
        ),
      ProductDetailLoaded(:final product, :final seller, :final isFavorite) =>
        ProductDetailLoadedView(
          product: product,
          seller: seller,
          isFavorite: isFavorite,
          productId: widget.productId,
          onEdit: _handleEdit,
          onBump: _handleBump,
          onDelete: _handleDelete,
          onReport: _handleReport,
          onStatusChange: _handleStatusChange,
          isMyProduct: _isMyProduct(product),
        ),
      ProductDetailInitial() => const Scaffold(
          appBar: GbAppBar(title: Text('')),
          body: GbLoadingView(),
        ),
    };
  }

  /// 상태 변경 처리
  Future<void> _handleStatusChange(
    pod.Product productData,
    pod.ProductStatus newStatus,
  ) async {
    if (productData.id == null) {
      return;
    }

    // 현재 상태와 동일하면 변경하지 않음
    final currentStatus = productData.status ?? pod.ProductStatus.selling;
    if (currentStatus == newStatus) {
      return;
    }

    // "판매완료"로 변경하는 경우 구매자 선택 모달 표시
    if (newStatus == pod.ProductStatus.sold && mounted) {
      unawaited(
        BuyerSelectionModal.show(
          context,
          productId: productData.id!,
          productName: productData.title,
          onBuyerSelected: () async {
            // 구매자 선택 시 상태 변경
            await ref
                .read(productDetailNotifierProvider.notifier)
                .updateProductStatus(productData.id!, newStatus);
          },
          onCancel: () async {
            // 선택하지 않기 클릭 시 상태 변경
            await ref
                .read(productDetailNotifierProvider.notifier)
                .updateProductStatus(productData.id!, newStatus);
          },
        ),
      );
    } else {
      // 판매완료에서 판매중/예약중으로 변경하는 경우 후기 삭제 경고
      final isRevertingFromSold = currentStatus == pod.ProductStatus.sold &&
          (newStatus == pod.ProductStatus.selling ||
              newStatus == pod.ProductStatus.reserved);

      final statusLabel = getProductStatusLabel(newStatus);
      final shouldChange = await GbDialog.show(
        context: context,
        title: isRevertingFromSold ? '⚠️ 후기 삭제 경고' : '상태 변경',
        content: isRevertingFromSold
            ? '판매완료 상품입니다.\n상태 변경 시 기존 후기는 삭제됩니다.\n\n정말로 변경하시겠습니까?'
            : '정말 $statusLabel 상태로 변경하시겠습니까?',
        confirmText: '변경',
        confirmColor: isRevertingFromSold ? Colors.red : null,
      );

      if (shouldChange != true || !mounted) {
        return;
      }

      await ref
          .read(productDetailNotifierProvider.notifier)
          .updateProductStatus(productData.id!, newStatus);
    }
  }
}
