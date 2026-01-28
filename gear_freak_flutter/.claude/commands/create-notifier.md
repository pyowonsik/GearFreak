# Notifier 생성

StateNotifier를 생성합니다.

## 입력
- $ARGUMENTS: {featureName} {notifierName} {stateName} {usecaseNames...}
- 예: order order_list order_list get_orders
- 예: order order_detail order_detail get_order_detail update_order delete_order

## 생성할 파일

`lib/feature/{featureName}/presentation/provider/{notifierName}_notifier.dart`

## 코드 패턴

### 기본 패턴 (단일 데이터)
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gear_freak_flutter/feature/{feature}/domain/domain.dart';
import 'package:gear_freak_flutter/feature/{feature}/presentation/provider/{stateName}_state.dart';

/// {NotifierName} Notifier
class {NotifierName}Notifier extends StateNotifier<{StateName}State> {
  {NotifierName}Notifier(
    this._{usecase1}UseCase,
    // 추가 UseCase들...
  ) : super(const {StateName}Initial());

  final {Usecase1}UseCase _{usecase1}UseCase;
  // 추가 UseCase들...

  // ==================== Public Methods (UseCase) ====================

  Future<void> fetch{Data}() async {
    state = const {StateName}Loading();

    final result = await _{usecase1}UseCase(/* params */);

    result.fold(
      (failure) => state = {StateName}Error(failure.message),
      (data) => state = {StateName}Loaded(data),
    );
  }

  // ==================== Private Helper Methods ====================
}
```

### 페이지네이션 패턴 (리스트 데이터)
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gear_freak_flutter/feature/{feature}/domain/domain.dart';
import 'package:gear_freak_flutter/feature/{feature}/presentation/provider/{stateName}_state.dart';

/// {NotifierName} Notifier
class {NotifierName}Notifier extends StateNotifier<{StateName}State> {
  {NotifierName}Notifier(
    this._getItemsUseCase,
  ) : super(const {StateName}Initial());

  final Get{Items}UseCase _getItemsUseCase;

  static const int _pageSize = 20;

  // ==================== Public Methods (UseCase) ====================

  /// 첫 페이지 로드
  Future<void> fetchItems() async {
    state = const {StateName}Loading();

    final result = await _getItemsUseCase(
      PaginationParams(page: 1, size: _pageSize),
    );

    result.fold(
      (failure) => state = {StateName}Error(failure.message),
      (items) => state = {StateName}Loaded(
        items: items,
        page: 1,
        hasMore: items.length >= _pageSize,
      ),
    );
  }

  /// 다음 페이지 로드
  Future<void> loadMoreItems() async {
    final currentState = state;
    if (currentState is! {StateName}Loaded) return;
    if (!currentState.hasMore) return;

    final nextPage = currentState.page + 1;

    state = {StateName}LoadingMore(
      items: currentState.items,
      page: currentState.page,
      hasMore: currentState.hasMore,
    );

    final result = await _getItemsUseCase(
      PaginationParams(page: nextPage, size: _pageSize),
    );

    result.fold(
      (failure) => state = {StateName}Error(failure.message),
      (newItems) => state = {StateName}Loaded(
        items: [...currentState.items, ...newItems],
        page: nextPage,
        hasMore: newItems.length >= _pageSize,
      ),
    );
  }

  /// 새로고침
  Future<void> refresh() async {
    await fetchItems();
  }

  // ==================== Private Helper Methods ====================
}
```

## DI Provider 추가 패턴

```dart
/// {NotifierName} Notifier Provider
final {notifierName}NotifierProvider =
    StateNotifierProvider.autoDispose<{NotifierName}Notifier, {StateName}State>((ref) {
  final {usecase1}UseCase = ref.watch({usecase1}UseCaseProvider);
  // 추가 UseCase들...
  return {NotifierName}Notifier({usecase1}UseCase, /* ... */);
});
```

## 추가 작업

1. **State 파일이 없으면 create-state 먼저 실행**

2. **DI Provider에 Notifier Provider 추가**
- `di/{feature}_providers.dart`에 추가

3. **Barrel 파일 업데이트**
- `presentation/provider/provider.dart`에 export 추가
```dart
export '{notifierName}_notifier.dart';
```

4. **필요한 import 추가**
- DI Provider 파일에 UseCase import 추가
- State 파일 import 추가

## 네이밍 규칙
- notifierName: snake_case (예: order_list, order_detail)
- NotifierName: PascalCase (예: OrderList, OrderDetail)
- stateName: snake_case (예: order_list, order_detail)
- StateName: PascalCase (예: OrderList, OrderDetail)
- usecase: camelCase (예: getOrders, getOrderDetail)
- DataType: Entity 사용 (예: OrderEntity, List<OrderEntity>)
