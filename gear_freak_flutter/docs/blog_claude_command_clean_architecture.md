# [AI] Claude Code Custom Command로 Flutter Clean Architecture 보일러플레이트 자동화하기

## 1. 들어가며

Flutter 프로젝트에서 Clean Architecture를 적용할 때마다 반복되는 작업이 있습니다. Feature를 추가할 때마다 `data`, `domain`, `presentation` 폴더를 만들고, DataSource, Repository, UseCase, State, Notifier 파일들을 일일이 생성해야 합니다.

이런 반복 작업을 **Claude Code의 Custom Command**로 자동화하면, 단 몇 초 만에 완벽한 Clean Architecture 구조를 생성할 수 있습니다.

```
/create-feature coupon
```

이 한 줄로 아래 구조가 자동 생성됩니다:

```
lib/feature/coupon/
├── data/
│   ├── datasource/coupon_remote_datasource.dart
│   ├── model/coupon_model.dart
│   ├── repository/coupon_repository_impl.dart
│   └── data.dart
├── domain/
│   ├── entity/coupon_entity.dart
│   ├── repository/coupon_repository.dart
│   ├── usecase/usecases.dart
│   ├── failures/coupon_failure.dart
│   └── domain.dart
├── presentation/
│   ├── page/pages.dart
│   ├── view/view.dart
│   ├── widget/widget.dart
│   ├── provider/provider.dart
│   └── presentation.dart
└── di/coupon_providers.dart
```

---

## 2. Custom Command란?

Claude Code에서 `.claude/commands/` 디렉토리에 마크다운 파일을 생성하면, 해당 파일명이 슬래시 커맨드로 등록됩니다.

```
.claude/commands/
├── create-feature.md   → /create-feature
├── create-usecase.md   → /create-usecase
├── create-state.md     → /create-state
└── create-notifier.md  → /create-notifier
```

### 핵심 문법

| 요소 | 설명 |
|------|------|
| `$ARGUMENTS` | 사용자가 입력한 인자값 |
| `{Name}` | PascalCase 플레이스홀더 |
| `{name}` | snake_case 플레이스홀더 |
| 코드 블록 | 생성할 코드 템플릿 |

---

## 3. 전체 워크플로우

새로운 Feature를 추가할 때의 전체 흐름입니다:

```bash
# 1. Feature 스켈레톤 생성
/create-feature coupon

# 2. UseCase 생성 (Repository, DataSource 메서드도 자동 추가)
/create-usecase coupon get_coupons "List<CouponEntity>" void

# 3. State 생성
/create-state coupon coupon_list "List<CouponEntity>" paginated

# 4. Notifier 생성 (DI Provider도 자동 추가)
/create-notifier coupon coupon_list coupon_list get_coupons
```

**4개 커맨드 실행 결과**:

| 레이어 | 생성된 파일 |
|--------|------------|
| **Data** | `coupon_remote_datasource.dart`, `coupon_model.dart`, `coupon_repository_impl.dart` |
| **Domain** | `coupon_entity.dart`, `coupon_repository.dart`, `get_coupons_usecase.dart`, `coupon_failure.dart` |
| **Presentation** | `coupon_list_state.dart`, `coupon_list_notifier.dart` |
| **DI** | `coupon_providers.dart` |

---

## 4. 실제 사용 예시

생성된 코드를 Page에서 사용하는 방법:

```dart
class CouponListPage extends ConsumerWidget {
  const CouponListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(couponListNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('쿠폰 목록')),
      body: switch (state) {
        CouponListInitial() || CouponListLoading() =>
          const Center(child: CircularProgressIndicator()),
        CouponListError(:final message) =>
          Center(child: Text(message)),
        CouponListLoaded(:final items) || CouponListLoadingMore(:final items) =>
          ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) => CouponCard(coupon: items[index]),
          ),
      },
    );
  }
}
```

---

## 5. 마무리

### 장점

| 항목 | 설명 |
|------|------|
| **일관성** | 모든 Feature가 동일한 구조와 패턴을 따름 |
| **생산성** | 보일러플레이트 작성 시간 90% 이상 절감 |
| **실수 방지** | 파일 누락, 오타, import 실수 방지 |
| **온보딩** | 신규 팀원도 커맨드만 알면 바로 작업 가능 |

### ⚠️ 커스터마이징 안내

> **중요**: 이 글에서 소개한 커맨드는 **제 프로젝트 구조에 맞게 커스텀한 예시**입니다.
>
> 여러분의 프로젝트에서는 **각자의 아키텍처, 상태관리, 패키지 선택에 맞게 수정**해서 사용하시면 됩니다!

**커스텀 가능한 항목들:**

| 항목 | 이 글의 예시 | 다른 선택지 |
|------|-------------|------------|
| **HTTP 클라이언트** | Dio | http, Retrofit, Chopper |
| **상태관리** | Riverpod (StateNotifier) | Bloc, GetX, Provider, MobX |
| **에러 처리** | dartz (Either) | fpdart, Result 패턴, try-catch |
| **폴더 구조** | Feature-first | Layer-first |
| **DI 방식** | Riverpod Provider | get_it, injectable |

**수정 방법:**
`.claude/commands/` 폴더의 마크다운 파일에서 코드 패턴만 바꿔주면 끝!

**핵심은 구조가 아니라 "반복 작업의 자동화"입니다.** 각자의 프로젝트 컨벤션에 맞게 템플릿을 만들어두면, 새로운 Feature를 추가할 때마다 일관된 코드를 빠르게 생성할 수 있습니다.

---

## 6. 참고 자료

- [Claude Code 공식 문서](https://docs.anthropic.com/claude-code)
- [Flutter Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Riverpod 공식 문서](https://riverpod.dev/)
