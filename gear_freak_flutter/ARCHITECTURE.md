# 클린 아키텍처 구조 가이드

## 📁 프로젝트 구조

```
lib/
├── main.dart
├── core/
│   ├── di/
│   │   └── providers.dart          # 전역 Provider 설정 (Serverpod Client 등)
│   └── route/
│       └── app_router.dart         # 라우팅 설정
│
└── feature/
    ├── chat/
    │   ├── data/
    │   │   ├── datasource/
    │   │   │   └── chat_remote_datasource.dart
    │   │   └── repository/
    │   │       └── chat_repository_impl.dart
    │   ├── domain/
    │   │   ├── entity/
    │   │   │   └── chat_message.dart
    │   │   ├── repository/
    │   │   │   └── chat_repository.dart
    │   │   └── usecase/
    │   │       ├── get_chat_list_usecase.dart
    │   │       └── send_message_usecase.dart
    │   ├── di/
    │   │   └── chat_providers.dart  # Chat 관련 Provider
    │   └── presentation/
    │       ├── provider/
    │       │   └── chat_notifier.dart
    │       ├── screen/
    │       │   ├── chat_list_screen.dart
    │       │   └── chat_detail_screen.dart
    │       └── widget/
    │           └── chat_item_widget.dart
    │
    ├── home/
    │   ├── data/
    │   ├── domain/
    │   └── presentation/
    │
    ├── search/
    │   ├── data/
    │   ├── domain/
    │   └── presentation/
    │
    └── profile/
        ├── data/
        ├── domain/
        └── presentation/
```

## 🏗️ 레이어 설명

### 1. **Domain Layer** (비즈니스 로직)

- **Entity**: 순수 Dart 클래스, 비즈니스 객체
- **Repository Interface**: 데이터 소스 추상화
- **UseCase**: 단일 책임 비즈니스 로직

### 2. **Data Layer** (데이터 소스)

- **DataSource**: Serverpod Client를 사용한 API 호출
- **Repository Implementation**: Repository 인터페이스 구현

### 3. **Presentation Layer** (UI)

- **Provider/Notifier**: Riverpod 상태 관리
- **Screen**: 화면 위젯
- **Widget**: 재사용 가능한 위젯

### 4. **DI Layer** (의존성 주입)

- **Providers**: Riverpod Provider 설정

## 📋 의존성 방향

```
Presentation → Domain ← Data
     ↓            ↑
     └────────────┘
```

- Presentation은 Domain만 의존
- Data는 Domain을 구현
- Domain은 외부에 의존하지 않음
