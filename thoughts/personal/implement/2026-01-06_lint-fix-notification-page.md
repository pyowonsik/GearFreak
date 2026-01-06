# 2026-01-06 | Notification Page Lint Fix

## 작업 내용
알림 리스트 페이지의 `use_build_context_synchronously` 린트 경고 해결

## 파일
- `lib/feature/notification/presentation/page/notification_list_page.dart`

## 문제
함수 파라미터로 받은 `BuildContext context`를 async gap을 넘어 사용할 때 State의 `mounted`로 체크하여 린트 경고 발생

## 해결 방법
State의 `mounted` 대신 BuildContext의 `context.mounted`로 체크

### 변경 사항
```dart
// Before
if (!mounted) return;
await context.push('/profile/reviews?tabIndex=1');

// After
if (!context.mounted) return;
await context.push('/profile/reviews?tabIndex=1');
```

## 핵심 포인트
- 함수 파라미터로 받은 `BuildContext`를 async 작업 이후 사용할 때는 `context.mounted` 체크 필요
- State의 `mounted`와 BuildContext의 `mounted`는 다른 것
- async gap 이후 navigation을 사용하는 경우 반드시 `context.mounted` 체크 후 사용

## 수정된 위치
- Line 235: `if (mounted)` → `if (context.mounted)`
- Line 248: `if (!mounted)` → `if (!context.mounted)`
- Line 262: `if (!mounted)` → `if (!context.mounted)`
- Line 285: `mounted` → `context.mounted`

## 결과
✅ 린트 경고 해결
✅ 기능상 문제 없음
✅ 코드 품질 개선
