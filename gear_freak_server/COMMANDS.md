# Serverpod 프로젝트 명령어 정리

## 📦 1. 도커 시작 (Postgres + Redis)

```bash
cd test_server
docker compose up --build --detach
```

**도커 중지:**

```bash
docker compose stop
```

**도커 상태 확인:**

```bash
docker compose ps
```

---

## 🔄 2. 마이그레이션 생성

모델 클래스를 변경한 후, 데이터베이스 마이그레이션 파일을 생성합니다.

```bash
cd test_server
serverpod create-migration
```

---

## ▶️ 3. 마이그레이션 실행

생성된 마이그레이션을 데이터베이스에 적용합니다.

```bash
cd test_server
flutter pub run bin/main.dart --apply-migrations
```

또는

```bash
dart run bin/main.dart --apply-migrations
```

---

## 🔧 4. 코드 생성

모델 클래스나 엔드포인트를 변경한 후, 서버와 클라이언트 코드를 생성합니다.

```bash
cd test_server
serverpod generate
```

이 명령어는 다음을 생성합니다:

- 서버 코드: `lib/src/generated/`
- 클라이언트 코드: `../test_client/lib/src/protocol/`

---

## 🚀 5. 서버 시작

Serverpod 서버를 실행합니다.

```bash
cd test_server
flutter pub run bin/main.dart
```

또는

```bash
dart run bin/main.dart
```

**서버 포트:**

- API 서버: `http://localhost:8080`
- 웹 서버: `http://localhost:8082`
- Insights: `http://localhost:8081`

---

## 🛑 서버 종료

서버를 실행 중인 터미널에서:

```
Ctrl + C
```

또는 포트를 사용하는 프로세스 강제 종료:

```bash
lsof -ti:8080,8081,8082 | xargs kill -9
```

---

## 📋 일반적인 워크플로우

### 새로운 모델 추가 후:

```bash
# 1. 코드 생성
serverpod generate

# 2. 마이그레이션 생성
serverpod create-migration

# 3. 마이그레이션 실행
flutter pub run bin/main.dart --apply-migrations

# 4. 서버 시작
flutter pub run bin/main.dart
```

### 처음 시작할 때:

```bash
# 1. 도커 시작
docker compose up --build --detach

# 2. 마이그레이션 실행 (처음 한 번만)
flutter pub run bin/main.dart --apply-migrations

# 3. 서버 시작
flutter pub run bin/main.dart
```

---

## 🔍 유용한 명령어

**의존성 업데이트:**

```bash
flutter pub get
```

**서버 상태 확인:**

```bash
curl http://localhost:8080
```

**도커 로그 확인:**

```bash
docker compose logs -f
```
