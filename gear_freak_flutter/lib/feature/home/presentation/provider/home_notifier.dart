import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import '../../domain/usecase/get_recent_products_usecase.dart';

/// 홈 상태
class HomeState {
  final List<pod.Product> products;
  final List<pod.ProductCategory> categories;
  final bool isLoading;
  final String? error;

  const HomeState({
    this.products = const [],
    this.categories = const [],
    this.isLoading = false,
    this.error,
  });

  HomeState copyWith({
    List<pod.Product>? products,
    List<pod.ProductCategory>? categories,
    bool? isLoading,
    String? error,
  }) {
    return HomeState(
      products: products ?? this.products,
      categories: categories ?? this.categories,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

/// 홈 Notifier
class HomeNotifier extends StateNotifier<HomeState> {
  final GetRecentProductsUseCase getRecentProductsUseCase;

  HomeNotifier(this.getRecentProductsUseCase) : super(const HomeState());

  /// 홈 데이터 로드
  Future<void> loadHomeData() async {
    state = state.copyWith(isLoading: true, error: null);

    final productsResult = await getRecentProductsUseCase(null);

    productsResult.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
          categories: pod.ProductCategory.values, // 카테고리는 고정값
        );
      },
      (products) {
        state = state.copyWith(
          products: products,
          categories: pod.ProductCategory.values, // 카테고리는 고정값
          isLoading: false,
        );
      },
    );
  }
}
