# Gear Freak Server 코드베이스 전체 리뷰

**날짜**: 2026-01-12
**분석 대상**: Serverpod 백엔드 전체 코드
**분석자**: Claude

---

## 1. 프로젝트 개요

### 1.1 목적
피트니스 장비 중고 거래 앱의 백엔드 서버

### 1.2 주요 기능
- 사용자 인증 (OAuth: Kakao, Naver, Google, Apple)
- 상품 CRUD 및 검색
- 실시간 채팅 (1:1 거래 채팅)
- FCM 푸시 알림
- 거래 후기 시스템 (양방향: 구매자 ↔ 판매자)
- S3 이미지 업로드

---

## 2. 기술 스택

| 항목 | 기술 |
|------|------|
| **프레임워크** | Serverpod 2.9.2 |
| **언어** | Dart 3.5+ |
| **인증** | Serverpod Auth + OAuth |
| **실시간 통신** | Serverpod Streams (Redis 기반) |
| **파일 저장소** | AWS S3 (Public + Private 버킷) |
| **푸시 알림** | Firebase Cloud Messaging (FCM V1 API) |
| **데이터베이스** | PostgreSQL (Serverpod 기본) |

---

## 3. 프로젝트 구조

```
lib/src/
├── common/                          # 공통 모듈
│   ├── authenticated_mixin.dart     # 인증 필수 엔드포인트 Mixin
│   ├── fcm/
│   │   └── service/
│   │       └── fcm_service.dart     # FCM 알림 전송
│   └── s3/
│       ├── endpoint/
│       │   └── s3_endpoint.dart     # S3 업로드 URL API
│       ├── service/
│       │   └── s3_service.dart      # S3 Presigned URL 생성
│       └── util/
│           └── s3_util.dart         # S3 파일 경로 유틸
│
├── feature/                         # 기능별 모듈
│   ├── auth/                        # 인증
│   │   ├── endpoint/
│   │   │   └── auth_endpoint.dart
│   │   └── service/
│   │       └── auth_service.dart
│   │
│   ├── product/                     # 상품
│   │   ├── endpoint/
│   │   │   └── product_endpoint.dart
│   │   ├── service/
│   │   │   ├── product_service.dart           # CRUD
│   │   │   ├── product_list_service.dart      # 목록 조회
│   │   │   ├── product_interaction_service.dart # 찜, 조회수
│   │   │   └── product_report_service.dart    # 신고
│   │   └── util/
│   │       └── product_filter_util.dart
│   │
│   ├── chat/                        # 채팅
│   │   ├── endpoint/
│   │   │   ├── chat_endpoint.dart
│   │   │   └── chat_stream_endpoint.dart      # 실시간 스트림
│   │   └── service/
│   │       ├── chat_room_service.dart
│   │       ├── chat_message_service.dart
│   │       └── chat_notification_service.dart
│   │
│   ├── user/                        # 사용자
│   │   ├── endpoint/
│   │   │   ├── user_endpoint.dart
│   │   │   └── fcm_endpoint.dart
│   │   └── service/
│   │       ├── user_service.dart
│   │       └── fcm_token_service.dart
│   │
│   ├── notification/                # 알림
│   │   ├── endpoint/
│   │   │   └── notification_endpoint.dart
│   │   └── service/
│   │       └── notification_service.dart
│   │
│   └── review/                      # 후기
│       ├── endpoint/
│       │   └── review_endpoint.dart
│       └── service/
│           ├── review_service.dart
│           └── review_list_service.dart
│
└── generated/                       # Serverpod 자동 생성 코드
    └── protocol.dart
```

---

## 4. 아키텍처 패턴

### 4.1 레이어 구조

```
Endpoint (API Layer)
    │
    ↓ 위임
Service (Business Logic Layer)
    │
    ↓ 데이터 접근
Model + Database (Data Layer - Serverpod ORM)
```

### 4.2 핵심 설계 원칙

| 원칙 | 적용 |
|------|------|
| **Thin Controller** | Endpoint는 Service에 위임만 수행 |
| **Service 분리** | 도메인별 책임 분리 (ProductService, ProductListService 등) |
| **Mixin 활용** | AuthenticatedMixin으로 인증 일관성 |
| **DTO 패턴** | Request/Response DTO로 데이터 전송 |

---

## 5. 핵심 모듈 분석

### 5.1 인증 시스템 (Auth)

**구조:**
```
AuthEndpoint
    ↓
AuthService
    ├── signupWithoutEmailVerification() - 개발용 직접 가입
    ├── authenticateWithKakao()          - 카카오 OAuth
    ├── authenticateWithNaver()          - 네이버 OAuth
    └── getOrCreateUserAfter*Login()     - User 테이블 생성
```

**특징:**
- Serverpod Auth 모듈 + 커스텀 OAuth 검증
- UserInfo (Serverpod) + User (커스텀) 이중 테이블 구조
- 닉네임 자동 생성: `장비충#UUID`

**개선 필요:**
- ⚠️ `getOrCreateUserAfter*Login` 4개 메서드 중복 (DRY 위반)
- ⚠️ 에러 응답에 `failReason: null` 반환 (디버깅 어려움)
- ⚠️ 토큰 검증 시 타임아웃 미설정

---

### 5.2 상품 관리 (Product)

**서비스 분리 전략:**
```
ProductService              → CRUD, 상태 변경
ProductListService          → 목록 조회, 페이지네이션
ProductInteractionService   → 찜, 조회수
ProductReportService        → 신고
```

**특징:**
- S3 이미지 관리 (temp → product 경로 이동)
- 찜 개수 동기화 (Favorite 테이블 + Product.favoriteCount)
- 조회수 중복 방지 (ProductView 테이블)

**개선 필요:**
- 🔴 N+1 쿼리 (getMyFavoriteProducts)
- 🔴 메모리 기반 필터링 (excludeSold 옵션)
- ⚠️ 이미지 이동 실패 시 임시 URL 그대로 저장

---

### 5.3 채팅 시스템 (Chat)

**실시간 메시징 구조:**
```
ChatMessageService.sendMessage()
    │
    ├── DB 저장
    ├── Redis 브로드캐스팅 (session.messages.postMessage)
    └── FCM 알림 (비동기)

ChatStreamEndpoint.chatMessageStream()
    │
    └── Redis 스트림 구독 (session.messages.createStream)
```

**특징:**
- Redis 기반 글로벌 브로드캐스팅
- leftAt 기반 메시지 필터링 (재참여 시)
- Private S3 버킷 Presigned URL 자동 변환
- FCM 알림 설정 분기 (알림 ON/OFF)

**개선 필요:**
- 🔴 N+1 쿼리 (getMyChatRooms - unreadCount 계산)
- 🔴 메모리 기반 메시지 필터링 (leftAt)
- ⚠️ Service 인스턴스 매번 생성 (싱글톤 권장)

---

### 5.4 S3 파일 관리

**Presigned URL 패턴:**
```
1. generatePresignedUploadUrlForRequest()
   → temp/{prefix}/{userId}/{timestamp}.{ext}

2. 상품 생성 시: moveS3Object()
   → temp/product/... → product/{productId}/...

3. 채팅 이미지: generateChatRoomImageUploadUrl()
   → chatRoom/{chatRoomId}/{userId}/{timestamp}.{ext}
   (임시 폴더 없이 바로 최종 경로)
```

**보안:**
- Content-Type 화이트리스트 검증
- AWS Signature V4 인증
- Presigned URL 1시간 만료

**설정:**
- Public 버킷: 상품, 프로필 이미지
- Private 버킷: 채팅 이미지 (Presigned URL로만 접근)

---

### 5.5 FCM 푸시 알림

**FCM V1 API 사용:**
```
FcmService.sendNotification()
    │
    ├── 서비스 계정 JSON → OAuth2 토큰 획득
    └── FCM API 호출 (Bearer 인증)
```

**특징:**
- Android/iOS 별도 설정 (priority, channel_id, apns)
- Data Only 모드 지원 (알림 설정 OFF 시)
- 토큰 마스킹 로깅 (보안)
- Session 닫힘 후 graceful degradation (developer.log)

---

### 5.6 알림 시스템 (Notification)

**데이터 구조:**
```dart
Notification {
  userId, notificationType, title, body,
  data (JSON),  // 딥링크 정보
  isRead, readAt
}
```

**현재 지원 타입:**
- `review_received` (거래 후기 수신)

**개선 필요:**
- ⚠️ NotificationType 확장 필요 (chat_message 등)
- ⚠️ data 필드 JSON 타입 안전성 부족
- 🔴 deleteNotificationsByProductId 성능 (모든 알림 스캔)

---

### 5.7 후기 시스템 (Review)

**양방향 후기:**
```
seller_to_buyer: 판매자 → 구매자 평가
buyer_to_seller: 구매자 → 판매자 평가
```

**유일성 제약:**
- `(productId, chatRoomId, reviewerId, reviewType)` 조합

**평점 계산:**
```dart
averageRating = Σ(rating) / count
```

**개선 필요:**
- 🔴 N+1 쿼리 (reviewer/reviewee 정보 조회)
- 🔴 평균 계산 시 전체 후기 로드 (SQL AVG 권장)
- ⚠️ createTransactionReview/createSellerReview 중복

---

## 6. 발견된 공통 패턴

### 6.1 좋은 패턴 ✅

| 패턴 | 설명 |
|------|------|
| **AuthenticatedMixin** | 인증 필수 엔드포인트 일관 처리 |
| **Thin Endpoint** | 비즈니스 로직 없이 Service 위임 |
| **Service 분리** | 도메인별 책임 분리 |
| **상세한 로깅** | `[ClassName] methodName - status:` 형식 |
| **DTO 패턴** | 명확한 Request/Response 분리 |
| **Presigned URL** | 서버 부하 없는 직접 업로드 |
| **Redis 스트리밍** | 실시간 메시징 |

### 6.2 개선 필요 패턴 ⚠️

| 문제 | 영향 | 우선순위 |
|------|------|---------|
| **N+1 쿼리** | 성능 저하 | 🔴 높음 |
| **메모리 필터링** | 대용량 데이터 시 OOM | 🔴 높음 |
| **코드 중복** | 유지보수 어려움 | 🟡 중간 |
| **Magic Number** | 변경 시 누락 위험 | 🟡 중간 |
| **Exception 타입화 부재** | 에러 처리 어려움 | 🟡 중간 |

---

## 7. 성능 이슈 상세

### 7.1 N+1 쿼리 발생 위치

| 위치 | 쿼리 수 | 영향 |
|------|--------|------|
| `getMyChatRooms` | N+1 (unreadCount) | 채팅 목록 조회 느림 |
| `getMyFavoriteProducts` | N+1 (product 조회) | 찜 목록 조회 느림 |
| `getReceivedReviews` | 2N+1 (reviewer + reviewee) | 후기 목록 조회 느림 |
| `getAllReviewsByUserId` | 2N+1 + 풀스캔 | 프로필 페이지 느림 |

### 7.2 메모리 필터링 위치

| 위치 | 데이터 로드 | 영향 |
|------|-----------|------|
| `getPaginatedProducts (excludeSold)` | 전체 상품 | 대용량 시 OOM |
| `getChatMessagesPaginated (leftAt)` | 전체 메시지 | 오래된 채팅방 느림 |
| `getAllReviewsByUserId (평균)` | 전체 후기 | 인기 판매자 느림 |
| `getUnreadCount` | 전체 메시지 | 매번 계산 |

---

## 8. 보안 분석

### 8.1 강점 ✅

| 항목 | 구현 |
|------|------|
| **인증** | AuthenticatedMixin + session.authenticated |
| **권한** | userId 일치 확인 (자신의 데이터만) |
| **S3 보안** | Content-Type 검증, Presigned URL 만료 |
| **토큰 보안** | FCM 토큰 마스킹 로깅 |
| **AWS 인증** | Signature V4, IAM Role 지원 |

### 8.2 개선 필요 ⚠️

| 항목 | 위험 | 권장 |
|------|------|------|
| **Rate Limiting 없음** | 스팸/DDoS | API Gateway 또는 미들웨어 |
| **파일 크기 제한 없음** | 스토리지 비용 | S3 Presigned URL 조건 추가 |
| **입력값 검증 부족** | 잘못된 데이터 | DTO 검증 강화 |

---

## 9. 권장 개선사항

### 9.1 즉시 조치 (우선순위: 높음)

1. **N+1 쿼리 최적화**
   - JOIN 쿼리 또는 IN 쿼리로 변경
   - 예: `getReceivedReviews`에서 reviewer/reviewee 배치 조회

2. **메모리 필터링 → DB 필터링**
   - leftAt, excludeSold 조건을 WHERE 절로 이동
   - SQL AVG 함수로 평균 계산

3. **코드 중복 제거**
   - `getOrCreateUserAfter*Login` 공통 메서드 추출
   - `createTransactionReview/createSellerReview` 통합

### 9.2 단기 개선 (우선순위: 중간)

4. **Custom Exception 도입**
   ```dart
   class ProductNotFoundException extends ServerpodException {}
   class UnauthorizedException extends ServerpodException {}
   ```

5. **상수 정의**
   ```dart
   const int MAX_REVIEW_CONTENT_LENGTH = 500;
   const int MIN_RATING = 1;
   const int MAX_RATING = 5;
   ```

6. **Service 싱글톤 패턴**
   ```dart
   static final ChatRoomService _instance = ChatRoomService._internal();
   factory ChatRoomService() => _instance;
   ```

### 9.3 장기 개선 (우선순위: 낮음)

7. **NotificationType 확장**
   - chat_message, product_status_change 등 추가

8. **테스트 코드 작성**
   - Service 단위 테스트
   - N+1 쿼리 모니터링 테스트

9. **국제화 대비**
   - 에러 메시지 코드화

---

## 10. 파일별 코드 라인 수

| 파일 | 라인 수 | 복잡도 |
|------|--------|--------|
| chat_room_service.dart | 771 | 높음 |
| chat_message_service.dart | 527 | 높음 |
| auth_service.dart | 459 | 중간 |
| review_service.dart | 481 | 중간 |
| notification_service.dart | 372 | 중간 |
| product_service.dart | 348 | 중간 |
| product_list_service.dart | 335 | 중간 |
| user_service.dart | 200 | 낮음 |
| fcm_token_service.dart | 250 | 낮음 |
| s3_service.dart | 320 | 중간 |
| fcm_service.dart | 280 | 중간 |

---

## 11. 결론

### 전체 평가

| 항목 | 점수 | 설명 |
|------|------|------|
| **아키텍처** | ⭐⭐⭐⭐ | 깔끔한 레이어 분리, Service 세분화 |
| **코드 품질** | ⭐⭐⭐⭐ | 상세한 로깅, 주석, 에러 처리 |
| **성능** | ⭐⭐⭐ | N+1 쿼리, 메모리 필터링 개선 필요 |
| **보안** | ⭐⭐⭐⭐ | 인증/권한 잘 구현, Rate Limiting 추가 권장 |
| **유지보수성** | ⭐⭐⭐ | 일부 코드 중복, 상수화 필요 |

### 요약

Gear Freak 서버는 **Serverpod를 잘 활용한 구조적으로 깔끔한 프로젝트**입니다.

**강점:**
- 명확한 레이어 분리 (Endpoint → Service → DB)
- 서비스 세분화 (ProductService, ProductListService 등)
- 상세한 로깅과 에러 처리
- S3, FCM 통합 잘 구현

**개선 필요:**
- N+1 쿼리 최적화 (가장 중요)
- 메모리 기반 필터링 → DB 쿼리로 변경
- 코드 중복 제거

---

**작성 완료**: 2026-01-12
