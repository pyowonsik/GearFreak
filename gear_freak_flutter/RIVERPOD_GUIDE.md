# Riverpod 사용 가이드

Flutter Riverpod의 주요 개념과 사용 패턴을 정리한 가이드입니다.

---

## 📚 목차

1. [기본 개념](#기본-개념)
2. [ref.watch vs ref.read vs ref.listen](#refwatch-vs-refread-vs-reflisten)
3. [Consumer 사용](#consumer-사용)
4. [상태 감지 패턴](#상태-감지-패턴)
5. [스낵바 표시](#스낵바-표시)
6. [라우팅 처리](#라우팅-처리)
7. [실전 예제](#실전-예제)

---

## 기본 개념

### Provider 종류

```dart
// 1. Provider - 읽기 전용 데이터
final nameProvider = Provider<String>((ref) => 'John');

// 2. StateProvider - 간단한 상태 관리
final countProvider = StateProvider<int>((ref) => 0);

// 3. StateNotifierProvider - 복잡한 상태 관리
final productNotifierProvider = StateNotifierProvider<ProductNotifier, ProductState>((ref) {
  return ProductNotifier();
});

// 4. FutureProvider - 비동기 데이터
final userProvider = FutureProvider<User>((ref) async {
  return await fetchUser();
});
```

### Widget 타입

```dart
// 1. ConsumerWidget - ref 사용 가능
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = ref.watch(nameProvider);
    return Text(name);
  }
}

// 2. ConsumerStatefulWidget - State에서 ref 사용 가능
class MyScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<MyScreen> createState() => _MyScreenState();
}

class _MyScreenState extends ConsumerState<MyScreen> {
  @override
  Widget build(BuildContext context) {
    final name = ref.watch(nameProvider);
    return Text(name);
  }
}
```

---

## ref.watch vs ref.read vs ref.listen

### 1. ref.watch - 상태 감지 및 자동 rebuild

**사용 시기:**
- UI가 상태 변화에 따라 자동으로 업데이트되어야 할 때
- build 메서드 내에서 사용
- 상태가 변경되면 위젯이 자동으로 rebuild됨

**예제:**
```dart
@override
Widget build(BuildContext context) {
  // 상태가 변경되면 자동으로 rebuild
  final productState = ref.watch(productNotifierProvider);
  
  return switch (productState) {
    ProductLoading() => CircularProgressIndicator(),
    ProductLoaded(:final products) => ListView(...),
    ProductError(:final message) => Text(message),
  };
}
```

**주의사항:**
- build 메서드 내에서만 사용
- 비동기 작업(버튼 클릭 등)에서는 사용하지 않음

---

### 2. ref.read - 일회성 읽기 (rebuild 없음)

**사용 시기:**
- 상태를 읽기만 하고 rebuild가 필요 없을 때
- 이벤트 핸들러(버튼 클릭, 콜백 등)에서 사용
- Notifier의 메서드를 호출할 때

**예제:**
```dart
// 버튼 클릭 시
ElevatedButton(
  onPressed: () {
    // rebuild 없이 상태 읽기
    final notifier = ref.read(productNotifierProvider.notifier);
    notifier.loadProducts(); // 메서드 호출
  },
  child: Text('로드'),
)

// 또는 직접 값 읽기
final count = ref.read(countProvider); // rebuild 없이 값만 읽기
```

**주의사항:**
- build 메서드 내에서 사용하면 안 됨 (경고 발생)
- 이벤트 핸들러, 콜백, initState 등에서 사용

---

### 3. ref.listen - 상태 변화 감지 및 사이드 이펙트

**사용 시기:**
- 상태 변화를 감지하고 스낵바, 다이얼로그, 라우팅 등 사이드 이펙트를 처리할 때
- build 메서드 내에서 사용
- rebuild는 하지 않고, 상태 변화만 감지

**예제:**
```dart
@override
Widget build(BuildContext context) {
  // 상태 변화 감지 (rebuild 없음)
  ref.listen<CreateProductState>(
    createProductNotifierProvider,
    (previous, next) {
      // 상태가 변경될 때마다 실행
      if (next is CreateProductCreated) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('상품이 등록되었습니다')),
        );
        context.pop(); // 화면 닫기
      } else if (next is CreateProductError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error)),
        );
      }
    },
  );
  
  return Scaffold(...);
}
```

**주의사항:**
- build 메서드 내에서 사용
- rebuild는 하지 않음 (watch와의 차이점)
- 사이드 이펙트 처리에만 사용

---

## Consumer 사용

### Consumer - 특정 위젯만 rebuild

**사용 시기:**
- 전체 화면이 아닌 특정 위젯만 상태에 따라 변경되어야 할 때
- 성능 최적화가 필요할 때
- 큰 위젯 트리에서 작은 부분만 업데이트하고 싶을 때

**예제:**
```dart
// AppBar의 버튼만 상태에 따라 변경
AppBar(
  actions: [
    Consumer(
      builder: (context, ref, child) {
        final state = ref.watch(createProductNotifierProvider);
        final isCreating = state is CreateProductCreating;
        
        return TextButton(
          onPressed: isCreating ? null : _submitProduct,
          child: isCreating
              ? CircularProgressIndicator()
              : Text('완료'),
        );
      },
    ),
  ],
)
```

**장점:**
- 전체 화면이 아닌 Consumer 내부만 rebuild
- 성능 최적화
- 불필요한 rebuild 방지

---

## 상태 감지 패턴

### 패턴 1: 전체 화면 상태 감지

```dart
class ProductScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(productNotifierProvider);
    
    return switch (state) {
      ProductInitial() => _buildInitial(),
      ProductLoading() => _buildLoading(),
      ProductLoaded(:final products) => _buildLoaded(products),
      ProductError(:final message) => _buildError(message),
    };
  }
}
```

### 패턴 2: 부분적 상태 감지 (Consumer)

```dart
class ProductScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: _buildBody(), // 상태 감지 안 함
      floatingActionButton: Consumer(
        builder: (context, ref, child) {
          final isLoading = ref.watch(productNotifierProvider) is ProductLoading;
          return FloatingActionButton(
            onPressed: isLoading ? null : _loadProducts,
            child: isLoading ? CircularProgressIndicator() : Icon(Icons.refresh),
          );
        },
      ),
    );
  }
}
```

### 패턴 3: 상태 변화 감지 및 사이드 이펙트 (listen)

```dart
class CreateProductScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<CreateProductScreen> createState() => _CreateProductScreenState();
}

class _CreateProductScreenState extends ConsumerState<CreateProductScreen> {
  @override
  Widget build(BuildContext context) {
    // 상태 변화 감지 및 스낵바 표시
    ref.listen<CreateProductState>(
      createProductNotifierProvider,
      (previous, next) {
        if (next is CreateProductCreated) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('상품이 등록되었습니다')),
          );
          context.pop();
        }
      },
    );
    
    return Scaffold(...);
  }
}
```

---

## 스낵바 표시

### 방법 1: ref.listen 사용 (권장)

```dart
@override
Widget build(BuildContext context) {
  ref.listen<CreateProductState>(
    createProductNotifierProvider,
    (previous, next) {
      if (!mounted) return; // 위젯이 dispose된 경우 체크
      
      if (next is CreateProductCreated) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('상품이 등록되었습니다'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (next is CreateProductError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error),
            backgroundColor: Colors.red,
          ),
        );
      }
    },
  );
  
  return Scaffold(...);
}
```

### 방법 2: Notifier에서 직접 표시 (비권장)

```dart
// Notifier에서 BuildContext를 받아야 하므로 비권장
class ProductNotifier extends StateNotifier<ProductState> {
  final BuildContext context; // ❌ 비권장
  
  void createProduct() {
    // ...
    ScaffoldMessenger.of(context).showSnackBar(...); // ❌
  }
}
```

**권장 패턴:**
- Notifier는 상태만 관리
- UI 관련 작업(스낵바, 다이얼로그 등)은 Widget에서 ref.listen으로 처리

---

## 라우팅 처리

### 방법 1: ref.listen에서 처리 (권장)

```dart
@override
Widget build(BuildContext context) {
  ref.listen<CreateProductState>(
    createProductNotifierProvider,
    (previous, next) {
      if (next is CreateProductCreated) {
        // 성공 시 화면 닫기
        context.pop();
        
        // 또는 다른 화면으로 이동
        // context.go('/products');
      }
    },
  );
  
  return Scaffold(...);
}
```

### 방법 2: 버튼 클릭 시 처리

```dart
ElevatedButton(
  onPressed: () async {
    final notifier = ref.read(createProductNotifierProvider.notifier);
    await notifier.createProduct();
    
    // 상태 확인 후 라우팅
    final state = ref.read(createProductNotifierProvider);
    if (state is CreateProductCreated) {
      context.pop();
    }
  },
  child: Text('등록'),
)
```

**권장 패턴:**
- ref.listen에서 자동으로 처리하는 것이 더 깔끔함
- 상태 기반 자동 라우팅 가능

---

## 실전 예제

### 예제 1: 상품 목록 화면

```dart
class ProductListScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends ConsumerState<ProductListScreen> {
  @override
  void initState() {
    super.initState();
    // 초기화 시 상품 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(productNotifierProvider.notifier).loadProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    // 상태 감지 및 자동 rebuild
    final state = ref.watch(productNotifierProvider);
    
    return Scaffold(
      appBar: AppBar(title: Text('상품 목록')),
      body: switch (state) {
        ProductLoading() => Center(child: CircularProgressIndicator()),
        ProductLoaded(:final products) => ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) => ProductItem(products[index]),
          ),
        ProductError(:final message) => Center(child: Text(message)),
        _ => SizedBox(),
      },
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 상품 생성 화면으로 이동
          context.push('/products/create');
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
```

### 예제 2: 상품 생성 화면

```dart
class CreateProductScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<CreateProductScreen> createState() => _CreateProductScreenState();
}

class _CreateProductScreenState extends ConsumerState<CreateProductScreen> {
  @override
  Widget build(BuildContext context) {
    // 상태 변화 감지 및 사이드 이펙트 처리
    ref.listen<CreateProductState>(
      createProductNotifierProvider,
      (previous, next) {
        if (!mounted) return;
        
        if (next is CreateProductCreated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('상품이 등록되었습니다'),
              backgroundColor: Colors.green,
            ),
          );
          context.pop(); // 화면 닫기
        } else if (next is CreateProductError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(next.error),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('상품 등록'),
        actions: [
          // 버튼만 상태에 따라 변경 (Consumer 사용)
          Consumer(
            builder: (context, ref, child) {
              final state = ref.watch(createProductNotifierProvider);
              final isCreating = state is CreateProductCreating;
              
              return TextButton(
                onPressed: isCreating ? null : _submitProduct,
                child: isCreating
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text('완료'),
              );
            },
          ),
        ],
      ),
      body: Form(...),
    );
  }

  void _submitProduct() {
    // ref.read로 Notifier 메서드 호출
    final notifier = ref.read(createProductNotifierProvider.notifier);
    notifier.createProduct(...);
  }
}
```

### 예제 3: 상품 상세 화면

```dart
class ProductDetailScreen extends ConsumerStatefulWidget {
  final int productId;
  
  @override
  ConsumerState<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  @override
  void initState() {
    super.initState();
    // 초기화 시 상품 상세 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(productDetailNotifierProvider.notifier)
          .loadProductDetail(widget.productId);
    });
  }

  @override
  Widget build(BuildContext context) {
    // 상태 감지 및 자동 rebuild
    final state = ref.watch(productDetailNotifierProvider);
    
    return Scaffold(
      appBar: AppBar(title: Text('상품 상세')),
      body: switch (state) {
        ProductDetailLoading() => Center(child: CircularProgressIndicator()),
        ProductDetailLoaded(:final product, :final seller) => 
          _buildProductDetail(product, seller),
        ProductDetailError(:final message) => Center(child: Text(message)),
        _ => SizedBox(),
      },
    );
  }
}
```

---

## 📝 정리

### ref.watch
- **언제**: UI가 상태에 따라 자동 업데이트되어야 할 때
- **어디서**: build 메서드 내
- **효과**: 상태 변경 시 자동 rebuild

### ref.read
- **언제**: 상태를 읽거나 메서드를 호출할 때 (rebuild 불필요)
- **어디서**: 이벤트 핸들러, 콜백, initState 등
- **효과**: rebuild 없음

### ref.listen
- **언제**: 상태 변화를 감지하고 사이드 이펙트 처리할 때
- **어디서**: build 메서드 내
- **효과**: rebuild 없음, 사이드 이펙트만 실행

### Consumer
- **언제**: 특정 위젯만 상태에 따라 변경되어야 할 때
- **어디서**: 큰 위젯 트리 내의 작은 부분
- **효과**: Consumer 내부만 rebuild

---

## 🎯 실전 팁

1. **성능 최적화**: 큰 화면에서는 Consumer를 적극 활용
2. **상태 관리**: Notifier는 상태만 관리, UI 작업은 Widget에서 처리
3. **에러 처리**: ref.listen으로 에러 상태 감지 및 스낵바 표시
4. **라우팅**: ref.listen에서 자동 라우팅 처리
5. **mounted 체크**: ref.listen 내부에서 반드시 mounted 체크

---

## 참고 자료

- [Riverpod 공식 문서](https://riverpod.dev/)
- [Riverpod 공식 예제](https://github.com/rrousselGit/riverpod/tree/master/examples)

