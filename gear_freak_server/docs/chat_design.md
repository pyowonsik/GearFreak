# 채팅 기능 설계 문서

## 📋 목차

1. [개요](#개요)
2. [ERD 설계](#erd-설계)
3. [데이터 모델](#데이터-모델)
4. [주요 기능](#주요-기능)
5. [API 설계](#api-설계)
6. [DTO 구조](#dto-구조)
7. [실시간 메시징](#실시간-메시징)
8. [채팅방 진입 플로우](#6-채팅방-진입-플로우)
9. [성능 최적화](#성능-최적화)
10. [보안 고려사항](#보안-고려사항)
11. [구현 완료 사항](#구현-완료-사항-)
12. [향후 구현 필요 사항](#향후-구현-필요-사항)

---

## 개요

### 목적

상품 거래를 위한 1:1 및 그룹 채팅 기능을 제공합니다.

### 주요 기능

- 상품 기반 채팅방 생성
- 1:1 및 그룹 채팅 지원
- 실시간 메시지 전송/수신 (Redis 기반)
- 텍스트, 이미지, 파일 메시지 지원
- 채팅방 참여/나가기 관리

---

## ERD 설계

### 엔티티 관계도

```
Product (1) ──< (N) ChatRoom
                │
                ├──< (N) ChatParticipant ──> (1) User
                │
                └──< (N) ChatMessage ──> (1) User (senderId)
```

### 관계 설명

1. **Product ↔ ChatRoom** (1:N)

   - 하나의 상품에 여러 채팅방이 생성될 수 있음
   - 상품 삭제 시 관련 채팅방도 삭제 (Cascade)

2. **ChatRoom ↔ ChatParticipant** (1:N)

   - 하나의 채팅방에 여러 참여자가 존재
   - 채팅방 삭제 시 참여자 정보도 삭제 (Cascade)

3. **ChatRoom ↔ ChatMessage** (1:N)

   - 하나의 채팅방에 여러 메시지가 존재
   - 채팅방 삭제 시 메시지도 삭제 (Cascade)

4. **User ↔ ChatParticipant** (1:N)

   - 한 사용자가 여러 채팅방에 참여 가능

5. **User ↔ ChatMessage** (1:N)
   - 한 사용자가 여러 메시지를 전송 가능
   - `senderId`로 연결 (relation 없이 int로 관리)

---

## 데이터 모델

### 1. ChatRoom (채팅방)

| 필드             | 타입         | 설명             | 제약조건                |
| ---------------- | ------------ | ---------------- | ----------------------- |
| id               | int          | 채팅방 ID        | PK, Auto Increment      |
| productId        | int          | 연결된 상품 ID   | FK → Product, NOT NULL  |
| title            | String?      | 채팅방 제목      | NULL 허용               |
| chatRoomType     | ChatRoomType | 채팅방 타입      | NOT NULL (direct/group) |
| participantCount | int          | 참여자 수 (캐시) | NOT NULL, Default: 0    |
| lastActivityAt   | DateTime?    | 최근 활동 시간   | NULL 허용               |
| createdAt        | DateTime?    | 생성일           | NULL 허용               |
| updatedAt        | DateTime?    | 수정일           | NULL 허용               |

**인덱스:**

- `product_id_idx`: productId
- `last_activity_idx`: lastActivityAt
- `chat_room_type_idx`: chatRoomType

### 2. ChatMessage (메시지)

| 필드           | 타입        | 설명                  | 제약조건                          |
| -------------- | ----------- | --------------------- | --------------------------------- |
| id             | int         | 메시지 ID             | PK, Auto Increment                |
| chatRoomId     | int         | 채팅방 ID             | FK → ChatRoom, NOT NULL           |
| senderId       | int         | 발신자 사용자 ID      | NOT NULL                          |
| content        | String      | 메시지 내용           | NOT NULL                          |
| messageType    | MessageType | 메시지 타입           | NOT NULL (text/image/file/system) |
| attachmentUrl  | String?     | 첨부파일 URL          | NULL 허용                         |
| attachmentName | String?     | 첨부파일 이름         | NULL 허용                         |
| attachmentSize | int?        | 첨부파일 크기 (bytes) | NULL 허용                         |
| createdAt      | DateTime?   | 전송일                | NULL 허용                         |
| updatedAt      | DateTime?   | 수정일                | NULL 허용                         |

**인덱스:**

- `chat_room_messages_idx`: (chatRoomId, createdAt)
- `sender_messages_idx`: (senderId, createdAt)
- `message_type_idx`: (messageType)

### 3. ChatParticipant (참여자)

| 필드       | 타입      | 설명      | 제약조건                |
| ---------- | --------- | --------- | ----------------------- |
| id         | int       | 참여자 ID | PK, Auto Increment      |
| chatRoomId | int       | 채팅방 ID | FK → ChatRoom, NOT NULL |
| userId     | int       | 사용자 ID | FK → User, NOT NULL     |
| joinedAt   | DateTime? | 참여 일시 | NULL 허용               |
| isActive   | bool      | 활성 상태 | NOT NULL, Default: true |
| leftAt     | DateTime? | 나간 시간 | NULL 허용               |
| createdAt  | DateTime? | 생성일    | NULL 허용               |
| updatedAt  | DateTime? | 수정일    | NULL 허용               |

**인덱스:**

- `unique_chat_participant_idx`: (chatRoomId, userId) - UNIQUE
- `active_participants_idx`: (chatRoomId, isActive)
- `user_participations_idx`: (userId, isActive)

### 4. ChatRoomType (Enum)

| 값     | 설명                   |
| ------ | ---------------------- |
| direct | 1:1 채팅방             |
| group  | 그룹 채팅방 (3명 이상) |

### 5. MessageType (Enum)

| 값     | 설명                          |
| ------ | ----------------------------- |
| text   | 텍스트 메시지                 |
| image  | 이미지 메시지                 |
| file   | 파일 메시지                   |
| system | 시스템 메시지 (입장, 퇴장 등) |

---

## 주요 기능

### 1. 채팅방 생성

- 상품 상세 페이지에서 "채팅하기" 버튼 클릭
- `createOrGetChatRoom` 호출
- **상품별 채팅방 분리**: 같은 사용자 조합이라도 상품마다 별도 채팅방 생성
  - 예: 사용자 A-B가 상품 1에 대해 채팅방 1개, 상품 2에 대해 채팅방 1개 (별도)
- 같은 상품 + 같은 사용자 조합이면 기존 채팅방 반환
- 없으면 새 채팅방 생성
- 1:1 채팅방은 자동으로 `direct` 타입
- 참여자 추가 시 자동으로 참여자 수 업데이트

### 2. 메시지 전송

- 텍스트, 이미지, 파일 메시지 지원
- 메시지 전송 시:
  1. DB에 메시지 저장
  2. Redis를 통한 실시간 브로드캐스팅
  3. 채팅방 `lastActivityAt` 업데이트

### 3. 메시지 조회

- 페이지네이션 지원 (최신 메시지부터, `orderDescending: true`)
- 무한 스크롤 지원 (프론트엔드 구현 필요)
- 메시지 타입별 필터링 가능 (text, image, file, system)
- 채팅방 참여자만 조회 가능
- 기본 페이지 크기: 50개 (변경 가능)
- 최대 페이지 크기: 100개

### 4. 채팅방 참여/나가기

- 채팅방 참여 시 `ChatParticipant` 생성 또는 활성화
- 이미 참여 중이면 기존 참여 정보 반환
- 나가기 시 `isActive = false`, `leftAt` 설정 (채팅방 삭제 아님)
- 참여자 수 자동 업데이트 (`participantCount`)
- 나간 사용자도 메시지는 받을 수 있음 (당근마켓 방식)

### 5. 실시간 메시징

- Redis 기반 Server Events 사용
- 채팅방별 스트림 구독
- 메시지 전송 시 모든 참여자에게 실시간 전달

---

## API 설계

### 엔드포인트 구조

채팅 기능은 두 개의 엔드포인트로 분리되어 있습니다:

- **`ChatEndpoint`**: 일반 REST API (채팅방 관리, 메시지 전송/조회)
- **`ChatStreamEndpoint`**: 실시간 스트림 API (WebSocket 기반 메시지 수신)

### 1. 채팅방 관련

#### 채팅방 생성/조회

**엔드포인트**: `POST /chat/createOrGetChatRoom`

```dart
// Request
CreateChatRoomRequestDto {
  productId: int,           // 상품 ID
  targetUserId: int?,       // 상대방 사용자 ID (1:1 채팅의 경우)
}

// Response
CreateChatRoomResponseDto {
  success: bool,
  chatRoomId: int?,
  chatRoom: ChatRoom?,
  message: String?,
}
```

**동작 방식:**

- 같은 상품 + 같은 두 사용자 조합이면 기존 채팅방 반환
- 없으면 새 채팅방 생성
- **상품별로 채팅방이 분리됨**: 사용자 A-B가 상품 1에 대해 채팅방 1개, 상품 2에 대해 채팅방 1개 (별도)

**예시:**

```
상품 1: 사용자 A ↔ 사용자 B → 채팅방 1
상품 2: 사용자 A ↔ 사용자 B → 채팅방 2 (다른 채팅방)
```

#### 채팅방 정보 조회

**엔드포인트**: `GET /chat/getChatRoomById`

```dart
// Request
chatRoomId: int

// Response
ChatRoom?
```

#### 상품 ID로 채팅방 목록 조회

**엔드포인트**: `GET /chat/getChatRoomsByProductId`

```dart
// Request
productId: int

// Response
List<ChatRoom>?
```

#### 사용자가 참여한 채팅방 목록 조회 (상품 ID 기준)

**엔드포인트**: `GET /chat/getUserChatRoomsByProductId`

```dart
// Request
productId: int

// Response
List<ChatRoom>?
```

#### 채팅방 참여

**엔드포인트**: `POST /chat/joinChatRoom`

```dart
// Request
JoinChatRoomRequestDto {
  chatRoomId: int,
}

// Response
JoinChatRoomResponseDto {
  success: bool,
  chatRoomId: int,
  joinedAt: DateTime,
  message: String?,
  participantCount: int?,
}
```

#### 채팅방 나가기

**엔드포인트**: `POST /chat/leaveChatRoom`

```dart
// Request
LeaveChatRoomRequestDto {
  chatRoomId: int,
}

// Response
LeaveChatRoomResponseDto {
  success: bool,
  chatRoomId: int,
  message: String?,
}
```

**동작 방식:**

- `isActive = false`로 설정 (채팅방 삭제 아님)
- 참여자 수 자동 업데이트
- 나간 사용자도 메시지는 받을 수 있음 (당근마켓 방식)

#### 채팅방 참여자 목록 조회

**엔드포인트**: `GET /chat/getChatParticipants`

```dart
// Request
chatRoomId: int

// Response
List<ChatParticipantInfoDto> {
  userId: int,
  nickname: String?,
  profileImageUrl: String?,
  joinedAt: DateTime?,
  isActive: bool,
}
```

### 2. 메시지 관련

#### 메시지 전송

**엔드포인트**: `POST /chat/sendMessage`

```dart
// Request
SendMessageRequestDto {
  chatRoomId: int,
  content: String,
  messageType: MessageType,      // text, image, file, system
  attachmentUrl: String?,
  attachmentName: String?,
  attachmentSize: int?,
}

// Response
ChatMessageResponseDto {
  id: int,
  chatRoomId: int,
  senderId: int,
  senderNickname: String?,
  content: String,
  messageType: MessageType,
  attachmentUrl: String?,
  attachmentName: String?,
  attachmentSize: int?,
  createdAt: DateTime,
  updatedAt: DateTime?,
}
```

**동작 방식:**

1. DB에 메시지 저장
2. Redis를 통한 실시간 브로드캐스팅 (`postMessage` with `global: true`)
3. 채팅방 `lastActivityAt` 업데이트

#### 페이지네이션된 메시지 조회

**엔드포인트**: `POST /chat/getChatMessagesPaginated`

```dart
// Request
GetChatMessagesRequestDto {
  chatRoomId: int,
  page: int,                      // 1부터 시작
  limit: int,                     // 1~100 사이
  messageType: MessageType?,      // 선택적 필터
}

// Response
PaginatedChatMessagesResponseDto {
  messages: List<ChatMessageResponseDto>,
  totalCount: int,
  mediaTotalCount: int,           // 이미지/동영상 총 개수
  fileTotalCount: int,            // 파일 총 개수
  currentPage: int,
  pageSize: int,
  hasNextPage: bool,
  hasPreviousPage: bool,
}
```

**동작 방식:**

- 최신 메시지부터 조회 (`orderDescending: true`)
- 페이지네이션 지원 (무한 스크롤용)
- 메시지 타입별 필터링 가능

#### 채팅방의 마지막 메시지 조회

**엔드포인트**: `GET /chat/getLastMessageByChatRoomId`

```dart
// Request
chatRoomId: int

// Response
ChatMessage?
```

### 3. 실시간 스트림

#### 메시지 스트림 구독

**엔드포인트**: `Stream /chatStream/chatMessageStream`

```dart
// Request
chatRoomId: int

// Response
Stream<ChatMessageResponseDto>
```

**동작 방식:**

- Redis 기반 Server Events 사용
- 채널 이름: `'chat_room_{chatRoomId}'`
- 채팅방 화면 진입 시 구독 시작
- 화면 종료 시 구독 해제

### 6. 채팅방 진입 플로우

```
1. createOrGetChatRoom()     → chatRoomId 획득
2. getChatRoomById()         → 채팅방 정보
3. joinChatRoom()            → 채팅방 참여
4. getChatParticipants()     → 참여자 목록
5. getChatMessagesPaginated() → 이전 메시지 (DB, 최신 50개)
6. chatMessageStream()       → 실시간 메시지 (스트림)
```

**상세 플로우:**

1. **상품 상세 화면**: "채팅하기" 버튼 클릭

   - `createOrGetChatRoom(productId, targetUserId)` 호출
   - 채팅방 생성 또는 기존 채팅방 조회
   - `chatRoomId` 획득

2. **채팅방 화면 진입** (`initState`)

   - 병렬 호출: `getChatRoomById()`, `joinChatRoom()`, `getChatParticipants()`
   - 이전 메시지 로드: `getChatMessagesPaginated(page: 1, limit: 50)`
   - 실시간 스트림 연결: `chatMessageStream(chatRoomId)`

3. **메시지 전송**

   - `sendMessage()` 호출
   - DB 저장 + Redis 브로드캐스팅
   - 구독 중인 모든 클라이언트에게 실시간 전달

4. **화면 종료** (`dispose`)
   - 스트림 구독 해제: `subscription.cancel()`

---

## DTO 구조

### Request DTOs

- `CreateChatRoomRequestDto`: 채팅방 생성 요청
- `JoinChatRoomRequestDto`: 채팅방 참여 요청
- `LeaveChatRoomRequestDto`: 채팅방 나가기 요청
- `SendMessageRequestDto`: 메시지 전송 요청
- `GetChatMessagesRequestDto`: 메시지 조회 요청 (페이지네이션)

### Response DTOs

- `CreateChatRoomResponseDto`: 채팅방 생성 응답
- `JoinChatRoomResponseDto`: 채팅방 참여 응답
- `LeaveChatRoomResponseDto`: 채팅방 나가기 응답
- `ChatMessageResponseDto`: 메시지 응답
- `PaginatedChatMessagesResponseDto`: 페이지네이션된 메시지 응답
- `ChatParticipantInfoDto`: 참여자 정보

---

## 실시간 메시징 (Redis + Server Events)

### Redis 설정 완료 ✅

#### 개발 환경 (`config/development.yaml`)

```yaml
redis:
  enabled: true
  host: localhost
  port: 8091
```

#### 프로덕션 환경 (`config/production.yaml`)

```yaml
redis:
  enabled: true
  host: localhost # 또는 별도 Redis 서버 주소
  port: 6379
```

#### Redis 비밀번호 설정 (`config/passwords.yaml`)

```yaml
development:
  redis: 'KtY1Brzm-d5l66wYVN3PsowAmKzM2EiR'
```

### Redis 서버 실행 확인

#### Docker Compose로 실행 (개발 환경)

```bash
# Redis 서버 실행
docker-compose up -d redis

# Redis 연결 테스트
docker-compose exec redis redis-cli -a "KtY1Brzm-d5l66wYVN3PsowAmKzM2EiR" ping
# 응답: PONG
```

#### 프로덕션 환경

- EC2에 Redis 설치 또는 Docker로 실행
- 같은 인스턴스에서 실행 시 추가 비용 없음

### Server Events 사용법

#### 1. 메시지 브로드캐스팅 (메시지 전송 시)

```dart
// 메시지 전송 후 Redis를 통한 실시간 브로드캐스팅
await session.messages.postMessage(
  'chat_room_${request.chatRoomId}',  // 채널 이름
  chatMessageResult,                   // 전송할 메시지 객체
  global: true,                        // 🔥 Redis를 통한 글로벌 브로드캐스팅
);
```

**주요 포인트:**

- `global: true`: Redis를 통한 멀티 인스턴스 브로드캐스팅
- 채널 이름: `'chat_room_{chatRoomId}'` 형식으로 채팅방별 구분
- 모든 활성 참여자에게 실시간 전달

#### 2. 스트림 구독 (실시간 메시지 수신)

**엔드포인트**: `ChatStreamEndpoint.chatMessageStream()`

```dart
// 엔드포인트에서 스트림 생성
Stream<ChatMessageResponseDto> chatMessageStream(
  Session session,
  int chatRoomId,
) async* {
  // 인증 확인
  final isUserSignedIn = await session.isUserSignedIn;
  if (!isUserSignedIn) {
    throw Exception('인증이 필요합니다. 로그인 후 다시 시도해주세요.');
  }

  final userInfo = await session.authenticated;
  if (userInfo == null) {
    throw Exception('사용자 정보를 찾을 수 없습니다.');
  }

  // 채팅방 참여 여부 확인
  final participation = await ChatParticipant.db.findFirstRow(
    session,
    where: (participant) =>
      participant.userId.equals(userInfo.userId) &
      participant.chatRoomId.equals(chatRoomId) &
      participant.isActive.equals(true),
  );

  if (participation == null) {
    throw Exception('채팅방에 참여하지 않은 사용자입니다.');
  }

  // 🚀 Server Events를 통한 Redis 기반 스트림 생성
  final messageStream = session.messages.createStream<ChatMessageResponseDto>(
    'chat_room_$chatRoomId',  // 채널 이름 (브로드캐스팅과 동일)
  );

  // 실시간 메시지 스트림 반환
  await for (final message in messageStream) {
    yield message;
  }
}
```

**주요 포인트:**

- `createStream<T>()`: 타입 안전한 스트림 생성
- 채널 이름은 브로드캐스팅과 동일해야 함
- `async*`와 `yield`로 스트림 반환

#### 3. 클라이언트에서 스트림 구독

```dart
// Flutter 클라이언트에서
final stream = client.chatStream.chatMessageStream(chatRoomId);

final subscription = stream.listen(
  (message) {
    // 실시간 메시지 수신 처리
    setState(() {
      messages.add(message);
    });
  },
  onError: (error) {
    // 에러 처리
    print('스트림 에러: $error');
  },
  onDone: () {
    // 스트림 종료 처리
    print('스트림 종료');
  },
);

// 화면 종료 시 구독 해제
@override
void dispose() {
  subscription.cancel();
  super.dispose();
}
```

**호출 시점:**

- 채팅방 화면 진입 시 (`initState`)
- 이전 메시지 로드 후 스트림 연결
- 화면 종료 시 구독 해제 (`dispose`)

### 멀티 인스턴스 지원

#### Redis를 통한 글로벌 브로드캐스팅

- `global: true` 옵션으로 모든 서버 인스턴스에 메시지 전달
- 여러 EC2 인스턴스가 있어도 메시지 동기화 보장
- 확장 가능한 아키텍처

#### 동작 방식

```
서버 인스턴스 1 (EC2-1)
  └─ 메시지 전송 → Redis → 모든 인스턴스에 브로드캐스팅
     ↓
서버 인스턴스 2 (EC2-2) ← 메시지 수신
서버 인스턴스 3 (EC2-3) ← 메시지 수신
```

### 성능 최적화

#### Redis 성능

- 단일 인스턴스: 약 2-5ms 추가 지연 (체감 어려움)
- 처리량: 초당 8,000-10,000+ 메시지 처리 가능
- 실제 영향: 클라이언트 네트워크 지연(10-50ms)이 더 큼

#### 채널 관리

- 채팅방별로 독립적인 채널 사용
- 채널 이름: `'chat_room_{chatRoomId}'`
- 자동 정리: Serverpod가 비활성 채널 자동 정리

### 주의사항

1. **채널 이름 일관성**

   - 브로드캐스팅과 스트림 구독 시 동일한 채널 이름 사용
   - 형식: `'chat_room_{chatRoomId}'`

2. **인증 및 권한 확인**

   - 스트림 구독 전 반드시 인증 확인
   - 채팅방 참여 여부 확인 필수

3. **에러 처리**

   - 스트림 연결 실패 시 재연결 로직 구현
   - 네트워크 오류 처리

4. **리소스 정리**
   - 스트림 구독 해제 시 `cancel()` 호출
   - 메모리 누수 방지

---

## 성능 최적화

### 1. 인덱스

- 채팅방별 메시지 조회: `chat_room_messages_idx`
- 활성 참여자 조회: `active_participants_idx`
- 최근 활동 채팅방 조회: `last_activity_idx`

### 2. 캐싱

- `participantCount`: 참여자 수를 캐시하여 매번 COUNT 쿼리 방지
- `lastActivityAt`: 최근 활동 시간으로 채팅방 목록 정렬

### 3. 페이지네이션

- 메시지 조회 시 페이지네이션 적용
- 기본 페이지 크기: 50개 (초기 로드)
- 최대 페이지 크기: 100개
- 무한 스크롤 지원 (프론트엔드 구현 필요)
- 최신 메시지부터 조회 (`orderDescending: true`)
- `hasNextPage`, `hasPreviousPage` 필드로 다음/이전 페이지 존재 여부 확인

---

## 보안 고려사항

### 1. 인증

- 모든 엔드포인트에서 인증 확인
- 채팅방 참여자만 메시지 조회/전송 가능

### 2. 권한 검증

- 채팅방 참여 여부 확인
- 메시지 전송 전 참여자 상태 확인 (`isActive = true`)

### 3. 데이터 검증

- 메시지 내용 길이 제한
- 첨부파일 크기 제한
- 파일 타입 검증

---

## 구현 완료 사항 ✅

### 1. 데이터 모델

- ✅ ChatRoom, ChatMessage, ChatParticipant 모델 생성
- ✅ ChatRoomType, MessageType Enum 생성
- ✅ 인덱스 생성 (성능 최적화)
- ✅ 마이그레이션 완료

### 2. DTO 구조

- ✅ Request DTOs 생성 (모든 엔드포인트용)
- ✅ Response DTOs 생성 (result → response로 명명)
- ✅ 페이지네이션 DTO 생성

### 3. 서비스 레이어

- ✅ ChatService 구현
  - 채팅방 생성/조회 로직
  - 메시지 전송/조회 로직
  - 참여자 관리 로직
  - 페이지네이션 처리
- ✅ 함수 그룹화 및 주석 추가 (Public Methods, Private Helper Methods)

### 4. 엔드포인트 레이어

- ✅ ChatEndpoint 구현 (일반 REST API)
  - 채팅방 관리 (생성, 조회, 참여, 나가기)
  - 메시지 전송/조회
  - 참여자 목록 조회
- ✅ ChatStreamEndpoint 구현 (실시간 스트림)
  - 메시지 스트림 구독
- ✅ 엔드포인트 분리 (ChatEndpoint / ChatStreamEndpoint)

### 5. 실시간 메시징

- ✅ Redis 설정 완료 (development.yaml)
- ✅ Server Events 구현
  - `postMessage` (메시지 브로드캐스팅)
  - `createStream` (스트림 구독)
- ✅ 채널 이름: `'chat_room_{chatRoomId}'`

### 6. 채팅방 생성 로직

- ✅ 상품별 채팅방 분리 구현
- ✅ 같은 사용자 조합 + 같은 상품 = 기존 채팅방 재사용
- ✅ 다른 상품 = 별도 채팅방 생성

## 향후 구현 필요 사항

### 프론트엔드

- ⏳ 채팅방 화면 구현
- ⏳ 메시지 무한 스크롤 구현 (`PaginationScrollMixin` 적용)
- ⏳ 실시간 메시지 수신 처리
- ⏳ 채팅방 목록 화면 구현

### 백엔드 (선택사항)

- ⏳ 읽음 상태 관리
- ⏳ 알림 기능
- ⏳ 파일 업로드 (이미지/파일)
- ⏳ 메시지 검색 기능

---

## 참고 자료

- [Serverpod Server Events 문서](https://docs.serverpod.dev/concepts/server-events)
- [Redis 설정 가이드](https://docs.serverpod.dev/configuration/redis)
- kobic 프로젝트 채팅 구현 참고
