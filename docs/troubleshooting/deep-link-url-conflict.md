# 트러블 슈팅

## 딥링크 URL Scheme 충돌 해결

---

### 🚨 문제 배경

카카오톡 공유 기능 구현 중 딥링크 동작에 대한 문제가 발생했습니다.

카카오톡으로 상품 링크(`gearfreak://product/138`)를 공유한 후 클릭하면 **앱은 열리지만 "Page Not Found" 에러**가 발생했습니다.

특히 앱이 완전히 종료된 상태(Cold Start)에서 딥링크를 클릭할 때만 문제가 발생해서 원인 파악이 어려웠습니다.

---

### ⭐ 해결 방법

로그를 찍어보니 **GoRouter가 수신한 경로**와 **DeepLinkService가 파싱한 경로**가 달랐습니다.

```
[GoRouter] No initial matches: /138        ← GoRouter: /138
[DeepLinkService] 파싱 결과: /product/138  ← DeepLinkService: /product/138
```

GoRouter가 Custom Scheme URI를 자동으로 감지하지만, `gearfreak://product/138`에서 **host(`product`)를 path의 일부로 인식하지 못하고** `/138`만 추출하는 것이 원인이었습니다.

추가로 **카카오 OAuth 딥링크**(`kakao{APP_KEY}://oauth`)가 DeepLinkService에 먼저 잡혀서 카카오 SDK가 처리하지 못하는 문제도 발견했습니다.

---

### 🔄 이전 코드와 비교

#### 문제 1: GoRouter의 Custom Scheme 파싱 오류

GoRouter가 `gearfreak://product/138`을 `/138`로 잘못 파싱하는 문제를 **AppRouteGuard에서 방어적으로 처리**했습니다.

**Before (문제 상황)**
```dart
// app_route_guard.dart
String? guard(BuildContext context, GoRouterState state) {
  final currentPath = state.uri.path;

  // GoRouter가 /138로 잘못 파싱해서 넘어옴
  // → 매칭되는 라우트 없음 → Page Not Found

  return null;
}
```

**After (해결)**
```dart
// app_route_guard.dart
String? guard(BuildContext context, GoRouterState state) {
  final currentPath = state.uri.path;

  // ✅ GoRouter가 custom scheme을 잘못 파싱한 경우 감지
  // 예: gearfreak://product/138 → /138로 파싱된 경우
  if (RegExp(r'^/\d+(\?.*)?$').hasMatch(currentPath)) {
    // DeepLinkService가 저장해둔 올바른 경로 확인
    final pendingLink = PendingDeepLinkService.instance.pendingDeepLink;

    if (pendingLink != null) {
      debugPrint('🔧 잘못된 경로 감지: $currentPath → 수정: $pendingLink');
      PendingDeepLinkService.instance.consumePendingDeepLink();
      return pendingLink;  // /product/138로 리디렉션
    } else {
      // Pending link 없으면 /product/:id로 추론
      final productId = currentPath.split('?').first.substring(1);
      return '/product/$productId';
    }
  }

  return null;
}
```

---

#### 문제 2: 카카오 OAuth 딥링크 충돌

카카오 로그인 후 콜백 딥링크가 DeepLinkService에 먼저 잡혀서 **카카오 SDK가 처리하지 못하는 문제**를 해결했습니다.

**Before (문제 상황)**
```dart
// deep_link_service.dart
String? _parseDeepLinkUrl(String url) {
  final uri = Uri.parse(url);

  // ❌ 카카오 OAuth 딥링크도 처리하려고 시도
  // kakao{APP_KEY}://oauth → 처리 실패 → 로그인 실패

  if (uri.scheme == 'gearfreak') {
    return uri.path;
  }
  return null;
}
```

**After (해결)**
```dart
// deep_link_service.dart
String? _parseDeepLinkUrl(String url) {
  final uri = Uri.parse(url);

  // ✅ 카카오 OAuth 딥링크는 카카오 SDK가 처리하도록 무시
  if (uri.scheme.startsWith('kakao') && uri.host == 'oauth') {
    debugPrint('✅ Kakao OAuth 딥링크 → 카카오 SDK가 처리');
    return null;
  }

  // ✅ 구글 OAuth 딥링크도 무시
  if (uri.scheme.startsWith('com.googleusercontent.apps')) {
    debugPrint('✅ Google OAuth 딥링크 → Google SDK가 처리');
    return null;
  }

  if (uri.scheme == 'gearfreak') {
    return uri.path;
  }
  return null;
}
```

---

#### 문제 3: 동일 딥링크 중복 수신

앱 시작 시 `getInitialLink()`와 `uriLinkStream`에서 **같은 딥링크가 2번 수신**되는 문제를 해결했습니다.

**Before (문제 상황)**
```dart
// deep_link_service.dart
Future<void> initialize(GoRouter router) async {
  _router = router;

  // 1. 앱 시작 시 초기 딥링크 처리
  await _handleInitialLink();

  // 2. 실시간 딥링크 스트림 구독
  _subscription = _appLinks.uriLinkStream.listen((uri) {
    // ❌ 초기 딥링크가 여기서도 또 수신됨
    _handleDeepLink(uri.toString());
  });
}
```

**After (해결)**
```dart
// deep_link_service.dart
Uri? _initialLinkUri;  // ✅ 초기 딥링크 저장 (중복 방지용)

Future<void> initialize(GoRouter router) async {
  _router = router;

  await _handleInitialLink();
  _startListening();
}

Future<void> _handleInitialLink() async {
  final uri = await _appLinks.getInitialLink();
  if (uri != null) {
    _initialLinkUri = uri;  // ✅ 저장
    _handleDeepLink(uri.toString());
  }
}

void _startListening() {
  _subscription = _appLinks.uriLinkStream.listen((uri) {
    // ✅ 초기 딥링크와 동일하면 무시
    if (_initialLinkUri != null && uri == _initialLinkUri) {
      debugPrint('⏭️ 초기 딥링크 중복 수신 무시: $uri');
      _initialLinkUri = null;
      return;
    }

    _handleDeepLink(uri.toString());
  });
}
```

---

### 📊 URL Scheme 충돌 구조

```
앱에 등록된 URL Schemes:
┌─────────────────────────────────────────────────────────────┐
│  gearfreak://                    → DeepLinkService 처리     │
│  https://gear-freaks.com         → DeepLinkService 처리     │
│  kakao{APP_KEY}://oauth          → 카카오 SDK 처리 (무시)   │
│  com.googleusercontent.apps://   → Google SDK 처리 (무시)   │
└─────────────────────────────────────────────────────────────┘

문제 상황:
┌─────────────────────────────────────────────────────────────┐
│  1. 카카오톡에서 gearfreak://product/138 클릭               │
│                        ↓                                    │
│  2. GoRouter 자동 감지 → /138로 잘못 파싱 ❌                │
│     DeepLinkService   → /product/138로 정상 파싱 ✅         │
│                        ↓                                    │
│  3. GoRouter가 /138 라우트 찾음 → 없음 → Page Not Found     │
└─────────────────────────────────────────────────────────────┘

해결 후:
┌─────────────────────────────────────────────────────────────┐
│  1. 카카오톡에서 gearfreak://product/138 클릭               │
│                        ↓                                    │
│  2. DeepLinkService가 /product/138 파싱 후 Pending 저장     │
│                        ↓                                    │
│  3. GoRouter가 /138로 잘못 파싱                             │
│                        ↓                                    │
│  4. AppRouteGuard에서 /138 감지 → Pending에서 조회          │
│                        ↓                                    │
│  5. /product/138로 리디렉션 ✅                              │
└─────────────────────────────────────────────────────────────┘
```

---

### 🔍 디버깅 과정

1. **증상 확인**: 카카오톡 공유 링크 클릭 시 Page Not Found
2. **재현 조건 파악**: 앱 완전 종료 상태(Cold Start)에서만 발생
3. **로그 추가**: GoRouter와 DeepLinkService 양쪽에 로그 추가
4. **원인 발견**: GoRouter가 `/138`, DeepLinkService가 `/product/138`로 서로 다르게 파싱
5. **GoRouter 소스 분석**: Custom Scheme URI 파싱 로직 확인
6. **해결책 설계**: AppRouteGuard에서 방어적 처리 + PendingDeepLinkService 도입

---

### 😊 해당 경험을 통해 알게된 점

**GoRouter의 Custom Scheme 처리 방식**에 대해 알게되었습니다. GoRouter가 앱 시작 시 URI를 자동으로 감지하지만, Custom Scheme의 host를 path로 인식하지 못하는 제한이 있다는 것을 배웠습니다.

**여러 SDK가 같은 딥링크 핸들러를 공유할 때의 충돌 문제**를 경험했습니다. 카카오, 네이버, 구글 OAuth가 각자의 URL Scheme을 사용하는데, 앱의 딥링크 서비스가 이를 가로채면 안 된다는 것을 알게 되었습니다.

**Cold Start vs Warm Start**에서 동작이 다를 수 있다는 것을 배웠습니다. 앱이 이미 실행 중일 때는 정상 동작하지만, 완전 종료 상태에서 딥링크로 시작할 때만 문제가 발생하는 케이스가 있어서 테스트 시 주의가 필요합니다.

---

### 🛠️ 관련 기술

- **Flutter**: GoRouter, app_links 패키지
- **딥링크**: Custom URL Scheme, Universal Links (HTTPS)
- **소셜 로그인**: Kakao SDK, Google Sign-In, Naver Login
- **디버깅**: Cold Start / Warm Start 시나리오 분석

---

### 📁 관련 파일

- `lib/shared/service/deep_link_service.dart` - 딥링크 처리 서비스
- `lib/shared/service/pending_deep_link_service.dart` - 대기 딥링크 저장
- `lib/core/route/app_route_guard.dart` - 라우팅 가드 및 경로 수정
- `ios/Runner/Info.plist` - iOS URL Scheme 설정
- `android/app/src/main/AndroidManifest.xml` - Android intent-filter 설정
