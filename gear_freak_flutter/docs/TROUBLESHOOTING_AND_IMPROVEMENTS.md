# 트러블슈팅 & 개선사항 정리

## 📋 목차

1. [StateProvider를 이용한 이벤트 브로드캐스팅 패턴](#1-stateprovider를-이용한-이벤트-브로드캐스팅-패턴)
2. [페이지네이션 & 무한 스크롤 Mixin 공통화](#2-페이지네이션--무한-스크롤-mixin-공통화)
3. [낙관적 업데이트 (Optimistic Update) 패턴](#3-낙관적-업데이트-optimistic-update-패턴)
4. [Consumer & CachedNetworkImage를 활용한 성능 최적화](#4-consumer--cachednetworkimage를-활용한-성능-최적화)
5. [프로필 이미지 S3 관리 개선](#5-프로필-이미지-s3-관리-개선)
6. [기타 트러블슈팅](#6-기타-트러블슈팅)

---

## 1. StateProvider를 이용한 이벤트 브로드캐스팅 패턴

### 📌 개요

**StateProvider를 이용한 이벤트 브로드캐스팅 패턴**은 하나의 이벤트를 여러 Provider에 전파하여 상태를 동기화하는 Riverpod 패턴입니다.

이 패턴은 **단일 소스(Single Source of Truth)** 원칙을 따르며, 중앙에서 이벤트를 발행하고 각 Provider가 자동으로 반응하도록 설계됩니다.

### ❌ 문제 상황

여러 Provider에 직접 접근하여 상태를 업데이트하는 방식:

```dart
// ❌ 나쁜 예: 각 Provider에 직접 접근
void deleteProduct(int productId) {
  // 모든 Provider를 일일이 호출해야 함
  ref.read(homeProductsNotifierProvider.notifier).removeProduct(productId);
  ref.read(allProductsNotifierProvider.notifier).removeProduct(productId);

  // 카테고리별 Provider도 모두 호출
  for (final category in ProductCategory.values) {
    try {
      ref.read(categoryProductsNotifierProvider(category).notifier)
          .removeProduct(productId);
    } catch (e) {
      // Provider가 없을 수 있어서 try-catch 필요
    }
  }
}
```

**문제점:**
- **확장성 부족**: Provider가 늘어날수록 수정 포인트 증가
- **의존성 증가**: UI가 모든 목록 Provider를 알아야 함
- **예외 처리 복잡**: 화면이 열려있지 않을 때 try-catch 필요
- **중복 코드**: 삭제 로직이 여러 곳에 분산
- **유지보수 어려움**: 새 Provider 추가 시마다 코드 수정 필요

### ✅ 해결 방법

**핵심 아이디어:**
- 중앙에서 이벤트를 발행하는 `StateProvider` 생성
- 각 목록 Provider가 `ref.listen`으로 이벤트 감지
- 이벤트 발생 시 자동으로 상태 업데이트

**구조:**
```
삭제 성공
  ↓
deletedProductIdProvider에 productId 발행
  ↓
각 목록 Provider가 자동 감지 (ref.listen)
  ↓
자동으로 목록에서 제거
```

### 🔧 구현 세부사항

#### 1. 이벤트 Provider 생성

```dart
/// 삭제된 상품 ID 이벤트 Provider (단일 소스)
/// 상품 삭제 시 이 Provider에 productId를 설정하면
/// 모든 목록 Provider가 자동으로 해당 상품을 제거합니다.
final deletedProductIdProvider = StateProvider<int?>((ref) => null);

/// 수정된 상품 이벤트 Provider (단일 소스)
/// 상품 수정 시 이 Provider에 product를 설정하면
/// 모든 목록 Provider가 자동으로 해당 상품을 업데이트합니다.
final updatedProductProvider = StateProvider<pod.Product?>((ref) => null);
```

#### 2. 이벤트 발행 (삭제 성공 시)

```dart
/// ProductDetailNotifier
Future<bool> deleteProduct(int productId) async {
  final result = await deleteProductUseCase(productId);

  return result.fold(
    (failure) {
      debugPrint('상품 삭제 실패: ${failure.message}');
      return false;
    },
    (_) {
      debugPrint('상품 삭제 성공: $productId');

      // ✅ 삭제 성공 시 이벤트 발행
      ref.read(deletedProductIdProvider.notifier).state = productId;

      // 이벤트 처리 후 초기화 (다음 삭제를 위해)
      Future.microtask(() {
        ref.read(deletedProductIdProvider.notifier).state = null;
      });

      return true;
    },
  );
}
```

#### 3. 이벤트 수신 (각 목록 Provider)

```dart
/// ProductNotifier
class ProductNotifier extends StateNotifier<ProductState> {
  ProductNotifier(
    this.ref,
    this.getPaginatedProductsUseCase,
    this.getProductDetailUseCase,
  ) : super(const ProductInitial()) {
  
    // ✅ 삭제 이벤트 감지하여 자동으로 목록에서 제거
    ref.listen<int?>(deletedProductIdProvider, (previous, next) {
      if (next != null) {
        _removeProduct(next);
      }
    });

    // ✅ 수정 이벤트 감지하여 자동으로 목록에서 업데이트
    ref.listen<pod.Product?>(updatedProductProvider, (previous, next) {
      if (next != null) {
        _updateProduct(next);
      }
    });
  }

  /// 목록에서 상품 제거 (삭제 이벤트에 의해 자동 호출)
  void _removeProduct(int productId) {
    final currentState = state;
    if (currentState is ProductPaginatedLoaded) {
      final updatedProducts = currentState.products
          .where((product) => product.id != productId)
          .toList();

      // 상품이 실제로 제거되었는지 확인
      if (updatedProducts.length < currentState.products.length) {
        debugPrint('🗑️ [ProductNotifier] 상품 제거: productId=$productId');

        // totalCount도 감소
        final updatedTotalCount =
            (currentState.pagination.totalCount ?? 0) - 1;

        state = ProductPaginatedLoaded(
          products: updatedProducts,
          pagination: currentState.pagination.copyWith(
            totalCount: updatedTotalCount.clamp(0, double.infinity).toInt(),
            hasMore: updatedProducts.length < updatedTotalCount,
          ),
          category: currentState.category,
          sortBy: currentState.sortBy,
        );
      }
    }
  }
}
```

### ✅ 장점

1. **중앙 집중 관리**: 이벤트를 한 곳에서 관리
2. **자동 반응**: 새 Provider 추가 시 자동 적용
3. **UI 단순화**: 삭제 API만 호출하면 됨
4. **유지보수 용이**: 수정 포인트 최소화
5. **확장성**: Provider가 10개, 20개가 되어도 동일한 코드
6. **타입 안전성**: Riverpod의 타입 시스템 활용

### ⚠️ 주의사항

1. **이벤트 초기화**: 이벤트 발행 후 반드시 초기화 (`Future.microtask` 사용)
2. **null 체크**: 이벤트 수신 시 반드시 null 체크
3. **Provider 생명주기**: `autoDispose` Provider의 경우 자동으로 정리됨
4. **순환 참조 방지**: Provider 간 순환 참조 주의

### 📍 사용 사례

- 상품 삭제 시 모든 목록에서 제거
- 상품 수정 시 모든 목록에서 업데이트
- 찜 추가/제거 시 모든 목록에서 반영
- 프로필 통계 자동 갱신

---

## 2. 페이지네이션 & 무한 스크롤 Mixin 공통화

### 📌 개요

**PaginationScrollMixin**은 페이지네이션과 무한 스크롤 로직을 공통화하여 코드 중복을 제거하고 일관된 사용자 경험을 제공하는 Mixin입니다.

### ❌ 문제 상황

기존에는 각 화면마다 무한 스크롤 로직을 중복 구현:

```dart
// ❌ 나쁜 예: 각 화면마다 중복 구현
class _HomeScreenState extends ConsumerState<HomeScreen> {
  ScrollController? _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController!.addListener(_onScroll);
  }

  void _onScroll() {
    // 스크롤 감지 로직
    // 디바운스 로직
    // 페이지네이션 체크 로직
    // ... 중복 코드
  }

  @override
  void dispose() {
    _scrollController?.dispose();
    super.dispose();
  }
}
```

**문제점:**
- 코드 중복
- 일관성 부족
- 유지보수 어려움
- 버그 발생 가능성 증가

### ✅ 해결 방법

**PaginationScrollMixin**을 사용하여 공통 로직 추출:

```dart
/// 페이지네이션 무한 스크롤을 위한 Mixin
mixin PaginationScrollMixin<T extends StatefulWidget> on State<T> {
  ScrollController? _scrollController;
  VoidCallback? _onLoadMore;
  pod.PaginationDto? Function()? _getPagination;
  bool Function()? _isLoading;
  String? _screenName;
  bool _hasLoggedNoMoreData = false;
  Timer? _debounceTimer;

  /// 페이지네이션 스크롤 초기화
  void initPaginationScroll({
    required VoidCallback onLoadMore,
    required pod.PaginationDto? Function() getPagination,
    required bool Function() isLoading,
    String? screenName,
  }) {
    _onLoadMore = onLoadMore;
    _getPagination = getPagination;
    _isLoading = isLoading;
    _screenName = screenName;
    _scrollController = ScrollController();
    _scrollController!.addListener(_onScroll);
  }

  /// 스크롤 이벤트 핸들러
  void _onScroll() {
    if (_scrollController == null || !_scrollController!.hasClients) {
      return;
    }

    final position = _scrollController!.position;

    // 스크롤 가능한 상태인지 확인
    if (!position.hasContentDimensions) {
      return;
    }

    // 스크롤이 하단 300px 이내에 도달하면 다음 페이지 로드
    final threshold = position.maxScrollExtent - 300;
    if (position.pixels >= threshold && position.pixels > 0) {
      // 디바운스: 이전 타이머 취소
      _debounceTimer?.cancel();

      // 300ms 후에 실행 (디바운스)
      _debounceTimer = Timer(const Duration(milliseconds: 300), () {
        final pagination = _getPagination?.call();
        final isLoading = _isLoading?.call() ?? false;

        // 로딩 중이 아니고, 더 불러올 데이터가 있을 때만 실행
        if (!isLoading && pagination != null && (pagination.hasMore ?? false)) {
          _hasLoggedNoMoreData = false;
          _onLoadMore?.call();
        } else if (pagination != null &&
            !(pagination.hasMore ?? false) &&
            !_hasLoggedNoMoreData) {
          _hasLoggedNoMoreData = true;
          debugPrint('✅ [$_screenName] 더 이상 불러올 데이터가 없습니다.');
        }
      });
    }
  }

  /// 스크롤 컨트롤러 정리
  void disposePaginationScroll() {
    _debounceTimer?.cancel();
    _debounceTimer = null;
    _scrollController?.removeListener(_onScroll);
    _scrollController?.dispose();
    _scrollController = null;
    _onLoadMore = null;
    _getPagination = null;
    _isLoading = null;
    _screenName = null;
    _hasLoggedNoMoreData = false;
  }
}
```

### 🔧 사용 예시

```dart
class _HomeScreenState extends ConsumerState<HomeScreen>
    with PaginationScrollMixin {
  @override
  void initState() {
    super.initState();
    initPaginationScroll(
      onLoadMore: () {
        ref.read(homeProductsNotifierProvider.notifier).loadMoreProducts();
      },
      getPagination: () {
        final state = ref.read(homeProductsNotifierProvider);
        if (state is ProductPaginatedLoaded) {
          return state.pagination;
        }
        return null;
      },
      isLoading: () {
        final state = ref.read(homeProductsNotifierProvider);
        return state is ProductPaginatedLoadingMore;
      },
      screenName: 'HomeScreen',
    );
  }

  @override
  void dispose() {
    disposePaginationScroll();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController, // Mixin에서 제공
      // ...
    );
  }
}
```

### ✅ 장점

1. **코드 중복 제거**: 한 번 구현하여 여러 화면에서 재사용
2. **일관된 동작**: 모든 화면에서 동일한 스크롤 동작
3. **디바운스 처리**: 불필요한 API 호출 방지
4. **자동 정리**: dispose 시 자동으로 리소스 정리
5. **디버깅 용이**: 로그를 통한 스크롤 상태 추적

### ⚠️ 주의사항

1. **dispose 호출**: 반드시 `disposePaginationScroll()` 호출
2. **상태 체크**: `getPagination`과 `isLoading`에서 올바른 상태 반환
3. **스크롤 컨트롤러**: `scrollController`를 ListView에 연결

---

## 3. 낙관적 업데이트 (Optimistic Update) 패턴

### 📌 개요

**낙관적 업데이트**는 서버 응답을 기다리지 않고 UI를 먼저 업데이트하여 사용자 경험을 개선하는 패턴입니다.

### ❌ 문제 상황

기존에는 서버 응답을 기다린 후 UI 업데이트:

```dart
// ❌ 나쁜 예: 서버 응답 대기 후 UI 업데이트
Future<void> toggleFavorite(int productId) async {
  // 서버 응답 대기 (느림)
  final result = await toggleFavoriteUseCase(productId);
  
  result.fold(
    (failure) {
      // 실패 처리
    },
    (isFavorite) {
      // 성공 후 UI 업데이트 (사용자가 느림을 느낌)
      state = currentState.copyWith(isFavorite: isFavorite);
    },
  );
}
```

**문제점:**
- 사용자가 버튼 클릭 후 반응이 느림
- 네트워크 지연 시 사용자 경험 저하
- 불필요한 대기 시간

### ✅ 해결 방법

**낙관적 업데이트** 적용:

```dart
/// ProductDetailNotifier
Future<void> toggleFavorite(int productId) async {
  final currentState = state;
  if (currentState is! ProductDetailLoaded) return;

  // ✅ 낙관적 업데이트: UI를 먼저 업데이트
  final previousIsFavorite = currentState.isFavorite;
  state = currentState.copyWith(
    isFavorite: !previousIsFavorite,
  );

  // 서버 요청
  final result = await toggleFavoriteUseCase(productId);

  await result.fold(
    (failure) {
      // 실패 시 이전 상태로 복원
      state = currentState.copyWith(isFavorite: previousIsFavorite);
      debugPrint('찜 상태 변경 실패: ${failure.message}');
    },
    (isFavorite) async {
      // 성공 시 상품 정보도 업데이트 (favoriteCount 변경)
      final productResult = await getProductDetailUseCase(productId);
      productResult.fold(
        (failure) {
          debugPrint('상품 정보를 불러오는데 실패했습니다: ${failure.message}');
        },
        (updatedProduct) {
          state = currentState.copyWith(
            product: updatedProduct,
            isFavorite: isFavorite,
          );
          // 찜 토글 성공 시 이벤트 발행 (ProfileNotifier가 stats 갱신)
          ref.read(updatedProductProvider.notifier).state = updatedProduct;
          Future.microtask(() {
            ref.read(updatedProductProvider.notifier).state = null;
          });
        },
      );
    },
  );
}
```

### ✅ 장점

1. **즉각적인 반응**: 사용자가 버튼 클릭 시 즉시 UI 업데이트
2. **향상된 UX**: 네트워크 지연을 느끼지 않음
3. **에러 처리**: 실패 시 자동으로 이전 상태 복원
4. **일관성**: 성공 시 최신 데이터로 동기화

### ⚠️ 주의사항

1. **상태 복원**: 실패 시 반드시 이전 상태로 복원
2. **에러 처리**: 사용자에게 실패 알림 제공
3. **동시 요청**: 동일한 작업의 중복 요청 방지

### 📍 사용 사례

- 찜 추가/제거
- 상품 상태 변경 (판매중 → 거래완료)
- 좋아요/북마크 기능

---

## 4. Consumer & CachedNetworkImage를 활용한 성능 최적화

### 📌 개요

**Consumer**와 **CachedNetworkImage**를 활용하여 불필요한 리빌드를 방지하고 이미지 로딩 성능을 최적화합니다.

### ❌ 문제 상황

기존에는 전체 위젯 트리가 리빌드되거나 이미지가 매번 다시 로드:

```dart
// ❌ 나쁜 예: 전체 위젯 트리 리빌드
class ProductCard extends StatelessWidget {
  final Product product;
  
  @override
  Widget build(BuildContext context) {
    // product 상태가 변경되면 전체 위젯이 리빌드됨
    return Card(
      child: Column(
        children: [
          Image.network(product.imageUrl), // 매번 다시 로드
          Text(product.title),
          // ...
        ],
      ),
    );
  }
}
```

**문제점:**
- 불필요한 리빌드
- 이미지 재로딩
- 성능 저하
- 메모리 낭비

### ✅ 해결 방법

#### 1. Consumer를 활용한 선택적 리빌드

```dart
/// ProductCardWidget
class ProductCardWidget extends ConsumerWidget {
  final pod.Product product;

  const ProductCardWidget({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ✅ Consumer를 사용하여 필요한 부분만 리빌드
    return Card(
      child: Column(
        children: [
          // 이미지는 한 번만 로드
          CachedNetworkImage(
            imageUrl: product.imageUrls?.first ?? '',
            width: 100,
            height: 100,
            fit: BoxFit.cover,
            placeholder: (context, url) => const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF9CA3AF)),
              ),
            ),
            errorWidget: (context, url, error) => const Center(
              child: Icon(
                Icons.shopping_bag,
                size: 48,
                color: Color(0xFF9CA3AF),
              ),
            ),
          ),
          Text(product.title),
          // 찜 상태만 선택적으로 리빌드
          Consumer(
            builder: (context, ref, child) {
              final favoriteState = ref.watch(
                productDetailNotifierProvider(product.id.toString()),
              );
              if (favoriteState is ProductDetailLoaded) {
                return IconButton(
                  icon: Icon(
                    favoriteState.isFavorite
                        ? Icons.favorite
                        : Icons.favorite_border,
                  ),
                  onPressed: () {
                    ref
                        .read(productDetailNotifierProvider(
                                product.id.toString())
                            .notifier)
                        .toggleFavorite(product.id!);
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }
}
```

#### 2. CachedNetworkImage를 활용한 이미지 캐싱

```dart
CachedNetworkImage(
  imageUrl: product.imageUrls?.first ?? '',
  width: 100,
  height: 100,
  fit: BoxFit.cover,
  // ✅ 플레이스홀더: 로딩 중 표시
  placeholder: (context, url) => const Center(
    child: CircularProgressIndicator(
      strokeWidth: 2,
      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF9CA3AF)),
    ),
  ),
  // ✅ 에러 위젯: 로딩 실패 시 표시
  errorWidget: (context, url, error) => const Center(
    child: Icon(
      Icons.shopping_bag,
      size: 48,
      color: Color(0xFF9CA3AF),
    ),
  ),
  // ✅ 메모리 캐시: 메모리에 이미지 저장
  // ✅ 디스크 캐시: 디스크에 이미지 저장
  // ✅ 자동 재시도: 네트워크 오류 시 자동 재시도
)
```

### ✅ 장점

1. **성능 향상**: 불필요한 리빌드 방지
2. **이미지 캐싱**: 한 번 로드한 이미지는 캐시에서 사용
3. **메모리 효율**: 필요한 부분만 리빌드
4. **사용자 경험**: 빠른 반응 속도
5. **네트워크 절약**: 이미지 재다운로드 방지

### ⚠️ 주의사항

1. **Consumer 범위**: 필요한 최소 범위에만 사용
2. **캐시 관리**: 필요시 캐시 크기 제한 설정
3. **메모리 관리**: 큰 이미지의 경우 메모리 주의

---

## 5. 프로필 이미지 S3 관리 개선

### 📌 개요

프로필 이미지 업데이트 시 DB와 S3를 동기화하여 불필요한 파일이 S3에 쌓이지 않도록 개선했습니다.

### ❌ 문제 상황

기존에는 DB에서만 삭제하고 S3에서는 삭제하지 않음:

```dart
// ❌ 나쁜 예: DB에서만 삭제
Future<void> updateProfile({
  required String nickname,
  bool removedExistingImage = false,
}) async {
  String? profileImageUrl;
  if (removedExistingImage) {
    profileImageUrl = null; // DB에만 null 저장
    // S3에서 파일 삭제 안 함 ❌
  }
  
  final request = pod.UpdateUserProfileRequestDto(
    nickname: nickname,
    profileImageUrl: profileImageUrl,
  );
  
  await updateUserProfileUseCase(request);
  // S3 파일이 계속 쌓임
}
```

**문제점:**
- DB에는 null인데 S3에는 파일이 남아있음
- 새 이미지로 교체 시 기존 이미지가 S3에 계속 쌓임
- S3 스토리지 비용 증가
- 불필요한 파일 관리 어려움

### ✅ 해결 방법

#### 1. 기존 이미지 파일 키 추출 및 삭제

```dart
/// ProfileNotifier
Future<void> updateProfile({
  required String nickname,
  bool removedExistingImage = false,
}) async {
  final currentState = state;
  if (currentState is! ProfileLoaded) {
    return;
  }

  try {
    // ✅ 기존 이미지 URL에서 파일 키 추출 (S3 삭제용)
    String? existingImageFileKey;
    final s3BaseUrl = dotenv.env['S3_PUBLIC_BASE_URL']!;

    // 기존 이미지가 있고, 다음 중 하나의 경우에 삭제:
    // 1. removedExistingImage = true (사용자가 명시적으로 삭제)
    // 2. uploadedFileKey가 있고 기존 이미지가 있음 (새 이미지로 교체)
    if (currentState.user.profileImageUrl != null &&
        currentState.user.profileImageUrl!.isNotEmpty) {
      final shouldDeleteExistingImage = removedExistingImage ||
          (currentState.uploadedFileKey != null); // 새 이미지로 교체되는 경우

      if (shouldDeleteExistingImage) {
        final existingImageUrl = currentState.user.profileImageUrl!;
        if (existingImageUrl.startsWith(s3BaseUrl)) {
          // URL에서 파일 키 추출
          existingImageFileKey = existingImageUrl.substring(s3BaseUrl.length);
          if (existingImageFileKey.startsWith('/')) {
            existingImageFileKey = existingImageFileKey.substring(1);
          }
        }
      }
    }

    // 업로드된 이미지 URL 생성
    String? profileImageUrl;
    if (removedExistingImage) {
      profileImageUrl = null;
    } else if (currentState.uploadedFileKey != null) {
      profileImageUrl = '$s3BaseUrl/${currentState.uploadedFileKey}';
    } else if (currentState.user.profileImageUrl != null &&
        currentState.user.profileImageUrl!.isNotEmpty) {
      profileImageUrl = currentState.user.profileImageUrl;
    }

    // UpdateUserProfileRequestDto 생성
    final request = pod.UpdateUserProfileRequestDto(
      nickname: nickname,
      profileImageUrl: profileImageUrl,
    );

    // 업데이트 시작
    state = ProfileUpdating(
      user: currentState.user,
      uploadedFileKey: currentState.uploadedFileKey,
      stats: currentState.stats,
    );

    // UseCase 호출
    final result = await updateUserProfileUseCase(request);

    await result.fold(
      (failure) {
        state = ProfileUpdateError(
          user: currentState.user,
          uploadedFileKey: currentState.uploadedFileKey,
          stats: currentState.stats,
          error: failure.message,
        );
      },
      (updatedUser) async {
        // ✅ 프로필 업데이트 성공 후, 기존 이미지가 제거되거나 교체된 경우 S3에서도 삭제
        if (existingImageFileKey != null) {
          try {
            debugPrint('🗑️ 기존 프로필 이미지 S3 삭제 시작: $existingImageFileKey');
            await deleteImageUseCase(
              DeleteImageParams(
                fileKey: existingImageFileKey,
                bucketType: 'public',
              ),
            );
            debugPrint('✅ 기존 프로필 이미지 S3 삭제 성공: $existingImageFileKey');
          } catch (e) {
            // S3 삭제 실패해도 프로필 업데이트는 성공했으므로 계속 진행
            debugPrint('❌ 기존 프로필 이미지 S3 삭제 실패: $e');
          }
        }

        state = ProfileUpdated(
          user: updatedUser,
          stats: currentState.stats,
        );
      },
    );
  } catch (e) {
    state = ProfileUpdateError(
      user: currentState.user,
      uploadedFileKey: currentState.uploadedFileKey,
      stats: currentState.stats,
      error: '프로필 업데이트 중 오류가 발생했습니다: $e',
    );
  }
}
```

#### 2. 새 이미지 업로드 시 기존 업로드 파일 삭제

```dart
/// ProfileNotifier
Future<void> uploadProfileImage({
  required File imageFile,
  String prefix = 'profile',
  String bucketType = 'public',
}) async {
  final currentState = state;
  if (currentState is! ProfileLoaded) {
    return;
  }

  // ✅ 기존에 업로드된 파일 키 저장 (업로드 실패 시 복원용)
  final previousUploadedFileKey = currentState.uploadedFileKey;

  try {
    // ✅ 1. 기존에 업로드된 파일이 있으면 먼저 삭제 (S3 정리)
    if (previousUploadedFileKey != null) {
      try {
        await deleteImageUseCase(
          DeleteImageParams(
            fileKey: previousUploadedFileKey,
            bucketType: bucketType,
          ),
        );
      } catch (e) {
        // 삭제 실패해도 계속 진행 (로깅만)
        debugPrint('⚠️ 기존 업로드 파일 S3 삭제 실패 (계속 진행): $previousUploadedFileKey - $e');
      }
    }

    // 2. 새 파일 업로드
    // ...
  } catch (e) {
    // 에러 처리
  }
}
```

### ✅ 장점

1. **DB와 S3 동기화**: DB 업데이트 시 S3도 함께 관리
2. **스토리지 비용 절감**: 불필요한 파일 자동 삭제
3. **일관성 유지**: DB와 S3 상태 일치
4. **자동 정리**: 사용자가 신경 쓸 필요 없음

### ⚠️ 주의사항

1. **에러 처리**: S3 삭제 실패해도 프로필 업데이트는 성공 처리
2. **파일 키 추출**: URL에서 정확한 파일 키 추출
3. **트랜잭션**: DB 업데이트 성공 후 S3 삭제 (순서 중요)

---

## 6. 기타 트러블슈팅

### 6.1 RefreshIndicator 동작 개선

**문제:** `RefreshIndicator`가 아이템이 적거나 로딩/에러 상태일 때 동작하지 않음

**해결:**
```dart
ListView.builder(
  controller: scrollController,
  physics: const AlwaysScrollableScrollPhysics(), // ✅ 항상 스크롤 가능하도록 설정
  // ...
)
```

### 6.2 채팅방 중복 생성 방지

**문제:** 같은 `userId`와 `productId` 조합의 채팅방이 계속 생성됨

**원인:** `targetUserId`가 `null`로 전달되어 기존 채팅방을 찾지 못함

**해결:**
- `product_detail_screen.dart`에서 `sellerId`를 `targetUserId`로 전달
- 백엔드에서 기존 1:1 채팅방 조회 로직 개선

### 6.3 저장 버튼 로딩 상태 개선

**문제:** 이미지 업로드 중에도 저장 버튼에 로딩 표시

**해결:**
```dart
// ✅ 저장 중일 때만 로딩 표시
final isUpdating = profileState is ProfileUpdating;

TextButton(
  onPressed: isUpdating ? null : _saveProfile,
  child: isUpdating
      ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        )
      : const Text('완료'),
)
```

---

## 📚 참고 자료

- [Riverpod 공식 문서](https://riverpod.dev/)
- [CachedNetworkImage 패키지](https://pub.dev/packages/cached_network_image)
- [Flutter 성능 최적화 가이드](https://docs.flutter.dev/perf/best-practices)

---

## 요약

이 문서에서 다룬 주요 개선사항:

1. ✅ **StateProvider 브로드캐스팅 패턴**: 여러 Provider 간 상태 동기화
2. ✅ **PaginationScrollMixin**: 페이지네이션 로직 공통화
3. ✅ **낙관적 업데이트**: 사용자 경험 개선
4. ✅ **Consumer & CachedNetworkImage**: 성능 최적화
5. ✅ **S3 관리 개선**: DB와 S3 동기화
6. ✅ **기타 트러블슈팅**: 다양한 UI/UX 개선

이러한 패턴과 개선사항들을 통해 코드의 재사용성, 유지보수성, 성능을 크게 향상시켰습니다.

