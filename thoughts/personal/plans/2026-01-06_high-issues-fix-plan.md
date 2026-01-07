# HIGH Priority Issues Fix Plan

**날짜**: 2026-01-06
**작업자**: Claude Code (Sonnet 4.5)
**관련 Plan**: `2026-01-06_code-review-improvement-plan.md` (PHASE 2)
**예상 소요 시간**: 1시간

---

## 작업 개요

코드 리뷰에서 발견된 HIGH 우선순위 이슈들을 수정합니다. 보안, 성능, 일관성 문제를 해결하여 프로덕션 배포 전에 안정성을 높입니다.

---

## HIGH 이슈 목록 (총 5개)

| # | 이슈 | 우선순위 | 파일 수 | 예상 시간 |
|---|------|---------|--------|---------|
| 2.1 | 민감 정보 로깅 | HIGH | 3 | 15분 |
| 2.2 | Open Redirect 취약점 | HIGH | 1 | 10분 |
| 2.3 | Nested ListView 성능 | HIGH | 2 | 15분 |
| 2.4 | Chat 메시지 중복 | HIGH | 1 | 15분 |
| 2.5 | FCM 콜백 미정리 | ~~HIGH~~ | - | **이미 완료** ✅ |
| 2.6 | GbDialog/SnackBar 미사용 | HIGH | 2 | 10분 |

**참고**: 2.5는 메모리 누수 수정 시 이미 처리됨

---

## 2.1 보안 - 민감 정보 로깅

### 문제점

**파일들**:
- `lib/shared/service/fcm_service.dart` (Line 54, 75, 104)
- `lib/shared/feature/s3/data/datasource/s3_remote_datasource.dart` (Line 43-44)
- `lib/feature/auth/data/datasource/auth_remote_datasource.dart` (Line 60)

**문제**: FCM 토큰, 이메일 등 민감 정보가 로그에 노출됨

```dart
// ❌ 위험: 프로덕션 로그에 토큰 노출
debugPrint('📱 FCM token retrieved: ${token.substring(0, 30)}...');

// ❌ 위험: 이메일 노출
debugPrint('📝 회원가입 시작: email=$email');
```

### 해결 방안

**Option 1: 완전 마스킹** (권장)
```dart
// ✅ 안전
debugPrint('📱 FCM token retrieved: [MASKED]');
debugPrint('📝 회원가입 시작: email=[MASKED]');
```

**Option 2: 부분 마스킹**
```dart
// ✅ 디버깅 가능하면서 안전
debugPrint('📱 FCM token: ${_maskToken(token)}');  // abc...xyz
debugPrint('📝 회원가입: ${_maskEmail(email)}');   // u***@example.com
```

### 수정 목록

#### 1. fcm_service.dart

**Line 54, 75, 104**:
```dart
// Before
debugPrint('📱 FCM token retrieved: ${token.substring(0, 30)}...');
debugPrint('📱 FCM token refreshed: ${newToken.substring(0, 30)}...');
debugPrint('✅ FCM token registered: ${token.substring(0, 20)}...');

// After
debugPrint('📱 FCM token retrieved: [MASKED]');
debugPrint('📱 FCM token refreshed: [MASKED]');
debugPrint('✅ FCM token registered: [MASKED]');
```

#### 2. s3_remote_datasource.dart

**Line 43-44**:
```dart
// Before
debugPrint('📤 S3 업로드 시작: ${request.fileName}');
debugPrint('📤 Presigned URL: ${uploadUrl.substring(0, 50)}...');

// After
debugPrint('📤 S3 업로드 시작: ${request.fileName}');
debugPrint('📤 Presigned URL: [MASKED]');
```

#### 3. auth_remote_datasource.dart

**Line 60**:
```dart
// Before
debugPrint('📝 회원가입 시작: email=$email');

// After
debugPrint('📝 회원가입 시작: email=[MASKED]');
```

---

## 2.2 Open Redirect 취약점

### 문제점

**파일**: `lib/core/route/app_route_guard.dart`
**라인**: 173, 183-187

**문제**: redirect 파라미터를 검증 없이 사용

```dart
// ❌ 위험: 악의적인 URL로 리다이렉트 가능
final redirect = state.uri.queryParameters['redirect'];
if (redirect != null) {
  return redirect;  // https://evil.com 가능!
}
```

**공격 시나리오**:
```
1. 공격자: https://yourapp.com/login?redirect=https://phishing.com 공유
2. 사용자: 로그인 성공
3. 앱: phishing.com으로 자동 리다이렉트
4. 사용자: 피싱 사이트에서 개인정보 입력
```

### 해결 방안

**화이트리스트 검증**:
```dart
String? _validateRedirect(String? redirect) {
  if (redirect == null || redirect.isEmpty) return null;

  // 1. 내부 경로만 허용 (외부 URL 차단)
  if (!redirect.startsWith('/')) return null;

  // 2. 허용된 경로 prefix 체크
  final allowedPrefixes = [
    '/',
    '/product',
    '/chat',
    '/profile',
    '/review',
    '/notifications',
  ];

  final isAllowed = allowedPrefixes.any(
    (prefix) => redirect.startsWith(prefix),
  );

  return isAllowed ? redirect : null;
}
```

### 수정 위치

**Line 173, 183-187**:
```dart
// Before
final redirect = state.uri.queryParameters['redirect'];
if (redirect != null && redirect.isNotEmpty) {
  return redirect;  // ❌ 위험
}

// After
final redirect = _validateRedirect(
  state.uri.queryParameters['redirect'],
);
if (redirect != null) {
  return redirect;  // ✅ 안전
}
```

---

## 2.3 Nested ListView 성능 문제

### 문제점

**파일들**:
- `lib/feature/search/presentation/view/search_loaded_view.dart` (Line 85-89)
- `lib/feature/product/presentation/view/profile_product_list_view.dart` (Line 63-67)

**문제**: `shrinkWrap: true`로 전체 아이템 한 번에 빌드

```dart
// ❌ 성능 문제
ListView(
  children: [
    SomeWidget(),
    ListView.builder(
      shrinkWrap: true,  // 모든 아이템 즉시 빌드!
      physics: NeverScrollableScrollPhysics(),
      itemCount: 1000,  // 1000개 위젯 전부 생성
      itemBuilder: (context, index) => ...,
    ),
  ],
)
```

**문제점**:
- 1000개 아이템이 있으면 1000개 위젯 모두 빌드
- 메모리 사용량 증가
- 초기 렌더링 느림
- 스크롤 성능 저하

### 해결 방안

**Option 1: CustomScrollView + Slivers** (권장)
```dart
CustomScrollView(
  slivers: [
    SliverToBoxAdapter(child: SomeWidget()),
    SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => ProductCard(...),
        childCount: products.length,
      ),
    ),
  ],
)
```

**Option 2: 단일 ListView**
```dart
ListView.builder(
  itemCount: products.length + 1,  // +1 for header
  itemBuilder: (context, index) {
    if (index == 0) return SomeWidget();
    return ProductCard(products[index - 1]);
  },
)
```

### 수정 목록

#### 1. search_loaded_view.dart

**Before** (Line 85-89):
```dart
ListView(
  children: [
    SearchHeader(),
    ListView.builder(
      shrinkWrap: true,  // ❌
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: ...,
    ),
  ],
)
```

**After**:
```dart
CustomScrollView(
  slivers: [
    SliverToBoxAdapter(child: SearchHeader()),
    SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => ProductCard(...),
        childCount: products.length,
      ),
    ),
  ],
)
```

#### 2. profile_product_list_view.dart

**Before** (Line 63-67):
```dart
ListView(
  children: [
    ProfileHeader(),
    ListView.builder(
      shrinkWrap: true,  // ❌
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: ...,
    ),
  ],
)
```

**After**:
```dart
CustomScrollView(
  slivers: [
    SliverToBoxAdapter(child: ProfileHeader()),
    SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => ProductCard(...),
        childCount: products.length,
      ),
    ),
  ],
)
```

---

## 2.4 Chat 메시지 중복 경쟁 조건

### 문제점

**파일**: `lib/feature/chat/presentation/provider/chat_notifier.dart`
**라인**: 597-612, 744

**문제**: 중복 체크가 로컬 복사본에서만 수행됨

```dart
// ❌ 문제 코드
void _handleNewMessage(Message message) {
  final currentMessages = List<Message>.from(state.messages);

  // 중복 체크
  if (currentMessages.any((m) => m.id == message.id)) {
    return;  // 중복이면 무시
  }

  currentMessages.add(message);
  state = state.copyWith(messages: currentMessages);
}

// 문제: 동시에 같은 메시지가 2번 도착하면?
// Thread 1: any() 체크 → false → add
// Thread 2: any() 체크 → false → add
// 결과: 중복 메시지!
```

### 해결 방안

**처리된 메시지 ID Set 유지**:
```dart
class ChatNotifier extends StateNotifier<ChatState> {
  final Set<int> _processedMessageIds = {};

  void _handleNewMessage(Message message) {
    // ✅ Set으로 원자적 중복 체크
    if (_processedMessageIds.contains(message.id)) {
      debugPrint('⏭️ 중복 메시지 무시: ${message.id}');
      return;
    }

    _processedMessageIds.add(message.id);

    final currentMessages = List<Message>.from(state.messages);
    currentMessages.add(message);
    state = state.copyWith(messages: currentMessages);
  }

  @override
  void dispose() {
    _processedMessageIds.clear();
    super.dispose();
  }
}
```

### 수정 위치

**Line 93 (필드 추가)**:
```dart
// 메시지 중복 방지용 Set
final Set<int> _processedMessageIds = {};
```

**Line 597-612 (중복 체크 로직)**:
```dart
// Before
if (currentMessages.any((m) => m.id == newMessage.id)) {
  return;
}

// After
if (_processedMessageIds.contains(newMessage.id)) {
  debugPrint('⏭️ 중복 메시지 무시: ${newMessage.id}');
  return;
}
_processedMessageIds.add(newMessage.id);
```

**Line 838-843 (dispose)**:
```dart
@override
void dispose() {
  _messageStreamSubscription?.cancel();
  _reconnectTimer?.cancel();
  _processedMessageIds.clear();  // 추가
  super.dispose();
}
```

---

## 2.5 FCM 콜백 로그아웃 시 미정리

**상태**: ✅ **이미 완료**

메모리 누수 수정 시 `deleteToken()`에서 이미 처리됨:
```dart
Future<void> deleteToken() async {
  // ...
  finally {
    _currentToken = null;
    onMessageReceived = null;  // ✅ 이미 추가됨
    onNotificationReceived = null;  // ✅ 이미 추가됨
  }
}
```

**추가 작업 불필요** ✅

---

## 2.6 GbDialog/GbSnackBar 미사용

### 문제점

**파일들**:
- `lib/feature/chat/presentation/widget/chat_room_item_widget.dart` (Line 138-158, 168-181)
- `lib/feature/chat/presentation/view/chat_loaded_view.dart` (Line 182-184, 261-269)

**문제**: Flutter 기본 AlertDialog/ScaffoldMessenger 사용

```dart
// ❌ 일관성 없음
showDialog(
  context: context,
  builder: (context) => AlertDialog(
    title: Text('삭제 확인'),
    actions: [...],
  ),
);

ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(content: Text('메시지')),
);
```

**프로젝트 규칙**: 공통 UI 컴포넌트 사용
- `GbDialog.show()` - AlertDialog 대체
- `GbSnackBar.showSuccess/Error()` - SnackBar 대체

### 해결 방안

#### 1. chat_room_item_widget.dart

**Line 138-158 (채팅방 나가기 다이얼로그)**:
```dart
// Before
showDialog<bool>(
  context: context,
  builder: (context) => AlertDialog(
    title: const Text('채팅방 나가기'),
    content: const Text('정말 나가시겠습니까?'),
    actions: [
      TextButton(...),
      TextButton(...),
    ],
  ),
);

// After
GbDialog.show(
  context: context,
  title: '채팅방 나가기',
  content: '정말 나가시겠습니까?',
  confirmText: '나가기',
  cancelText: '취소',
);
```

**Line 168-181 (채팅방 삭제 다이얼로그)**:
```dart
// 동일한 패턴으로 수정
```

#### 2. chat_loaded_view.dart

**Line 182-184 (스낵바)**:
```dart
// Before
ScaffoldMessenger.of(context).showSnackBar(
  const SnackBar(content: Text('메시지를 입력해주세요')),
);

// After
GbSnackBar.showWarning(context, message: '메시지를 입력해주세요');
```

**Line 261-269 (다이얼로그)**:
```dart
// Before: AlertDialog 사용
// After: GbDialog.show() 사용
```

---

## 테스트 체크리스트

### 2.1 민감 정보 로깅
- [ ] 프로덕션 빌드 후 로그 확인
- [ ] FCM 토큰이 [MASKED]로 표시되는지 확인
- [ ] 이메일이 [MASKED]로 표시되는지 확인

### 2.2 Open Redirect
- [ ] `/login?redirect=/product/123` - 정상 동작
- [ ] `/login?redirect=https://evil.com` - 무시됨
- [ ] `/login?redirect=/unknown` - 무시됨

### 2.3 Nested ListView
- [ ] 검색 결과 100개 - 스크롤 성능 확인
- [ ] 프로필 상품 목록 - 메모리 사용량 확인
- [ ] Flutter DevTools Performance 탭에서 jank 확인

### 2.4 Chat 중복
- [ ] 동일 메시지 빠르게 2번 전송
- [ ] 네트워크 지연 후 재전송
- [ ] 중복 메시지가 UI에 나타나지 않는지 확인

### 2.6 GbDialog/SnackBar
- [ ] 채팅방 나가기 다이얼로그 - GbDialog 스타일
- [ ] 채팅방 삭제 다이얼로그 - GbDialog 스타일
- [ ] 메시지 입력 경고 - GbSnackBar 스타일

---

## 예상 효과

### 보안 강화
- 민감 정보 로그 노출 방지
- Open Redirect 공격 방어
- 프로덕션 환경 안전성 향상

### 성능 개선
- Nested ListView 제거로 메모리 사용량 감소
- 초기 렌더링 속도 향상
- 스크롤 성능 개선

### 안정성 향상
- Chat 메시지 중복 방지
- 일관된 UI/UX (GbDialog/SnackBar)

---

## 관련 파일 목록

### 수정 파일 (총 7개)

| 파일 | 이슈 | 수정 개수 |
|-----|------|---------|
| `fcm_service.dart` | 2.1 | 3 |
| `s3_remote_datasource.dart` | 2.1 | 1 |
| `auth_remote_datasource.dart` | 2.1 | 1 |
| `app_route_guard.dart` | 2.2 | 2 + 함수 추가 |
| `search_loaded_view.dart` | 2.3 | 1 (구조 변경) |
| `profile_product_list_view.dart` | 2.3 | 1 (구조 변경) |
| `chat_notifier.dart` | 2.4 | 3 |
| `chat_room_item_widget.dart` | 2.6 | 2 |
| `chat_loaded_view.dart` | 2.6 | 2 |

---

## 체크리스트

수정 전:
- [ ] 현재 브랜치 확인
- [ ] 백업 커밋 생성

수정 중:
- [ ] 2.1 민감 정보 마스킹 (3파일)
- [ ] 2.2 Open Redirect 검증
- [ ] 2.3 Nested ListView 수정 (2파일)
- [ ] 2.4 Chat 중복 방지
- [ ] 2.5 확인 (이미 완료)
- [ ] 2.6 GbDialog/SnackBar 교체 (2파일)
- [ ] 컴파일 에러 확인

수정 후:
- [ ] flutter analyze 실행
- [ ] 각 이슈별 기능 테스트
- [ ] 커밋 및 implement 파일 작성

---

## 커밋 메시지 (제안)

```
fix(high): resolve security, performance, and consistency issues

Security:
- Mask sensitive info in logs (FCM tokens, emails, URLs)
- Add redirect parameter validation to prevent open redirect attacks

Performance:
- Replace nested ListView with CustomScrollView + Slivers
- Remove shrinkWrap: true to improve memory usage

Stability:
- Prevent duplicate chat messages using Set-based tracking
- Replace AlertDialog/SnackBar with GbDialog/GbSnackBar for consistency

This addresses 5 HIGH priority issues identified in code review:
- 2.1: Sensitive info logging → [MASKED]
- 2.2: Open redirect → Whitelist validation
- 2.3: Nested ListView → Sliver pattern
- 2.4: Chat duplication → Set-based deduplication
- 2.6: Widget consistency → Gb* components

Closes #[ISSUE_NUMBER]
```
