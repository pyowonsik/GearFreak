import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../di/product_providers.dart';
import '../provider/product_state.dart';
import '../widget/product_card_widget.dart';

class AllProductsScreen extends ConsumerStatefulWidget {
  const AllProductsScreen({super.key});

  @override
  ConsumerState<AllProductsScreen> createState() => _AllProductsScreenState();
}

class _AllProductsScreenState extends ConsumerState<AllProductsScreen> {
  String _selectedSort = '최신순';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(productNotifierProvider.notifier).loadAllProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final productState = ref.watch(productNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('전체 상품'),
        actions: [
          PopupMenuButton<String>(
            initialValue: _selectedSort,
            onSelected: (value) {
              setState(() {
                _selectedSort = value;
              });
              // TODO: 정렬 기능 구현
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: '최신순',
                child: Text('최신순'),
              ),
              const PopupMenuItem(
                value: '인기순',
                child: Text('인기순'),
              ),
              const PopupMenuItem(
                value: '낮은 가격순',
                child: Text('낮은 가격순'),
              ),
              const PopupMenuItem(
                value: '높은 가격순',
                child: Text('높은 가격순'),
              ),
            ],
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Text(
                    _selectedSort,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_drop_down, size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
      body: switch (productState) {
        ProductLoading() => const Center(child: CircularProgressIndicator()),
        ProductError(:final message) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  message,
                  style: const TextStyle(fontSize: 16, color: Colors.red),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    ref
                        .read(productNotifierProvider.notifier)
                        .loadAllProducts();
                  },
                  child: const Text('다시 시도'),
                ),
              ],
            ),
          ),
        ProductLoaded(:final products) => products.isEmpty
            ? const Center(
                child: Text(
                  '등록된 상품이 없습니다',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  return ProductCardWidget(
                    product: products[index],
                  );
                },
              ),
        ProductInitial() => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}
