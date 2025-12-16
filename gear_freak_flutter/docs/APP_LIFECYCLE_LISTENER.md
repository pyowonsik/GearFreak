# AppLifecycleListener 가이드

## 개요

`AppLifecycleListener`는 Flutter 3.13+에서 도입된 새로운 API로, 앱의 생명주기 상태 변화를 감지하고 처리하는 데 사용됩니다. 기존의 `WidgetsBindingObserver`보다 더 간결하고 사용하기 쉬운 인터페이스를 제공합니다.

## 버전 요구사항

- **Flutter 3.13.0 이상** 필요
- 현재 프로젝트: Flutter `>=3.24.0` ✅

## AppLifecycleState 전체 상태

`AppLifecycleListener`는 다음 모든 생명주기 상태 변화를 감지합니다:

### 1. `resumed`
- **의미**: 앱이 포그라운드에 있고 활성 상태
- **발생 시점**: 
  - 앱이 백그라운드에서 포그라운드로 복귀
  - 앱이 처음 시작될 때
- **특징**: 사용자 입력을 받을 수 있는 상태

### 2. `inactive`
- **의미**: 앱이 비활성 상태
- **발생 시점**:
  - 전화가 올 때
  - 알림이 표시될 때
  - 멀티태스킹 화면으로 전환할 때
- **특징**: 앱은 여전히 포그라운드에 있지만 사용자 입력을 받지 않음

### 3. `paused`
- **의미**: 앱이 백그라운드에 있음
- **발생 시점**:
  - 홈 버튼을 눌러 앱을 백그라운드로 보낼 때
  - 다른 앱으로 전환할 때
- **특징**: 앱이 사용자에게 보이지 않지만 메모리에 유지됨

### 4. `detached`
- **의미**: 앱이 호스트 뷰에서 분리된 상태
- **발생 시점**:
  - 앱이 종료되기 직전
  - iOS에서 앱이 종료될 때
- **특징**: 앱이 곧 종료될 예정

### 5. `hidden` (Flutter 3.13+)
- **의미**: 앱의 모든 뷰가 숨겨진 상태
- **발생 시점**:
  - macOS에서 앱이 숨겨질 때
  - 일부 플랫폼에서 특정 상황
- **특징**: 앱은 실행 중이지만 UI가 보이지 않음

## 생명주기 상태 전환 흐름

```
앱 시작
  ↓
resumed (포그라운드, 활성)
  ↓
inactive (비활성) ← 전화/알림 등
  ↓
paused (백그라운드)
  ↓
resumed (포그라운드로 복귀)
  ↓
detached (종료)
```

## 사용 방법

### 기본 사용법

```dart
class _MyWidgetState extends State<MyWidget> {
  AppLifecycleListener? _lifecycleListener;

  @override
  void initState() {
    super.initState();
    _lifecycleListener = AppLifecycleListener(
      onStateChange: (AppLifecycleState state) {
        switch (state) {
          case AppLifecycleState.resumed:
            // 포그라운드로 복귀
            print('앱이 포그라운드로 복귀했습니다');
            break;
          case AppLifecycleState.inactive:
            // 비활성 상태
            print('앱이 비활성 상태입니다');
            break;
          case AppLifecycleState.paused:
            // 백그라운드로 전환
            print('앱이 백그라운드로 전환되었습니다');
            break;
          case AppLifecycleState.detached:
            // 앱이 분리됨
            print('앱이 분리되었습니다');
            break;
          case AppLifecycleState.hidden:
            // 앱이 숨겨짐
            print('앱이 숨겨졌습니다');
            break;
        }
      },
    );
  }

  @override
  void dispose() {
    _lifecycleListener?.dispose();
    super.dispose();
  }
}
```

### 실제 사용 예시 (채팅방 리스트)

```dart
class _ChatRoomListScreenState extends ConsumerState<ChatRoomListScreen>
    with PaginationScrollMixin {
  AppLifecycleListener? _lifecycleListener;

  @override
  void initState() {
    super.initState();
    
    // 앱 생명주기 감지
    _lifecycleListener = AppLifecycleListener(
      onStateChange: (AppLifecycleState state) {
        // 백그라운드에서 포그라운드로 돌아올 때 채팅방 리스트 새로고침
        if (state == AppLifecycleState.resumed) {
          ref.read(chatRoomListNotifierProvider.notifier).loadChatRooms();
        }
      },
    );
  }

  @override
  void dispose() {
    _lifecycleListener?.dispose();
    super.dispose();
  }
}
```

## WidgetsBindingObserver vs AppLifecycleListener

### WidgetsBindingObserver (구 방식)

```dart
class _MyWidgetState extends State<MyWidget> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // 처리
  }
}
```

**단점:**
- Mixin 사용 필요
- `addObserver`/`removeObserver` 수동 관리
- 더 많은 보일러플레이트 코드

### AppLifecycleListener (신 방식)

```dart
class _MyWidgetState extends State<MyWidget> {
  AppLifecycleListener? _lifecycleListener;

  @override
  void initState() {
    super.initState();
    _lifecycleListener = AppLifecycleListener(
      onStateChange: (state) {
        // 처리
      },
    );
  }

  @override
  void dispose() {
    _lifecycleListener?.dispose();
    super.dispose();
  }
}
```

**장점:**
- 더 간결한 코드
- 선언적 접근 방식
- 자동 리소스 관리
- Flutter 공식 권장 (3.13+)

## 일반적인 사용 사례

### 1. 백그라운드에서 포그라운드로 복귀 시 데이터 새로고침

```dart
_lifecycleListener = AppLifecycleListener(
  onStateChange: (state) {
    if (state == AppLifecycleState.resumed) {
      // 데이터 새로고침
      ref.read(dataNotifierProvider.notifier).refresh();
    }
  },
);
```

### 2. 백그라운드로 전환 시 작업 일시 중지

```dart
_lifecycleListener = AppLifecycleListener(
  onStateChange: (state) {
    if (state == AppLifecycleState.paused) {
      // 타이머 일시 중지, 네트워크 요청 취소 등
      timer?.cancel();
    } else if (state == AppLifecycleState.resumed) {
      // 타이머 재개
      timer?.start();
    }
  },
);
```

### 3. 앱 종료 시 데이터 저장

```dart
_lifecycleListener = AppLifecycleListener(
  onStateChange: (state) {
    if (state == AppLifecycleState.detached) {
      // 데이터 저장
      saveData();
    }
  },
);
```

### 4. 모든 상태 변화 로깅

```dart
_lifecycleListener = AppLifecycleListener(
  onStateChange: (state) {
    debugPrint('앱 생명주기 상태 변경: $state');
    // Analytics 이벤트 전송 등
    analytics.logEvent('app_lifecycle_change', {'state': state.name});
  },
);
```

## 주의사항

1. **반드시 dispose 호출**: `_lifecycleListener?.dispose()`를 `dispose()` 메서드에서 호출해야 메모리 누수를 방지할 수 있습니다.

2. **상태 전환 순서**: 상태 전환이 항상 예상한 순서대로 발생하지 않을 수 있습니다. 예를 들어, `inactive` 상태를 건너뛰고 바로 `paused`로 전환될 수 있습니다.

3. **플랫폼 차이**: 일부 상태는 플랫폼에 따라 다르게 동작할 수 있습니다. 예를 들어, `hidden` 상태는 주로 macOS에서 발생합니다.

4. **빠른 전환**: 사용자가 빠르게 앱을 전환하면 상태 변화가 매우 빠르게 발생할 수 있습니다. 이에 대비한 처리가 필요합니다.

## 참고 자료

- [Flutter 공식 문서 - AppLifecycleListener](https://api.flutter.dev/flutter/widgets/AppLifecycleListener-class.html)
- [Flutter 공식 문서 - AppLifecycleState](https://api.flutter.dev/flutter/dart-ui/AppLifecycleState.html)
- [Flutter 공식 문서 - WidgetsBindingObserver](https://api.flutter.dev/flutter/widgets/WidgetsBindingObserver-class.html)

## 마이그레이션 가이드

기존 `WidgetsBindingObserver`를 사용하는 코드를 `AppLifecycleListener`로 마이그레이션하는 방법:

### Before (WidgetsBindingObserver)

```dart
class _MyWidgetState extends State<MyWidget> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // 처리
    }
  }
}
```

### After (AppLifecycleListener)

```dart
class _MyWidgetState extends State<MyWidget> {
  AppLifecycleListener? _lifecycleListener;

  @override
  void initState() {
    super.initState();
    _lifecycleListener = AppLifecycleListener(
      onStateChange: (state) {
        if (state == AppLifecycleState.resumed) {
          // 처리
        }
      },
    );
  }

  @override
  void dispose() {
    _lifecycleListener?.dispose();
    super.dispose();
  }
}
```

## 요약

- ✅ **Flutter 3.13+ 권장 방법**
- ✅ **더 간결하고 선언적인 API**
- ✅ **모든 생명주기 상태 감지 가능**
- ✅ **자동 리소스 관리**
- ✅ **현재 프로젝트에 적용 완료** (chat_room_list_screen.dart)

