# GearFreak

GearFreak 프로젝트는 Flutter 클라이언트와 Serverpod 서버를 포함하는 monorepo입니다.

## 프로젝트 구조

```
gear_freak/
├── gear_freak_client/    # Serverpod 클라이언트 패키지
├── gear_freak_flutter/   # Flutter 앱
└── gear_freak_server/    # Serverpod 서버
```

## 개발 환경 설정

### Flutter 앱 실행
```bash
cd gear_freak_flutter
flutter pub get
flutter run
```

### 서버 실행
```bash
cd gear_freak_server
dart pub get
dart run bin/main.dart
```

## 기술 스택

- **Client**: Flutter
- **Server**: Serverpod (Dart)
- **Database**: PostgreSQL

