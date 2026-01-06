# 2026-01-06 | Deep Link Routing Issue Fix - Plan

## 목표
Custom Scheme 딥링크(`gearfreak://product/:id`)로 앱 시작 시 발생하는 Page Not Found 에러 해결

## 문제 분석

### 현상
```
[GoRouter] No initial matches: /138
GoException: no routes for location: gearfreak://product/137
```

### 로그 분석
```
[GoRouter] redirecting to RouteMatchList#8902b(uri: /main/home, ...)
flutter: 🔗 딥링크 수신: gearfreak://product/138
flutter: 🔍 Custom Scheme 처리: routePath = /product/138
flutter: 📍 최종 딥링크 경로: /product/138
flutter: 🚀 라우팅 실행: /product/138
[GoRouter] No initial matches: /138  ← 문제 발생!
flutter: 🛡️ AppRouteGuard 실행:
flutter:    - 현재 경로: /138
```

### 근본 원인 분석

1. **GoRouter의 URI 파싱 문제**
   - GoRouter가 앱 시작 시 custom scheme URI를 자동 감지
   - `gearfreak://product/138`를 `/138`로 잘못 파싱
   - Host(`product`)를 경로로 인식하지 못함

2. **타이밍 충돌**
   - GoRouter: 앱 초기화 시점에 URI 자동 감지
   - DeepLinkService: `addPostFrameCallback`에서 초기화
   - GoRouter가 먼저 실행되어 잘못된 경로 사용

3. **중복 처리 이슈**
   - `getInitialLink()`: 초기 딥링크 한 번 반환
   - `uriLinkStream`: 동일 딥링크 다시 수신
   - 동일 딥링크가 두 번 처리됨

## 해결 전략

### 전략 1: AppRouteGuard에서 경로 수정
**장점**:
- 가장 확실한 해결책
- GoRouter의 잘못된 파싱을 Guard 레벨에서 차단
- 다른 딥링크 패턴에도 확장 가능

**구현 방법**:
```dart
// AppRouteGuard.guard()에서
if (RegExp(r'^/\d+$').hasMatch(currentPath)) {
  // Pending deep link 사용 또는 /product/:id로 추론
}
```

### 전략 2: 중복 처리 방지
**장점**:
- 메모리 효율적
- 불필요한 라우팅 시도 방지

**구현 방법**:
```dart
// DeepLinkService
Uri? _initialLinkUri; // 초기 딥링크 저장

_appLinks.uriLinkStream.listen((uri) {
  if (_initialLinkUri != null && uri == _initialLinkUri) {
    return; // 중복 무시
  }
});
```

### 전략 3: PendingDeepLinkService 활용
**장점**:
- 기존 시스템 활용
- 인증 플로우와 통합

**구현 방법**:
- Guard에서 Pending link 우선 확인
- 없으면 경로 추론

## 구현 계획

### Phase 1: AppRouteGuard 수정 ✓
1. 잘못된 경로 패턴 감지 (`/\d+$`)
2. PendingDeepLinkService에서 올바른 경로 확인
3. 없으면 `/product/:id` 형식으로 추론하여 리디렉션

**파일**: `lib/core/route/app_route_guard.dart`

**수정 위치**: `guard()` 메서드 시작 부분

### Phase 2: DeepLinkService 중복 처리 방지 ✓
1. 초기 딥링크 URI 저장 (`_initialLinkUri`)
2. `uriLinkStream`에서 중복 체크
3. 중복이면 무시하고 return

**파일**: `lib/shared/service/deep_link_service.dart`

**수정 위치**:
- `_initialLinkUri` 필드 추가
- `_handleInitialLink()` 메서드
- `_startListening()` 메서드

### Phase 3: 테스트 시나리오
1. ✓ 앱 종료 상태에서 딥링크로 시작
2. ✓ 앱 실행 중 딥링크 수신
3. ✓ 로그인 전/후 딥링크 동작
4. ⚠ 중복 딥링크 수신 (확인 필요)

## 예상 결과

### Before
```
사용자: 딥링크 클릭 (gearfreak://product/138)
↓
GoRouter: /138로 파싱 ❌
↓
Page Not Found
```

### After
```
사용자: 딥링크 클릭 (gearfreak://product/138)
↓
GoRouter: /138로 파싱 ❌
↓
AppRouteGuard: /138 감지 → /product/138로 수정 ✓
↓
정상 라우팅
```

## 고려사항

### 1. 다른 딥링크 패턴
현재는 `/product/:id` 패턴만 처리
향후 확장 가능성:
- `/chat/:id?sellerId=X&chatRoomId=Y`
- `/product/:id/review/write?revieweeId=X`
- `/profile/user/:userId`

**해결책**:
- 현재는 숫자만 있는 경로(`/\d+$`)를 product로 추론
- 추가 패턴 필요 시 Guard 로직 확장

### 2. Universal Links (HTTPS)
Custom scheme(`gearfreak://`) 대신 HTTPS scheme 사용 시:
- GoRouter가 올바르게 파싱할 가능성 높음
- 현재 수정사항도 영향 없음 (패턴 매칭 실패하므로)

### 3. 성능 영향
- 정규식 체크: 매우 가벼움 (`O(1)`)
- Pending link 체크: 싱글톤 접근 (`O(1)`)
- 전체적으로 무시할 수 있는 수준

## 대안 검토

### 대안 1: GoRouter initialLocation 수정
**방법**: GoRouter 생성 시 custom scheme 처리
**문제**: GoRouter가 자동으로 URI를 감지하는 것을 막을 수 없음
**결론**: ❌ 불가능

### 대안 2: app_links 대신 uni_links 사용
**방법**: 다른 딥링크 패키지 사용
**문제**: app_links가 공식 권장 패키지
**결론**: ❌ 비권장

### 대안 3: Firebase Dynamic Links
**방법**: Custom scheme 대신 Firebase 서비스 사용
**문제**: 외부 서비스 의존성, 비용
**결론**: △ 향후 고려

### 대안 4: Guard에서 수정 (선택)
**방법**: AppRouteGuard에서 잘못된 경로 감지 및 수정
**장점**: 간단하고 효과적
**결론**: ✅ 채택

## 위험 요소

### 1. 다른 경로와 충돌 가능성
- `/138` 같은 경로가 정상적인 라우트일 가능성?
- **평가**: 현재 라우트 구조상 없음 (모든 경로가 `/feature/...` 형식)

### 2. Pending link가 없는 경우
- 추론 로직이 잘못될 가능성
- **해결**: `/product/:id`로 추론 (가장 일반적인 딥링크)

### 3. 정규식 패턴 변경 필요
- 향후 다른 딥링크 패턴 추가 시
- **해결**: 패턴 매칭 로직 확장 가능하게 설계

## 검증 계획

### 단위 테스트
- [ ] 정규식 패턴 테스트 (`/\d+$`)
- [ ] Pending link 우선순위 테스트
- [ ] 경로 추론 테스트

### 통합 테스트
- [x] 앱 종료 → 딥링크 시작
- [x] 앱 실행 중 → 딥링크 수신
- [ ] 로그인 전 → 딥링크 → 로그인 → 리디렉션
- [ ] 중복 딥링크 수신

### 수동 테스트
- [x] iOS 시뮬레이터
- [ ] Android 에뮬레이터
- [ ] 실제 디바이스

## 타임라인
- ✅ 문제 분석: 30분
- ✅ 해결 방법 설계: 20분
- ✅ 구현 (Phase 1): 15분
- ✅ 구현 (Phase 2): 15분
- ⏳ 테스트: 20분
- ⏳ 문서화: 20분

**예상 총 소요 시간**: 약 2시간

## 결론
AppRouteGuard에서 잘못된 경로를 감지하고 수정하는 방식이 가장 효과적이고 안전한 해결책.
중복 처리 방지를 추가하여 안정성을 더욱 향상시킬 수 있음.
