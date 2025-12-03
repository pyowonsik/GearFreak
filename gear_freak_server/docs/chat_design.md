# 채팅 기능 설계 문서

## 📋 목차

1. [개요](#개요)
2. [ERD 설계](#erd-설계)
3. [데이터 모델](#데이터-모델)
4. [주요 기능](#주요-기능)
5. [API 설계](#api-설계)
6. [실시간 메시징](#실시간-메시징)

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
- `message_type_idx`: (messageType, isDeleted)
- `active_messages_idx`: (chatRoomId, isDeleted, createdAt)

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
- 기존 채팅방이 있으면 기존 채팅방 반환
- 없으면 새 채팅방 생성
- 1:1 채팅방은 자동으로 `direct` 타입
- 3명 이상이 되면 자동으로 `group` 타입으로 변경

### 2. 메시지 전송

- 텍스트, 이미지, 파일 메시지 지원
- 메시지 전송 시:
  1. DB에 메시지 저장
  2. Redis를 통한 실시간 브로드캐스팅
  3. 채팅방 `lastActivityAt` 업데이트

### 3. 메시지 조회

- 페이지네이션 지원 (최신 메시지부터)
- 삭제되지 않은 메시지만 조회 (`isDeleted = false`)
- 채팅방 참여자만 조회 가능

### 4. 채팅방 참여/나가기

- 채팅방 참여 시 `ChatParticipant` 생성
- 나가기 시 `isActive = false`, `leftAt` 설정
- 참여자 수 자동 업데이트

### 5. 실시간 메시징

- Redis 기반 Server Events 사용
- 채팅방별 스트림 구독
- 메시지 전송 시 모든 참여자에게 실시간 전달

---

## API 설계

### 1. 채팅방 관련

#### 채팅방 생성/조회

```
POST /chat/room
- 상품 ID로 채팅방 생성 또는 기존 채팅방 조회

GET /chat/room/:chatRoomId
- 채팅방 정보 조회

GET /chat/room/product/:productId
- 상품 ID로 채팅방 목록 조회
```

#### 채팅방 참여/나가기

```
POST /chat/room/:chatRoomId/join
- 채팅방 참여

POST /chat/room/:chatRoomId/leave
- 채팅방 나가기

GET /chat/room/:chatRoomId/participants
- 채팅방 참여자 목록 조회
```

### 2. 메시지 관련

#### 메시지 전송

```
POST /chat/message
- 메시지 전송
- Request: { chatRoomId, content, messageType, attachmentUrl?, ... }
- Response: ChatMessageResult
```

#### 메시지 조회

```
GET /chat/message/:chatRoomId
- 채팅방 메시지 목록 조회 (페이지네이션)
- Query: page, limit
- Response: PaginatedChatMessagesResult
```

### 3. 실시간 스트림

#### 메시지 스트림 구독

```
Stream /chat/stream/:chatRoomId
- 실시간 메시지 수신
- Redis 기반 Server Events
```

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

```dart
// 엔드포인트에서 스트림 생성
Stream<ChatMessageResult> chatMessageStream(
  Session session,
  int chatRoomId,
) async* {
  // 인증 확인
  final isUserSignedIn = await session.isUserSignedIn;
  if (!isUserSignedIn) {
    throw Exception('인증이 필요합니다.');
  }

  // 채팅방 참여 여부 확인
  final userInfo = await session.authenticated;
  final participation = await ChatParticipant.db.findFirstRow(
    session,
    where: (p) =>
      p.userId.equals(userInfo!.userId) &
      p.chatRoomId.equals(chatRoomId) &
      p.isActive.equals(true),
  );

  if (participation == null) {
    throw Exception('채팅방에 참여하지 않은 사용자입니다.');
  }

  // 🚀 Server Events를 통한 Redis 기반 스트림 생성
  final messageStream = session.messages.createStream<ChatMessageResult>(
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

stream.listen(
  (message) {
    // 실시간 메시지 수신 처리
    print('새 메시지: ${message.content}');
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
```

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
- 기본 페이지 크기: 20개
- 최대 페이지 크기: 100개

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

## 향후 확장 계획

### 1. 읽음 상태 관리

- 메시지 읽음/안 읽음 상태 추적
- 읽지 않은 메시지 수 표시

### 2. 알림 기능

- 새 메시지 알림
- 채팅방 초대 알림

### 3. 파일 업로드

- 이미지/파일 업로드 기능
- S3 연동

### 4. 검색 기능

- 채팅방 내 메시지 검색
- 키워드 검색

---

## 마이그레이션 계획

1. **1단계**: 기본 모델 생성 (ChatRoom, ChatMessage, ChatParticipant)
2. **2단계**: Enum 타입 생성 (ChatRoomType, MessageType)
3. **3단계**: 인덱스 생성
4. **4단계**: 기본 API 구현
5. **5단계**: 실시간 메시징 구현

---

## 참고 자료

- [Serverpod Server Events 문서](https://docs.serverpod.dev/concepts/server-events)
- [Redis 설정 가이드](https://docs.serverpod.dev/configuration/redis)
- kobic 프로젝트 채팅 구현 참고
