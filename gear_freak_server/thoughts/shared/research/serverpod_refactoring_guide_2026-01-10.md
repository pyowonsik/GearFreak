# Gear Freak Server - NestJS 스타일 리팩토링 가이드

**날짜**: 2026-01-10
**분석 대상**: Serverpod 백엔드 프로젝트를 NestJS 스타일로 리팩토링

## 1. 프로젝트 개요

### 현재 상태
- **프레임워크**: Serverpod 2.9.2
- **언어**: Dart
- **기능 모듈**: auth, chat, notification, product, review, user

### 목표
NestJS의 깔끔한 레이어 분리와 주석 스타일을 Serverpod에 적용

---

## 2. NestJS vs Serverpod 구조 비교

### NestJS 구조 (참조 모델)
```
src/
├── product/
│   ├── dto/                    # DTO 정의
│   │   ├── create-product.dto.ts
│   │   ├── product-response.dto.ts
│   │   └── index.ts           # barrel export
│   ├── entity/                 # Entity 정의
│   │   ├── product.entity.ts
│   │   └── index.ts
│   ├── product.controller.ts   # Controller (Endpoint)
│   ├── product.service.ts      # Service (비즈니스 로직)
│   └── product.module.ts       # Module 등록
```

### Serverpod 현재 구조
```
lib/src/
├── feature/
│   ├── product/
│   │   ├── endpoint/
│   │   │   └── product_endpoint.dart    # Endpoint (Controller 역할)
│   │   ├── service/
│   │   │   ├── product_service.dart
│   │   │   ├── product_list_service.dart
│   │   │   ├── product_interaction_service.dart
│   │   │   ├── product_report_service.dart
│   │   │   └── service.dart             # barrel export
│   │   └── util/
│   │       └── product_filter_util.dart
├── generated/                           # 자동 생성 (DTO, Entity)
│   ├── feature/product/model/
│   │   ├── product.dart
│   │   └── dto/
```

---

## 3. 현재 문제점 분석

### 3.1 레이어 분리 불일치

**NestJS 패턴**:
- Controller: 라우팅 + 요청 검증 + 응답 반환
- Service: 비즈니스 로직만

**Serverpod 현재 상태**:
- Endpoint: Controller 역할이지만 서비스 인스턴스를 직접 생성
- Service: 비즈니스 로직 담당 (양호)

```dart
// 현재: Endpoint에서 Service를 직접 생성
class ProductEndpoint extends Endpoint {
  final ProductService productService = ProductService();
  final ProductListService productListService = ProductListService();
  // ...
}
```

### 3.2 주석 스타일 불일치

**NestJS 스타일**:
```typescript
/**
 * Create product
 */
async createProduct(...): Promise<ProductResponseDto> { }
```

**Serverpod 현재 스타일 (일관성 없음)**:
```dart
// 어떤 곳은 ///
/// 상품 생성
Future<Product> createProduct(...) async { }

// 어떤 곳은 주석 없음
Future<Product> getProduct(Session session, int id) async { }
```

### 3.3 로깅 스타일 불일치

**NestJS 스타일**:
```typescript
private readonly logger = new Logger(ChatService.name);
this.logger.log('Message');
this.logger.warn('Warning');
```

**Serverpod 현재 스타일 (이모지 사용)**:
```dart
session.log('💬 채팅방 생성/조회 시작 - userId: $userId', level: LogLevel.info);
session.log('✅ 기존 채팅방 발견', level: LogLevel.info);
session.log('❌ 채팅방 생성/조회 실패: $e', level: LogLevel.error);
```

### 3.4 Service 세분화

**NestJS**: 하나의 Service에 모든 로직
**Serverpod 현재**: 기능별로 Service 분리 (이건 좋은 패턴)
- `ProductService` - CRUD
- `ProductListService` - 목록/통계
- `ProductInteractionService` - 찜/조회수
- `ProductReportService` - 신고

---

## 4. 리팩토링 권장사항

### 4.1 Endpoint 주석 표준화

**적용할 스타일**:
```dart
/// 상품 엔드포인트
///
/// 상품 CRUD 및 관련 기능을 제공합니다.
class ProductEndpoint extends Endpoint with AuthenticatedMixin {

  // ==================== Public Methods ====================

  /// 상품 생성
  ///
  /// [request]: 상품 생성 요청 DTO
  /// Returns: 생성된 상품 정보
  Future<Product> createProduct(
    Session session,
    CreateProductRequestDto request,
  ) async {
    final user = await UserService.getMe(session);
    return await productService.createProduct(session, user.id!, request);
  }
}
```

### 4.2 Service 주석 표준화

**적용할 스타일**:
```dart
/// 상품 서비스
///
/// 상품 기본 CRUD 및 상태 관리 관련 비즈니스 로직을 처리합니다.
class ProductService {

  // ==================== Public Methods ====================

  /// 상품 생성
  ///
  /// [session]: 서버 세션
  /// [sellerId]: 판매자 ID
  /// [request]: 상품 생성 요청 DTO
  /// Returns: 생성된 상품
  /// Throws: Exception - 이미지 이동 실패 시 원본 URL 유지
  Future<Product> createProduct(
    Session session,
    int sellerId,
    CreateProductRequestDto request,
  ) async {
    // 구현...
  }

  // ==================== Private Methods ====================

  /// 이미지 URL을 임시 경로에서 실제 경로로 이동
  Future<List<String>> _moveImagesToProductPath(
    Session session,
    int productId,
    List<String> imageUrls,
  ) async {
    // 구현...
  }
}
```

### 4.3 로깅 표준화 (이모지 제거)

**Before**:
```dart
session.log('💬 채팅방 생성/조회 시작 - userId: $userId', level: LogLevel.info);
session.log('✅ 채팅방 생성 완료', level: LogLevel.info);
session.log('❌ 오류 발생: $e', level: LogLevel.error);
```

**After**:
```dart
session.log('[ChatRoomService] createOrGetChatRoom - start: userId=$userId, productId=${request.productId}', level: LogLevel.info);
session.log('[ChatRoomService] createOrGetChatRoom - success: chatRoomId=${createdChatRoom.id}', level: LogLevel.info);
session.log('[ChatRoomService] createOrGetChatRoom - error: $e', level: LogLevel.error, exception: e, stackTrace: stackTrace);
```

**로그 형식 규칙**:
```
[클래스명] 메서드명 - 상태: 주요정보
```

### 4.4 섹션 주석 표준화

**NestJS 스타일 (참조)**:
```typescript
// ==================== Private Methods ====================
private toProductResponse(...) { }
```

**Serverpod 적용**:
```dart
// ==================== Public Methods ====================

// ==================== Private Helper Methods ====================
```

### 4.5 Barrel Export 파일 유지

현재 구조 유지 (좋은 패턴):
```dart
// service/service.dart
export 'product_service.dart';
export 'product_list_service.dart';
export 'product_interaction_service.dart';
export 'product_report_service.dart';
```

---

## 5. 파일별 리팩토링 체크리스트

### 5.1 Endpoint 파일

| 파일 | 현재 상태 | 개선 필요 |
|------|----------|----------|
| `product_endpoint.dart` | 주석 일부 있음 | 표준 주석 추가 |
| `chat_endpoint.dart` | 섹션 주석 있음 | 로그 이모지 제거 |
| `auth_endpoint.dart` | 주석 양호 | 유지 |
| `user_endpoint.dart` | 확인 필요 | 표준 주석 추가 |
| `notification_endpoint.dart` | 확인 필요 | 표준 주석 추가 |
| `review_endpoint.dart` | 확인 필요 | 표준 주석 추가 |

### 5.2 Service 파일

| 파일 | 현재 상태 | 개선 필요 |
|------|----------|----------|
| `product_service.dart` | 기본 주석 있음 | 상세 주석 추가 |
| `chat_room_service.dart` | 이모지 로그 있음 | 로그 형식 표준화 |
| `chat_message_service.dart` | 확인 필요 | 표준 적용 |
| `auth_service.dart` | 확인 필요 | 표준 적용 |

---

## 6. 코드 스타일 가이드

### 6.1 주석 규칙

```dart
/// 클래스 설명 (한 줄)
///
/// 상세 설명 (선택적)
class MyClass {

  /// 메서드 설명 (한 줄)
  ///
  /// [param1]: 파라미터 설명
  /// [param2]: 파라미터 설명
  /// Returns: 반환값 설명
  /// Throws: Exception - 예외 조건
  Future<ReturnType> myMethod(Type param1, Type param2) async {
    // 구현
  }
}
```

### 6.2 로그 규칙

```dart
// INFO 레벨 - 시작/성공
session.log(
  '[ClassName] methodName - start: key1=$value1, key2=$value2',
  level: LogLevel.info,
);

// WARNING 레벨 - 경고 (계속 진행)
session.log(
  '[ClassName] methodName - warning: 상황 설명',
  level: LogLevel.warning,
);

// ERROR 레벨 - 에러 (실패)
session.log(
  '[ClassName] methodName - error: $e',
  level: LogLevel.error,
  exception: e,
  stackTrace: stackTrace,
);
```

### 6.3 섹션 구분

```dart
class MyService {

  // ==================== Public Methods ====================

  /// 공개 메서드들...

  // ==================== Private Helper Methods ====================

  /// 비공개 헬퍼 메서드들...
}
```

### 6.4 Import 순서

```dart
// 1. Dart SDK
import 'dart:async';

// 2. 외부 패키지
import 'package:serverpod/serverpod.dart';

// 3. 프로젝트 내부 - generated
import 'package:gear_freak_server/src/generated/protocol.dart';

// 4. 프로젝트 내부 - common
import 'package:gear_freak_server/src/common/authenticated_mixin.dart';

// 5. 프로젝트 내부 - feature
import 'package:gear_freak_server/src/feature/user/service/user_service.dart';
```

---

## 7. 리팩토링 우선순위

### Phase 1: 로그 표준화 (가장 빠른 개선)
1. 모든 이모지 로그를 `[ClassName] methodName - status:` 형식으로 변경
2. `LogLevel` 적절히 사용

### Phase 2: 주석 표준화
1. 모든 public 메서드에 `///` 문서화 주석 추가
2. 파라미터와 반환값 설명 추가

### Phase 3: 섹션 주석 추가
1. `// ==================== Section Name ====================` 형식 적용
2. Public/Private 메서드 구분

### Phase 4: 코드 정리
1. 불필요한 주석 제거
2. Import 순서 정리
3. 일관된 네이밍 컨벤션 확인

---

## 8. 결론

### 유지할 좋은 패턴
- Service 세분화 (ProductService, ProductListService 등)
- Barrel export 파일 (service.dart, endpoint.dart)
- Mixin 활용 (AuthenticatedMixin)

### 개선이 필요한 영역
- 로그 메시지 형식 (이모지 → 구조화된 형식)
- 주석 일관성 (모든 public 메서드에 적용)
- 섹션 구분 주석 (Public/Private 구분)

### 예상 효과
- 코드 가독성 향상
- 유지보수성 향상
- 로그 검색 및 분석 용이
- 새 개발자 온보딩 시간 단축
