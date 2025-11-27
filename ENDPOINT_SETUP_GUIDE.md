# Serverpod 엔드포인트 설정 가이드

## 📋 작업 순서

### 1단계: 필요한 패키지 추가

#### `gear_freak_server/pubspec.yaml` 수정
```yaml
dependencies:
  serverpod: 2.9.2
  serverpod_auth_server: 2.9.2  # ← 추가 필요!
```

### 2단계: 패키지 설치
```bash
cd gear_freak_server
dart pub get
```

### 3단계: 서버 설정 확인
- `server.dart`에서 인증 모듈이 자동으로 활성화되는지 확인
- Serverpod 2.9.2에서는 기본적으로 인증 모듈이 포함되어 있음

### 4단계: 마이그레이션 실행
```bash
cd gear_freak_server
dart run bin/main.dart --apply-migrations
```

### 5단계: 엔드포인트 생성
- 사용자 관련 엔드포인트 생성
- 인증이 필요한 엔드포인트 생성

---

## 🔧 상세 작업 내용

### Step 1: pubspec.yaml 수정

```yaml
name: gear_freak_server
description: Starting point for a Serverpod server.

environment:
  sdk: '>=3.5.0 <4.0.0'

dependencies:
  serverpod: 2.9.2
  serverpod_auth_server: 2.9.2  # ← 이 줄 추가

dev_dependencies:
  lints: '>=3.0.0 <7.0.0'
  test: '^1.24.2'
  serverpod_test: 2.9.2
```

### Step 2: 패키지 설치 및 코드 생성

```bash
cd gear_freak_server
dart pub get
serverpod generate
```

### Step 3: 마이그레이션 실행

```bash
dart run bin/main.dart --apply-migrations
```

이 명령어는:
- 인증 관련 데이터베이스 테이블 생성
- 필요한 스키마 설정

### Step 4: 엔드포인트 생성 예시

#### 사용자 엔드포인트 생성
`lib/src/feature/user/endpoint/user_endpoint.dart` 파일 생성

```dart
import 'package:serverpod/serverpod.dart';
import '../common/authenticated_mixin.dart';

class UserEndpoint extends Endpoint with AuthenticatedMixin {
  // requireLogin => true 자동 적용
  
  Future<User> getCurrentUser(Session session) async {
    final auth = await session.authenticated;
    if (auth == null) {
      throw Exception('인증이 필요합니다.');
    }
    
    // 사용자 정보 조회 로직
    // ...
  }
}
```

---

## ✅ 체크리스트

- [ ] `pubspec.yaml`에 `serverpod_auth_server: 2.9.2` 추가
- [ ] `dart pub get` 실행
- [ ] `serverpod generate` 실행
- [ ] `dart run bin/main.dart --apply-migrations` 실행
- [ ] 서버 재시작하여 정상 동작 확인

---

## 🚀 다음 단계

엔드포인트 설정이 완료되면:
1. 사용자 모델 정의 (`.spy.yaml`)
2. 인증 엔드포인트 구현
3. `serverpod generate` 실행하여 클라이언트 코드 생성


