# BuildContext Safety Fix Plan

**날짜**: 2026-01-06
**작업자**: Claude Code (Sonnet 4.5)
**관련 Plan**: `2026-01-06_code-review-improvement-plan.md` (Section 1.4)
**예상 소요 시간**: 30분

---

## 작업 개요

`ref.listen` 콜백에서 BuildContext를 사용할 때, State의 `mounted` 대신 `context.mounted`를 사용해야 합니다. 잘못된 mounted 체크는 간헐적인 크래시를 유발할 수 있습니다.

---

## 문제 분석

### 배경 지식

Flutter에서 BuildContext를 async gap 이후 사용할 때는 반드시 유효성을 체크해야 합니다:

1. **State.mounted**: State 객체 자체가 트리에 마운트되어 있는지 확인
2. **context.mounted**: 특정 BuildContext가 여전히 유효한지 확인

### 문제 상황

```dart
// ❌ 잘못된 코드
@override
void initState() {
  super.initState();

  ref.listen<ProductState>(productNotifierProvider, (previous, next) {
    // 이 콜백은 함수 파라미터로 받은 context가 아니라
    // State의 context를 사용하는 경우가 있음

    if (!mounted) return;  // ❌ State의 mounted 체크
    context.go('/somewhere');  // 하지만 context 사용
  });
}
```

**위험한 이유**:
- `ref.listen` 콜백은 State가 dispose된 후에도 호출될 수 있음
- State의 `mounted`는 true여도 `context`는 이미 무효화되었을 수 있음
- 무효화된 context로 navigation하면 크래시 발생

### 올바른 패턴

```dart
// ✅ 올바른 코드
ref.listen<ProductState>(productNotifierProvider, (previous, next) {
  if (!context.mounted) return;  // ✅ context.mounted 체크
  context.go('/somewhere');
});
```

---

## 수정 대상 파일

### 1. create_product_page.dart

**파일**: `lib/feature/product/presentation/page/create_product_page.dart`
**라인**: 47-72

**현재 코드**:
```dart
ref.listen<CreateProductState>(
  createProductNotifierProvider,
  (previous, next) {
    switch (next) {
      case CreateProductLoading():
        // 로딩 상태
        break;
      case CreateProductSuccess():
        if (!mounted) return;  // ❌ 잘못됨
        GbSnackBar.showSuccess(context, message: '상품이 등록되었습니다.');
        context.pop();
      case CreateProductError(:final message):
        if (!mounted) return;  // ❌ 잘못됨
        GbSnackBar.showError(context, message: message);
    }
  },
);
```

**수정 코드**:
```dart
ref.listen<CreateProductState>(
  createProductNotifierProvider,
  (previous, next) {
    switch (next) {
      case CreateProductLoading():
        break;
      case CreateProductSuccess():
        if (!context.mounted) return;  // ✅ 수정
        GbSnackBar.showSuccess(context, message: '상품이 등록되었습니다.');
        context.pop();
      case CreateProductError(:final message):
        if (!context.mounted) return;  // ✅ 수정
        GbSnackBar.showError(context, message: message);
    }
  },
);
```

---

### 2. product_detail_page.dart

**파일**: `lib/feature/product/presentation/page/product_detail_page.dart`
**라인**: 82-186 (여러 곳)

**패턴 1: deleteProductNotifierProvider 리스너**

**현재 코드** (Line 82-99):
```dart
ref.listen<DeleteProductState>(
  deleteProductNotifierProvider,
  (previous, next) {
    switch (next) {
      case DeleteProductLoading():
        break;
      case DeleteProductSuccess():
        if (!mounted) return;  // ❌
        GbSnackBar.showSuccess(context, message: '상품이 삭제되었습니다.');
        context.go('/');
      case DeleteProductError(:final message):
        if (!mounted) return;  // ❌
        GbSnackBar.showError(context, message: message);
    }
  },
);
```

**수정 코드**:
```dart
ref.listen<DeleteProductState>(
  deleteProductNotifierProvider,
  (previous, next) {
    switch (next) {
      case DeleteProductLoading():
        break;
      case DeleteProductSuccess():
        if (!context.mounted) return;  // ✅
        GbSnackBar.showSuccess(context, message: '상품이 삭제되었습니다.');
        context.go('/');
      case DeleteProductError(:final message):
        if (!context.mounted) return;  // ✅
        GbSnackBar.showError(context, message: message);
    }
  },
);
```

**패턴 2: updateProductStatusNotifierProvider 리스너**

**현재 코드** (Line 101-120):
```dart
ref.listen<UpdateProductStatusState>(
  updateProductStatusNotifierProvider,
  (previous, next) {
    switch (next) {
      case UpdateProductStatusLoading():
        break;
      case UpdateProductStatusSuccess(:final updatedProduct):
        if (!mounted) return;  // ❌
        GbSnackBar.showSuccess(
          context,
          message: '상품 상태가 변경되었습니다.',
        );
        // 상태 변경 후 리뷰 작성 유도
        if (updatedProduct.productStatus == ProductStatus.sold) {
          // 후기 작성 네비게이션
        }
      case UpdateProductStatusError(:final message):
        if (!mounted) return;  // ❌
        GbSnackBar.showError(context, message: message);
    }
  },
);
```

**수정 코드**:
```dart
ref.listen<UpdateProductStatusState>(
  updateProductStatusNotifierProvider,
  (previous, next) {
    switch (next) {
      case UpdateProductStatusLoading():
        break;
      case UpdateProductStatusSuccess(:final updatedProduct):
        if (!context.mounted) return;  // ✅
        GbSnackBar.showSuccess(
          context,
          message: '상품 상태가 변경되었습니다.',
        );
        if (updatedProduct.productStatus == ProductStatus.sold) {
          // 후기 작성 네비게이션
        }
      case UpdateProductStatusError(:final message):
        if (!context.mounted) return;  // ✅
        GbSnackBar.showError(context, message: message);
    }
  },
);
```

**패턴 3: toggleFavoriteNotifierProvider 리스너**

**현재 코드** (Line 122-138):
```dart
ref.listen<ToggleFavoriteState>(
  toggleFavoriteNotifierProvider,
  (previous, next) {
    switch (next) {
      case ToggleFavoriteLoading():
        break;
      case ToggleFavoriteSuccess(:final isFavorite):
        if (!mounted) return;  // ❌
        GbSnackBar.showInfo(
          context,
          message: isFavorite ? '찜 목록에 추가되었습니다.' : '찜 목록에서 제거되었습니다.',
        );
      case ToggleFavoriteError(:final message):
        if (!mounted) return;  // ❌
        GbSnackBar.showError(context, message: message);
    }
  },
);
```

**수정 코드**:
```dart
ref.listen<ToggleFavoriteState>(
  toggleFavoriteNotifierProvider,
  (previous, next) {
    switch (next) {
      case ToggleFavoriteLoading():
        break;
      case ToggleFavoriteSuccess(:final isFavorite):
        if (!context.mounted) return;  // ✅
        GbSnackBar.showInfo(
          context,
          message: isFavorite ? '찜 목록에 추가되었습니다.' : '찜 목록에서 제거되었습니다.',
        );
      case ToggleFavoriteError(:final message):
        if (!context.mounted) return;  // ✅
        GbSnackBar.showError(context, message: message);
    }
  },
);
```

---

### 3. edit_profile_page.dart

**파일**: `lib/feature/profile/presentation/page/edit_profile_page.dart`
**라인**: 186-195

**현재 코드**:
```dart
ref.listen<UpdateProfileState>(
  updateProfileNotifierProvider,
  (previous, next) {
    if (next is UpdateProfileSuccess) {
      if (!mounted) return;  // ❌
      GbSnackBar.showSuccess(context, message: '프로필이 수정되었습니다.');
      context.pop();
    } else if (next is UpdateProfileError) {
      if (!mounted) return;  // ❌
      GbSnackBar.showError(context, message: next.message);
    }
  },
);
```

**수정 코드**:
```dart
ref.listen<UpdateProfileState>(
  updateProfileNotifierProvider,
  (previous, next) {
    if (next is UpdateProfileSuccess) {
      if (!context.mounted) return;  // ✅
      GbSnackBar.showSuccess(context, message: '프로필이 수정되었습니다.');
      context.pop();
    } else if (next is UpdateProfileError) {
      if (!context.mounted) return;  // ✅
      GbSnackBar.showError(context, message: next.message);
    }
  },
);
```

---

## 수정 전략

### 일괄 검색 및 치환

모든 `ref.listen` 콜백 내부의 `mounted` → `context.mounted`로 변경:

```bash
# 검색 패턴
if (!mounted) return;

# 위치: ref.listen 콜백 내부
# 치환: if (!context.mounted) return;
```

### 예외 케이스

**변경하지 않는 경우**:
```dart
// State 메서드 내부 (ref.listen 외부)
Future<void> _handleSubmit() async {
  await someAsyncOperation();

  if (!mounted) return;  // ✅ 이건 그대로 유지 (State의 context 사용)
  setState(() { ... });
}
```

---

## 위험 분석

### Before (문제 상황)

```dart
// Scenario: 사용자가 상품 등록 후 빠르게 뒤로가기
Time 0s: 상품 등록 요청
Time 1s: 사용자가 뒤로가기 (dispose 시작)
Time 1.5s: State disposed, mounted = false
Time 2s: 서버 응답 도착
  → ref.listen 콜백 실행
  → if (!mounted) return;  // ❌ State.mounted == false → return
  → 하지만 State가 dispose되기 직전이라면?
  → context는 이미 무효화됨
  → if (!mounted)가 false를 반환할 수 있음 (타이밍 이슈)
  → context.pop() 실행 → 💥 CRASH!
```

### After (수정 후)

```dart
Time 2s: 서버 응답 도착
  → ref.listen 콜백 실행
  → if (!context.mounted) return;  // ✅ context 직접 체크
  → context가 무효화됨 → return
  → ✅ 크래시 방지
```

---

## 테스트 시나리오

### 1. 상품 등록 중 뒤로가기
```
1. 상품 등록 페이지 진입
2. 상품 정보 입력 후 등록 버튼 클릭
3. 즉시 뒤로가기 (Android back 버튼 또는 AppBar back)
4. 기대: 크래시 없이 정상 종료
```

### 2. 상품 삭제 중 뒤로가기
```
1. 상품 상세 페이지 진입
2. 삭제 버튼 클릭 → 확인
3. 즉시 뒤로가기
4. 기대: 크래시 없이 정상 종료
```

### 3. 프로필 수정 중 뒤로가기
```
1. 프로필 수정 페이지 진입
2. 정보 변경 후 저장 버튼 클릭
3. 즉시 뒤로가기
4. 기대: 크래시 없이 정상 종료
```

### 4. 느린 네트워크 환경
```
1. 네트워크를 3G로 제한
2. 상품 등록 시도
3. 5초 대기 후 뒤로가기
4. 10초 후 응답 도착
5. 기대: 스낵바 표시 안 됨, 크래시 없음
```

---

## 예상 효과

### 안정성
- 간헐적 크래시 방지
- 타이밍 이슈로 인한 예측 불가능한 동작 제거
- 사용자가 빠르게 화면 전환해도 안전

### 코드 품질
- BuildContext 사용 모범 사례 준수
- Flutter 공식 가이드라인 준수
- 유지보수성 향상

---

## 관련 파일

### 수정 파일 (3개)
- `lib/feature/product/presentation/page/create_product_page.dart`
- `lib/feature/product/presentation/page/product_detail_page.dart`
- `lib/feature/profile/presentation/page/edit_profile_page.dart`

### 수정 개수
- create_product_page.dart: 2곳
- product_detail_page.dart: 6곳 (3개 리스너 × 2개 브랜치)
- edit_profile_page.dart: 2곳
- **총 10곳**

---

## 체크리스트

수정 전:
- [ ] 현재 브랜치 확인
- [ ] 백업 (git status)

수정 중:
- [ ] create_product_page.dart - 2곳 수정
- [ ] product_detail_page.dart - 6곳 수정
- [ ] edit_profile_page.dart - 2곳 수정
- [ ] 컴파일 에러 확인

수정 후:
- [ ] flutter analyze 실행
- [ ] 각 페이지 기능 테스트
- [ ] 빠른 뒤로가기 테스트
- [ ] 커밋 및 implement 파일 작성

---

## 참고 자료

### Flutter 공식 문서
- [BuildContext.mounted](https://api.flutter.dev/flutter/widgets/BuildContext/mounted.html)
- [State.mounted](https://api.flutter.dev/flutter/widgets/State/mounted.html)

### Best Practice
```dart
// ✅ 올바른 패턴
void someCallback(BuildContext context) {
  if (!context.mounted) return;
  context.go('/somewhere');
}

// ✅ State 메서드 내부
Future<void> someMethod() async {
  await future;
  if (!mounted) return;  // State의 context 사용
  setState(() {});
}

// ❌ 잘못된 패턴
void someCallback(BuildContext context) {
  if (!mounted) return;  // ❌ State.mounted 체크
  context.go('/somewhere');  // context 파라미터 사용
}
```

---

## 예상 소요 시간

- 파일 읽기 및 위치 확인: 5분
- 코드 수정 (10곳): 10분
- 테스트: 10분
- 문서 작성: 5분
- **총 30분**

---

## 커밋 메시지 (제안)

```
fix: use context.mounted instead of mounted in ref.listen callbacks

- Fix create_product_page.dart: 2 occurrences
- Fix product_detail_page.dart: 6 occurrences (3 listeners)
- Fix edit_profile_page.dart: 2 occurrences

Using State.mounted in callbacks that receive BuildContext as a
parameter can cause crashes when the context is invalidated before
the State is disposed. This change ensures we check the validity
of the specific BuildContext being used.

Fixes potential crashes when users quickly navigate away during
async operations (product creation, deletion, profile updates).

Closes #[ISSUE_NUMBER]
```
