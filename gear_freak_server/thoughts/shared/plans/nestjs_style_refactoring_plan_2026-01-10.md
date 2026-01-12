# NestJS 스타일 리팩토링 구현 계획

**날짜**: 2026-01-10
**작성자**: Claude
**관련 연구 문서**: thoughts/shared/research/serverpod_refactoring_guide_2026-01-10.md

## 1. 요구사항

### 기능 개요
Serverpod 백엔드 프로젝트를 NestJS 스타일의 깔끔한 레이어 분리와 주석/로그 스타일로 리팩토링

### 목표
- 로그 메시지 표준화 (이모지 제거 → 구조화된 형식)
- 모든 public 메서드에 일관된 문서화 주석 적용
- 섹션 구분 주석으로 코드 구조 명확화
- Import 순서 정리

### 성공 기준
- [ ] 모든 이모지 로그가 `[ClassName] methodName - status:` 형식으로 변경됨
- [ ] 모든 public 메서드에 `///` 문서화 주석이 있음
- [ ] 모든 Service/Endpoint 클래스에 섹션 구분 주석이 있음
- [ ] Import 순서가 통일됨
- [ ] 빌드 및 기존 기능이 정상 동작함

---

## 2. 현황 분석

### 2.1 파일별 현재 상태

| 파일 | 라인 수 | 주석 상태 | 로그 상태 | 섹션 구분 |
|------|---------|----------|----------|----------|
| **Endpoint** |
| `product_endpoint.dart` | 199 | 일부 있음 | 없음 | 없음 |
| `chat_endpoint.dart` | 221 | 양호 | 없음 | 있음 |
| `auth_endpoint.dart` | 74 | 양호 | 없음 | 없음 |
| `user_endpoint.dart` | 34 | 양호 | 없음 | 없음 |
| `notification_endpoint.dart` | 95 | 양호 | 없음 | 없음 |
| `review_endpoint.dart` | 175 | 양호 | 없음 | 없음 |
| `fcm_endpoint.dart` | 50 | 확인 필요 | 없음 | 없음 |
| **Service** |
| `product_service.dart` | 348 | 기본 있음 | 일부 있음 | 없음 |
| `product_list_service.dart` | 335 | 확인 필요 | 확인 필요 | 없음 |
| `product_interaction_service.dart` | 114 | 확인 필요 | 확인 필요 | 없음 |
| `product_report_service.dart` | 77 | 확인 필요 | 확인 필요 | 없음 |
| `chat_room_service.dart` | 767 | 양호 | 이모지 있음 | 있음 |
| `chat_message_service.dart` | 496 | 양호 | 이모지+표준 혼재 | 없음 |
| `chat_notification_service.dart` | - | 확인 필요 | 확인 필요 | 없음 |
| `auth_service.dart` | 459 | 양호 | 없음 | 있음 |
| `user_service.dart` | 185 | 확인 필요 | 확인 필요 | 없음 |
| `fcm_token_service.dart` | 242 | 확인 필요 | 확인 필요 | 없음 |
| `notification_service.dart` | 365 | 확인 필요 | 확인 필요 | 없음 |
| `review_service.dart` | 462 | 확인 필요 | 확인 필요 | 없음 |
| `review_list_service.dart` | 236 | 확인 필요 | 확인 필요 | 없음 |

### 2.2 이모지 로그 현황

현재 이모지 사용 패턴:
- `💬` - 채팅 관련 시작
- `✅` - 성공
- `❌` - 실패/에러
- `⚠️` - 경고
- `📱` - FCM 관련
- `🚀` - 브로드캐스팅
- `⭐` - 주석 내 강조

---

## 3. 구현 단계

### Phase 1: 로그 표준화
**목표**: 모든 이모지 로그를 구조화된 형식으로 변경

**작업 목록**:
- [ ] `chat_room_service.dart` - 이모지 로그 → 표준 형식
- [ ] `chat_message_service.dart` - 이모지 로그 → 표준 형식
- [ ] `chat_notification_service.dart` - 로그 점검 및 표준화
- [ ] `fcm_token_service.dart` - 로그 점검 및 표준화
- [ ] `notification_service.dart` - 로그 점검 및 표준화
- [ ] `product_service.dart` - 로그 점검 및 표준화
- [ ] `review_service.dart` - 로그 점검 및 표준화

**변환 규칙**:
```dart
// Before
session.log('💬 채팅방 생성/조회 시작 - userId: $userId', level: LogLevel.info);
session.log('✅ 채팅방 생성 완료 - chatRoomId: ${createdChatRoom.id}', level: LogLevel.info);
session.log('❌ 채팅방 생성/조회 실패: $e', level: LogLevel.error);
session.log('⚠️ Presigned URL 생성 실패: $e', level: LogLevel.warning);

// After
session.log('[ChatRoomService] createOrGetChatRoom - start: userId=$userId, productId=${request.productId}', level: LogLevel.info);
session.log('[ChatRoomService] createOrGetChatRoom - success: chatRoomId=${createdChatRoom.id}', level: LogLevel.info);
session.log('[ChatRoomService] createOrGetChatRoom - error: $e', level: LogLevel.error, exception: e, stackTrace: stackTrace);
session.log('[ChatMessageService] sendMessage - warning: Presigned URL 생성 실패 - $e', level: LogLevel.warning);
```

**예상 영향**:
- 영향 받는 파일: lib/src/feature/chat/service/*.dart, lib/src/feature/**/service/*.dart
- 의존성: 없음 (독립적 작업)

**검증 방법**:
- [ ] `grep -r "💬\|✅\|❌\|⚠️\|📱\|🚀\|⭐" lib/src/` 결과가 주석 외에 없음
- [ ] 서버 빌드 성공
- [ ] 로그 출력 형식 확인

---

### Phase 2: 섹션 주석 추가
**목표**: 모든 Service/Endpoint 클래스에 섹션 구분 주석 추가

**작업 목록**:
- [ ] `product_endpoint.dart` - 섹션 주석 추가
- [ ] `product_service.dart` - 섹션 주석 추가
- [ ] `product_list_service.dart` - 섹션 주석 추가
- [ ] `product_interaction_service.dart` - 섹션 주석 추가
- [ ] `product_report_service.dart` - 섹션 주석 추가
- [ ] `chat_message_service.dart` - 섹션 주석 추가 (기존 없음)
- [ ] `notification_service.dart` - 섹션 주석 추가
- [ ] `user_service.dart` - 섹션 주석 추가
- [ ] `fcm_token_service.dart` - 섹션 주석 추가
- [ ] `review_service.dart` - 섹션 주석 추가
- [ ] `review_list_service.dart` - 섹션 주석 추가
- [ ] `fcm_endpoint.dart` - 섹션 주석 추가
- [ ] 이미 있는 파일 확인: `chat_endpoint.dart`, `chat_room_service.dart`, `auth_service.dart`

**섹션 구분 형식**:
```dart
class MyService {
  // ==================== Public Methods ====================

  /// 공개 메서드들...

  // ==================== Private Helper Methods ====================

  /// 비공개 헬퍼 메서드들...
}
```

**예상 영향**:
- 영향 받는 파일: 모든 Endpoint/Service 파일
- 의존성: Phase 1 완료 권장 (동시 진행 가능)

**검증 방법**:
- [ ] 모든 Service/Endpoint 클래스에 섹션 구분 주석 존재
- [ ] 빌드 성공

---

### Phase 3: 문서화 주석 표준화
**목표**: 모든 public 메서드에 일관된 문서화 주석 추가/수정

**작업 목록**:
- [ ] `product_endpoint.dart` - 주석 표준화 (일부만 있음)
- [ ] `product_service.dart` - 주석 상세화 (파라미터/반환값 추가)
- [ ] `product_list_service.dart` - 주석 추가/표준화
- [ ] `product_interaction_service.dart` - 주석 추가/표준화
- [ ] `product_report_service.dart` - 주석 추가/표준화
- [ ] `chat_message_service.dart` - 주석 상세화
- [ ] `user_service.dart` - 주석 추가/표준화
- [ ] `fcm_token_service.dart` - 주석 추가/표준화
- [ ] `notification_service.dart` - 주석 추가/표준화
- [ ] `review_service.dart` - 주석 추가/표준화
- [ ] `review_list_service.dart` - 주석 추가/표준화
- [ ] `fcm_endpoint.dart` - 주석 추가

**주석 표준 형식**:
```dart
/// 메서드 설명 (한 줄)
///
/// [session]: 서버 세션
/// [param1]: 파라미터 설명
/// Returns: 반환값 설명
/// Throws: Exception - 예외 조건 (선택적)
Future<ReturnType> myMethod(Session session, Type param1) async {
  // 구현
}
```

**예상 영향**:
- 영향 받는 파일: 모든 Endpoint/Service 파일
- 의존성: Phase 2 완료 권장 (섹션 구분 후 주석 추가가 더 명확)

**검증 방법**:
- [ ] 모든 public 메서드에 `///` 주석 존재
- [ ] 빌드 성공
- [ ] dartdoc 생성 가능 (선택적)

---

### Phase 4: Import 순서 정리 및 코드 정리
**목표**: Import 순서 통일 및 불필요한 코드 정리

**작업 목록**:
- [ ] 모든 파일의 Import 순서 정리
- [ ] 불필요한 주석 제거
- [ ] 코드 스타일 일관성 확인

**Import 순서 규칙**:
```dart
// 1. Dart SDK
import 'dart:async';
import 'dart:convert';

// 2. 외부 패키지
import 'package:http/http.dart' as http;
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_server/serverpod_auth_server.dart';

// 3. 프로젝트 내부 - generated
import 'package:gear_freak_server/src/generated/protocol.dart';

// 4. 프로젝트 내부 - common
import 'package:gear_freak_server/src/common/authenticated_mixin.dart';
import 'package:gear_freak_server/src/common/s3/service/s3_service.dart';

// 5. 프로젝트 내부 - feature (같은 feature 먼저, 다른 feature 나중에)
import '../service/product_service.dart';
import 'package:gear_freak_server/src/feature/user/service/user_service.dart';
```

**예상 영향**:
- 영향 받는 파일: 모든 Dart 파일
- 의존성: Phase 1-3 완료 후 진행

**검증 방법**:
- [ ] `flutter analyze` 통과
- [ ] 빌드 성공
- [ ] 모든 테스트 통과

---

## 4. 파일별 상세 작업 목록

### 4.1 chat_room_service.dart (Phase 1 우선)
```
현재 상태:
- 이모지 로그: 💬, ✅, ❌ 사용
- 섹션 주석: 있음 (// ==================== Private Helper Methods ====================)
- 주석: 양호

작업:
1. [Phase 1] 이모지 로그 → 표준 형식 변경
   - 💬 → [ChatRoomService] methodName - start:
   - ✅ → [ChatRoomService] methodName - success:
   - ❌ → [ChatRoomService] methodName - error:
2. [Phase 2] 섹션 주석 확인 (이미 있음)
3. [Phase 3] 주석 확인 (이미 양호)
```

### 4.2 chat_message_service.dart (Phase 1 우선)
```
현재 상태:
- 이모지 로그: ⚠️, 📱, 🚀 사용 (주로 주석)
- 섹션 주석: 없음
- 주석: 양호

작업:
1. [Phase 1] 이모지 로그 → 표준 형식 변경
   - ⚠️ Presigned URL 생성 실패 → [ChatMessageService] sendMessage - warning:
   - ⚠️ FCM 알림 전송 실패 → [ChatMessageService] sendMessage - warning:
2. [Phase 2] 섹션 주석 추가
3. [Phase 3] 주석 확인 (이미 양호)
```

### 4.3 product_service.dart
```
현재 상태:
- 로그: session.log 사용 (이모지 없음)
- 섹션 주석: 없음
- 주석: 기본 있음

작업:
1. [Phase 1] 로그 형식 표준화 (이모지는 없지만 형식 통일)
2. [Phase 2] 섹션 주석 추가
3. [Phase 3] 주석 상세화 (파라미터/반환값 추가)
```

### 4.4 auth_service.dart
```
현재 상태:
- 로그: 없음
- 섹션 주석: 있음 (// ==================== Public Methods (Endpoint에서 직접 호출) ====================)
- 주석: 양호

작업:
1. [Phase 1] 해당 없음
2. [Phase 2] 섹션 주석 확인 (이미 있음)
3. [Phase 3] 주석 확인 (이미 양호)
```

---

## 5. 리스크 및 대응

### 리스크 1: 로그 형식 변경으로 인한 모니터링 영향
- **확률**: Low
- **영향도**: Low
- **완화 방안**: 로그 검색 패턴 업데이트 문서화

### 리스크 2: 대량 파일 수정으로 인한 머지 충돌
- **확률**: Medium
- **영향도**: Medium
- **완화 방안**: Phase별로 PR 분리, 작은 단위로 커밋

### 리스크 3: 주석 추가로 인한 코드 리뷰 시간 증가
- **확률**: Low
- **영향도**: Low
- **완화 방안**: 표준화된 템플릿 사용으로 일관성 유지

---

## 6. 전체 검증 계획

### 빌드 검증
- [ ] `dart analyze` 통과
- [ ] `dart compile` 성공
- [ ] 서버 시작 정상

### 기능 테스트
- [ ] 인증 API 정상 동작
- [ ] 상품 CRUD 정상 동작
- [ ] 채팅 기능 정상 동작
- [ ] 알림 기능 정상 동작
- [ ] 리뷰 기능 정상 동작

### 로그 검증
- [ ] 서버 로그에 이모지 없음 (주석 제외)
- [ ] 로그 형식이 `[ClassName] methodName - status:` 패턴 준수
- [ ] LogLevel 적절히 사용됨

---

## 7. 예상 작업 시간

| Phase | 예상 작업량 | 파일 수 |
|-------|------------|---------|
| Phase 1: 로그 표준화 | 약 7개 파일 | ~1500줄 수정 |
| Phase 2: 섹션 주석 | 약 15개 파일 | ~100줄 추가 |
| Phase 3: 문서화 주석 | 약 12개 파일 | ~300줄 추가 |
| Phase 4: Import 정리 | 약 20개 파일 | ~100줄 수정 |

---

## 8. 참고 사항

### 유지할 좋은 패턴
- Service 세분화 (ProductService, ProductListService 등) - 변경 없음
- Barrel export 파일 (service.dart, endpoint.dart) - 변경 없음
- Mixin 활용 (AuthenticatedMixin) - 변경 없음
- 기존의 양호한 주석 스타일 - 유지

### 주의할 점
- `developer.log()` 사용처는 Session 외부에서 사용하므로 형식 다름 (변경 필요 없음)
- 주석 내 이모지 (`⭐`)는 유지 가능 (코드 실행에 영향 없음)
- 기존 에러 핸들링 패턴 유지 (catchError, rethrow 등)

### 권장 진행 순서
1. Phase 1 (로그 표준화) - 가장 빠른 개선 효과
2. Phase 2 (섹션 주석) - 코드 구조 파악 용이
3. Phase 3 (문서화 주석) - 가장 노력 많이 필요
4. Phase 4 (Import 정리) - 마무리 단계
