# Flutter에서 낙관적 UI 업데이트(Optimistic UI Update) 구현하기

## 들어가며

중고거래 앱을 개발하면서 사용자 경험(UX)을 개선하기 위해 고민했던 부분이 있습니다. 바로 **"찜 버튼을 눌렀을 때 반응이 느리다"**는 문제였습니다.

기존 방식은 이랬습니다:

```
사용자가 찜 버튼 클릭 → 서버 요청 → 서버 응답 대기(0.5~2초) → UI 업데이트
```

네트워크 상태에 따라 0.5초에서 2초까지 버튼이 반응하지 않는 것처럼 보였고, 사용자는 "버튼이 안 눌렸나?" 싶어 여러 번 탭하는 경우도 있었습니다.

### 실제로 겪었던 문제들

1. **반응 지연**: 찜 버튼을 눌러도 하트가 바로 안 바뀜
2. **중복 요청**: 사용자가 반응이 없다고 생각해 여러 번 탭
3. **불안한 느낌**: "내 요청이 제대로 갔나?" 하는 불안감
4. **앱이 느리다는 인식**: 실제로는 서버가 느린 건데, 앱 탓으로 느껴짐

이 문제를 해결하기 위해 **낙관적 UI 업데이트(Optimistic UI Update)** 패턴을 도입했습니다.

### 기술 스택
- **Frontend**: Flutter 3.24+, Riverpod 2.6
- **Backend**: Serverpod
- **Architecture**: Clean Architecture + StateNotifier

---

## 낙관적 UI 업데이트란?

**"서버 응답을 기다리지 않고, 사용자의 액션을 즉시 UI에 반영한 뒤, 서버 응답에 따라 조정하는 방식"**입니다.

이름이 "낙관적(Optimistic)"인 이유는, **"이 요청은 성공할 거야"**라고 낙관적으로 가정하고 먼저 UI를 바꾸기 때문입니다.

### 왜 "낙관적"이라고 할까?

일반적인 서버 요청의 성공률을 생각해보면:
- 찜 토글: 99% 이상 성공
- 상태 변경: 99% 이상 성공
- 댓글 작성: 98% 이상 성공

**대부분의 요청은 성공합니다.** 그런데 왜 1% 미만의 실패 가능성 때문에 99%의 사용자를 기다리게 할까요?

낙관적 업데이트는 이 관점을 뒤집습니다:
> "일단 성공한다고 가정하고 UI를 바꾸자. 만약 실패하면 그때 되돌리면 된다."

### 기존 방식 vs 낙관적 업데이트

**기존 방식 (Pessimistic) - 비관적 접근**
```
[사용자 클릭] → [서버 요청] → [응답 대기...] → [UI 업데이트]
                              ↑
                         사용자가 기다림 (0.5~2초)
```

비관적 방식은 "서버 응답이 올 때까지 아무것도 확신할 수 없다"는 태도입니다. 안전하지만, 사용자 경험이 좋지 않습니다.

**낙관적 업데이트 (Optimistic) - 낙관적 접근**
```
[사용자 클릭] → [UI 즉시 업데이트] → [서버 요청] → [성공: 유지 / 실패: 롤백]
                    ↑
               사용자는 즉시 반응을 봄 (0ms)
```

낙관적 방식은 "대부분 성공하니까 일단 반영하자"는 태도입니다. 사용자는 즉각적인 피드백을 받고, 드물게 실패하면 원래대로 돌립니다.

### 언제 사용하면 좋을까?

모든 상황에 낙관적 업데이트가 적합한 것은 아닙니다.

| 적합한 경우 | 부적합한 경우 |
|------------|-------------|
| 좋아요/찜 토글 | 결제 처리 |
| 댓글 작성 | 중요한 데이터 삭제 |
| 상태 변경 (판매중 → 예약중) | 계좌 이체 |
| 메시지 전송 | 본인 인증 |
| 프로필 수정 | 비밀번호 변경 |

**적합한 경우의 공통점:**
- 실패해도 크게 문제되지 않음
- 롤백이 가능함
- 실패 확률이 매우 낮음
- 즉각적인 피드백이 UX에 중요함

**부적합한 경우의 공통점:**
- 되돌릴 수 없는 액션 (결제, 송금)
- 실패 시 심각한 문제 발생
- 보안이 중요한 액션
- 정확한 결과 확인이 필수인 경우

---

## 구현 예시 1: 찜(좋아요) 토글

가장 대표적인 낙관적 UI 업데이트 사례입니다. 인스타그램, 트위터, 당근마켓 등 대부분의 앱에서 이 패턴을 사용합니다.

### 사용자 시나리오

1. 사용자가 상품 상세 화면에서 빈 하트(♡)를 탭
2. **즉시** 하트가 채워짐(♥) - 사용자는 바로 피드백을 받음
3. 백그라운드에서 서버에 "찜 추가" 요청
4. 서버 응답:
   - 성공: 아무 일도 안 함 (이미 UI가 맞으니까)
   - 실패: 하트를 다시 비움(♡) + 에러 메시지 표시

### State 정의

먼저 상품 상세 화면의 상태를 정의합니다. `isFavorite` 필드가 찜 상태를 나타냅니다.

```dart
/// 상품 상세 State
/// Sealed class를 사용하여 모든 가능한 상태를 컴파일 타임에 보장
sealed class ProductDetailState {
  const ProductDetailState();
}

/// 초기 상태 - 아직 데이터를 로드하지 않음
class ProductDetailInitial extends ProductDetailState {
  const ProductDetailInitial();
}

/// 로딩 중 - 서버에서 데이터를 가져오는 중
class ProductDetailLoading extends ProductDetailState {
  const ProductDetailLoading();
}

/// 로드 완료 - 상품 정보가 있는 상태
class ProductDetailLoaded extends ProductDetailState {
  const ProductDetailLoaded({
    required this.product,
    required this.seller,
    required this.isFavorite,  // 👈 찜 상태
  });

  final Product product;
  final User? seller;
  final bool isFavorite;

  /// copyWith: 불변 객체의 일부만 변경한 새 객체 생성
  /// 낙관적 업데이트의 핵심!
  ProductDetailLoaded copyWith({
    Product? product,
    User? seller,
    bool? isFavorite,
  }) {
    return ProductDetailLoaded(
      product: product ?? this.product,
      seller: seller ?? this.seller,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}

/// 에러 상태
class ProductDetailError extends ProductDetailState {
  const ProductDetailError(this.message);
  final String message;
}
```

**왜 `copyWith`가 중요할까요?**

Flutter에서 상태 관리의 기본 원칙은 **불변성(Immutability)**입니다. 상태를 직접 수정하지 않고, 새로운 상태 객체를 만들어서 교체합니다.

```dart
// ❌ 잘못된 방식 - 직접 수정
state.isFavorite = true;

// ✅ 올바른 방식 - 새 객체 생성
state = state.copyWith(isFavorite: true);
```

이렇게 하면:
1. 이전 상태 객체가 그대로 남아있어 롤백 가능
2. 상태 변화를 추적하기 쉬움
3. 예기치 않은 부작용 방지

### Notifier 구현 - 핵심 로직

이제 실제로 찜 토글을 구현하는 Notifier 코드입니다. 주석으로 각 단계를 상세히 설명했습니다.

```dart
class ProductDetailNotifier extends StateNotifier<ProductDetailState> {
  ProductDetailNotifier(
    this.ref,
    this.toggleFavoriteUseCase,
    this.getProductDetailUseCase,
  ) : super(const ProductDetailInitial());

  final Ref ref;
  final ToggleFavoriteUseCase toggleFavoriteUseCase;
  final GetProductDetailUseCase getProductDetailUseCase;

  /// 찜 토글 - 낙관적 UI 업데이트의 핵심 메서드
  Future<void> toggleFavorite(int productId) async {
    // 현재 상태 확인 - 로드된 상태에서만 동작
    final currentState = state;
    if (currentState is! ProductDetailLoaded) return;

    // ============================================
    // 1단계: 이전 상태 저장 (롤백용)
    // ============================================
    // 🔑 핵심: 실패 시 되돌릴 수 있도록 현재 값을 저장
    // 불변 객체이므로 참조만 저장해도 안전함
    final previousIsFavorite = currentState.isFavorite;

    // ============================================
    // 2단계: 낙관적 업데이트 - UI 먼저 변경
    // ============================================
    // 🚀 사용자는 이 순간 즉각적인 피드백을 받음
    // 서버 응답을 기다리지 않고 바로 하트가 바뀜
    state = currentState.copyWith(
      isFavorite: !previousIsFavorite,  // true ↔ false 토글
    );

    // ============================================
    // 3단계: 서버 요청 (백그라운드)
    // ============================================
    // UI는 이미 바뀌었고, 서버와 동기화 진행
    final result = await toggleFavoriteUseCase(productId);

    // ============================================
    // 4단계: 결과에 따른 처리
    // ============================================
    await result.fold(
      // ❌ 실패 시: 롤백
      (failure) {
        // 저장해둔 이전 상태로 복원
        state = currentState.copyWith(isFavorite: previousIsFavorite);
        debugPrint('찜 상태 변경 실패: ${failure.message}');
        // 선택적: 사용자에게 실패 알림 표시
      },
      // ✅ 성공 시: 서버 데이터로 동기화
      (isFavorite) async {
        // 찜 개수(favoriteCount)도 변경되었으므로 전체 상품 정보 갱신
        final productResult = await getProductDetailUseCase(productId);
        productResult.fold(
          (failure) {
            // 상품 정보 갱신 실패해도 찜 상태는 유지
            // (이미 서버에서 성공 응답을 받았으므로)
            debugPrint('상품 정보 갱신 실패: ${failure.message}');
          },
          (updatedProduct) {
            // 서버의 최신 데이터로 상태 업데이트
            state = currentState.copyWith(
              product: updatedProduct,
              isFavorite: isFavorite,
            );
            // 다른 화면들도 동기화 (이벤트 발행)
            _notifyProductUpdated(updatedProduct);
          },
        );
      },
    );
  }

  /// 상품 업데이트 이벤트 발행
  /// 홈 화면, 내 상품 목록 등 다른 화면에도 변경 사항 전파
  void _notifyProductUpdated(Product product) {
    ref.read(updatedProductProvider.notifier).state = product;
    // 이벤트 처리 후 초기화 (일회성 이벤트이므로)
    Future.microtask(() {
      ref.read(updatedProductProvider.notifier).state = null;
    });
  }
}
```

### 왜 이 순서로 처리할까?

```dart
// 1. 이전 상태 저장
// 2. UI 먼저 업데이트  ← 사용자가 보는 건 여기!
// 3. 서버 요청
// 4. 결과 처리
```

이 순서가 중요한 이유:

1. **사용자 경험 우선**: 2단계에서 UI가 바로 바뀌므로 사용자는 0ms 지연을 느낌
2. **안전한 롤백**: 1단계에서 이전 상태를 저장했으므로 실패 시 복구 가능
3. **데이터 일관성**: 4단계에서 서버 응답을 확인하고 필요시 조정

### 동작 흐름 시각화

실제 사용자 관점에서 어떻게 동작하는지 시각화했습니다.

```
┌─────────────────────────────────────────────────────────────┐
│  사용자가 찜 버튼 클릭 (하트가 비어있는 상태 ♡)               │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼ (즉시, 0ms)
┌─────────────────────────────────────────────────────────────┐
│  1. previousIsFavorite = false (현재 상태 저장)              │
│  2. state.isFavorite = true (UI 즉시 업데이트)               │
│     → 사용자 화면: ♡ → ♥ (하트가 채워짐)                      │
│     → 사용자는 "찜했다!"고 느낌                               │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼ (백그라운드, 0.5~2초)
┌─────────────────────────────────────────────────────────────┐
│  3. 서버에 "찜 추가" 요청 전송                                │
│     → 사용자는 이 과정을 인지하지 못함 (이미 UI가 바뀌었으니까) │
└─────────────────────────────────────────────────────────────┘
                              │
              ┌───────────────┴───────────────┐
              ▼                               ▼
┌─────────────────────────┐     ┌─────────────────────────┐
│  ✅ 성공 (99% 이상)      │     │  ❌ 실패 (1% 미만)       │
│  → 아무 변화 없음        │     │  → state.isFavorite =   │
│  → 찜 개수만 서버 동기화  │     │     false로 롤백        │
│  → 다른 화면에 이벤트     │     │  → 하트 다시 비워짐 ♥→♡ │
│     발행                 │     │  → "실패" 메시지 표시   │
└─────────────────────────┘     └─────────────────────────┘
```

### UI 코드

UI 코드는 매우 단순합니다. 상태만 바라보면 됩니다.

```dart
class ProductDetailPage extends ConsumerWidget {
  const ProductDetailPage({super.key, required this.productId});

  final int productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 상태 구독 - 상태가 바뀌면 자동으로 리빌드
    final state = ref.watch(productDetailNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        actions: [
          // 찜 버튼 - 로드된 상태에서만 표시
          if (state is ProductDetailLoaded)
            IconButton(
              onPressed: () {
                // 탭하면 토글 메서드 호출
                // 내부에서 낙관적 업데이트가 일어남
                ref
                    .read(productDetailNotifierProvider.notifier)
                    .toggleFavorite(productId);
              },
              // 현재 찜 상태에 따라 아이콘 변경
              icon: Icon(
                state.isFavorite
                    ? Icons.favorite        // 채워진 하트
                    : Icons.favorite_border, // 빈 하트
                color: state.isFavorite ? Colors.red : null,
              ),
            ),
        ],
      ),
      // Dart 3 패턴 매칭으로 상태별 UI
      body: switch (state) {
        ProductDetailInitial() || ProductDetailLoading() =>
          const Center(child: CircularProgressIndicator()),
        ProductDetailError(:final message) =>
          Center(child: Text(message)),
        ProductDetailLoaded(:final product) =>
          ProductDetailView(product: product),
      },
    );
  }
}
```

**UI가 단순해지는 이유:**

낙관적 업데이트 로직이 Notifier에 캡슐화되어 있기 때문에, UI는 그냥 상태를 보여주기만 하면 됩니다. `state.isFavorite`가 바뀌면 Flutter가 알아서 리빌드합니다.

---

## 구현 예시 2: 상품 상태 변경

중고거래 앱에서 판매자가 상품 상태를 변경하는 기능입니다.

### 사용자 시나리오

판매자가 채팅으로 거래를 약속하고, 상품 상태를 "예약중"으로 변경하려 합니다.

1. 상품 상세 화면에서 상태 변경 버튼 탭
2. 바텀시트에서 "예약중" 선택
3. **즉시** 상태 배지가 "판매중" → "예약중"으로 변경
4. 서버와 동기화
5. 홈 화면, 내 상품 목록 등 다른 화면에도 반영

### 찜 토글과의 차이점

| 항목 | 찜 토글 | 상품 상태 변경 |
|------|--------|---------------|
| 변경 범위 | `isFavorite` 하나 | `Product` 객체 전체 |
| 롤백 방식 | 단일 값 복원 | 전체 상태 복원 |
| 연관 데이터 | 찜 개수 | 없음 |
| 다른 화면 영향 | 홈, 찜 목록 | 모든 상품 목록 |

### 상태 정의

```dart
/// 상품 상태 열거형
enum ProductStatus {
  selling,   // 판매중 - 구매 가능
  reserved,  // 예약중 - 거래 약속됨
  sold,      // 판매완료 - 거래 끝
}
```

### Notifier 구현

찜 토글보다 조금 복잡합니다. Product 객체 전체를 새로 만들어야 하기 때문입니다.

```dart
/// 상품 상태 변경 - 낙관적 UI 업데이트 적용
///
/// 반환값: 성공 여부 (true/false)
/// UI에서 성공/실패 메시지 표시에 활용
Future<bool> updateProductStatus(
  int productId,
  ProductStatus status,
) async {
  final currentState = state;
  if (currentState is! ProductDetailLoaded) return false;

  // ============================================
  // 1단계: 현재 상태 전체 저장 (롤백용)
  // ============================================
  // 찜 토글과 달리 단일 값이 아닌 전체 상태를 저장
  // 불변 객체이므로 참조만 저장해도 원본은 안전함
  //
  // 🔑 핵심: currentState를 저장해두면
  //          실패 시 state = currentState 한 줄로 완전 복구 가능

  // ============================================
  // 2단계: 낙관적 업데이트 - 새 Product 객체 생성
  // ============================================
  // Product가 불변 객체이므로 새 객체를 만들어야 함
  // copyWith가 없다면 이렇게 모든 필드를 나열해야 함
  // (실제 프로젝트에서는 copyWith 추가 권장)
  final updatedProduct = Product(
    id: currentState.product.id,
    sellerId: currentState.product.sellerId,
    title: currentState.product.title,
    category: currentState.product.category,
    price: currentState.product.price,
    condition: currentState.product.condition,
    description: currentState.product.description,
    tradeMethod: currentState.product.tradeMethod,
    baseAddress: currentState.product.baseAddress,
    detailAddress: currentState.product.detailAddress,
    imageUrls: currentState.product.imageUrls,
    status: status,  // ← 이 부분만 변경!
    viewCount: currentState.product.viewCount,
    favoriteCount: currentState.product.favoriteCount,
    chatCount: currentState.product.chatCount,
    createdAt: currentState.product.createdAt,
    updatedAt: currentState.product.updatedAt,
    seller: currentState.product.seller,
  );

  // 🚀 UI 먼저 업데이트 - 사용자는 즉시 변경을 봄
  state = currentState.copyWith(product: updatedProduct);

  // ============================================
  // 3단계: 서버 요청
  // ============================================
  final request = UpdateProductStatusRequestDto(
    productId: productId,
    status: status,
  );

  final result = await updateProductStatusUseCase(request);

  // ============================================
  // 4단계: 결과 처리
  // ============================================
  return result.fold(
    // ❌ 실패: 전체 상태 롤백
    (failure) {
      // 🔑 핵심: 저장해둔 currentState로 완전 복구
      state = currentState;
      debugPrint('상품 상태 변경 실패: ${failure.message}');
      return false;  // UI에서 실패 메시지 표시용
    },
    // ✅ 성공: 서버 응답으로 최종 확인
    (serverProduct) {
      // 서버가 반환한 Product로 상태 확정
      // (서버에서 updatedAt 등이 변경되었을 수 있음)
      state = currentState.copyWith(product: serverProduct);
      debugPrint('상품 상태 변경 성공: $productId → ${status.name}');

      // 🔔 다른 화면들도 동기화
      // 홈 화면, 내 상품 목록, 검색 결과 등에 이벤트 전파
      ref.read(updatedProductProvider.notifier).state = serverProduct;
      Future.microtask(() {
        ref.read(updatedProductProvider.notifier).state = null;
      });

      return true;  // UI에서 성공 메시지 표시용
    },
  );
}
```

### 불변 객체와 롤백의 관계

이 부분이 낙관적 업데이트에서 가장 중요한 개념입니다.

```dart
// 1. 현재 상태 참조 저장
final currentState = state;  // 참조만 저장 (복사 아님)

// 2. 새로운 상태로 교체
state = currentState.copyWith(product: updatedProduct);
// 이 시점에서:
// - state → 새로운 ProductDetailLoaded 객체
// - currentState → 원래 ProductDetailLoaded 객체 (그대로 존재)

// 3. 실패 시 롤백
state = currentState;  // 원래 객체를 다시 할당
// 새로운 객체는 참조가 없어지면 GC가 수거
```

**불변 객체이기 때문에 가능한 것:**
- `currentState`를 저장해도 나중에 값이 바뀌지 않음
- 롤백 시 저장해둔 객체를 그대로 사용하면 됨
- 중간에 누가 `currentState`를 수정할 걱정이 없음

**만약 가변 객체였다면?**
```dart
// ❌ 가변 객체라면 이런 문제 발생
final currentState = state;
state.product.status = newStatus;  // 원본도 변경됨!
// 롤백해도 이미 원본이 바뀌어서 복구 불가
```

### UI 코드 - 상태 변경 바텀시트

사용자가 상태를 선택하는 바텀시트 UI입니다.

```dart
class ProductStatusBottomSheet extends ConsumerWidget {
  const ProductStatusBottomSheet({
    super.key,
    required this.productId,
    required this.currentStatus,
  });

  final int productId;
  final ProductStatus currentStatus;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 헤더
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              '상태 변경',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Divider(height: 1),
          // 상태 옵션들
          ...ProductStatus.values.map((status) {
            final isSelected = status == currentStatus;

            return ListTile(
              leading: Icon(
                _getStatusIcon(status),
                color: isSelected ? Colors.blue : Colors.grey,
              ),
              title: Text(
                _getStatusLabel(status),
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              trailing: isSelected
                  ? const Icon(Icons.check, color: Colors.blue)
                  : null,
              onTap: isSelected
                  ? null  // 이미 선택된 상태면 비활성화
                  : () async {
                      // 낙관적 업데이트로 즉시 반응
                      final success = await ref
                          .read(productDetailNotifierProvider.notifier)
                          .updateProductStatus(productId, status);

                      if (context.mounted) {
                        Navigator.pop(context);
                        // 결과에 따른 피드백
                        if (success) {
                          GbSnackBar.showSuccess(
                            context,
                            '${_getStatusLabel(status)}(으)로 변경되었습니다',
                          );
                        } else {
                          GbSnackBar.showError(
                            context,
                            '상태 변경에 실패했습니다. 다시 시도해주세요.',
                          );
                        }
                      }
                    },
            );
          }),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  IconData _getStatusIcon(ProductStatus status) {
    return switch (status) {
      ProductStatus.selling => Icons.storefront,
      ProductStatus.reserved => Icons.bookmark,
      ProductStatus.sold => Icons.check_circle,
    };
  }

  String _getStatusLabel(ProductStatus status) {
    return switch (status) {
      ProductStatus.selling => '판매중',
      ProductStatus.reserved => '예약중',
      ProductStatus.sold => '판매완료',
    };
  }
}
```

**사용자 경험 포인트:**
- 옵션 탭 → 바텀시트 닫힘 → 상태 즉시 변경됨 → 스낵바로 확인
- 서버 응답을 기다리지 않으므로 자연스러운 흐름
- 실패 시에만 롤백 + 에러 메시지

---

## 다중 화면 동기화: 이벤트 기반 패턴

낙관적 업데이트의 또 다른 과제는 **다른 화면과의 동기화**입니다.

### 문제 상황

상품 상세에서 "판매완료"로 변경했는데, 뒤로 가면 홈 화면에는 여전히 "판매중"으로 표시된다면?

사용자는 혼란스럽습니다. "내가 분명 바꿨는데?"

### 해결 방법: 이벤트 Provider 패턴

Riverpod의 `StateProvider`를 이벤트 버스처럼 활용합니다.

```
[상품 상세]                    [홈 화면]        [내 상품 목록]
    │                            │                  │
    │  상태 변경 성공             │                  │
    │       │                    │                  │
    │       ▼                    │                  │
    │  updatedProductProvider    │                  │
    │  에 이벤트 발행             │                  │
    │       │                    │                  │
    └───────┼────────────────────┼──────────────────┘
            │                    │                  │
            ▼                    ▼                  ▼
        [이벤트 전파] ───────────────────────────────→
            │                    │                  │
            ▼                    ▼                  ▼
    자동 업데이트 안 함      목록에서 업데이트    목록에서 업데이트
    (이미 업데이트됨)
```

### 이벤트 Provider 정의

```dart
// di/product_providers.dart

/// 삭제된 상품 ID 이벤트 Provider
///
/// 사용법:
/// 1. 상품 삭제 성공 시: ref.read(deletedProductIdProvider.notifier).state = productId
/// 2. 다른 화면에서 listen하여 목록에서 해당 상품 제거
/// 3. 처리 후 null로 초기화
final deletedProductIdProvider = StateProvider<int?>((ref) => null);

/// 수정된 상품 이벤트 Provider
///
/// 사용법:
/// 1. 상품 수정 성공 시: ref.read(updatedProductProvider.notifier).state = product
/// 2. 다른 화면에서 listen하여 목록의 해당 상품 업데이트
/// 3. 처리 후 null로 초기화
final updatedProductProvider = StateProvider<Product?>((ref) => null);
```

### 이벤트 발행 측 (상품 상세 화면)

```dart
// 상품 업데이트 성공 시
void _notifyProductUpdated(Product product) {
  // 이벤트 발행: 다른 화면들이 구독 중
  ref.read(updatedProductProvider.notifier).state = product;

  // 이벤트는 일회성이므로 처리 후 초기화
  // Future.microtask를 사용하여 구독자들이 처리할 시간 확보
  Future.microtask(() {
    ref.read(updatedProductProvider.notifier).state = null;
  });
}
```

**왜 `Future.microtask`를 쓸까?**

```dart
// ❌ 바로 null로 설정하면
ref.read(updatedProductProvider.notifier).state = product;
ref.read(updatedProductProvider.notifier).state = null;
// 구독자가 product를 받기도 전에 null이 됨

// ✅ microtask로 지연시키면
ref.read(updatedProductProvider.notifier).state = product;
Future.microtask(() {
  ref.read(updatedProductProvider.notifier).state = null;
});
// 구독자가 product를 처리한 후에 null이 됨
```

### 이벤트 구독 측 (목록 화면들)

```dart
class ProductNotifier extends StateNotifier<ProductState> {
  ProductNotifier(this.ref, ...) : super(const ProductInitial()) {
    // 🔔 생성자에서 이벤트 구독 설정

    // 삭제 이벤트 구독
    ref.listen<int?>(deletedProductIdProvider, (previous, next) {
      if (next != null) {
        _removeProduct(next);  // 목록에서 제거
      }
    });

    // 수정 이벤트 구독
    ref.listen<Product?>(updatedProductProvider, (previous, next) {
      if (next != null) {
        _updateProduct(next);  // 목록에서 업데이트
      }
    });
  }

  /// 목록에서 상품 제거
  void _removeProduct(int productId) {
    final currentState = state;
    if (currentState is! ProductLoaded) return;

    // 해당 상품만 필터링하여 제외
    final updatedProducts = currentState.products
        .where((p) => p.id != productId)
        .toList();

    state = currentState.copyWith(products: updatedProducts);
    debugPrint('목록에서 상품 제거: $productId');
  }

  /// 목록에서 상품 업데이트
  void _updateProduct(Product product) {
    final currentState = state;
    if (currentState is! ProductLoaded) return;

    // 해당 상품만 교체
    final updatedProducts = currentState.products.map((p) {
      return p.id == product.id ? product : p;
    }).toList();

    state = currentState.copyWith(products: updatedProducts);
    debugPrint('목록에서 상품 업데이트: ${product.id}');
  }
}
```

### 이 패턴의 장점

| 장점 | 설명 |
|------|------|
| **느슨한 결합** | 상세 화면이 목록 화면을 직접 참조하지 않음 |
| **확장성** | 새 화면 추가 시 구독만 추가하면 됨 |
| **일관성** | 모든 화면이 같은 이벤트를 받으므로 동기화 보장 |
| **성능** | 서버 재요청 없이 로컬에서 업데이트 |

### 전체 흐름 정리

```
┌─────────────────────────────────────────────────────────────┐
│  [상품 상세] 사용자가 "판매완료"로 상태 변경                    │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│  1. 낙관적 업데이트: 상품 상세 UI 즉시 "판매완료"로 변경        │
│  2. 서버 요청 → 성공                                         │
│  3. updatedProductProvider에 product 이벤트 발행            │
└─────────────────────────────────────────────────────────────┘
                              │
                              │ (이벤트 전파)
                              │
              ┌───────────────┼───────────────┐
              ▼               ▼               ▼
┌──────────────────┐ ┌──────────────────┐ ┌──────────────────┐
│  [홈 화면]        │ │  [내 상품 목록]   │ │  [검색 결과]      │
│  ProductNotifier │ │  ProductNotifier │ │  SearchNotifier  │
│                  │ │                  │ │                  │
│  ref.listen 동작 │ │  ref.listen 동작 │ │  ref.listen 동작 │
│  _updateProduct  │ │  _updateProduct  │ │  _updateProduct  │
│  호출            │ │  호출            │ │  호출            │
│                  │ │                  │ │                  │
│  → 목록 내 해당   │ │  → 목록 내 해당   │ │  → 목록 내 해당   │
│    상품 status   │ │    상품 status   │ │    상품 status   │
│    업데이트      │ │    업데이트      │ │    업데이트      │
└──────────────────┘ └──────────────────┘ └──────────────────┘
```

---

## 핵심 패턴 정리

지금까지 살펴본 내용을 패턴으로 정리합니다.

### 1. 기본 패턴 템플릿

모든 낙관적 업데이트는 이 4단계를 따릅니다.

```dart
Future<void> optimisticUpdate() async {
  // 1️⃣ 이전 상태 저장 (롤백용)
  final previousState = currentState;

  // 2️⃣ UI 먼저 업데이트 (낙관적)
  state = newState;

  // 3️⃣ 서버 요청
  final result = await serverRequest();

  // 4️⃣ 결과 처리
  result.fold(
    (failure) => state = previousState,    // 실패: 롤백
    (success) => syncWithServer(success),  // 성공: 동기화
  );
}
```

### 2. 구현 체크리스트

새로운 낙관적 업데이트를 구현할 때 확인할 사항:

| 체크 | 항목 | 설명 |
|:----:|------|------|
| ☐ | 이전 상태 저장 | 롤백을 위해 반드시 저장 |
| ☐ | 불변 객체 사용 | copyWith 패턴으로 안전한 롤백 보장 |
| ☐ | UI 먼저 업데이트 | 서버 요청 전에 상태 변경 |
| ☐ | 실패 시 롤백 | 저장한 이전 상태로 복원 |
| ☐ | 성공 시 서버 동기화 | 서버 응답으로 최신 데이터 반영 |
| ☐ | 다중 화면 동기화 | 이벤트 패턴으로 다른 화면에 전파 |
| ☐ | 에러 피드백 | 실패 시 사용자에게 알림 |

### 3. 주의사항

**가변 객체 사용 금지:**
```dart
// ❌ 잘못된 예: 상태를 직접 변경
currentState.isFavorite = !currentState.isFavorite;
// 원본이 변경되어 롤백 불가능

// ✅ 올바른 예: copyWith로 새 객체 생성
state = currentState.copyWith(isFavorite: !currentState.isFavorite);
// 원본은 그대로, 새 객체가 생성됨
```

**이전 상태 저장 필수:**
```dart
// ❌ 잘못된 예: 이전 상태 저장 없이 업데이트
state = newState;
final result = await serverRequest();
if (result.isFailure) {
  // 롤백할 방법이 없음!
}

// ✅ 올바른 예: 이전 상태 먼저 저장
final previousState = state;  // 이 시점의 상태 캡처
state = newState;
final result = await serverRequest();
if (result.isFailure) {
  state = previousState;  // 안전하게 롤백
}
```

**적절한 사용처 선택:**
```dart
// ❌ 낙관적 업데이트가 부적합한 경우
Future<void> processPayment() async {
  state = PaymentSuccess();  // 결제 성공으로 먼저 표시?
  final result = await paymentUseCase();  // 실제 결제
  // 실패하면 이미 "결제 성공"을 봤는데 롤백?
  // → 사용자 혼란, 신뢰 저하
}

// ✅ 비관적 업데이트가 적합한 경우
Future<void> processPayment() async {
  state = PaymentLoading();  // 로딩 표시
  final result = await paymentUseCase();  // 실제 결제
  state = result.fold(
    (f) => PaymentError(f.message),
    (s) => PaymentSuccess(),
  );
  // 결과가 확정된 후에만 표시
}
```

---

## 적용 효과

낙관적 UI 업데이트를 적용한 후 체감되는 변화:

### 정량적 개선

| 지표 | Before | After |
|------|--------|-------|
| 찜 버튼 반응 시간 | 0.5~2초 | **0ms** (즉시) |
| 상태 변경 체감 시간 | 0.5~2초 | **0ms** (즉시) |
| 중복 탭 발생률 | 높음 | **거의 없음** |

### 정성적 개선

| 항목 | 설명 |
|------|------|
| **체감 속도** | 앱이 빠르다고 느낌 |
| **신뢰감** | 내 요청이 즉시 반영된다는 확신 |
| **자연스러움** | 네트워크 지연이 느껴지지 않음 |
| **일관성** | 모든 화면이 동기화됨 |

### 개발 측면

| 항목 | 설명 |
|------|------|
| **코드 복잡도** | 약간 증가 (롤백 로직 추가) |
| **유지보수** | 패턴이 정해져 있어 일관성 있음 |
| **테스트** | 성공/실패 케이스 분리 테스트 가능 |

---

## 마무리

낙관적 UI 업데이트는 **"서버를 믿고 UI를 먼저 바꾸자"**라는 간단한 아이디어입니다.

기술적으로는:
1. **UI 먼저 업데이트** → 사용자는 즉각적인 반응을 봄
2. **실패 시 롤백** → 데이터 일관성 유지
3. **불변 객체 활용** → 안전한 상태 관리
4. **이벤트 패턴** → 다중 화면 동기화

하지만 더 중요한 건 **사용자 관점**입니다:
- "버튼 눌렀는데 왜 안 바뀌지?" → 해결
- "또 눌러봐야 하나?" → 해결
- "이 앱 느리네" → 해결

작은 변화가 사용자 경험에 큰 차이를 만듭니다.

---

> ⚠️ **커스터마이징 안내**
>
> 이 글의 코드는 **제 프로젝트(Riverpod + StateNotifier + Clean Architecture)**에 맞게 작성된 예시입니다.
>
> Bloc, GetX, Provider 등 다른 상태관리를 사용하신다면 **패턴만 참고**하여 각자의 구조에 맞게 적용하시면 됩니다.
>
> 핵심은 상태관리 도구가 아니라:
> - 이전 상태 저장
> - UI 먼저 업데이트
> - 실패 시 롤백
>
> 이 3단계입니다.

---

## 참고 자료

- [Optimistic UI Updates - Apollo GraphQL](https://www.apollographql.com/docs/react/performance/optimistic-ui/)
- [Flutter Riverpod Documentation](https://riverpod.dev/)
- [The Clean Architecture - Uncle Bob](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
