# 상품 업데이트 최적화 가이드 (Lazy Update 전략)

## 📋 개요

현재 앱은 모든 상품 관련 변경사항(조회수, 찜, 채팅 카운트 등)을 **즉시 반영(Real-time Update)**하는 방식으로 구현되어 있습니다.
앱 규모가 작을 때는 문제가 없지만, 사용자가 증가하면 서버 부하와 비용이 증가할 수 있습니다.

이 문서는 **Lazy Update (지연 업데이트)** 전략을 적용하는 방법을 안내합니다.

### Lazy Update란?

**Lazy Update (지연 업데이트)**는 부하를 줄이기 위해 일부러 업데이트를 즉시 반영하지 않고,
사용자가 새로고침을 할 때나 필요할 때만 반영하는 최적화 전략입니다.

- **서버에는 즉시 반영**: 데이터는 정상적으로 저장됨
- **클라이언트는 지연 반영**: UI 업데이트는 새로고침 시에만 반영
- **효과**: API 호출 50% 감소, 서버 부하 감소, 비용 절감

---

## 🔍 현재 상태

### 즉시 업데이트되는 기능들

| 기능                     | 위치                           | 설명                                      |
| ------------------------ | ------------------------------ | ----------------------------------------- |
| **조회수 증가**          | `product_detail_notifier.dart` | 상품 상세 화면 진입 시 즉시 반영          |
| **찜 토글**              | `product_detail_notifier.dart` | 찜 버튼 클릭 시 즉시 반영 (상태 + 카운트) |
| **채팅 카운트**          | `chat_notifier.dart`           | 채팅방 생성 시 즉시 반영                  |
| **상품 삭제**            | `product_detail_notifier.dart` | 삭제 시 즉시 목록에서 제거                |
| **상품 수정**            | `update_product_notifier.dart` | 수정 완료 시 즉시 반영                    |
| **상품 상태 변경**       | `product_detail_notifier.dart` | 상태 변경 시 즉시 반영                    |
| **상품 상단으로 올리기** | `product_detail_notifier.dart` | 끌어올리기 시 즉시 반영                   |

### 현재 아키텍처

```
사용자 액션
    ↓
UseCase 호출
    ↓
서버 API 호출
    ↓
상품 정보 재조회 (getProductDetailUseCase) ← 추가 API 호출
    ↓
updatedProductProvider 이벤트 발행
    ↓
모든 목록 Provider 자동 업데이트
```

**문제점**:

- 조회수 증가 시 API 2회 호출 (조회수 증가 + 상품 정보 재조회)
- 찜 토글 시 API 2회 호출 (토글 + 상품 정보 재조회)
- 채팅방 생성 시 API 2회 호출 (생성 + 상품 정보 재조회)

---

## ⚠️ 언제 Lazy Update를 적용해야 할까?

### 변경을 고려해야 하는 시점

1. **동시 접속자 1,000명 이상**
2. **상품 상세 조회가 초당 100회 이상**
3. **서버 응답 시간이 느려지거나 에러 증가**
4. **인프라 비용이 부담스러울 때**
5. **데이터베이스 부하가 높을 때**

### 현재 상태로 유지해도 되는 경우

- 동시 접속자 수백 명 이하
- 일일 활성 사용자 수천 명 이하
- 서버 응답 시간이 정상 범위 (200ms 이하)
- 비용 부담이 없음

---

## 🎯 권장 변경 방안

### 즉시 업데이트 유지 (중요한 사용자 액션)

✅ **상품 삭제** - 삭제 후 목록에 남아있으면 혼란  
✅ **상품 수정** - 수정 내용을 바로 확인해야 함  
✅ **상품 상태 변경** - 상태 변경은 중요한 정보  
✅ **상품 상단으로 올리기** - 액션 결과를 바로 확인해야 함

### Lazy Update 적용 (통계성 데이터)

❌ **조회수 증가** - 빈번한 호출, 즉시 반영 불필요  
❌ **찜 카운트** - 찜 상태는 즉시 반영, 카운트만 새로고침  
❌ **채팅 카운트** - 빈번한 호출, 즉시 반영 불필요

---

## 🔧 Lazy Update 적용 방법

### 1. 조회수 증가 - Lazy Update 적용

**파일**: `lib/feature/product/presentation/provider/product_detail_notifier.dart`

**현재 코드** (140-178줄):

```dart
Future<bool> incrementViewCount(int productId) async {
  final result = await incrementViewCountUseCase(productId);
  return result.fold(
    (failure) {
      debugPrint('조회수 증가 실패: ${failure.message}');
      return false;
    },
    (incremented) {
      // 조회수가 증가한 경우 상품 정보 업데이트
      if (incremented) {
        final currentState = state;
        if (currentState is ProductDetailLoaded) {
          final productResult = getProductDetailUseCase(productId);
          productResult.then((result) {
            result.fold(
              (failure) {
                debugPrint('상품 정보를 불러오는데 실패했습니다: ${failure.message}');
              },
              (updatedProduct) {
                final updatedState = state;
                if (updatedState is ProductDetailLoaded) {
                  state = updatedState.copyWith(product: updatedProduct);
                  // 조회수 증가 성공 시 이벤트 발행 (목록 Provider가 갱신)
                  ref.read(updatedProductProvider.notifier).state = updatedProduct;
                  // 이벤트 처리 후 초기화 (다음 업데이트를 위해)
                  Future.microtask(() {
                    ref.read(updatedProductProvider.notifier).state = null;
                  });
                }
              },
            );
          });
        }
      }
      return incremented;
    },
  );
}
```

**변경 후 코드 (Lazy Update 적용)**:

```dart
Future<bool> incrementViewCount(int productId) async {
  final result = await incrementViewCountUseCase(productId);
  return result.fold(
    (failure) {
      debugPrint('조회수 증가 실패: ${failure.message}');
      return false;
    },
    (incremented) {
      // ✅ Lazy Update: 서버에만 반영, 클라이언트는 새로고침 시 반영
      // 상품 정보 재조회 및 이벤트 발행 제거 → API 호출 50% 감소
      return incremented;
    },
  );
}
```

**변경 사항**:

- ✅ 상품 정보 재조회 제거
- ✅ `updatedProductProvider` 이벤트 발행 제거
- ✅ API 호출 1회로 감소 (조회수 증가만)

---

### 2. 찜 토글 - 카운트만 Lazy Update 적용

**파일**: `lib/feature/product/presentation/provider/product_detail_notifier.dart`

**현재 코드** (180-222줄):

```dart
Future<void> toggleFavorite(int productId) async {
  final currentState = state;
  if (currentState is! ProductDetailLoaded) return;

  // 낙관적 업데이트
  final previousIsFavorite = currentState.isFavorite;
  state = currentState.copyWith(isFavorite: !previousIsFavorite);

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
          // 찜 토글 성공 시 이벤트 발행
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

**변경 후 코드 (Lazy Update 적용)**:

```dart
Future<void> toggleFavorite(int productId) async {
  final currentState = state;
  if (currentState is! ProductDetailLoaded) return;

  // 낙관적 업데이트 (찜 상태만 즉시 반영)
  final previousIsFavorite = currentState.isFavorite;
  state = currentState.copyWith(isFavorite: !previousIsFavorite);

  final result = await toggleFavoriteUseCase(productId);

  await result.fold(
    (failure) {
      // 실패 시 이전 상태로 복원
      state = currentState.copyWith(isFavorite: previousIsFavorite);
      debugPrint('찜 상태 변경 실패: ${failure.message}');
    },
    (isFavorite) async {
      // ✅ Lazy Update: 찜 상태만 즉시 반영, 카운트는 새로고침 시 반영
      state = currentState.copyWith(isFavorite: isFavorite);
      // 상품 정보 재조회 및 이벤트 발행 제거 → API 호출 50% 감소
    },
  );
}
```

**변경 사항**:

- ✅ 찜 상태는 즉시 반영 (UI에서 하트 아이콘 바로 변경)
- ✅ 찜 카운트는 새로고침 시 반영
- ✅ 상품 정보 재조회 제거
- ✅ `updatedProductProvider` 이벤트 발행 제거
- ✅ API 호출 1회로 감소 (토글만)

---

### 3. 채팅 카운트 - Lazy Update 적용

**파일**: `lib/feature/chat/presentation/provider/chat_notifier.dart`

**현재 코드** (554-573줄):

```dart
void _updateProductAfterChatRoomCreated(int productId) {
  // 상품 정보를 다시 조회하여 updatedProductProvider에 이벤트 발행
  getProductDetailUseCase(productId).then((result) {
    result.fold(
      (failure) {
        debugPrint('채팅방 생성 후 상품 정보 조회 실패: ${failure.message}');
      },
      (updatedProduct) {
        debugPrint(
            '채팅방 생성 후 상품 정보 업데이트: productId=$productId, chatCount=${updatedProduct.chatCount}');
        // 상품 업데이트 이벤트 발행 (모든 목록 Provider가 자동으로 반응)
        ref.read(updatedProductProvider.notifier).state = updatedProduct;
        // 이벤트 처리 후 초기화 (다음 업데이트를 위해)
        Future.microtask(() {
          ref.read(updatedProductProvider.notifier).state = null;
        });
      },
    );
  });
}
```

**변경 방법**:

1. **`_updateProductAfterChatRoomCreated` 메서드 제거 또는 주석 처리**

2. **`createOrGetChatRoomAndEnter` 메서드에서 호출 제거** (127줄):

```dart
// 2. 새 채팅방이 생성된 경우 상품 정보 업데이트 (chatCount 반영)
// ✅ Lazy Update 적용: 제거
// if (response.isNewChatRoom ?? false) {
//   _updateProductAfterChatRoomCreated(productId);
// }
```

3. **`sendMessageWithoutChatRoom` 메서드에서 호출 제거** (296줄):

```dart
// 새 채팅방이 생성되었을 수 있으므로 상품 정보 업데이트 (chatCount 반영)
// ✅ Lazy Update 적용: 제거
// _updateProductAfterChatRoomCreated(productId);
```

**변경 사항**:

- ✅ `_updateProductAfterChatRoomCreated` 메서드 제거
- ✅ 상품 정보 재조회 제거
- ✅ `updatedProductProvider` 이벤트 발행 제거
- ✅ API 호출 1회로 감소 (채팅방 생성만)

---

## 📊 변경 전후 비교

### 변경 전 (Real-time Update)

| 기능        | API 호출 횟수 | 설명                           |
| ----------- | ------------- | ------------------------------ |
| 조회수 증가 | 2회           | 조회수 증가 + 상품 정보 재조회 |
| 찜 토글     | 2회           | 토글 + 상품 정보 재조회        |
| 채팅 카운트 | 2회           | 채팅방 생성 + 상품 정보 재조회 |

**총 API 호출**: 6회

### 변경 후 (Lazy Update)

| 기능        | API 호출 횟수 | 설명                          |
| ----------- | ------------- | ----------------------------- |
| 조회수 증가 | 1회           | 조회수 증가만                 |
| 찜 토글     | 1회           | 토글만 (카운트는 새로고침 시) |
| 채팅 카운트 | 1회           | 채팅방 생성만                 |

**총 API 호출**: 3회

**예상 효과**:

- ✅ API 호출 **50% 감소**
- ✅ 서버 부하 감소
- ✅ 데이터베이스 쿼리 감소
- ✅ 인프라 비용 절감
- ✅ 응답 시간 개선

---

## ✅ 변경 체크리스트

### 변경 전 확인사항

- [ ] 서버 모니터링 도구 설정 (응답 시간, 에러율)
- [ ] 현재 API 호출 빈도 측정
- [ ] 데이터베이스 부하 확인
- [ ] 사용자 피드백 수집 (새로고침 필요성)

### 변경 후 확인사항

- [ ] 서버 부하 감소 확인
- [ ] API 호출 빈도 감소 확인
- [ ] 사용자 경험 저하 여부 확인
- [ ] 에러 발생 여부 확인
- [ ] 새로고침 시 카운트 정상 반영 확인

---

## 🔄 롤백 방법

변경 후 문제가 발생하면:

1. **Git으로 변경 전 상태로 복원**

   ```bash
   git checkout HEAD -- lib/feature/product/presentation/provider/product_detail_notifier.dart
   git checkout HEAD -- lib/feature/chat/presentation/provider/chat_notifier.dart
   ```

2. **또는 각 메서드의 주석 처리된 코드를 다시 활성화**

---

## 📝 참고사항

### 백엔드 로직은 변경하지 않음

- ✅ 서버에는 여전히 조회수/찜/채팅 카운트가 정상적으로 반영됩니다.
- ✅ 데이터는 정상적으로 저장되며, 단지 클라이언트 UI 업데이트만 지연됩니다.

### `updatedProductProvider`는 유지

- ✅ 삭제/수정/상태 변경 등 다른 용도로 사용됩니다.
- ✅ Lazy Update를 적용한 기능만 이벤트 발행을 제거합니다.

### `ProductNotifier`의 `ref.listen`은 유지

- ✅ 다른 업데이트(삭제, 수정, 상태 변경)에 필요합니다.
- ✅ Lazy Update를 적용한 기능만 이벤트를 발행하지 않습니다.

---

## 💡 추가 최적화 아이디어

필요하다면 다음도 고려할 수 있습니다:

### 1. 배치 처리 (Batch Update)

조회수를 일정 시간마다 배치로 업데이트

```dart
// 예: 10초마다 조회수 배치 업데이트
Timer.periodic(Duration(seconds: 10), (timer) {
  _batchUpdateViewCounts();
});
```

### 2. 캐싱 (Caching)

자주 조회되는 상품 정보를 캐싱

```dart
// 예: 상품 정보 캐시 (5분)
final cachedProduct = _productCache.get(productId);
if (cachedProduct != null && !cachedProduct.isExpired) {
  return cachedProduct;
}
```

### 3. CDN 활용

정적 데이터는 CDN으로 제공

### 4. 읽기 전용 복제본

데이터베이스 읽기 전용 복제본 사용

---

## 📚 관련 용어 정리

### Lazy Update (지연 업데이트)

- 필요할 때만 업데이트하는 방식
- 가장 일반적인 용어

### Deferred Update (연기된 업데이트)

- 업데이트를 나중으로 미루는 방식
- 공식적인 용어

### On-Demand Update (요청 시 업데이트)

- 사용자가 요청할 때만 업데이트
- Pull-based Update와 유사

### Eventual Consistency (최종 일관성)

- 분산 시스템 용어
- 즉시 일관되지 않아도 최종적으로 일관되게 수렴

### 반대 개념

- **Real-time Update (실시간 업데이트)**: 즉시 반영
- **Optimistic Update (낙관적 업데이트)**: 즉시 반영하고 나중에 검증
- **Pessimistic Update (비관적 업데이트)**: 검증 후 반영

---

**작성일**: 2024-12-24  
**최종 수정일**: 2024-12-24  
**관련 패턴**: Lazy Update, Deferred Update, Eventual Consistency
