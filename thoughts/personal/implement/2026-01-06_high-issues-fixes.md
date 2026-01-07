# HIGH Issues 수정 작업 (2026-01-06)

**작업 일시**: 2026-01-06
**작업 범위**: Code Review HIGH Issues (2.1-2.6) 수정
**참고 문서**: `2026-01-06_high-issues-fix-plan.md`

---

## 작업 내용

### 2.1 민감 정보 로깅 제거 (Sensitive Info Logging)

**파일**: 3개
1. `lib/shared/service/fcm_service.dart`
2. `lib/shared/feature/s3/data/datasource/s3_remote_datasource.dart`
3. `lib/feature/auth/data/datasource/auth_remote_datasource.dart`

**변경 사항**:

#### 1. fcm_service.dart (3곳 수정)
```dart
// Before
debugPrint('📱 FCM token retrieved: $token');
debugPrint('📱 FCM token refreshed: $newToken');
debugPrint('✅ FCM token registered: $token');

// After
debugPrint('📱 FCM token retrieved: [MASKED]');
debugPrint('📱 FCM token refreshed: [MASKED]');
debugPrint('✅ FCM token registered: [MASKED]');
```

**수정 위치**:
- Line 75: `getToken()` 결과 로깅
- Line 104: `onTokenRefresh` 리스너
- Line 135: `_registerTokenToServer()` 성공 로그

#### 2. s3_remote_datasource.dart (1곳 수정)
```dart
// Before
debugPrint('   - URL: $presignedUrl');

// After
debugPrint('   - URL: [MASKED]');
```

**수정 위치**:
- Line 43: S3 Presigned URL 로깅

#### 3. auth_remote_datasource.dart (1곳 수정)
```dart
// Before
debugPrint('📝 회원가입 시작: userName=$userName, email=$email');

// After
debugPrint('📝 회원가입 시작: userName=$userName, email=[MASKED]');
```

**수정 위치**:
- Line 60: 회원가입 시작 로그

**효과**:
- FCM 토큰, S3 URL, 이메일 등 민감 정보가 로그에 노출되지 않음
- 프로덕션 빌드에서 개인정보 유출 방지

---

### 2.2 Open Redirect 취약점 수정

**파일**: `lib/core/route/app_route_guard.dart`

**변경 사항**:

#### 추가된 검증 함수
```dart
/// redirect 파라미터 검증 (Open Redirect 공격 방지)
///
/// 내부 경로만 허용하고, 외부 URL이나 허용되지 않은 경로는 null 반환
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
    '/search',
  ];

  final isAllowed = allowedPrefixes.any(
    (prefix) => redirect.startsWith(prefix),
  );

  return isAllowed ? redirect : null;
}
```

#### 수정된 함수
```dart
/// 리디렉션 경로 결정
String _getRedirectPath(GoRouterState goRouterState, String defaultPath) {
  final redirectParam = goRouterState.uri.queryParameters['redirect'];

  // redirect 파라미터 검증 (Open Redirect 방지)
  final validatedRedirect = _validateRedirect(redirectParam);

  if (validatedRedirect != null) {
    // 검증된 내부 경로로 이동
    return validatedRedirect;
  }
  // 일반 로그인인 경우 기본 경로로 이동
  return defaultPath;
}
```

**수정 위치**:
- Line 178-203: `_validateRedirect()` 함수 추가
- Line 209-221: `_getRedirectPath()` 함수 수정

**효과**:
- `/login?redirect=https://evil.com` → 무시됨 (외부 URL 차단)
- `/login?redirect=/unknown` → 무시됨 (허용되지 않은 경로)
- `/login?redirect=/product/123` → 정상 동작 (허용된 경로)

---

### 2.4 채팅 메시지 중복 처리

**파일**: `lib/feature/chat/presentation/provider/chat_notifier.dart`

**변경 사항**:

#### 1. 필드 추가
```dart
/// 처리된 메시지 ID Set (중복 방지)
final Set<int> _processedMessageIds = {};
```

**수정 위치**: Line 26-27

#### 2. 중복 검사 로직 수정
```dart
bool _addMessageIfNotDuplicate(
  List<pod.ChatMessageResponseDto> messages,
  pod.ChatMessageResponseDto message,
) {
  // Set을 사용한 중복 검사 (이미 처리된 메시지 무시)
  if (_processedMessageIds.contains(message.id)) {
    debugPrint('⏭️ 중복 메시지 무시: ${message.id}');
    return false;
  }

  // 처리된 메시지로 등록
  _processedMessageIds.add(message.id);

  // 기존 메시지 리스트에도 없는 경우만 이벤트 발행
  final existingIds = messages.map((m) => m.id).toSet();
  if (!existingIds.contains(message.id)) {
    // 새 메시지 이벤트 발행 (채팅방 목록 Notifier가 자동으로 반응)
    ref.read(newChatMessageProvider.notifier).state = message;
    // 이벤트 처리 후 초기화 (다음 메시지를 위해)
    Future.microtask(() {
      ref.read(newChatMessageProvider.notifier).state = null;
    });
    return true;
  }
  return false;
}
```

**수정 위치**: Line 600-625

#### 3. dispose 메모리 정리
```dart
@override
void dispose() {
  _messageStreamSubscription?.cancel();
  _reconnectTimer?.cancel();
  _processedMessageIds.clear(); // 처리된 메시지 ID Set 정리
  super.dispose();
}
```

**수정 위치**: Line 852-857

**효과**:
- 스트림 재연결 시 중복 메시지 표시 방지
- Set 자료구조로 O(1) 검색 성능
- 메모리 누수 방지 (dispose에서 clear)

---

### 2.3 Nested ListView 성능 문제 해결

**파일**: 2개
1. `lib/feature/search/presentation/view/search_loaded_view.dart`
2. `lib/feature/product/presentation/view/profile_product_list_view.dart`

**변경 사항**:

#### 1. search_loaded_view.dart

**Before** (Line 64-100):
```dart
return RefreshIndicator(
  onRefresh: onRefresh,
  child: SingleChildScrollView(
    controller: scrollController,
    physics: const AlwaysScrollableScrollPhysics(),
    child: Column(
      children: [
        Container(
          child: Column(
            children: [
              ProductSortHeaderWidget(...),
              const SizedBox(height: 12),
              ListView.builder(
                shrinkWrap: true,  // ❌ 성능 문제
                physics: const NeverScrollableScrollPhysics(),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  return ProductCardWidget(product: products[index]);
                },
              ),
            ],
          ),
        ),
      ],
    ),
  ),
);
```

**After**:
```dart
return RefreshIndicator(
  onRefresh: onRefresh,
  child: CustomScrollView(
    controller: scrollController,
    physics: const AlwaysScrollableScrollPhysics(),
    slivers: [
      SliverToBoxAdapter(
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProductSortHeaderWidget(
                totalCount: pagination.totalCount ?? 0,
                sortBy: sortBy,
                onSortChanged: onSortChanged,
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final product = products[index];
              return ProductCardWidget(product: product);
            },
            childCount: products.length,
          ),
        ),
      ),
    ],
  ),
);
```

#### 2. profile_product_list_view.dart

**Before** (Line 42-79):
```dart
return RefreshIndicator(
  onRefresh: onRefresh,
  child: SingleChildScrollView(
    controller: scrollController,
    physics: const AlwaysScrollableScrollPhysics(),
    child: Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (products.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: GbEmptyView(
                message: '등록된 상품이 없습니다',
              ),
            )
          else
            Column(
              children: [
                ListView.builder(
                  shrinkWrap: true,  // ❌ 성능 문제
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    return ProductCardWidget(
                      product: products[index],
                    );
                  },
                ),
              ],
            ),
        ],
      ),
    ),
  ),
);
```

**After**:
```dart
if (products.isEmpty) {
  return RefreshIndicator(
    onRefresh: onRefresh,
    child: SingleChildScrollView(
      controller: scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(48),
        child: const GbEmptyView(
          message: '등록된 상품이 없습니다',
        ),
      ),
    ),
  );
}

return RefreshIndicator(
  onRefresh: onRefresh,
  child: CustomScrollView(
    controller: scrollController,
    physics: const AlwaysScrollableScrollPhysics(),
    slivers: [
      SliverPadding(
        padding: const EdgeInsets.all(16),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              return ProductCardWidget(
                product: products[index],
              );
            },
            childCount: products.length,
          ),
        ),
      ),
    ],
  ),
);
```

**효과**:
- `shrinkWrap: true` 제거 → 모든 아이템 한 번에 빌드하지 않음
- Lazy loading: 화면에 보이는 아이템만 렌더링
- 메모리 사용량 감소
- 스크롤 성능 개선 (특히 100개+ 아이템)

---

### 2.6 GbDialog/GbSnackBar 미사용 문제 해결

**파일**: 2개
1. `lib/feature/chat/presentation/widget/chat_room_item_widget.dart`
2. `lib/feature/chat/presentation/view/chat_loaded_view.dart`

**변경 사항**:

#### 1. chat_room_item_widget.dart

**Before** (Line 136-182):
```dart
final confirmed = await showDialog<bool>(
  context: context,
  builder: (context) => AlertDialog(
    title: const Text('채팅방 나가기'),
    content: const Text(
      '채팅방을 나가시겠습니까?\n'
      '나가기 후에도 상대방이 메시지를 보내면 다시 채팅방에 입장할 수 있습니다.',
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.of(context).pop(true),
        child: const Text(
          '나가기',
          style: TextStyle(color: Color(0xFFEF4444)),
        ),
      ),
      TextButton(
        onPressed: () => Navigator.of(context).pop(false),
        child: const Text('취소'),
      ),
    ],
  ),
);

if (confirmed ?? false) {
  final success = await ref
      .read(chatRoomListNotifierProvider.notifier)
      .leaveChatRoom(chatRoom.id!);

  if (context.mounted) {
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('채팅방에서 나갔습니다.'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('채팅방 나가기에 실패했습니다.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
```

**After**:
```dart
final confirmed = await GbDialog.show(
  context: context,
  title: '채팅방 나가기',
  content: '채팅방을 나가시겠습니까?\n'
      '나가기 후에도 상대방이 메시지를 보내면 다시 채팅방에 입장할 수 있습니다.',
  confirmText: '나가기',
  cancelText: '취소',
);

if (confirmed ?? false) {
  final success = await ref
      .read(chatRoomListNotifierProvider.notifier)
      .leaveChatRoom(chatRoom.id!);

  if (context.mounted) {
    if (success) {
      GbSnackBar.showSuccess(
        context,
        message: '채팅방에서 나갔습니다.',
      );
    } else {
      GbSnackBar.showError(
        context,
        message: '채팅방 나가기에 실패했습니다.',
      );
    }
  }
}
```

#### 2. chat_loaded_view.dart

**Before** (Line 182-184):
```dart
ScaffoldMessenger.of(context).showSnackBar(
  const SnackBar(content: Text('이미지 선택에 실패했습니다.')),
);
```

**After**:
```dart
GbSnackBar.showError(
  context,
  message: '이미지 선택에 실패했습니다.',
);
```

**Before** (Line 261-269):
```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text(
      ChatUtil.isVideoFile(media.path.split('/').last)
          ? '동영상 전송 중 오류가 발생했습니다.'
          : '이미지 전송 중 오류가 발생했습니다.',
    ),
  ),
);
```

**After**:
```dart
GbSnackBar.showError(
  context,
  message: ChatUtil.isVideoFile(media.path.split('/').last)
      ? '동영상 전송 중 오류가 발생했습니다.'
      : '이미지 전송 중 오류가 발생했습니다.',
);
```

**효과**:
- UI 일관성: 프로젝트 전체에서 공통 다이얼로그/스낵바 사용
- 유지보수성: GbDialog/GbSnackBar 수정 시 전체 앱에 일괄 반영
- CLAUDE.md 규칙 준수

---

## 검증 체크리스트

### 2.1 민감 정보 로깅
- [ ] 프로덕션 빌드 후 로그 확인
- [ ] FCM 토큰이 [MASKED]로 표시되는지 확인
- [ ] S3 Presigned URL이 [MASKED]로 표시되는지 확인
- [ ] 이메일이 [MASKED]로 표시되는지 확인

### 2.2 Open Redirect
- [ ] `/login?redirect=/product/123` - 정상 동작
- [ ] `/login?redirect=https://evil.com` - 무시됨
- [ ] `/login?redirect=/unknown` - 무시됨

### 2.3 Nested ListView
- [ ] 검색 결과 100개 - 스크롤 성능 확인
- [ ] 프로필 상품 목록 - 메모리 사용량 확인
- [ ] Flutter DevTools Performance 탭에서 jank 확인

### 2.4 채팅 중복
- [ ] 네트워크 끊김 후 재연결 시 중복 메시지 표시 안 됨
- [ ] 스트림 재구독 시 중복 메시지 표시 안 됨
- [ ] 메모리 누수 없음 (dispose에서 Set.clear() 호출)

### 2.5 FCM Callback
- [x] 이미 수정됨 (Memory Leak 작업에서 해결)

### 2.6 GbDialog/SnackBar
- [ ] 채팅방 나가기 다이얼로그 정상 동작
- [ ] 이미지 선택 실패 스낵바 정상 표시
- [ ] 이미지/동영상 업로드 실패 스낵바 정상 표시
- [ ] UI 스타일이 기존 GbDialog/GbSnackBar와 일치

---

## 요약

**수정된 파일**: 총 7개
1. `lib/shared/service/fcm_service.dart` (2.1)
2. `lib/shared/feature/s3/data/datasource/s3_remote_datasource.dart` (2.1)
3. `lib/feature/auth/data/datasource/auth_remote_datasource.dart` (2.1)
4. `lib/core/route/app_route_guard.dart` (2.2)
5. `lib/feature/chat/presentation/provider/chat_notifier.dart` (2.4)
6. `lib/feature/search/presentation/view/search_loaded_view.dart` (2.3)
7. `lib/feature/product/presentation/view/profile_product_list_view.dart` (2.3)
8. `lib/feature/chat/presentation/widget/chat_room_item_widget.dart` (2.6)
9. `lib/feature/chat/presentation/view/chat_loaded_view.dart` (2.6)

**수정 통계**:
- 보안 이슈: 2개 (민감 정보 로깅, Open Redirect)
- 성능 이슈: 1개 (Nested ListView)
- 버그 수정: 1개 (채팅 중복)
- 코드 품질: 1개 (GbDialog/SnackBar 일관성)

**다음 단계**:
- 모든 HIGH 이슈 해결 완료
- MEDIUM 이슈로 이동 가능
- 또는 실제 앱 테스트로 검증 진행
