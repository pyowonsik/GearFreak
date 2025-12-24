import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import 'package:gear_freak_flutter/common/presentation/component/component.dart';
import 'package:gear_freak_flutter/common/presentation/view/view.dart';
import 'package:gear_freak_flutter/common/utils/format_utils.dart';
import 'package:gear_freak_flutter/common/utils/product_utils.dart';
import 'package:gear_freak_flutter/common/utils/share_utils.dart';
import 'package:gear_freak_flutter/feature/auth/di/auth_providers.dart';
import 'package:gear_freak_flutter/feature/auth/presentation/provider/auth_state.dart';
import 'package:gear_freak_flutter/feature/product/di/product_providers.dart';
import 'package:gear_freak_flutter/feature/product/presentation/provider/product_detail_state.dart';
import 'package:gear_freak_flutter/feature/product/presentation/utils/product_enum_helper.dart';
import 'package:gear_freak_flutter/feature/product/presentation/widget/widget.dart';
import 'package:gear_freak_flutter/feature/review/presentation/widget/buyer_selection_modal.dart';
import 'package:go_router/go_router.dart';

/// 상품 상세 화면
class ProductDetailScreen extends ConsumerStatefulWidget {
  /// ProductDetailScreen 생성자
  ///
  /// [key]는 위젯의 키입니다.
  /// [productId]는 상품 ID입니다.
  const ProductDetailScreen({
    required this.productId,
    super.key,
  });

  /// 상품 ID
  final String productId;

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  late PageController _pageController;
  int _currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final id = int.parse(widget.productId);
      unawaited(
        ref.read(productDetailNotifierProvider.notifier).loadProductDetail(id),
      );
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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
        _buildProductDetail(
          context,
          product,
          seller,
          isFavorite,
        ),
      ProductDetailInitial() => const Scaffold(
          appBar: GbAppBar(title: Text('')),
          body: GbLoadingView(),
        ),
    };
  }

  Widget _buildProductDetail(
    BuildContext context,
    pod.Product productData,
    pod.User? sellerData,
    bool isFavorite,
  ) {
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
              if (productData.id != null) {
                ShareUtils.shareProduct(
                  productId: productData.id!.toString(),
                  title: productData.title,
                  price: productData.price,
                  imageUrl: productData.imageUrls?.first,
                );
              }
            },
          ),
          if (_isMyProduct(productData))
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    _handleEdit(productData);
                  case 'delete':
                    _handleDelete(productData);
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
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
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline, size: 20, color: Colors.red),
                      SizedBox(width: 8),
                      Text('삭제', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          final id = int.parse(widget.productId);
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
                    child: (productData.imageUrls?.isNotEmpty ?? false)
                        ? PageView.builder(
                            controller: _pageController,
                            onPageChanged: (index) {
                              setState(() {
                                _currentPageIndex = index;
                              });
                            },
                            itemCount: productData.imageUrls!.length,
                            itemBuilder: (context, index) {
                              return CachedNetworkImage(
                                imageUrl: productData.imageUrls![index],
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
                  if (productData.status == pod.ProductStatus.sold ||
                      productData.status == pod.ProductStatus.reserved)
                    Positioned.fill(
                      child: ColoredBox(
                        color: Colors.black.withValues(alpha: 0.6),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                productData.status == pod.ProductStatus.sold
                                    ? Icons.check_circle_outline
                                    : Icons.schedule_outlined,
                                size: 64,
                                color: Colors.white,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                productData.status == pod.ProductStatus.sold
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
                  if ((productData.imageUrls?.length ?? 0) > 1)
                    Positioned(
                      bottom: 16,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          productData.imageUrls!.length,
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
                        final sellerId = sellerData?.id ?? productData.sellerId;
                        context.push('/profile/user/$sellerId');
                      },
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: const Color(0xFFF3F4F6),
                            backgroundImage: (sellerData?.profileImageUrl !=
                                        null &&
                                    sellerData!.profileImageUrl!.isNotEmpty)
                                ? CachedNetworkImageProvider(
                                    sellerData.profileImageUrl!,
                                  )
                                : (productData.seller?.profileImageUrl !=
                                            null &&
                                        productData.seller!.profileImageUrl!
                                            .isNotEmpty)
                                    ? CachedNetworkImageProvider(
                                        productData.seller!.profileImageUrl!,
                                      )
                                    : null,
                            child: (sellerData?.profileImageUrl == null ||
                                        sellerData!.profileImageUrl!.isEmpty) &&
                                    (productData.seller?.profileImageUrl ==
                                            null ||
                                        productData
                                            .seller!.profileImageUrl!.isEmpty)
                                ? Icon(
                                    Icons.person,
                                    color: Colors.grey.shade500,
                                  )
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Builder(
                            builder: (context) {
                              final location = getProductLocation(productData);
                              final hasLocation = location.isNotEmpty;
                              return Column(
                                crossAxisAlignment: hasLocation
                                    ? CrossAxisAlignment.start
                                    : CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    sellerData?.nickname ??
                                        productData.seller?.nickname ??
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
                                productData.title,
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
                                        productData.category),
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
                                    formatRelativeTime(productData.createdAt),
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
                        if (_isMyProduct(productData))
                          Padding(
                            padding: const EdgeInsets.only(left: 16),
                            child: ProductStatusDropdownWidget(
                              currentStatus: productData.status ??
                                  pod.ProductStatus.selling,
                              onStatusChanged: (newStatus) {
                                _handleStatusChange(productData, newStatus);
                              },
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // 가격
                    Text(
                      '${formatPrice(productData.price)}원',
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
                                getProductConditionLabel(productData.condition),
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
                                getTradeMethodLabel(productData.tradeMethod),
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
                      productData.description,
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
                          label: '조회 ${productData.viewCount ?? 0}',
                        ),
                        ProductInfoItemWidget(
                          icon: Icons.favorite_border,
                          label: '찜 ${productData.favoriteCount ?? 0}',
                        ),
                        ProductInfoItemWidget(
                          icon: Icons.chat_bubble_outline,
                          label: '채팅 ${productData.chatCount ?? 0}',
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
                  final id = int.parse(widget.productId);
                  unawaited(
                    ref
                        .read(productDetailNotifierProvider.notifier)
                        .toggleFavorite(id),
                  );
                },
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite
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
                    if (_isMyProduct(productData)) {
                      // 본인 상품인 경우: 대화중인 채팅방 보기 화면
                      final productId = int.parse(widget.productId);
                      context.push('/chat-room-selection/$productId');
                    } else {
                      // 다른 사람 상품인 경우: 1:1 채팅하기
                      final sellerId = productData.sellerId;
                      context
                          .push('/chat/${widget.productId}?sellerId=$sellerId');
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
                    _isMyProduct(productData) ? '대화중인 채팅방 보기' : '1:1 채팅하기',
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
