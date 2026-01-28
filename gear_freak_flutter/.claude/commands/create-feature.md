# Feature 스켈레톤 생성

새로운 feature의 기본 구조를 생성합니다.

## 입력
- $ARGUMENTS: feature 이름 (예: order, payment, coupon)

## 생성할 구조

```
lib/feature/{name}/
├── data/
│   ├── datasource/{name}_remote_datasource.dart
│   ├── model/{name}_model.dart
│   ├── repository/{name}_repository_impl.dart
│   └── data.dart
├── domain/
│   ├── entity/{name}_entity.dart
│   ├── repository/{name}_repository.dart
│   ├── usecase/usecases.dart
│   ├── failures/{name}_failure.dart
│   ├── failures/failures.dart
│   └── domain.dart
├── presentation/
│   ├── page/pages.dart
│   ├── view/view.dart
│   ├── widget/widget.dart
│   ├── provider/provider.dart
│   └── presentation.dart
└── di/{name}_providers.dart
```

## 코드 패턴

### Entity (Domain Layer) - 순수 비즈니스 객체
```dart
/// {Name} 엔티티
class {Name}Entity {
  const {Name}Entity({
    required this.id,
    // TODO: 필드 추가
  });

  final int id;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is {Name}Entity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
```

### Model (Data Layer) - API 응답 DTO
```dart
import 'package:gear_freak_flutter/feature/{name}/domain/entity/{name}_entity.dart';

/// {Name} 모델 (API 응답 DTO)
class {Name}Model {
  const {Name}Model({
    required this.id,
    // TODO: 필드 추가
  });

  factory {Name}Model.fromJson(Map<String, dynamic> json) {
    return {Name}Model(
      id: json['id'] as int,
      // TODO: 필드 파싱 추가
    );
  }

  final int id;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      // TODO: 필드 추가
    };
  }

  /// Model -> Entity 변환
  {Name}Entity toEntity() {
    return {Name}Entity(
      id: id,
      // TODO: 필드 매핑 추가
    );
  }
}
```

### RemoteDataSource - API 호출
```dart
import 'package:dio/dio.dart';
import 'package:gear_freak_flutter/feature/{name}/data/model/{name}_model.dart';

/// {Name} 원격 데이터 소스
class {Name}RemoteDataSource {
  const {Name}RemoteDataSource(this._dio);

  final Dio _dio;

  // TODO: 메서드 추가
  // 예시:
  // Future<List<{Name}Model>> get{Name}s() async {
  //   final response = await _dio.get('/api/{name}s');
  //   return (response.data as List)
  //       .map((json) => {Name}Model.fromJson(json as Map<String, dynamic>))
  //       .toList();
  // }
  //
  // Future<{Name}Model> get{Name}ById(int id) async {
  //   final response = await _dio.get('/api/{name}s/$id');
  //   return {Name}Model.fromJson(response.data as Map<String, dynamic>);
  // }
}
```

### Repository Interface (Domain Layer)
```dart
import 'package:dartz/dartz.dart';
import 'package:gear_freak_flutter/feature/{name}/domain/entity/{name}_entity.dart';
import 'package:gear_freak_flutter/shared/domain/failure/failure.dart';

/// {Name} Repository 인터페이스
abstract class {Name}Repository {
  // TODO: 메서드 정의
  // 예시:
  // Future<Either<Failure, List<{Name}Entity>>> get{Name}s();
  // Future<Either<Failure, {Name}Entity>> get{Name}ById(int id);
  // Future<Either<Failure, {Name}Entity>> create{Name}(Create{Name}Params params);
  // Future<Either<Failure, {Name}Entity>> update{Name}(Update{Name}Params params);
  // Future<Either<Failure, void>> delete{Name}(int id);
}
```

### Repository Impl (Data Layer)
```dart
import 'package:dartz/dartz.dart';
import 'package:gear_freak_flutter/feature/{name}/data/datasource/{name}_remote_datasource.dart';
import 'package:gear_freak_flutter/feature/{name}/domain/entity/{name}_entity.dart';
import 'package:gear_freak_flutter/feature/{name}/domain/failures/{name}_failure.dart';
import 'package:gear_freak_flutter/feature/{name}/domain/repository/{name}_repository.dart';
import 'package:gear_freak_flutter/shared/domain/failure/failure.dart';

/// {Name} Repository 구현
class {Name}RepositoryImpl implements {Name}Repository {
  const {Name}RepositoryImpl(this._remoteDataSource);

  final {Name}RemoteDataSource _remoteDataSource;

  // TODO: 메서드 구현
  // 예시:
  // @override
  // Future<Either<Failure, List<{Name}Entity>>> get{Name}s() async {
  //   try {
  //     final models = await _remoteDataSource.get{Name}s();
  //     final entities = models.map((model) => model.toEntity()).toList();
  //     return Right(entities);
  //   } on Exception catch (e) {
  //     return Left({Name}Failure('목록을 불러오는데 실패했습니다.', exception: e));
  //   }
  // }
}
```

### Failure
```dart
import 'package:gear_freak_flutter/shared/domain/failure/failure.dart';

/// {Name} 관련 실패
class {Name}Failure extends Failure {
  const {Name}Failure(
    super.message, {
    super.exception,
    super.stackTrace,
  });
}
```

### DI Providers (Riverpod)
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gear_freak_flutter/core/di/dio_provider.dart';
import 'package:gear_freak_flutter/feature/{name}/data/datasource/{name}_remote_datasource.dart';
import 'package:gear_freak_flutter/feature/{name}/data/repository/{name}_repository_impl.dart';
import 'package:gear_freak_flutter/feature/{name}/domain/repository/{name}_repository.dart';

/// {Name} Remote DataSource Provider
final {name}RemoteDataSourceProvider = Provider<{Name}RemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return {Name}RemoteDataSource(dio);
});

/// {Name} Repository Provider
final {name}RepositoryProvider = Provider<{Name}Repository>((ref) {
  final remoteDataSource = ref.watch({name}RemoteDataSourceProvider);
  return {Name}RepositoryImpl(remoteDataSource);
});

// TODO: UseCase Provider 추가
// TODO: Notifier Provider 추가
```

### Barrel 파일들

**data/data.dart**
```dart
export 'datasource/{name}_remote_datasource.dart';
export 'model/{name}_model.dart';
export 'repository/{name}_repository_impl.dart';
```

**domain/domain.dart**
```dart
export 'package:gear_freak_flutter/shared/domain/failure/failure.dart';
export 'entity/{name}_entity.dart';
export 'failures/failures.dart';
export 'repository/{name}_repository.dart';
export 'usecase/usecases.dart';
```

**domain/failures/failures.dart**
```dart
export '{name}_failure.dart';
```

**domain/usecase/usecases.dart**
```dart
// export usecase files here
```

**presentation/presentation.dart**
```dart
export 'page/pages.dart';
export 'provider/provider.dart';
export 'view/view.dart';
export 'widget/widget.dart';
```

**presentation/page/pages.dart, view/view.dart, widget/widget.dart, provider/provider.dart**
```dart
// export files here
```

## 주의사항
- feature 이름은 소문자 snake_case (예: order, user_profile)
- 클래스 이름은 PascalCase (예: Order, UserProfile)
- 파일 이름은 snake_case
- 모든 파일 생성 후 barrel 파일에 export 추가
- dioProvider는 `core/di/dio_provider.dart`에 정의되어 있다고 가정
- Entity는 순수 Dart 객체 (외부 의존성 없음)
- Model은 JSON 직렬화 + Entity 변환 담당
