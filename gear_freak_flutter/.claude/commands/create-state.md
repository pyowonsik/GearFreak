# State 클래스 생성

Sealed class 기반 State를 생성합니다.

## 입력
- $ARGUMENTS: {featureName} {stateName} {dataType} {isPaginated?}
- 예: order order_list "List<OrderEntity>" paginated
- 예: order order_detail OrderEntity

isPaginated를 넣으면 페이지네이션 State도 함께 생성

## 생성할 파일

`lib/feature/{featureName}/presentation/provider/{stateName}_state.dart`

## 기본 코드 패턴

```dart
import 'package:gear_freak_flutter/feature/{feature}/domain/domain.dart';

/// {StateName} 상태 (Sealed Class 방식)
sealed class {StateName}State {
  const {StateName}State();
}

/// 초기 상태
class {StateName}Initial extends {StateName}State {
  const {StateName}Initial();
}

/// 로딩 중 상태
class {StateName}Loading extends {StateName}State {
  const {StateName}Loading();
}

/// 에러 상태
class {StateName}Error extends {StateName}State {
  const {StateName}Error(this.message);

  final String message;
}

/// 로드 성공 상태
class {StateName}Loaded extends {StateName}State {
  const {StateName}Loaded(this.data);

  final {DataType} data;
}
```

## 페이지네이션 패턴 (isPaginated인 경우 추가)

```dart
import 'package:gear_freak_flutter/feature/{feature}/domain/domain.dart';

/// {StateName} 상태 (Sealed Class 방식)
sealed class {StateName}State {
  const {StateName}State();
}

/// 초기 상태
class {StateName}Initial extends {StateName}State {
  const {StateName}Initial();
}

/// 로딩 중 상태
class {StateName}Loading extends {StateName}State {
  const {StateName}Loading();
}

/// 에러 상태
class {StateName}Error extends {StateName}State {
  const {StateName}Error(this.message);

  final String message;
}

/// 로드 성공 상태
class {StateName}Loaded extends {StateName}State {
  const {StateName}Loaded({
    required this.items,
    required this.page,
    required this.hasMore,
  });

  final {DataType} items;
  final int page;
  final bool hasMore;

  {StateName}Loaded copyWith({
    {DataType}? items,
    int? page,
    bool? hasMore,
  }) {
    return {StateName}Loaded(
      items: items ?? this.items,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

/// 추가 로딩 중 상태 (기존 데이터 유지)
class {StateName}LoadingMore extends {StateName}State {
  const {StateName}LoadingMore({
    required this.items,
    required this.page,
    required this.hasMore,
  });

  final {DataType} items;
  final int page;
  final bool hasMore;
}
```

## 추가 작업

1. **Barrel 파일 업데이트**
- `presentation/provider/provider.dart`에 export 추가
```dart
export '{stateName}_state.dart';
```

## 네이밍 규칙
- stateName: snake_case (예: order_list, order_detail)
- StateName: PascalCase (예: OrderList, OrderDetail)
- DataType: Entity 사용 (예: OrderEntity, List<OrderEntity>)
