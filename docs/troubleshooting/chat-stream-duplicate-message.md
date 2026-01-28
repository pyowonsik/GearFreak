# 트러블슈팅

## 실시간 채팅 스트림 중복 메시지 방지

---

### 🚨 문제 배경

Serverpod의 Server Events(Redis 기반) 스트림을 사용한 실시간 채팅 구현 중 **동일한 메시지가 중복으로 표시되는 문제**가 발생했습니다.

주요 증상:
- 메시지 전송 시 같은 메시지가 2~3번 표시됨
- 네트워크 불안정 시 스트림 재연결 후 중복 메시지 수신
- 이미지 업로드 중에도 스트림 메시지가 중복 추가됨

---

### ⭐ 해결 방법

**처리된 메시지 ID를 Set으로 관리**하여 중복 메시지를 필터링했습니다.

```dart
// chat_notifier.dart

/// 처리된 메시지 ID Set (중복 방지)
final Set<int> _processedMessageIds = {};

/// 중복 메시지 확인 및 이벤트 발행
bool _addMessageIfNotDuplicate(
  List<ChatMessageResponseDto> messages,
  ChatMessageResponseDto message,
) {
  // 1. Set을 사용한 중복 검사 (이미 처리된 메시지 무시)
  if (_processedMessageIds.contains(message.id)) {
    debugPrint('⏭️ 중복 메시지 무시: ${message.id}');
    return false;
  }

  // 2. 처리된 메시지로 등록
  _processedMessageIds.add(message.id);

  // 3. 기존 메시지 리스트에도 없는 경우만 추가
  final existingIds = messages.map((m) => m.id).toSet();
  if (!existingIds.contains(message.id)) {
    // 새 메시지 이벤트 발행
    ref.read(newChatMessageProvider.notifier).state = message;
    return true;
  }
  return false;
}
```

---

### 🔄 이전 코드와 비교

#### 문제 1: 단순 리스트 검사의 한계

**Before (문제 상황)**
```dart
void _onNewMessage(ChatMessageResponseDto message) {
  final currentState = state;
  if (currentState is ChatLoaded) {
    // ❌ 리스트에서만 중복 검사 (스트림 지연 시 누락 가능)
    if (!currentState.messages.any((m) => m.id == message.id)) {
      final updatedMessages = [...currentState.messages, message];
      state = currentState.copyWith(messages: updatedMessages);
    }
  }
}
```

**After (해결)**
```dart
void _onNewMessage(ChatMessageResponseDto message) {
  final currentState = state;
  if (currentState is ChatLoaded) {
    // ✅ Set으로 전역 중복 검사 + 리스트 중복 검사 (이중 검증)
    if (_addMessageIfNotDuplicate(currentState.messages, message)) {
      final updatedMessages = [...currentState.messages, message];
      _sortMessagesByCreatedAt(updatedMessages);
      state = currentState.copyWith(messages: updatedMessages);
    }
  }
}
```

---

#### 문제 2: 스트림 재연결 시 중복 메시지

네트워크 불안정으로 스트림이 끊어졌다가 재연결될 때, **이미 받은 메시지가 다시 수신**되는 문제가 있었습니다.

**Before (문제 상황)**
```dart
void _connectMessageStream(int chatRoomId) {
  // 기존 스트림만 해제하고 바로 재연결
  _messageStreamSubscription?.cancel();

  final stream = subscribeChatMessageStreamUseCase(
    SubscribeChatMessageStreamParams(chatRoomId: chatRoomId),
  );

  _messageStreamSubscription = stream.listen(
    (message) {
      // ❌ 재연결 후 이미 처리한 메시지도 다시 추가됨
      _onNewMessage(message);
    },
    onError: (error) {
      // 즉시 재연결 → 무한 루프 위험
      _connectMessageStream(chatRoomId);
    },
  );
}
```

**After (해결)**
```dart
/// 스트림 재연결 타이머
Timer? _reconnectTimer;

/// 처리된 메시지 ID Set (중복 방지)
final Set<int> _processedMessageIds = {};

void _connectMessageStream(int chatRoomId) {
  // ✅ 기존 스트림 및 재연결 타이머 모두 해제
  _messageStreamSubscription?.cancel();
  _reconnectTimer?.cancel();

  debugPrint('🔌 스트림 연결 시도: chatRoomId=$chatRoomId');

  final stream = subscribeChatMessageStreamUseCase(
    SubscribeChatMessageStreamParams(chatRoomId: chatRoomId),
  );

  _messageStreamSubscription = stream.listen(
    (message) {
      // ✅ Set으로 중복 검사 후 처리
      if (_addMessageIfNotDuplicate(currentMessages, message)) {
        _onNewMessage(message);
      }
    },
    onError: (error) {
      debugPrint('❌ 스트림 에러 발생: $error');

      // ✅ 스트림 연결 상태 업데이트
      if (currentState is ChatLoaded) {
        state = currentState.copyWith(isStreamConnected: false);
      }

      // ✅ 3초 후 재연결 시도 (즉시 재연결 방지)
      _reconnectTimer = Timer(const Duration(seconds: 3), () {
        debugPrint('🔄 스트림 재연결 시도 중...');
        _connectMessageStream(chatRoomId);
      });
    },
    onDone: () {
      debugPrint('✅ 스트림 정상 종료');
      if (currentState is ChatLoaded) {
        state = currentState.copyWith(isStreamConnected: false);
      }
    },
  );
}
```

---

#### 문제 3: 메모리 누수 (dispose 누락)

화면 이탈 시 스트림 구독과 Set을 정리하지 않아 **메모리 누수**가 발생했습니다.

**Before (문제 상황)**
```dart
@override
void dispose() {
  _messageStreamSubscription?.cancel();
  super.dispose();
}
```

**After (해결)**
```dart
@override
void dispose() {
  _messageStreamSubscription?.cancel();
  _reconnectTimer?.cancel();               // ✅ 재연결 타이머도 해제
  _processedMessageIds.clear();            // ✅ 처리된 메시지 ID Set 정리
  super.dispose();
}
```

---

### 📊 중복 메시지 발생 시나리오

```
시나리오 1: 메시지 전송 직후 스트림 수신
┌─────────────────────────────────────────────────────────────┐
│  1. 사용자가 메시지 전송                                      │
│                    ↓                                         │
│  2. sendMessageUseCase 호출 → 서버에 메시지 저장              │
│                    ↓                                         │
│  3. 서버가 Redis로 메시지 브로드캐스트                         │
│                    ↓                                         │
│  4. 스트림으로 동일 메시지 수신 ❌ 중복!                       │
└─────────────────────────────────────────────────────────────┘

해결 후:
┌─────────────────────────────────────────────────────────────┐
│  1. 사용자가 메시지 전송                                      │
│                    ↓                                         │
│  2. sendMessageUseCase 성공 → _processedMessageIds에 ID 추가  │
│                    ↓                                         │
│  3. 스트림으로 동일 메시지 수신                               │
│                    ↓                                         │
│  4. Set에서 ID 확인 → 이미 존재 → 무시 ✅                     │
└─────────────────────────────────────────────────────────────┘

시나리오 2: 스트림 재연결 시
┌─────────────────────────────────────────────────────────────┐
│  1. 네트워크 불안정으로 스트림 끊어짐                          │
│                    ↓                                         │
│  2. onError 콜백 → isStreamConnected = false                 │
│                    ↓                                         │
│  3. 3초 대기 (재연결 타이머)                                  │
│                    ↓                                         │
│  4. 재연결 시도                                               │
│                    ↓                                         │
│  5. 서버에서 최근 메시지 재전송 시도                          │
│                    ↓                                         │
│  6. _processedMessageIds로 중복 필터링 ✅                     │
└─────────────────────────────────────────────────────────────┘
```

---

### 🔍 디버깅 과정

1. **증상 확인**: 채팅방에서 같은 메시지가 2~3번 나타남
2. **로그 추가**: 스트림 수신 시점과 sendMessage 응답 시점에 메시지 ID 로그 추가
3. **원인 발견**:
   - sendMessage 성공 시 메시지를 리스트에 추가
   - 동시에 스트림으로 동일 메시지 수신
   - 리스트 검사만으로는 타이밍 이슈 발생
4. **해결책 설계**:
   - Set을 사용한 전역 중복 관리
   - 스트림 재연결 시 딜레이 추가
   - dispose에서 리소스 정리

---

### 😊 해당 경험을 통해 알게된 점

**실시간 스트림과 API 응답의 타이밍 이슈**를 이해하게 되었습니다. 메시지를 전송하면 서버는 API 응답과 스트림 브로드캐스트를 거의 동시에 수행하므로, 클라이언트에서 중복 처리가 필수입니다.

**Set을 활용한 O(1) 중복 검사**의 중요성을 배웠습니다. 리스트의 `any()` 메서드는 O(n)이지만, Set의 `contains()`는 O(1)이므로 메시지가 많아져도 성능이 유지됩니다.

**스트림 재연결 시 적절한 딜레이**가 필요하다는 것을 알게 되었습니다. 즉시 재연결하면 네트워크 불안정 시 무한 재연결 루프가 발생할 수 있으므로, 3초 정도의 딜레이를 두는 것이 안정적입니다.

**StateNotifier의 dispose에서 모든 리소스 정리**가 필수라는 것을 경험했습니다. 스트림 구독, 타이머, Set 등 모든 리소스를 정리하지 않으면 메모리 누수가 발생합니다.

---

### 🛠️ 관련 기술

- **Serverpod**: Server Events (Redis 기반 메시지 브로드캐스트)
- **Flutter/Dart**: StreamSubscription, Timer, Set 자료구조
- **Riverpod**: StateNotifier 라이프사이클 관리
- **디자인 패턴**: 이벤트 기반 실시간 통신, 중복 제거 패턴

---

### 📁 관련 파일

- `lib/feature/chat/presentation/provider/chat_notifier.dart` - 채팅 상태 관리 및 스트림 처리
- `lib/feature/chat/domain/usecase/subscribe_chat_message_stream_usecase.dart` - 스트림 구독 UseCase
- `gear_freak_server/lib/src/feature/chat/endpoint/chat_stream_endpoint.dart` - 서버 스트림 엔드포인트
- `gear_freak_server/lib/src/feature/chat/service/chat_message_service.dart` - 메시지 브로드캐스트 서비스
