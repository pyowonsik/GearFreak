# 트러블슈팅

## Flutter 메모리 관리의 중요성

---

### 🚨 문제 배경

Flutter 앱 개발 중 다음과 같은 메모리 관련 문제들이 발생할 수 있습니다:

- **메모리 누수 (Memory Leak)**: 더 이상 필요하지 않은 객체가 해제되지 않아 메모리 사용량이 지속적으로 증가
- **앱 크래시**: 과도한 메모리 사용으로 인한 OOM(Out of Memory) 크래시
- **성능 저하**: GC(Garbage Collection) 빈번 발생으로 인한 프레임 드롭
- **배터리 소모**: 불필요한 백그라운드 작업으로 인한 리소스 낭비

특히 다음 상황에서 메모리 누수가 자주 발생합니다:
1. Stream 구독 해제 누락
2. Timer 취소 누락
3. AnimationController dispose 누락
4. ScrollController dispose 누락
5. 비동기 작업 중 위젯 dispose 후 setState 호출

---

### ⭐ 핵심 원칙

**"생성한 것은 반드시 해제한다"**

Flutter에서 메모리 관리의 핵심은 `dispose()` 메서드에서 모든 리소스를 정리하는 것입니다.

```dart
class _MyPageState extends State<MyPage> {
  late final StreamSubscription _subscription;
  late final Timer _timer;
  late final AnimationController _animationController;
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    // 리소스 초기화
  }

  @override
  void dispose() {
    // ✅ 반드시 역순으로 해제
    _subscription.cancel();
    _timer.cancel();
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
```

---

### 🔄 주요 메모리 누수 패턴과 해결책

---

#### 패턴 1: Stream 구독 해제 누락

실시간 채팅, 알림 등에서 Stream을 사용할 때 가장 흔히 발생하는 메모리 누수입니다.

**Before (문제 상황)**
```dart
class _ChatPageState extends State<ChatPage> {
  @override
  void initState() {
    super.initState();

    // ❌ 구독만 하고 해제하지 않음
    chatStream.listen((message) {
      setState(() {
        messages.add(message);
      });
    });
  }

  @override
  void dispose() {
    // Stream 구독이 계속 살아있어 메모리 누수 발생
    super.dispose();
  }
}
```

**After (해결)**
```dart
class _ChatPageState extends State<ChatPage> {
  StreamSubscription<Message>? _subscription;

  @override
  void initState() {
    super.initState();

    // ✅ 구독 참조 저장
    _subscription = chatStream.listen((message) {
      if (!mounted) return;  // dispose 후 setState 방지
      setState(() {
        messages.add(message);
      });
    });
  }

  @override
  void dispose() {
    // ✅ 반드시 구독 취소
    _subscription?.cancel();
    super.dispose();
  }
}
```

---

#### 패턴 2: Timer 취소 누락

주기적 작업, 딜레이 작업에서 Timer를 사용할 때 발생합니다.

**Before (문제 상황)**
```dart
class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();

    // ❌ Timer 참조를 저장하지 않음
    Timer(const Duration(seconds: 2), () {
      context.go('/home');  // dispose 후에도 실행될 수 있음
    });

    // ❌ Periodic timer도 마찬가지
    Timer.periodic(const Duration(seconds: 5), (timer) {
      _refreshData();
    });
  }
}
```

**After (해결)**
```dart
class _SplashPageState extends State<SplashPage> {
  Timer? _splashTimer;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();

    // ✅ Timer 참조 저장
    _splashTimer = Timer(const Duration(seconds: 2), () {
      if (!mounted) return;  // mounted 체크
      context.go('/home');
    });

    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!mounted) {
        timer.cancel();  // 위젯 dispose 시 타이머도 취소
        return;
      }
      _refreshData();
    });
  }

  @override
  void dispose() {
    // ✅ 모든 Timer 취소
    _splashTimer?.cancel();
    _refreshTimer?.cancel();
    super.dispose();
  }
}
```

---

#### 패턴 3: AnimationController dispose 누락

애니메이션을 사용하는 위젯에서 자주 발생합니다.

**Before (문제 상황)**
```dart
class _AnimatedButtonState extends State<AnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    // ❌ AnimationController dispose 누락
    // Ticker가 계속 동작하며 메모리 누수 + 에러 발생
    super.dispose();
  }
}
```

**After (해결)**
```dart
class _AnimatedButtonState extends State<AnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    // ✅ 반드시 dispose
    _controller.dispose();
    super.dispose();
  }
}
```

---

#### 패턴 4: 비동기 작업 후 mounted 체크 누락

API 호출, 파일 I/O 등 비동기 작업에서 자주 발생합니다.

**Before (문제 상황)**
```dart
class _ProductDetailPageState extends State<ProductDetailPage> {
  Future<void> _loadProduct() async {
    final product = await productRepository.getProduct(widget.id);

    // ❌ 위젯이 dispose된 후에도 setState 시도
    // "setState() called after dispose()" 에러 발생
    setState(() {
      _product = product;
    });
  }

  Future<void> _handlePurchase() async {
    await purchaseService.purchase(widget.id);

    // ❌ context 사용 시에도 마찬가지
    context.push('/success');
  }
}
```

**After (해결)**
```dart
class _ProductDetailPageState extends State<ProductDetailPage> {
  Future<void> _loadProduct() async {
    final product = await productRepository.getProduct(widget.id);

    // ✅ mounted 체크 후 setState
    if (!mounted) return;

    setState(() {
      _product = product;
    });
  }

  Future<void> _handlePurchase() async {
    await purchaseService.purchase(widget.id);

    // ✅ context.mounted 체크 (Flutter 3.7+)
    if (!context.mounted) return;

    context.push('/success');
  }
}
```

---

#### 패턴 5: TextEditingController dispose 누락

폼 입력 필드에서 자주 발생합니다.

**Before (문제 상황)**
```dart
class _LoginPageState extends State<LoginPage> {
  // ❌ Controller가 dispose되지 않음
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
  }
}
```

**After (해결)**
```dart
class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    // ✅ 모든 Controller dispose
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
```

---

#### 패턴 6: GlobalKey 과다 사용

GlobalKey는 전역 상태를 유지하므로 메모리에 계속 남아있습니다.

**Before (문제 상황)**
```dart
class _MyPageState extends State<MyPage> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: (context, index) {
        // ❌ 매번 새로운 GlobalKey 생성 → 메모리 누수
        return ProductCard(key: GlobalKey());
      },
    );
  }
}
```

**After (해결)**
```dart
class _MyPageState extends State<MyPage> {
  // ✅ 필요한 경우에만 GlobalKey 사용하고 캐싱
  final Map<int, GlobalKey> _itemKeys = {};

  GlobalKey _getKey(int index) {
    return _itemKeys.putIfAbsent(index, () => GlobalKey());
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: (context, index) {
        // ✅ 또는 ValueKey, ObjectKey 등 사용
        return ProductCard(key: ValueKey(products[index].id));
      },
    );
  }

  @override
  void dispose() {
    _itemKeys.clear();
    super.dispose();
  }
}
```

---

#### 패턴 7: 이미지 캐시 과다

대량의 이미지를 로드할 때 메모리 부족이 발생합니다.

**Before (문제 상황)**
```dart
// ❌ 이미지 캐시 크기 제한 없음
ListView.builder(
  itemBuilder: (context, index) {
    return Image.network(products[index].imageUrl);
  },
);
```

**After (해결)**
```dart
// ✅ 앱 시작 시 이미지 캐시 크기 제한
void main() {
  // 이미지 캐시를 100MB로 제한
  PaintingBinding.instance.imageCache.maximumSizeBytes = 100 * 1024 * 1024;

  runApp(const MyApp());
}

// ✅ 개별 이미지 메모리 최적화
ListView.builder(
  itemBuilder: (context, index) {
    return Image.network(
      products[index].imageUrl,
      cacheWidth: 300,  // 메모리 내 크기 제한
      cacheHeight: 300,
    );
  },
);

// ✅ 필요시 캐시 수동 정리
void _clearImageCache() {
  PaintingBinding.instance.imageCache.clear();
  PaintingBinding.instance.imageCache.clearLiveImages();
}
```

---

### 📊 메모리 누수 체크리스트

```
┌─────────────────────────────────────────────────────────────────────┐
│                     dispose() 체크리스트                             │
├─────────────────────────────────────────────────────────────────────┤
│  □ StreamSubscription.cancel()                                      │
│  □ Timer.cancel()                                                   │
│  □ AnimationController.dispose()                                    │
│  □ ScrollController.dispose()                                       │
│  □ TextEditingController.dispose()                                  │
│  □ FocusNode.dispose()                                              │
│  □ PageController.dispose()                                         │
│  □ TabController.dispose()                                          │
│  □ VideoPlayerController.dispose()                                  │
│  □ WebViewController (필요시)                                       │
└─────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────┐
│                     비동기 작업 체크리스트                           │
├─────────────────────────────────────────────────────────────────────┤
│  □ async 함수 내 setState 전에 if (!mounted) return;                │
│  □ async 함수 내 context 사용 전에 if (!context.mounted) return;    │
│  □ Stream.listen() 콜백 내 mounted 체크                             │
│  □ Timer 콜백 내 mounted 체크                                       │
│  □ Future.then() 콜백 내 mounted 체크                               │
└─────────────────────────────────────────────────────────────────────┘
```

---

### 🔍 메모리 누수 디버깅 방법

#### 1. DevTools Memory 탭 사용

```bash
# DevTools 실행
flutter pub global activate devtools
flutter pub global run devtools
```

- **Memory** 탭에서 힙 사용량 모니터링
- **Snapshot** 버튼으로 메모리 스냅샷 촬영
- 두 스냅샷 비교하여 해제되지 않는 객체 확인

#### 2. 로그로 확인

```dart
class _MyPageState extends State<MyPage> {
  @override
  void initState() {
    super.initState();
    debugPrint('🟢 MyPage initState');
  }

  @override
  void dispose() {
    debugPrint('🔴 MyPage dispose');
    super.dispose();
  }
}
```

#### 3. LeakTracker 사용 (Flutter 3.18+)

```dart
// test/widget_test.dart
testWidgets('memory leak test', (tester) async {
  await tester.pumpWidget(const MyApp());

  // LeakTracker가 자동으로 메모리 누수 감지
});
```

#### 4. 메모리 사용량 코드로 확인

```dart
import 'dart:developer' as developer;

void checkMemory() {
  developer.postEvent('memory_check', {
    'rss': ProcessInfo.currentRss,
    'maxRss': ProcessInfo.maxRss,
  });
}
```

---

### 😊 해당 경험을 통해 알게된 점

**dispose() 메서드의 중요성**을 깊이 이해하게 되었습니다. Flutter에서는 Widget의 생명주기를 직접 관리해야 하며, 생성한 모든 리소스는 반드시 해제해야 합니다.

**mounted 체크의 필수성**을 배웠습니다. 비동기 작업이 완료된 시점에 위젯이 이미 트리에서 제거되었을 수 있으므로, setState나 context 사용 전 항상 mounted를 확인해야 합니다.

**메모리 누수는 즉시 나타나지 않는다**는 점을 알게 되었습니다. 작은 누수는 앱 사용 중에는 눈에 띄지 않지만, 시간이 지나면서 누적되어 결국 앱 크래시로 이어집니다. 따라서 코딩 시점부터 메모리 관리를 철저히 해야 합니다.

**도구 활용의 중요성**을 경험했습니다. Flutter DevTools의 Memory 탭을 활용하면 메모리 누수를 쉽게 찾고 해결할 수 있습니다.

---

### 🛠️ 관련 기술

- **Flutter**: StatefulWidget 생명주기, dispose 패턴
- **Dart**: Stream, Timer, Future, async/await
- **디버깅**: Flutter DevTools, Memory Profiler
- **패턴**: RAII (Resource Acquisition Is Initialization)

---

### 📁 관련 파일 예시

- `lib/feature/chat/presentation/page/chat_room_page.dart` - Stream 구독 관리
- `lib/shared/widget/gb_loading_view.dart` - AnimationController 관리
- `lib/feature/product/presentation/page/product_list_page.dart` - ScrollController 관리
- `lib/core/util/pagination_scroll_mixin.dart` - Mixin에서의 dispose 처리

---

### 📚 참고 자료

- [Flutter - State lifecycle](https://api.flutter.dev/flutter/widgets/State-class.html)
- [Flutter - Debugging memory issues](https://docs.flutter.dev/tools/devtools/memory)
- [Dart - Streams](https://dart.dev/tutorials/language/streams)
- [Flutter - Performance best practices](https://docs.flutter.dev/perf/best-practices)
