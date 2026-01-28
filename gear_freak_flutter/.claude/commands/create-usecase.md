# UseCase 생성

UseCase 클래스를 생성하고 관련 파일들을 업데이트합니다.

## 입력
- $ARGUMENTS: {featureName} {usecaseName} {returnType} {paramType}
- 예: order get_orders "List<OrderEntity>" PaginationParams
- 예: order get_order_detail OrderEntity int
- 예: order delete_order void int

paramType이 void면 파라미터 없는 UseCase 생성

## 생성할 파일

`lib/feature/{featureName}/domain/usecase/{usecaseName}_usecase.dart`

## 코드 패턴

### paramType이 void인 경우
```dart
import 'package:dartz/dartz.dart';
import 'package:gear_freak_flutter/feature/{feature}/domain/domain.dart';

/// {UseCaseName} UseCase
class {UseCaseName}UseCase {
  const {UseCaseName}UseCase(this._repository);

  final {Feature}Repository _repository;

  Future<Either<Failure, {ReturnType}>> call() async {
    return _repository.{methodName}();
  }
}
```

### paramType이 있는 경우
```dart
import 'package:dartz/dartz.dart';
import 'package:gear_freak_flutter/feature/{feature}/domain/domain.dart';

/// {UseCaseName} UseCase
class {UseCaseName}UseCase {
  const {UseCaseName}UseCase(this._repository);

  final {Feature}Repository _repository;

  Future<Either<Failure, {ReturnType}>> call({ParamType} param) async {
    return _repository.{methodName}(param);
  }
}
```

## 추가 작업 (자동으로 수행)

1. **Repository interface에 메서드 추가**
```dart
Future<Either<Failure, {ReturnType}>> {methodName}({ParamType} param);
// 또는 void인 경우
Future<Either<Failure, {ReturnType}>> {methodName}();
```

2. **Repository impl에 메서드 구현**
```dart
@override
Future<Either<Failure, {ReturnType}>> {methodName}({ParamType} param) async {
  try {
    final model = await _remoteDataSource.{methodName}(param);
    return Right(model.toEntity()); // Model -> Entity 변환
  } on Exception catch (e) {
    return Left({Feature}Failure('데이터를 불러오는데 실패했습니다.', exception: e));
  }
}

// 리스트인 경우
@override
Future<Either<Failure, List<{Entity}>>> {methodName}({ParamType} param) async {
  try {
    final models = await _remoteDataSource.{methodName}(param);
    final entities = models.map((m) => m.toEntity()).toList();
    return Right(entities);
  } on Exception catch (e) {
    return Left({Feature}Failure('목록을 불러오는데 실패했습니다.', exception: e));
  }
}
```

3. **DataSource에 메서드 추가**
```dart
Future<{ReturnType}Model> {methodName}({ParamType} param) async {
  final response = await _dio.get('/api/{feature}s/$param');
  return {ReturnType}Model.fromJson(response.data as Map<String, dynamic>);
}

// 리스트인 경우
Future<List<{Entity}Model>> {methodName}({ParamType} param) async {
  final response = await _dio.get('/api/{feature}s');
  return (response.data as List)
      .map((json) => {Entity}Model.fromJson(json as Map<String, dynamic>))
      .toList();
}
```

4. **DI Provider에 UseCase Provider 추가**
```dart
/// {UseCaseName} UseCase Provider
final {usecaseName}UseCaseProvider = Provider<{UseCaseName}UseCase>((ref) {
  final repository = ref.watch({feature}RepositoryProvider);
  return {UseCaseName}UseCase(repository);
});
```

5. **Barrel 파일 업데이트**
- `domain/usecase/usecases.dart`에 export 추가

## 네이밍 규칙
- usecaseName: snake_case (예: get_orders, create_order)
- UseCaseName: PascalCase (예: GetOrders, CreateOrder)
- methodName: camelCase (예: getOrders, createOrder)
- ReturnType: Entity 사용 (예: OrderEntity, List<OrderEntity>)
