# Route Parsing Fix Plan - Runtime Crash Prevention

**날짜**: 2026-01-06
**작업자**: Claude Code (Sonnet 4.5)
**관련 Plan**: `2026-01-06_code-review-improvement-plan.md` (Section 1.5)
**예상 소요 시간**: 15분

---

## 작업 개요

GoRouter의 경로 파라미터를 파싱할 때 `int.parse()`를 사용하면 잘못된 입력 시 런타임 크래시가 발생합니다. `int.tryParse()`를 사용하여 안전하게 처리하도록 수정합니다.

---

## 문제 분석

### 현재 상황

**파일**: `lib/core/route/app_routes.dart`

**위험한 코드**:
```dart
// Line 90: ChatRoomSelectionPage
productId: int.parse(productId),

// Line 184-186: WriteReviewPage
productId: int.parse(productId),
revieweeId: revieweeId != null ? int.parse(revieweeId) : 0,
chatRoomId: chatRoomId != null ? int.parse(chatRoomId) : 0,
```

### 문제점

**int.parse()의 위험성**:
```dart
int.parse("123")      // ✅ 123
int.parse("abc")      // 💥 FormatException: Invalid radix-10 number
int.parse("")         // 💥 FormatException: Invalid radix-10 number
int.parse("123.45")   // 💥 FormatException: Invalid radix-10 number
```

**발생 시나리오**:

1. **악의적인 URL 조작**
   ```
   https://yourapp.com/chat-room-selection/abc
   → int.parse("abc") 💥 CRASH!
   ```

2. **딥링크 URL 파싱 오류**
   ```
   yourapp://product/review/write?productId=123&revieweeId=invalid
   → int.parse("invalid") 💥 CRASH!
   ```

3. **개발 중 실수**
   ```dart
   context.go('/chat-room-selection/$someVariable');
   // someVariable이 의도치 않게 null 또는 문자열이면 크래시
   ```

4. **외부 소스에서 받은 URL**
   ```
   공유 링크: yourapp://product/999999999999999999999
   → int.parse overflow 또는 예외
   ```

---

## 해결 방안

### int.tryParse() 사용

```dart
// ✅ 안전한 패턴
final productId = int.tryParse(pathParameter) ?? 0;

// 또는 기본값 지정
final productId = int.tryParse(pathParameter) ?? -1;  // -1로 오류 표시
```

**int.tryParse()의 장점**:
```dart
int.tryParse("123")      // ✅ 123
int.tryParse("abc")      // ✅ null (크래시 없음)
int.tryParse("")         // ✅ null
int.tryParse("123.45")   // ✅ null
```

---

## 수정 대상

### 1. ChatRoomSelectionPage (Line 90)

**현재 코드**:
```dart
GoRoute(
  path: '/chat-room-selection/:id',
  name: 'chat-room-selection',
  builder: (context, state) {
    final productId = state.pathParameters['id'] ?? '';
    return ChatRoomSelectionPage(
      productId: int.parse(productId),  // ❌ 위험
    );
  },
),
```

**수정 코드**:
```dart
GoRoute(
  path: '/chat-room-selection/:id',
  name: 'chat-room-selection',
  builder: (context, state) {
    final productId = state.pathParameters['id'] ?? '';
    return ChatRoomSelectionPage(
      productId: int.tryParse(productId) ?? 0,  // ✅ 안전
    );
  },
),
```

**기본값 선택 이유**:
- `0`: 잘못된 ID, 해당 페이지에서 에러 처리 가능
- 앱 크래시보다는 에러 메시지 표시가 나음

---

### 2. WriteReviewPage (Line 184-186)

**현재 코드**:
```dart
GoRoute(
  path: '/product/:id/review/write',
  name: 'write-review',
  builder: (context, state) {
    final productId = state.pathParameters['id'] ?? '';
    final revieweeId = state.uri.queryParameters['revieweeId'];
    final chatRoomId = state.uri.queryParameters['chatRoomId'];
    final isSellerReview =
        state.uri.queryParameters['isSellerReview'] == 'true';
    return WriteReviewPage(
      productId: int.parse(productId),  // ❌
      revieweeId: revieweeId != null ? int.parse(revieweeId) : 0,  // ❌
      chatRoomId: chatRoomId != null ? int.parse(chatRoomId) : 0,  // ❌
      isSellerReview: isSellerReview,
    );
  },
),
```

**수정 코드**:
```dart
GoRoute(
  path: '/product/:id/review/write',
  name: 'write-review',
  builder: (context, state) {
    final productId = state.pathParameters['id'] ?? '';
    final revieweeId = state.uri.queryParameters['revieweeId'];
    final chatRoomId = state.uri.queryParameters['chatRoomId'];
    final isSellerReview =
        state.uri.queryParameters['isSellerReview'] == 'true';
    return WriteReviewPage(
      productId: int.tryParse(productId) ?? 0,  // ✅
      revieweeId: int.tryParse(revieweeId ?? '') ?? 0,  // ✅
      chatRoomId: int.tryParse(chatRoomId ?? '') ?? 0,  // ✅
      isSellerReview: isSellerReview,
    );
  },
),
```

**변경 내용**:
- `productId`: `int.tryParse(productId) ?? 0`
- `revieweeId`: 기존 null 체크 제거, `int.tryParse(revieweeId ?? '') ?? 0`
- `chatRoomId`: 기존 null 체크 제거, `int.tryParse(chatRoomId ?? '') ?? 0`

**더 깔끔한 패턴**:
```dart
productId: int.tryParse(productId) ?? 0,
revieweeId: int.tryParse(revieweeId ?? '') ?? 0,
chatRoomId: int.tryParse(chatRoomId ?? '') ?? 0,
```

---

## 기본값 전략

### 0을 기본값으로 선택한 이유

1. **서버 API 규약**: 대부분의 ID는 1부터 시작, 0은 유효하지 않은 ID
2. **페이지 레벨 검증**: 각 페이지에서 `id == 0`일 때 에러 처리 가능
3. **사용자 경험**: 크래시보다는 "잘못된 링크" 메시지가 나음

### 대안: -1 사용

```dart
productId: int.tryParse(productId) ?? -1,
```

**장점**: 0과 구분되어 명확히 파싱 실패를 나타냄
**단점**: 일부 API에서 음수 ID를 허용하지 않을 수 있음

**권장**: `0` 사용 (현재 코드베이스 패턴과 일치)

---

## 페이지별 에러 핸들링

수정 후 각 페이지에서 잘못된 ID 처리:

### ChatRoomSelectionPage

```dart
class ChatRoomSelectionPage extends ConsumerStatefulWidget {
  final int productId;

  @override
  void initState() {
    super.initState();

    // productId 유효성 검증
    if (widget.productId <= 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          GbSnackBar.showError(context, '잘못된 상품 링크입니다');
          context.pop();
        }
      });
      return;
    }

    // 정상 처리
    // ...
  }
}
```

### WriteReviewPage

```dart
class WriteReviewPage extends ConsumerStatefulWidget {
  final int productId;
  final int revieweeId;
  final int chatRoomId;

  @override
  void initState() {
    super.initState();

    // 유효성 검증
    if (widget.productId <= 0 || widget.revieweeId <= 0 || widget.chatRoomId <= 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          GbSnackBar.showError(context, '잘못된 링크입니다');
          context.pop();
        }
      });
      return;
    }

    // 정상 처리
    // ...
  }
}
```

**참고**: 이미 이런 검증이 있는지 확인 필요 (implement 단계에서 확인)

---

## 테스트 시나리오

### 1. 정상 케이스
```
/chat-room-selection/123
→ productId = 123 ✅

/product/456/review/write?revieweeId=789&chatRoomId=101
→ productId=456, revieweeId=789, chatRoomId=101 ✅
```

### 2. 잘못된 path 파라미터
```
/chat-room-selection/abc
→ Before: 💥 CRASH
→ After: productId = 0 → 에러 메시지 표시 ✅

/product/invalid/review/write
→ Before: 💥 CRASH
→ After: productId = 0 → 에러 메시지 표시 ✅
```

### 3. 잘못된 query 파라미터
```
/product/123/review/write?revieweeId=abc&chatRoomId=xyz
→ Before: 💥 CRASH
→ After: revieweeId=0, chatRoomId=0 → 에러 메시지 표시 ✅
```

### 4. 누락된 query 파라미터
```
/product/123/review/write
→ Before: revieweeId=0, chatRoomId=0 (이미 처리됨)
→ After: 동일 ✅
```

### 5. 딥링크 공유
```
사용자가 잘못된 딥링크 공유:
yourapp://chat-room-selection/product-123

→ Before: 💥 CRASH
→ After: 에러 메시지 "잘못된 링크입니다" ✅
```

---

## 예상 효과

### 안정성
- 잘못된 URL 입력 시 크래시 방지
- 외부에서 공유받은 딥링크 안전 처리
- 개발 중 실수로 인한 크래시 방지

### 사용자 경험
- 크래시 대신 명확한 에러 메시지
- 잘못된 링크 클릭 시 우아한 처리
- 앱이 종료되지 않고 이전 화면으로 복귀 가능

### 보안
- URL 조작 시도 시 크래시 방지
- 악의적인 딥링크 공격 방어

---

## 관련 파일

### 수정 파일 (1개)
- `lib/core/route/app_routes.dart`

### 수정 위치
- Line 90: ChatRoomSelectionPage (1곳)
- Line 184-186: WriteReviewPage (3곳)
- **총 4곳**

### 영향받는 페이지 (확인 필요)
- `lib/feature/chat/presentation/page/chat_room_selection_page.dart`
- `lib/feature/review/presentation/page/write_review_page.dart`

---

## 추가 고려사항

### 1. 다른 route에도 적용

프로젝트 전체에서 int.parse() 사용 위치 검색:

```bash
grep -r "int.parse" lib/core/route --include="*.dart"
```

**발견 시**: 모두 int.tryParse()로 변경

### 2. Product Detail 같은 주요 페이지

이미 안전한지 확인:
```dart
// lib/core/route/app_routes.dart
GoRoute(
  path: '/product/:id',
  builder: (context, state) {
    final productId = state.pathParameters['id'] ?? '';
    return ProductDetailPage(productId: productId);  // String 전달
  },
),

// ProductDetailPage에서 파싱
final id = int.parse(widget.productId);  // ❌ 여기도 위험!
```

**확인 필요**: ProductDetailPage 내부 구현

### 3. 모범 사례 확립

향후 새 route 추가 시:
```dart
// ✅ 권장 패턴
final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;

// ❌ 피해야 할 패턴
final id = int.parse(state.pathParameters['id'] ?? '');
```

---

## 체크리스트

수정 전:
- [ ] 현재 브랜치 확인
- [ ] app_routes.dart 백업

수정 중:
- [ ] Line 90 수정 (ChatRoomSelectionPage)
- [ ] Line 184 수정 (WriteReviewPage productId)
- [ ] Line 185 수정 (WriteReviewPage revieweeId)
- [ ] Line 186 수정 (WriteReviewPage chatRoomId)
- [ ] 컴파일 에러 확인

수정 후:
- [ ] flutter analyze 실행
- [ ] 정상 케이스 테스트
- [ ] 잘못된 URL 테스트 (수동)
- [ ] ProductDetailPage 같은 다른 파일도 확인
- [ ] 커밋 및 implement 파일 작성

---

## 참고 자료

### Dart 공식 문서
- [int.parse](https://api.dart.dev/stable/dart-core/int/parse.html)
  > "Throws a FormatException if the source string does not contain a valid integer literal."

- [int.tryParse](https://api.dart.dev/stable/dart-core/int/tryParse.html)
  > "Returns null if the source string does not contain a valid integer literal."

### GoRouter Best Practices
```dart
// ✅ Safe route parsing
builder: (context, state) {
  final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
  if (id <= 0) {
    // Handle error
  }
  return MyPage(id: id);
}
```

---

## 예상 소요 시간

- 파일 읽기 및 위치 확인: 3분
- 코드 수정 (4곳): 5분
- 테스트: 5분
- 문서 작성: 2분
- **총 15분**

---

## 커밋 메시지 (제안)

```
fix: use int.tryParse to prevent route parsing crashes

- Replace int.parse with int.tryParse in app_routes.dart
- ChatRoomSelectionPage: safe productId parsing (line 90)
- WriteReviewPage: safe productId, revieweeId, chatRoomId parsing (line 184-186)
- Default to 0 for invalid integer parameters

This prevents runtime crashes when users receive malformed deep links
or when URL parameters are manually manipulated. Invalid IDs (0) will
be handled gracefully at the page level with error messages instead
of app crashes.

Closes #[ISSUE_NUMBER]
```
