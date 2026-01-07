import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import 'package:gear_freak_flutter/core/util/format_utils.dart';
import 'package:gear_freak_flutter/core/util/product_utils.dart';
import 'package:gear_freak_flutter/core/util/share_utils.dart';
import 'package:gear_freak_flutter/feature/product/di/product_providers.dart';
import 'package:gear_freak_flutter/feature/product/presentation/presentation.dart';
import 'package:gear_freak_flutter/shared/widget/widget.dart';
import 'package:go_router/go_router.dart';

/// 상품 상세 로드된 상태의 View
class ProductDetailLoadedView extends ConsumerStatefulWidget {
  /// ProductDetailLoadedView 생성자
  ///
  /// [product]는 상품 정보입니다.
  /// [seller]는 판매자 정보입니다.
  /// [isFavorite]는 찜하기 상태입니다.
  /// [productId]는 상품 ID입니다.
  /// [onEdit]는 수정 콜백입니다.
  /// [onBump]는 상단으로 올리기 콜백입니다.
  /// [onDelete]는 삭제 콜백입니다.
  /// [onReport]는 신고하기 콜백입니다.
  /// [onStatusChange]는 상태 변경 콜백입니다.
  /// [isMyProduct]는 본인 상품 여부입니다.
  const ProductDetailLoadedView({
    required this.product,
    required this.seller,
    required this.isFavorite,
    required this.productId,
    required this.onEdit,
    required this.onBump,
    required this.onDelete,
    required this.onReport,
    required this.onStatusChange,
    required this.isMyProduct,
    super.key,
  });

  /// 상품 정보
  final pod.Product product;

  /// 판매자 정보
  final pod.User? seller;

  /// 찜하기 상태
  final bool isFavorite;

  /// 상품 ID
  final String productId;

  /// 수정 콜백
  final void Function(pod.Product) onEdit;

  /// 상단으로 올리기 콜백
  final Future<void> Function(pod.Product) onBump;

  /// 삭제 콜백
  final Future<void> Function(pod.Product) onDelete;

  /// 신고하기 콜백
  final Future<void> Function(pod.Product) onReport;

  /// 상태 변경 콜백
  final Future<void> Function(pod.Product, pod.ProductStatus) onStatusChange;

  /// 본인 상품 여부
  final bool isMyProduct;

  @override
  ConsumerState<ProductDetailLoadedView> createState() =>
      _ProductDetailLoadedViewState();
}

class _ProductDetailLoadedViewState
    extends ConsumerState<ProductDetailLoadedView> {
  late PageController _pageController;
  int _currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GbAppBar(
        title: const Text(''),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              // 스택에 이전 화면이 없으면 홈으로 이동
              context.go('/main/home');
            }
          },
        ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              if (widget.product.id != null) {
                ShareUtils.shareProduct(
                  productId: widget.product.id!.toString(),
                  title: widget.product.title,
                  price: widget.product.price,
                  imageUrl: widget.product.imageUrls?.first,
                );
              }
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              switch (value) {
                case 'edit':
                  widget.onEdit(widget.product);
                case 'bump':
                  widget.onBump(widget.product);
                case 'delete':
                  widget.onDelete(widget.product);
                case 'report':
                  widget.onReport(widget.product);
              }
            },
            itemBuilder: (BuildContext context) {
              if (widget.isMyProduct) {
                // 본인 상품인 경우: 수정, 상단으로 올리기, 삭제
                return <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined, size: 20),
                        SizedBox(width: 8),
                        Text('수정'),
                      ],
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'bump',
                    child: Row(
                      children: [
                        Icon(Icons.arrow_upward, size: 20),
                        SizedBox(width: 8),
                        Text('상단으로 올리기'),
                      ],
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline, size: 20, color: Colors.red),
                        SizedBox(width: 8),
                        Text('삭제', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ];
              } else {
                // 다른 사람 상품인 경우: 신고하기
                return <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'report',
                    child: Row(
                      children: [
                        Icon(Icons.flag_outlined, size: 20, color: Colors.red),
                        SizedBox(width: 8),
                        Text('신고하기', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ];
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          final id = int.tryParse(widget.productId);
          if (id == null) return;
          await ref
              .read(productDetailNotifierProvider.notifier)
              .loadProductDetail(id);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 상품 이미지 (스와이프 가능)
              Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: 320,
                    color: const Color(0xFFF3F4F6),
                    child: (widget.product.imageUrls?.isNotEmpty ?? false)
                        ? PageView.builder(
                            controller: _pageController,
                            onPageChanged: (index) {
                              setState(() {
                                _currentPageIndex = index;
                              });
                            },
                            itemCount: widget.product.imageUrls!.length,
                            itemBuilder: (context, index) {
                              return CachedNetworkImage(
                                imageUrl: widget.product.imageUrls![index],
                                fit: BoxFit.cover,
                                fadeInDuration: Duration.zero,
                                fadeOutDuration: Duration.zero,
                                placeholderFadeInDuration: Duration.zero,
                                memCacheWidth: 1200, // 화면 크기 고려 (약 1.5x)
                                memCacheHeight: 960, // 화면 크기 고려 (약 1.5x)
                                maxWidthDiskCache: 1200,
                                maxHeightDiskCache: 960,
                                useOldImageOnUrlChange: true,
                                placeholder: (context, url) => const Center(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Color(0xFF9CA3AF),
                                    ),
                                  ),
                                ),
                                errorWidget: (context, url, error) =>
                                    const Center(
                                  child: Icon(
                                    Icons.shopping_bag,
                                    size: 120,
                                    color: Color(0xFF9CA3AF),
                                  ),
                                ),
                              );
                            },
                          )
                        : const Center(
                            child: Icon(
                              Icons.shopping_bag,
                              size: 120,
                              color: Color(0xFF9CA3AF),
                            ),
                          ),
                  ),
                  // 판매완료 또는 예약중 오버레이
                  if (widget.product.status == pod.ProductStatus.sold ||
                      widget.product.status == pod.ProductStatus.reserved)
                    Positioned.fill(
                      child: ColoredBox(
                        color: Colors.black.withValues(alpha: 0.6),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                widget.product.status == pod.ProductStatus.sold
                                    ? Icons.check_circle_outline
                                    : Icons.schedule_outlined,
                                size: 64,
                                color: Colors.white,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                widget.product.status == pod.ProductStatus.sold
                                    ? '판매완료'
                                    : '예약중',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  // 이미지 인디케이터 (여러 이미지가 있을 때만 표시)
                  if ((widget.product.imageUrls?.length ?? 0) > 1)
                    Positioned(
                      bottom: 16,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          widget.product.imageUrls!.length,
                          (index) => Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _currentPageIndex == index
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.5),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              // 상품 정보
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 판매자 정보
                    InkWell(
                      onTap: () {
                        // 판매자 프로필 화면으로 이동
                        final sellerId =
                            widget.seller?.id ?? widget.product.sellerId;
                        context.push('/profile/user/$sellerId');
                      },
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: const Color(0xFFF3F4F6),
                            backgroundImage: (widget.seller?.profileImageUrl !=
                                        null &&
                                    (widget.seller?.profileImageUrl
                                            ?.isNotEmpty ??
                                        false))
                                ? CachedNetworkImageProvider(
                                    widget.seller!.profileImageUrl!,
                                  )
                                : (widget.product.seller?.profileImageUrl !=
                                            null &&
                                        widget.product.seller!.profileImageUrl!
                                            .isNotEmpty)
                                    ? CachedNetworkImageProvider(
                                        widget.product.seller!.profileImageUrl!,
                                      )
                                    : null,
                            child: ((widget.seller?.profileImageUrl == null ||
                                        widget.seller!.profileImageUrl!
                                            .isEmpty) &&
                                    (widget.product.seller?.profileImageUrl ==
                                            null ||
                                        widget.product.seller!.profileImageUrl!
                                            .isEmpty))
                                ? Icon(
                                    Icons.person,
                                    color: Colors.grey.shade500,
                                  )
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Builder(
                            builder: (context) {
                              final location =
                                  getProductLocation(widget.product);
                              final hasLocation = location.isNotEmpty;
                              return Column(
                                crossAxisAlignment: hasLocation
                                    ? CrossAxisAlignment.start
                                    : CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    widget.seller?.nickname ??
                                        widget.product.seller?.nickname ??
                                        '판매자',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF1F2937),
                                    ),
                                  ),
                                  if (hasLocation) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      location,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF9CA3AF),
                                      ),
                                    ),
                                  ],
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Divider(color: Color(0xFFE5E7EB)),
                    const SizedBox(height: 20),
                    // 상품명과 상태 (본인 상품인 경우)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.product.title,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1F2937),
                                ),
                              ),
                              const SizedBox(height: 8),
                              // 카테고리 및 시간
                              Row(
                                children: [
                                  Text(
                                    getProductCategoryLabel(
                                      widget.product.category,
                                    ),
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF6B7280),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    '·',
                                    style: TextStyle(color: Color(0xFF9CA3AF)),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    formatRelativeTime(
                                      widget.product.updatedAt ??
                                          widget.product.createdAt,
                                    ),
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF6B7280),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        if (widget.isMyProduct)
                          Padding(
                            padding: const EdgeInsets.only(left: 16),
                            child: ProductStatusDropdownWidget(
                              currentStatus: widget.product.status ??
                                  pod.ProductStatus.selling,
                              onStatusChanged: (newStatus) {
                                widget.onStatusChange(
                                  widget.product,
                                  newStatus,
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // 가격
                    Text(
                      '${formatPrice(widget.product.price)}원',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                    // 상품 상태 및 거래 방법
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_circle_outline,
                                size: 16,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                getProductConditionLabel(
                                  widget.product.condition,
                                ),
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.local_shipping_outlined,
                                size: 16,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                getTradeMethodLabel(widget.product.tradeMethod),
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Divider(color: Color(0xFFE5E7EB)),
                    const SizedBox(height: 24),
                    // 상품 설명
                    const Text(
                      '상품 설명',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.product.description,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF4B5563),
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Divider(color: Color(0xFFE5E7EB)),
                    const SizedBox(height: 16),
                    // 상품 정보
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ProductInfoItemWidget(
                          icon: Icons.remove_red_eye_outlined,
                          label: '조회 ${widget.product.viewCount ?? 0}',
                        ),
                        ProductInfoItemWidget(
                          icon: Icons.favorite_border,
                          label: '찜 ${widget.product.favoriteCount ?? 0}',
                        ),
                        ProductInfoItemWidget(
                          icon: Icons.chat_bubble_outline,
                          label: '채팅 ${widget.product.chatCount ?? 0}',
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              // 찜하기 버튼
              IconButton(
                onPressed: () {
                  final id = int.tryParse(widget.productId);
                  if (id == null) return;
                  unawaited(
                    ref
                        .read(productDetailNotifierProvider.notifier)
                        .toggleFavorite(id),
                  );
                },
                icon: Icon(
                  widget.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: widget.isFavorite
                      ? const Color(0xFFEF4444)
                      : const Color(0xFF6B7280),
                  size: 28,
                ),
              ),
              const SizedBox(width: 8),
              // 1:1 채팅하기 / 대화중인 채팅방 보기 버튼
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    if (widget.isMyProduct) {
                      // 본인 상품인 경우: 대화중인 채팅방 보기 화면
                      final productId = int.tryParse(widget.productId);
                      if (productId == null) return;
                      context.push('/chat-room-selection/$productId');
                    } else {
                      // 다른 사람 상품인 경우: 1:1 채팅하기
                      final sellerId = widget.product.sellerId;
                      context.push(
                        '/chat/${widget.productId}?sellerId=$sellerId',
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    widget.isMyProduct ? '대화중인 채팅방 보기' : '1:1 채팅하기',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
