# Gear Freak Server 성능 최적화 구현 계획

**날짜**: 2026-01-12
**작성자**: Claude
**관련 연구 문서**: thoughts/shared/research/gear_freak_server_full_review_2026-01-12.md

---

## 1. 요구사항

### 기능 개요
Gear Freak 서버의 성능 이슈(N+1 쿼리, 메모리 필터링)를 해결하고 코드 품질을 개선합니다.

### 목표
- N+1 쿼리 문제 해결 (6개 위치)
- 메모리 기반 필터링을 DB 쿼리로 변경 (4개 위치)
- 코드 중복 제거 (2개 영역)
- 상수화 및 예외 타입 정의

### 성공 기준
- [ ] 채팅 목록 조회 시 쿼리 수: N+1 → 2~3개
- [ ] 후기 목록 조회 시 쿼리 수: 2N+1 → 2~3개
- [ ] 찜 목록 조회 시 쿼리 수: N+1 → 2개
- [ ] 메모리 필터링 제거 (DB WHERE 절 사용)
- [ ] 코드 중복 95% 이상 제거
- [ ] 빌드 성공 및 기존 기능 정상 동작

---

## 2. 현황 분석

### 2.1 N+1 쿼리 발생 위치

| 위치 | 현재 쿼리 수 | 문제 |
|------|------------|------|
| `ChatRoomService.getMyChatRooms` | N+1 | 각 채팅방마다 unreadCount 계산 |
| `ProductListService.getMyFavoriteProducts` | N+1 | 각 찜마다 Product 조회 |
| `ReviewListService.getReceivedReviews` | 2N+1 | 각 후기마다 reviewer + reviewee 조회 |
| `ReviewListService.getAllReviewsByUserId` | 2N+1 + 풀스캔 | 평균 계산 위해 전체 로드 |
| `FcmTokenService.getTokensByChatRoomIdWithNotificationSettings` | N+1 | 각 참여자마다 토큰 조회 |
| `ChatNotificationService.getUnreadCount` | 전체 로드 | 메모리에서 필터링 |

### 2.2 메모리 필터링 위치

| 위치 | 현재 방식 | 문제 |
|------|----------|------|
| `ProductListService.getPaginatedProducts` | excludeSold 메모리 필터 | 전체 로드 후 필터 |
| `ChatMessageService.getChatMessagesPaginated` | leftAt 메모리 필터 | 전체 메시지 로드 |
| `ChatNotificationService.getUnreadCount` | 메모리 카운트 | 전체 메시지 로드 |
| `ReviewListService.getAllReviewsByUserId` | 평균 계산 | 전체 후기 로드 |

### 2.3 코드 중복 위치

| 위치 | 중복 내용 |
|------|----------|
| `AuthService.getOrCreateUserAfter*Login` | 4개 메서드 95% 동일 |
| `ReviewService.createTransactionReview/createSellerReview` | 2개 메서드 95% 동일 |

---

## 3. 구현 단계

### Phase 1: N+1 쿼리 최적화 (Chat & Review)
**목표**: 채팅 및 후기 관련 N+1 쿼리 제거

**작업 목록**:

#### 1.1 ChatNotificationService.getUnreadCount 최적화
- [ ] DB WHERE 절로 leftAt/lastReadAt 조건 필터링
- [ ] COUNT 쿼리 사용 (메모리 로드 대신)

**현재 코드** (chat_notification_service.dart):
```dart
// 문제: 전체 메시지 로드 후 메모리 필터링
final allMessages = await ChatMessage.db.find(...);
final unreadCount = allMessages.where((msg) =>
  msg.createdAt!.isAfter(participant.lastReadAt!)
).length;
```

**개선 코드**:
```dart
// DB에서 직접 카운트
int unreadCount;
if (participant.leftAt != null) {
  unreadCount = await ChatMessage.db.count(
    session,
    where: (msg) =>
      msg.chatRoomId.equals(chatRoomId) &
      msg.senderId.notEquals(userId) &
      msg.createdAt.greaterThan(participant.leftAt!),
  );
} else if (participant.lastReadAt != null) {
  unreadCount = await ChatMessage.db.count(
    session,
    where: (msg) =>
      msg.chatRoomId.equals(chatRoomId) &
      msg.senderId.notEquals(userId) &
      msg.createdAt.greaterThan(participant.lastReadAt!),
  );
} else {
  unreadCount = await ChatMessage.db.count(
    session,
    where: (msg) =>
      msg.chatRoomId.equals(chatRoomId) &
      msg.senderId.notEquals(userId),
  );
}
```

#### 1.2 ReviewListService.getReceivedReviews 최적화
- [ ] reviewer/reviewee ID 목록 수집
- [ ] IN 쿼리로 한 번에 User 조회
- [ ] Map으로 매핑 후 DTO 생성

**현재 코드** (review_list_service.dart):
```dart
// 문제: 각 후기마다 2개 쿼리
for (final review in reviews) {
  final reviewer = await User.db.findById(session, review.reviewerId);
  final reviewee = await User.db.findById(session, review.revieweeId);
  // DTO 생성...
}
```

**개선 코드**:
```dart
// 1. ID 수집
final reviewerIds = reviews.map((r) => r.reviewerId).toSet();
final revieweeIds = reviews.map((r) => r.revieweeId).toSet();
final allUserIds = {...reviewerIds, ...revieweeIds};

// 2. 한 번에 조회
final users = await User.db.find(
  session,
  where: (u) => u.id.inSet(allUserIds),
);

// 3. Map 생성
final userMap = {for (var u in users) u.id!: u};

// 4. DTO 생성
for (final review in reviews) {
  final reviewer = userMap[review.reviewerId];
  final reviewee = userMap[review.revieweeId];
  // DTO 생성...
}
```

#### 1.3 ReviewListService.getAllReviewsByUserId 평균 최적화
- [ ] SQL AVG 대신 별도 COUNT/SUM 쿼리 사용
- [ ] 또는 Raw SQL 사용

**현재 코드**:
```dart
// 문제: 평균 계산 위해 전체 로드
final allReviews = await TransactionReview.db.find(
  session,
  where: (review) => review.revieweeId.equals(userId),
);
final totalRating = allReviews.fold<int>(0, (sum, r) => sum + r.rating);
averageRating = totalRating / allReviews.length;
```

**개선 코드**:
```dart
// 별도 통계 쿼리 (Serverpod 방식)
// 옵션 1: 두 번의 쿼리로 분리
final totalCount = await TransactionReview.db.count(
  session,
  where: (review) => review.revieweeId.equals(userId),
);

// Serverpod은 SUM을 직접 지원하지 않으므로,
// 전체 로드 대신 totalCount만으로 먼저 처리
// 평균은 필요할 때만 별도 조회

// 옵션 2: Raw SQL 사용 (PostgreSQL)
// final result = await session.db.unsafeQuery(
//   'SELECT AVG(rating) as avg FROM transaction_review WHERE reviewee_id = @userId',
//   {'userId': userId},
// );
```

**예상 영향**:
- 영향 받는 파일:
  - `lib/src/feature/chat/service/chat_notification_service.dart`
  - `lib/src/feature/review/service/review_list_service.dart`
- 의존성: 없음

**검증 방법**:
- [ ] 쿼리 로그로 쿼리 수 확인
- [ ] 동일한 결과값 반환 확인
- [ ] 빌드 성공

---

### Phase 2: N+1 쿼리 최적화 (Product & FCM)
**목표**: 상품 및 FCM 관련 N+1 쿼리 제거

**작업 목록**:

#### 2.1 ProductListService.getMyFavoriteProducts 최적화
- [ ] Favorite에서 productId 목록 수집
- [ ] IN 쿼리로 한 번에 Product 조회

**현재 코드** (product_list_service.dart):
```dart
// 문제: 각 찜마다 Product 조회
for (final favorite in paginatedFavorites) {
  final product = await Product.db.findById(session, favorite.productId);
  if (product != null) {
    products.add(product);
  }
}
```

**개선 코드**:
```dart
// 1. productId 목록 추출
final productIds = paginatedFavorites.map((f) => f.productId).toList();

// 2. 한 번에 조회
final products = await Product.db.find(
  session,
  where: (p) => p.id.inSet(productIds),
);

// 3. 순서 유지 (찜한 순서)
final productMap = {for (var p in products) p.id!: p};
final orderedProducts = productIds
    .map((id) => productMap[id])
    .whereType<Product>()
    .toList();
```

#### 2.2 FcmTokenService.getTokensByChatRoomIdWithNotificationSettings 최적화
- [ ] 참여자 목록에서 userId 추출
- [ ] IN 쿼리로 한 번에 FCM 토큰 조회

**현재 코드** (fcm_token_service.dart):
```dart
// 문제: 각 참여자마다 토큰 조회
for (final participant in participants) {
  final tokens = await getTokensByUserId(
    session: session,
    userId: participant.userId,
  );
  // ...
}
```

**개선 코드**:
```dart
// 1. userId 목록 추출
final userIds = participants.map((p) => p.userId).toList();

// 2. 한 번에 모든 토큰 조회
final allTokens = await FcmToken.db.find(
  session,
  where: (t) => t.userId.inSet(userIds),
);

// 3. userId별로 그룹화
final tokensByUserId = <int, List<FcmToken>>{};
for (final token in allTokens) {
  tokensByUserId.putIfAbsent(token.userId, () => []).add(token);
}

// 4. 결과 매핑
final result = <int, Map<String, bool>>{};
for (final participant in participants) {
  final tokens = tokensByUserId[participant.userId] ?? [];
  if (tokens.isEmpty) continue;

  final tokenMap = <String, bool>{};
  for (final token in tokens) {
    tokenMap[token.token] = participant.isNotificationEnabled;
  }
  result[participant.userId] = tokenMap;
}
```

**예상 영향**:
- 영향 받는 파일:
  - `lib/src/feature/product/service/product_list_service.dart`
  - `lib/src/feature/user/service/fcm_token_service.dart`
- 의존성: Phase 1 완료 권장

**검증 방법**:
- [ ] 찜 목록 정상 조회 확인
- [ ] FCM 토큰 정상 조회 확인
- [ ] 쿼리 수 감소 확인

---

### Phase 3: 메모리 필터링 → DB 필터링
**목표**: 메모리 기반 필터링을 DB WHERE 절로 이동

**작업 목록**:

#### 3.1 ProductListService.getPaginatedProducts excludeSold 최적화
- [ ] excludeSold 조건을 WHERE 절에 추가
- [ ] 메모리 필터링 제거

**현재 코드**:
```dart
// 문제: 전체 로드 후 메모리 필터링
if (filterParams.excludeSold) {
  final allProducts = await _findProductsWithFilter(session, filterParams);
  final filteredProducts = _filterSoldProducts(allProducts);
  // 메모리에서 정렬, 페이지네이션...
}
```

**개선 코드**:
```dart
// DB에서 직접 필터링
var whereCondition = /* 기존 조건 */;

if (filterParams.excludeSold) {
  // status가 sold가 아닌 것만 (null, selling, reserved)
  whereCondition = whereCondition &
    (product.status.equals(null) |
     product.status.equals(ProductStatus.selling) |
     product.status.equals(ProductStatus.reserved));
}

final products = await Product.db.find(
  session,
  where: (p) => whereCondition,
  orderBy: /* 정렬 */,
  limit: limit,
  offset: offset,
);
```

#### 3.2 ChatMessageService.getChatMessagesPaginated leftAt 최적화
- [ ] leftAt 조건을 WHERE 절에 추가
- [ ] 메모리 필터링 제거

**현재 코드**:
```dart
// 문제: 전체 로드 후 메모리 필터링
final allMessages = await ChatMessage.db.find(...);
final filteredMessages = leftAtFilter != null
    ? allMessages.where((msg) => msg.createdAt!.isAfter(leftAtFilter!)).toList()
    : allMessages;
```

**개선 코드**:
```dart
// DB에서 직접 필터링
var whereCondition = (msg) => msg.chatRoomId.equals(request.chatRoomId);

if (leftAtFilter != null) {
  whereCondition = (msg) =>
    msg.chatRoomId.equals(request.chatRoomId) &
    msg.createdAt.greaterThan(leftAtFilter);
}

final messages = await ChatMessage.db.find(
  session,
  where: whereCondition,
  orderBy: (msg) => msg.createdAt,
  orderDescending: true,
  limit: limit,
  offset: offset,
);
```

**예상 영향**:
- 영향 받는 파일:
  - `lib/src/feature/product/service/product_list_service.dart`
  - `lib/src/feature/chat/service/chat_message_service.dart`
- 의존성: Phase 1, 2 완료 권장

**검증 방법**:
- [ ] excludeSold 필터 정상 동작
- [ ] leftAt 필터 정상 동작
- [ ] 대량 데이터에서 성능 향상 확인

---

### Phase 4: 코드 중복 제거
**목표**: 중복 코드를 공통 메서드로 추출

**작업 목록**:

#### 4.1 AuthService.getOrCreateUserAfter*Login 통합
- [ ] 공통 private 메서드 `_getOrCreateUser` 생성
- [ ] 4개 메서드에서 공통 메서드 호출

**현재 코드** (auth_service.dart):
```dart
// 4개의 거의 동일한 메서드
static Future<User> getOrCreateUserAfterGoogleLogin(Session session) async { ... }
static Future<User> getOrCreateUserAfterAppleLogin(Session session) async { ... }
static Future<User> getOrCreateUserAfterKakaoLogin(Session session) async { ... }
static Future<User> getOrCreateUserAfterNaverLogin(Session session) async { ... }
```

**개선 코드**:
```dart
/// 공통 User 생성/조회 로직
static Future<User> _getOrCreateUser(Session session) async {
  final authenticationInfo = await session.authenticated;
  if (authenticationInfo == null) {
    throw Exception('인증 정보가 없습니다.');
  }

  final userInfo = await UserInfo.db.findById(
    session,
    authenticationInfo.userId,
  );
  if (userInfo == null) {
    throw Exception('사용자 정보를 찾을 수 없습니다.');
  }

  // 기존 User 확인
  final existingUser = await User.db.findFirstRow(
    session,
    where: (user) => user.userInfoId.equals(userInfo.id ?? 0),
  );

  if (existingUser != null) {
    return existingUser.copyWith(userInfo: userInfo);
  }

  // 새 User 생성
  final now = DateTime.now().toUtc();
  final nickname = '장비충#${const Uuid().v4().substring(0, 8)}';

  final newUser = User(
    userInfoId: userInfo.id!,
    nickname: nickname,
    createdAt: now,
  );

  final createdUser = await User.db.insertRow(session, newUser);
  return createdUser.copyWith(userInfo: userInfo);
}

// 공개 메서드들은 단순 위임
static Future<User> getOrCreateUserAfterGoogleLogin(Session session) async {
  return _getOrCreateUser(session);
}

static Future<User> getOrCreateUserAfterAppleLogin(Session session) async {
  return _getOrCreateUser(session);
}

static Future<User> getOrCreateUserAfterKakaoLogin(Session session) async {
  return _getOrCreateUser(session);
}

static Future<User> getOrCreateUserAfterNaverLogin(Session session) async {
  return _getOrCreateUser(session);
}
```

#### 4.2 ReviewService.createTransactionReview/createSellerReview 통합
- [ ] 공통 private 메서드 `_createReview` 생성
- [ ] reviewType만 다르게 전달

**현재 코드** (review_service.dart):
```dart
// 2개의 거의 동일한 메서드
static Future<TransactionReviewResponseDto> createTransactionReview(...) async {
  // reviewType = ReviewType.seller_to_buyer
  // ... 동일한 로직
}

static Future<TransactionReviewResponseDto> createSellerReview(...) async {
  // reviewType = ReviewType.buyer_to_seller
  // ... 동일한 로직
}
```

**개선 코드**:
```dart
/// 공통 후기 생성 로직
static Future<TransactionReviewResponseDto> _createReview({
  required Session session,
  required int reviewerId,
  required CreateTransactionReviewRequestDto request,
  required ReviewType reviewType,
}) async {
  // 1. 검증
  if (request.rating < 1 || request.rating > 5) {
    throw Exception('평점은 1~5 사이의 값이어야 합니다.');
  }
  if (request.content != null && request.content!.length > 500) {
    throw Exception('후기 내용은 500자를 초과할 수 없습니다.');
  }

  // 2. 중복 확인
  final existingReview = await TransactionReview.db.findFirstRow(
    session,
    where: (review) =>
        review.productId.equals(request.productId) &
        review.chatRoomId.equals(request.chatRoomId) &
        review.reviewerId.equals(reviewerId) &
        review.reviewType.equals(reviewType),
  );
  if (existingReview != null) {
    throw Exception('이미 후기를 작성하셨습니다.');
  }

  // 3. 후기 생성
  final now = DateTime.now().toUtc();
  final review = TransactionReview(
    productId: request.productId,
    chatRoomId: request.chatRoomId,
    reviewerId: reviewerId,
    revieweeId: request.revieweeId,
    rating: request.rating,
    content: request.content,
    reviewType: reviewType,
    createdAt: now,
    updatedAt: now,
  );

  final createdReview = await TransactionReview.db.insertRow(session, review);

  // 4. 사용자 정보 조회
  final reviewer = await User.db.findById(session, reviewerId);
  final reviewee = await User.db.findById(session, request.revieweeId);

  // 5. 알림 전송 (비동기)
  await _sendReviewNotification(
    session: session,
    review: createdReview,
    reviewer: reviewer,
    reviewee: reviewee,
  ).catchError((error) {
    developer.log('[ReviewService] _createReview - warning: notification failed');
  });

  // 6. 응답 생성
  return TransactionReviewResponseDto(
    id: createdReview.id!,
    productId: createdReview.productId,
    chatRoomId: createdReview.chatRoomId,
    reviewerId: createdReview.reviewerId,
    reviewerNickname: reviewer?.nickname,
    reviewerProfileImageUrl: reviewer?.profileImageUrl,
    revieweeId: createdReview.revieweeId,
    revieweeNickname: reviewee?.nickname,
    rating: createdReview.rating,
    content: createdReview.content,
    reviewType: createdReview.reviewType,
    createdAt: createdReview.createdAt,
  );
}

/// 판매자 → 구매자 후기 (seller_to_buyer)
static Future<TransactionReviewResponseDto> createTransactionReview({
  required Session session,
  required int reviewerId,
  required CreateTransactionReviewRequestDto request,
}) async {
  return _createReview(
    session: session,
    reviewerId: reviewerId,
    request: request,
    reviewType: ReviewType.seller_to_buyer,
  );
}

/// 구매자 → 판매자 후기 (buyer_to_seller)
static Future<TransactionReviewResponseDto> createSellerReview({
  required Session session,
  required int reviewerId,
  required CreateTransactionReviewRequestDto request,
}) async {
  return _createReview(
    session: session,
    reviewerId: reviewerId,
    request: request,
    reviewType: ReviewType.buyer_to_seller,
  );
}
```

**예상 영향**:
- 영향 받는 파일:
  - `lib/src/feature/auth/service/auth_service.dart`
  - `lib/src/feature/review/service/review_service.dart`
- 의존성: Phase 1-3 완료 권장

**검증 방법**:
- [ ] 모든 OAuth 로그인 정상 동작
- [ ] 양방향 후기 작성 정상 동작
- [ ] 빌드 성공

---

### Phase 5: 코드 품질 개선
**목표**: 상수 정의, 예외 타입화

**작업 목록**:

#### 5.1 상수 파일 생성
- [ ] `lib/src/common/constants.dart` 생성
- [ ] 매직 넘버를 상수로 정의

**생성할 파일**:
```dart
// lib/src/common/constants.dart

/// 후기 관련 상수
class ReviewConstants {
  static const int minRating = 1;
  static const int maxRating = 5;
  static const int maxContentLength = 500;
  static const int fcmContentPreviewLength = 16;
}

/// 페이지네이션 상수
class PaginationConstants {
  static const int defaultPage = 1;
  static const int defaultLimit = 10;
  static const int maxLimit = 100;
}

/// FCM 상수
class FcmConstants {
  static const int tokenLogLength = 20;
  static const String chatChannel = 'chat_channel';
}
```

#### 5.2 Custom Exception 정의
- [ ] `lib/src/common/exceptions.dart` 생성
- [ ] 주요 예외 타입 정의

**생성할 파일**:
```dart
// lib/src/common/exceptions.dart

import 'package:serverpod/serverpod.dart';

/// 리소스를 찾을 수 없을 때
class NotFoundException extends SerializableException {
  final String resource;
  final int? id;

  NotFoundException(this.resource, [this.id]);

  @override
  String toString() => '$resource${id != null ? ' (id: $id)' : ''}을(를) 찾을 수 없습니다.';
}

/// 권한이 없을 때
class UnauthorizedException extends SerializableException {
  final String message;

  UnauthorizedException([this.message = '권한이 없습니다.']);

  @override
  String toString() => message;
}

/// 중복 데이터
class DuplicateException extends SerializableException {
  final String message;

  DuplicateException([this.message = '이미 존재하는 데이터입니다.']);

  @override
  String toString() => message;
}

/// 유효성 검증 실패
class ValidationException extends SerializableException {
  final String field;
  final String message;

  ValidationException(this.field, this.message);

  @override
  String toString() => '$field: $message';
}
```

**예상 영향**:
- 새 파일 생성:
  - `lib/src/common/constants.dart`
  - `lib/src/common/exceptions.dart`
- 기존 파일 수정 (import 추가)
- 의존성: Phase 1-4 완료 권장

**검증 방법**:
- [ ] 상수 사용으로 변경된 코드 동작 확인
- [ ] 예외 타입으로 변경된 에러 처리 확인
- [ ] 빌드 성공

---

## 4. 리스크 및 대응

### 리스크 1: Serverpod ORM 제약
- **설명**: Serverpod ORM이 IN 쿼리, JOIN을 완벽히 지원하지 않을 수 있음
- **확률**: Medium
- **영향도**: High
- **완화 방안**:
  - `inSet()` 메서드 지원 여부 확인
  - 지원하지 않으면 Raw SQL 사용 또는 여러 쿼리로 분할

### 리스크 2: 쿼리 변경으로 인한 결과 차이
- **설명**: DB 필터링과 메모리 필터링 결과가 미묘하게 다를 수 있음
- **확률**: Low
- **영향도**: Medium
- **완화 방안**:
  - 기존 로직과 새 로직 결과 비교 테스트
  - null 처리, 정렬 순서 주의

### 리스크 3: 대량 수정으로 인한 버그
- **설명**: 여러 파일 수정 시 실수 가능
- **확률**: Medium
- **영향도**: Medium
- **완화 방안**:
  - Phase별로 점진적 수정
  - 각 Phase 완료 후 빌드/테스트

---

## 5. 전체 검증 계획

### 빌드 검증
- [ ] `dart analyze lib/` 통과
- [ ] `dart compile` 성공
- [ ] 서버 시작 정상

### 기능 테스트

#### Phase 1 검증
- [ ] 채팅 목록에서 unreadCount 정상 표시
- [ ] 후기 목록에서 reviewer/reviewee 정보 표시
- [ ] 평균 평점 계산 정확

#### Phase 2 검증
- [ ] 찜 목록 정상 조회 (순서 유지)
- [ ] FCM 토큰 조회 정상

#### Phase 3 검증
- [ ] excludeSold 필터 정상 동작
- [ ] leftAt 기반 메시지 필터링 정상

#### Phase 4 검증
- [ ] Google/Apple/Kakao/Naver 로그인 후 User 생성 정상
- [ ] seller_to_buyer/buyer_to_seller 후기 작성 정상

#### Phase 5 검증
- [ ] 상수 적용된 검증 로직 정상
- [ ] 예외 타입 정상 동작

### 성능 검증
- [ ] 채팅 목록 쿼리 수: N+1 → 3개 이하
- [ ] 후기 목록 쿼리 수: 2N+1 → 3개 이하
- [ ] 찜 목록 쿼리 수: N+1 → 2개

---

## 6. 참고 사항

### Serverpod ORM 참고
- `db.find()`: 목록 조회
- `db.findById()`: ID로 단일 조회
- `db.count()`: 개수 조회
- `inSet()`: IN 쿼리 (지원 여부 확인 필요)

### 파일 위치 요약

| Phase | 파일 |
|-------|------|
| Phase 1 | chat_notification_service.dart, review_list_service.dart |
| Phase 2 | product_list_service.dart, fcm_token_service.dart |
| Phase 3 | product_list_service.dart, chat_message_service.dart |
| Phase 4 | auth_service.dart, review_service.dart |
| Phase 5 | common/constants.dart (새 파일), common/exceptions.dart (새 파일) |

### 권장 진행 순서
1. Phase 1 (가장 빈번한 쿼리 최적화)
2. Phase 2 (나머지 N+1 쿼리)
3. Phase 3 (메모리 필터링 제거)
4. Phase 4 (코드 중복 제거)
5. Phase 5 (코드 품질 - 선택적)

---

**작성 완료**: 2026-01-12
