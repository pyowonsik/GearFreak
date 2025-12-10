# User ID 사용 가이드

## 📋 개요

이 프로젝트에서는 **두 가지 사용자 ID**가 존재합니다:

- **`UserInfo.id`**: Serverpod 인증 모듈의 사용자 ID (serverpod_user_info 테이블)
- **`User.id`**: 애플리케이션의 사용자 ID (user 테이블)

## 🔗 테이블 관계

```
UserInfo (serverpod_user_info)
  └─ id: UserInfo.id (인증 모듈 ID)

User (user)
  ├─ id: User.id (애플리케이션 ID) ⭐ 이것을 사용해야 함
  └─ userInfoId: UserInfo.id를 참조 (Foreign Key)
```

## ✅ 올바른 사용 방법

### 모든 비즈니스 로직에서 `User.id`를 사용해야 합니다!

```dart
// ✅ 올바른 방법
final user = await UserService.getMe(session);
final userId = user.id!; // User.id 사용

// ❌ 잘못된 방법
final userInfo = await session.authenticated;
final userId = userInfo.userId; // UserInfo.id 사용 (잘못됨!)
```

## 📊 각 테이블에서 사용하는 ID

### 1. Product 테이블

- **필드**: `sellerId`
- **저장 값**: `User.id` ✅
- **Foreign Key**: `product.sellerId` → `user.id`
- **사용 위치**: `ProductService.createProduct()`, `ProductService.updateProduct()`

### 2. ChatParticipant 테이블

- **필드**: `userId`
- **저장 값**: `User.id` ✅
- **Foreign Key**: `chat_participant.userId` → `user.id`
- **사용 위치**: `ChatService._addParticipant()`, `ChatService.joinChatRoom()`

### 3. ChatMessage 테이블

- **필드**: `senderId`
- **저장 값**: `User.id` ✅
- **Foreign Key**: 없음 (relation 정의 없음)
- **사용 위치**: `ChatService.sendMessage()`

### 4. Favorite 테이블

- **필드**: `userId`
- **저장 값**: `User.id` ✅
- **Foreign Key**: `favorite.userId` → `user.id`
- **사용 위치**: `ProductService.toggleFavorite()`, `ProductService.isFavorite()`

## 🔍 엔드포인트별 사용 현황

### ✅ 올바르게 구현된 엔드포인트

모든 엔드포인트에서 `UserService.getMe(session)`을 사용하여 `User.id`를 가져옵니다:

1. **ProductEndpoint**

   - `createProduct()`: `user.id!` 사용 ✅
   - `updateProduct()`: `user.id!` 사용 ✅
   - `deleteProduct()`: `user.id!` 사용 ✅
   - `toggleFavorite()`: `user.id!` 사용 ✅
   - `isFavorite()`: `user.id!` 사용 ✅
   - `getMyProducts()`: `user.id!` 사용 ✅
   - `getMyFavoriteProducts()`: `user.id!` 사용 ✅

2. **ChatEndpoint**

   - `createOrGetChatRoom()`: `user.id!` 사용 ✅
   - `getUserChatRoomsByProductId()`: `user.id!` 사용 ✅
   - `getMyChatRooms()`: `user.id!` 사용 ✅
   - `joinChatRoom()`: `user.id!` 사용 ✅
   - `leaveChatRoom()`: `user.id!` 사용 ✅
   - `sendMessage()`: `user.id!` 사용 ✅

3. **ChatStreamEndpoint** (수정 완료)
   - `chatMessageStream()`: `UserService.getMe(session)`으로 `user.id!` 사용 ✅
   - **이전 문제**: `userInfo.userId` (UserInfo.id) 사용 → 수정됨

## 🐛 발견된 문제 및 수정

### 문제: ChatStreamEndpoint에서 UserInfo.id 사용

- **위치**: `chat_stream_endpoint.dart`
- **문제**: `userInfo.userId` (UserInfo.id)를 사용하여 ChatParticipant 조회
- **원인**: `ChatParticipant.userId`는 `User.id`를 저장하는데, `UserInfo.id`로 조회함
- **결과**: "채팅방에 참여하지 않은 사용자입니다" 에러 발생
- **수정**: `UserService.getMe(session)`으로 `User` 객체를 가져와 `user.id!` 사용

## 📝 체크리스트

새로운 코드를 작성할 때 다음을 확인하세요:

- [ ] `session.authenticated` 대신 `UserService.getMe(session)` 사용
- [ ] `userInfo.userId` 대신 `user.id!` 사용
- [ ] 모든 테이블의 `userId`, `sellerId`, `senderId` 필드에 `User.id` 저장
- [ ] Foreign Key 관계 확인 (모두 `user.id`를 참조해야 함)

## 🔧 디버깅 팁

### 로그에서 확인할 사항

- 로그의 `user=6`은 `UserInfo.id`를 의미할 수 있음
- 실제 데이터베이스의 `ChatParticipant.userId`는 `User.id`를 저장
- 두 값이 다를 수 있으므로 주의 필요

### 데이터베이스 확인 쿼리

```sql
-- User와 UserInfo의 관계 확인
SELECT u.id as user_id, u."userInfoId", ui.id as userinfo_id
FROM "user" u
JOIN "serverpod_user_info" ui ON u."userInfoId" = ui.id;

-- ChatParticipant의 userId가 User.id와 일치하는지 확인
SELECT cp."userId", u.id as user_id, u."userInfoId"
FROM chat_participant cp
JOIN "user" u ON cp."userId" = u.id;
```

## ⚠️ 주의사항

1. **절대 `UserInfo.id`를 비즈니스 로직에 사용하지 마세요**

   - `UserInfo.id`는 인증 모듈 내부에서만 사용
   - 모든 애플리케이션 로직은 `User.id`를 사용해야 함

2. **Foreign Key 제약 조건 확인**

   - 모든 `userId`, `sellerId`, `senderId` 필드는 `user.id`를 참조
   - 잘못된 ID를 저장하면 Foreign Key 제약 조건 위반 에러 발생

3. **일관성 유지**
   - 모든 엔드포인트에서 동일한 방식으로 `User.id`를 가져와야 함
   - `UserService.getMe(session)` 사용을 표준으로 유지
