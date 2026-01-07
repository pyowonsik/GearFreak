# BuildContext Safety Fixes - Implementation Log

**날짜**: 2026-01-06
**작업자**: Claude Code (Sonnet 4.5)
**관련 Plan**: `2026-01-06_buildcontext-safety-fix-plan.md`
**작업 시간**: ~20분

---

## 작업 개요

`ref.listen` 콜백 내부에서 BuildContext를 사용할 때, State의 `mounted` 대신 `context.mounted`를 사용하도록 수정했습니다. 이를 통해 간헐적인 크래시를 방지하고 Flutter 모범 사례를 준수합니다.

---

## 문제점

### 기존 패턴 (잘못됨)

```dart
@override
Widget build(BuildContext context) {
  ref.listen<SomeState>(
    someNotifierProvider,
    (previous, next) {
      if (!mounted) return;  // ❌ State.mounted 체크
      context.go('/somewhere');  // BuildContext 사용
    },
  );
}
```

**문제**:
- `ref.listen` 콜백은 State가 dispose된 직후에도 호출될 수 있음
- State의 `mounted`는 `true`여도 `context`는 이미 무효화되었을 수 있음
- 무효화된 context로 navigation하면 크래시 발생

### 수정 패턴 (올바름)

```dart
@override
Widget build(BuildContext context) {
  ref.listen<SomeState>(
    someNotifierProvider,
    (previous, next) {
      if (!context.mounted) return;  // ✅ context.mounted 체크
      context.go('/somewhere');
    },
  );
}
```

---

## 수정 내역

### 1. create_product_page.dart

**파일**: `lib/feature/product/presentation/page/create_product_page.dart`
**라인**: 52

**Before**:
```dart
ref.listen<CreateProductState>(
  createProductNotifierProvider,
  (previous, next) {
    if (!mounted) return;  // ❌

    if (next is CreateProductUploadError) {
      GbSnackBar.showError(context, next.error);
    }
    // ...
  },
);
```

**After**:
```dart
ref.listen<CreateProductState>(
  createProductNotifierProvider,
  (previous, next) {
    if (!context.mounted) return;  // ✅

    if (next is CreateProductUploadError) {
      GbSnackBar.showError(context, next.error);
    }
    // ...
  },
);
```

---

### 2. update_product_page.dart

**파일**: `lib/feature/product/presentation/page/update_product_page.dart`
**라인**: 96

**Before**:
```dart
ref.listen<UpdateProductState>(
  updateProductNotifierProvider,
  (previous, next) {
    if (!mounted) return;  // ❌

    if (next is UpdateProductUploadError) {
      GbSnackBar.showError(context, next.error);
    }
    // ...
  },
);
```

**After**:
```dart
ref.listen<UpdateProductState>(
  updateProductNotifierProvider,
  (previous, next) {
    if (!context.mounted) return;  // ✅

    if (next is UpdateProductUploadError) {
      GbSnackBar.showError(context, next.error);
    }
    // ...
  },
);
```

---

### 3. edit_profile_page.dart

**파일**: `lib/feature/profile/presentation/page/edit_profile_page.dart`
**라인**: 155, 160

**Before**:
```dart
ref.listen<ProfileState>(
  profileNotifierProvider,
  (previous, next) {
    if (!mounted) return;  // ❌ Line 155

    if (next is ProfileUpdated) {
      GbSnackBar.showSuccess(context, '프로필이 저장되었습니다');
      if (mounted) {  // ❌ Line 160
        ref.read(profileNotifierProvider.notifier).loadProfile();
        context.pop();
      }
    }
    // ...
  },
);
```

**After**:
```dart
ref.listen<ProfileState>(
  profileNotifierProvider,
  (previous, next) {
    if (!context.mounted) return;  // ✅ Line 155

    if (next is ProfileUpdated) {
      GbSnackBar.showSuccess(context, '프로필이 저장되었습니다');
      if (context.mounted) {  // ✅ Line 160
        ref.read(profileNotifierProvider.notifier).loadProfile();
        context.pop();
      }
    }
    // ...
  },
);
```

---

## 수정하지 않은 경우

### State 메서드 내부의 mounted는 유지

일반 State 메서드 내부에서는 State의 `mounted`를 사용하는 것이 맞습니다:

**예시 (create_product_page.dart Line 170)**:
```dart
Future<void> _selectImages() async {
  final images = await ImagePicker().pickMultiImage();

  for (final image in images) {
    // 이미지 업로드...

    final currentState = ref.read(createProductNotifierProvider);
    if (currentState is CreateProductUploadSuccess) {
      setState(() {
        _selectedImages.add(image);
      });
    } else if (currentState is CreateProductUploadError) {
      if (!mounted) return;  // ✅ 이건 그대로 유지 (State 메서드 내부)
      GbSnackBar.showError(context, '업로드 실패');
    }
  }
}
```

**이유**:
- State 메서드 내부에서는 State의 context를 사용하므로 State.mounted 체크가 맞음
- 함수 파라미터로 받은 context가 아님

---

## 테스트 수행

### 컴파일 확인
```bash
flutter analyze
```
**결과**: No issues found ✅

### 기능 테스트 (예정)
- [ ] 상품 등록 중 뒤로가기
- [ ] 상품 수정 중 뒤로가기
- [ ] 프로필 수정 중 뒤로가기
- [ ] 느린 네트워크 환경에서 테스트

---

## 수정 전/후 비교

### Before (문제 상황)

```
User: 상품 등록 요청
→ API 호출 시작

User: 빠르게 뒤로가기 (dispose 시작)
→ State.mounted = false (곧 true일 수도)
→ context는 이미 무효화됨

Server: 응답 도착
→ ref.listen 콜백 실행
→ if (!mounted) return;
→ mounted가 false면 return ✅
→ BUT 타이밍 이슈로 mounted가 true면?
→ context.pop() 실행
→ 💥 CRASH! (context 무효화됨)
```

### After (수정 후)

```
User: 상품 등록 요청
→ API 호출 시작

User: 빠르게 뒤로가기 (dispose 시작)
→ context 무효화됨

Server: 응답 도착
→ ref.listen 콜백 실행
→ if (!context.mounted) return;
→ context가 무효화됨 → return ✅
→ ✅ 크래시 방지
```

---

## 수정 통계

| 파일 | 수정 라인 | 수정 개수 |
|-----|---------|---------|
| `create_product_page.dart` | 52 | 1 |
| `update_product_page.dart` | 96 | 1 |
| `edit_profile_page.dart` | 155, 160 | 2 |
| **총계** | | **4** |

---

## 예상 효과

### 안정성 향상
- 간헐적 크래시 방지 (특히 빠른 화면 전환 시)
- 타이밍 이슈로 인한 예측 불가능한 동작 제거
- 프로덕션 환경에서 안정성 개선

### 코드 품질
- Flutter 공식 가이드라인 준수
- BuildContext 사용 모범 사례 적용
- 유지보수성 향상

### 사용자 경험
- 빠른 화면 전환 시에도 안정적 동작
- 불필요한 스낵바 표시 방지 (화면 이미 닫힌 경우)
- 예상치 못한 크래시 감소

---

## 추가 작업 필요 사항

### 즉시 작업
없음 - 모든 ref.listen 콜백의 BuildContext 안전성 수정 완료 ✅

### 향후 고려사항
1. **린트 룰 추가**: ref.listen 내부에서 mounted 사용 시 경고
   - custom_lint 또는 analyzer 플러그인 설정

2. **통합 테스트**: 빠른 화면 전환 시나리오 자동화 테스트

3. **코드 리뷰 체크리스트**: PR 리뷰 시 BuildContext 사용 패턴 확인

---

## 관련 파일

### 수정된 파일 (3개)
- [x] `lib/feature/product/presentation/page/create_product_page.dart`
- [x] `lib/feature/product/presentation/page/update_product_page.dart`
- [x] `lib/feature/profile/presentation/page/edit_profile_page.dart`

### 확인한 파일 (수정 불필요)
- [x] `lib/feature/auth/presentation/page/signup_page.dart` - mounted 사용 안 함
- [x] `lib/feature/auth/presentation/page/login_page.dart` - mounted 사용 안 함
- [x] `lib/feature/product/presentation/page/product_detail_page.dart` - ref.listen 없음

---

## 체크리스트

수정 작업:
- [x] create_product_page.dart 수정
- [x] update_product_page.dart 수정
- [x] edit_profile_page.dart 수정
- [x] 전체 프로젝트 ref.listen 검색
- [x] 컴파일 에러 확인

후속 작업:
- [ ] 실제 기기에서 기능 테스트
- [ ] 빠른 뒤로가기 시나리오 테스트
- [ ] 네트워크 지연 환경 테스트
- [ ] 커밋 및 PR 생성

---

## 커밋 메시지 (제안)

```
fix: use context.mounted instead of mounted in ref.listen callbacks

- Fix create_product_page.dart ref.listen callback
- Fix update_product_page.dart ref.listen callback
- Fix edit_profile_page.dart ref.listen callback (2 occurrences)

Using State.mounted in ref.listen callbacks that use BuildContext
can cause crashes when the context is invalidated before the State
is disposed. This change ensures we check the validity of the
specific BuildContext being used.

This prevents potential crashes when users quickly navigate away
during async operations (product creation/update, profile update).

Follows Flutter best practices for BuildContext safety across
async gaps in callbacks.

Closes #[ISSUE_NUMBER]
```

---

## 참고 자료

### Flutter 공식 문서
- [BuildContext.mounted](https://api.flutter.dev/flutter/widgets/BuildContext/mounted.html)
  > "Whether the BuildContext is currently in the tree."

- [State.mounted](https://api.flutter.dev/flutter/widgets/State/mounted.html)
  > "Whether this State object is currently in a tree."

### Best Practice 패턴

```dart
// ✅ ref.listen 콜백: context.mounted 사용
ref.listen<SomeState>(
  someProvider,
  (previous, next) {
    if (!context.mounted) return;
    context.go('/somewhere');
  },
);

// ✅ State 메서드: State.mounted 사용
Future<void> someMethod() async {
  await someAsyncOperation();
  if (!mounted) return;
  setState(() {});
}

// ❌ 잘못된 패턴
ref.listen<SomeState>(
  someProvider,
  (previous, next) {
    if (!mounted) return;  // ❌ State.mounted
    context.go('/somewhere');  // BuildContext 사용
  },
);
```

---

## 결론

ref.listen 콜백 내부의 BuildContext 안전성 문제를 성공적으로 수정했습니다:
- ✅ 3개 파일, 4곳 수정
- ✅ `mounted` → `context.mounted` 변경
- ✅ 간헐적 크래시 방지
- ✅ Flutter 모범 사례 준수
- ✅ 컴파일 에러 없음

**다음 단계**: 실제 기기에서 빠른 화면 전환 시나리오 테스트 후 커밋
