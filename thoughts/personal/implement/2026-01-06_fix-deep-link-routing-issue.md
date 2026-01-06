# 2026-01-06 | Deep Link Routing Issue Fix

## 작업 내용
Custom Scheme 딥링크(`gearfreak://product/:id`)로 앱 시작 시 발생하는 라우팅 실패 문제 해결

## 파일
- `lib/core/route/app_route_guard.dart`
- `lib/shared/service/deep_link_service.dart`

## 문제

### 증상
```
[GoRouter] No initial matches: /138
flutter: 🛡️ AppRouteGuard 실행:
flutter:    - 현재 경로: /138
```

앱이 `gearfreak://product/138` 딥링크로 시작될 때:
1. GoRouter가 custom scheme을 잘못 파싱하여 `/138`만 추출
2. DeepLinkService는 `/product/138`로 정상 파싱
3. 타이밍 충돌로 인한 라우팅 실패

### 근본 원인
1. **GoRouter의 잘못된 URI 파싱**
   - Custom scheme URI를 자동으로 감지하지만 제대로 파싱하지 못함
   - `gearfreak://product/138` → `/138`로 잘못 추출

2. **딥링크 중복 처리**
   - `getInitialLink()`와 `uriLinkStream`에서 동일 딥링크 두 번 수신
   - 타이밍 충돌로 인한 라우팅 실패

## 해결 방법

### 1. AppRouteGuard에서 잘못된 경로 감지 및 수정

**파일**: `lib/core/route/app_route_guard.dart`

```dart
// ==================== 딥링크 경로 수정 ====================
// GoRouter가 custom scheme 딥링크를 잘못 파싱한 경우 수정
// 예: gearfreak://product/138 → /138로 파싱된 경우
if (RegExp(r'^/\d+$').hasMatch(currentPath)) {
  // Pending deep link 확인
  final pendingLink = PendingDeepLinkService.instance.pendingDeepLink;

  if (pendingLink != null) {
    debugPrint(
      '🔧 잘못된 경로 감지: $currentPath → Pending link 사용: $pendingLink',
    );
    // Pending link 소비하고 해당 경로로 리디렉션
    PendingDeepLinkService.instance.consumePendingDeepLink();
    return pendingLink;
  } else {
    // Pending link가 없으면 /product/:id로 추론
    final productId = currentPath.substring(1); // '/' 제거
    final correctedPath = '/product/$productId';
    debugPrint('🔧 잘못된 경로 감지: $currentPath → 수정: $correctedPath');
    return correctedPath;
  }
}
// ==================== End ====================
```

**핵심 로직**:
- 정규식으로 `/138` 패턴 감지 (`/\d+$`)
- Pending deep link가 있으면 우선 사용
- 없으면 `/product/:id` 형식으로 추론

### 2. DeepLinkService에서 중복 처리 방지

**파일**: `lib/shared/service/deep_link_service.dart`

#### 2.1 초기 딥링크 URI 저장
```dart
Uri? _initialLinkUri; // 초기 딥링크 URI (중복 처리 방지용)

Future<void> _handleInitialLink() async {
  final uri = await _appLinks.getInitialLink();
  if (uri != null) {
    // 초기 딥링크 URI 저장 (중복 처리 방지용)
    _initialLinkUri = uri;

    // ... 기존 로직
  }
}
```

#### 2.2 uriLinkStream에서 중복 체크
```dart
void _startListening() {
  _subscription = _appLinks.uriLinkStream.listen(
    (uri) {
      // 초기 딥링크와 동일한 URI는 무시 (중복 처리 방지)
      if (_initialLinkUri != null && uri == _initialLinkUri) {
        debugPrint('⏭️ 초기 딥링크 중복 수신 무시: $uri');
        _initialLinkUri = null; // 한 번만 체크하고 초기화
        return;
      }

      debugPrint('🔗 딥링크 수신: $uri');
      _handleDeepLink(uri.toString());
    },
  );
}
```

**핵심 로직**:
- 초기 딥링크 URI를 저장
- 스트림에서 동일 URI 수신 시 무시
- 한 번만 체크하고 초기화하여 메모리 효율성 확보

## 작동 흐름

### Before (문제 발생)
```
1. 앱 시작: gearfreak://product/138
2. GoRouter: /138로 파싱 ❌
3. DeepLinkService: /product/138로 파싱 ✅
4. 충돌 → Page Not Found
```

### After (해결)
```
1. 앱 시작: gearfreak://product/138
2. GoRouter: /138로 파싱 ❌
3. AppRouteGuard: /138 감지 → /product/138로 리디렉션 ✅
4. 또는 Pending deep link 사용 ✅
5. 정상 라우팅 완료
```

## 테스트 시나리오

### 1. 앱 종료 상태에서 딥링크로 시작
```bash
# 시뮬레이터/디바이스에서
xcrun simctl openurl booted "gearfreak://product/138"
adb shell am start -W -a android.intent.action.VIEW -d "gearfreak://product/138"
```

**예상 로그**:
```
🔗 초기 딥링크 수신: gearfreak://product/138
📌 인증 대기를 위해 딥링크를 보류합니다
🔧 잘못된 경로 감지: /138 → Pending link 사용: /product/138
✅ 보류된 딥링크로 이동: /product/138
```

### 2. 앱 실행 중 딥링크 수신
- 문자나 이메일에서 딥링크 클릭
- 정상적으로 해당 화면으로 이동

**예상 로그**:
```
🔗 딥링크 수신: gearfreak://product/138
🔍 Custom Scheme 처리: routePath = /product/138
🚀 라우팅 실행: /product/138
```

### 3. 중복 딥링크 수신
- 초기 딥링크가 두 번 수신되는 경우

**예상 로그**:
```
🔗 초기 딥링크 수신: gearfreak://product/138
⏭️ 초기 딥링크 중복 수신 무시: gearfreak://product/138
```

## 핵심 포인트

1. **Guard에서 방어적 처리**
   - GoRouter가 잘못 파싱한 경로를 감지하고 수정
   - Pending deep link 우선 사용으로 타이밍 이슈 해결

2. **중복 처리 방지**
   - 초기 딥링크 URI를 저장하여 스트림 중복 수신 방지
   - 메모리 효율성을 위한 일회성 체크 후 초기화

3. **Fallback 로직**
   - Pending link 없을 때 `/product/:id` 형식으로 추론
   - 최대한 사용자 의도대로 라우팅

## 수정된 위치

### app_route_guard.dart
- Line 57-79: 딥링크 경로 수정 로직 추가
- Line 60: 정규식으로 `/\d+$` 패턴 감지
- Line 64-70: Pending deep link 사용
- Line 72-76: `/product/:id`로 추론

### deep_link_service.dart
- Line 21: `_initialLinkUri` 필드 추가
- Line 66: 초기 딥링크 URI 저장
- Line 98-102: 중복 수신 무시 로직

## 결과
✅ Custom scheme 딥링크 정상 작동
✅ Page Not Found 에러 해결
✅ 중복 처리 방지로 안정성 향상
✅ 타이밍 이슈 해결

## 관련 이슈
- GoRouter의 custom scheme URI 파싱 제한
- app_links 패키지의 중복 이벤트 발생
- Firebase Dynamic Links 대신 custom scheme 사용 시 주의사항

## 향후 개선 사항
- 다른 딥링크 패턴 (채팅, 리뷰 등)도 동일한 이슈 발생 가능성 확인
- Universal Links (HTTPS scheme) 사용 시 문제 발생 여부 확인
- 테스트 자동화 고려
