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
      ref.read(productDetailNotifierProvider.notifier).loadProductDetail(id);
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
      ProductDetailLoading() => Scaffold(
          appBar: AppBar(),
          body: const GbLoadingView(),
        ),
      ProductDetailError(:final message) => Scaffold(
          appBar: AppBar(),
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
      ProductDetailInitial() => Scaffold(
          appBar: AppBar(),
          body: const GbLoadingView(),
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
      appBar: AppBar(
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
      body: SingleChildScrollView(
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
                                : Colors.white.withOpacity(0.5),
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
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: const Color(0xFFF3F4F6),
                        child: Icon(
                          Icons.person,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                          const SizedBox(height: 2),
                          Text(
                            getProductLocation(productData),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF9CA3AF),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(color: Color(0xFFE5E7EB)),
                  const SizedBox(height: 20),
                  // 상품명
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
                        getProductCategoryLabel(productData.category),
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
                  const SizedBox(height: 20),
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
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
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
                  ref
                      .read(productDetailNotifierProvider.notifier)
                      .toggleFavorite(id);
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
              // 1:1 채팅하기 버튼
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    context.push('/chat/${widget.productId}');
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
                  child: const Text(
                    '1:1 채팅하기',
                    style: TextStyle(
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
