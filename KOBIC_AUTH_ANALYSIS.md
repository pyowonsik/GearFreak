# kobic 프로젝트 로그인/회원가입 로직 분석

## 📋 목차
1. [전체 아키텍처](#전체-아키텍처)
2. [로그인 플로우](#로그인-플로우)
3. [회원가입 플로우](#회원가입-플로우)
4. [주요 컴포넌트](#주요-컴포넌트)
5. [코드 구조](#코드-구조)

---

## 전체 아키텍처

```
┌─────────────────────────────────────────────────────────────┐
│                    UI Layer (BLoC)                          │
│  SignInWithEmailBloc → SignInWithEmailPage                 │
└──────────────────────┬──────────────────────────────────────┘
                       │
┌──────────────────────▼──────────────────────────────────────┐
│                  Domain Layer (UseCase)                     │
│  - SignInWithEmailUsecase                                   │
│  - CreateAccountUsecase                                     │
│  - ConfirmEmailUsecase                                      │
│  - InitiatePasswordResetUsecase                             │
│  - ResetPasswordUsecase                                     │
└──────────────────────┬──────────────────────────────────────┘
                       │
┌──────────────────────▼──────────────────────────────────────┐
│                  Data Layer (Repository)                    │
│  SignInWithEmailRepository                                  │
└──────────────────────┬──────────────────────────────────────┘
                       │
┌──────────────────────▼──────────────────────────────────────┐
│                  Service Layer                              │
│  PodService → Serverpod Client                              │
│  - podService.email.authenticate()                          │
│  - podService.email.createAccountRequest()                  │
│  - podService.email.createAccount()                         │
│  - podService.sessionManager.registerSignedInUser()         │
└─────────────────────────────────────────────────────────────┘
```

---

## 로그인 플로우

### 1. 사용자 입력
```dart
// SignInWithEmailPage
void _onSignInPressed(BuildContext context, SignInWithEmailState state) {
  if (state.formKey.currentState?.saveAndValidate() ?? false) {
    final email = state.formKey.currentState?.fields[FormKeys.email]?.value;
    final password = state.formKey.currentState?.fields[FormKeys.password]?.value;
    
    context.read<SignInWithEmailBloc>().add(
      OnSignInWithEmailEvent(email: email, password: password),
    );
  }
}
```

### 2. BLoC 이벤트 처리
```dart
// SignInWithEmailBloc
FutureOr<void> _onSignInWithEmail(
  OnSignInWithEmailEvent event,
  Emitter<SignInWithEmailState> emit,
) async {
  emit(state.copyWith(status: SignInWithEmailStatus.loading));
  
  // UseCase 호출
  final result = await const SignInWithEmailUsecase().call(
    SignInWithEmailParam(event.email, event.password),
  );
  
  await result.fold<Future<void>>(
    (failure) async {
      // 실패 처리
      emit(state.copyWith(
        failure: failure,
        status: SignInWithEmailStatus.error,
      ));
    },
    (userInfo) async {
      // 성공 처리
      emit(state.copyWith(status: SignInWithEmailStatus.success));
      
      // AuthBloc에 인증 이벤트 전달
      getIt<AuthBloc>().add(const AuthenticateEvent());
      
      // 페이지 상태 초기화
      safeAdd(const OnPageStatusChangedSignInWithEmailEvent(PageStatus.signIn));
    },
  );
}
```

### 3. UseCase 실행
```dart
// SignInWithEmailUsecase
Future<Either<Failure, UserInfo>> call(SignInWithEmailParam params) async {
  // 1. 입력값 검증
  final emailValidation = validateEmailAddress(params.email);
  if (emailValidation.isLeft()) {
    return emailValidation.fold(left, (_) => throw UnimplementedError());
  }
  
  final passwordValidation = validatePassword(params.password);
  if (passwordValidation.isLeft()) {
    return passwordValidation.fold(left, (_) => throw UnimplementedError());
  }
  
  // 2. Repository 호출
  final result = await repo.signInWithEmail(params.email, params.password);
  
  return result.fold(Left.new, (user) async => right(user));
}
```

### 4. Repository → Serverpod 호출
```dart
// SignInWithEmailRepository
Future<Either<Failure, UserInfo>> signInWithEmail(
  String email,
  String password,
) async {
  try {
    // Serverpod 이메일 인증 호출
    final response = await podService.email.authenticate(email, password);
    
    // 응답 검증
    if (response.userInfo == null ||
        response.keyId == null ||
        response.key == null) {
      return left(const SignInWithEmailError(
        SignInWithEmailErrorMessages.userInfoNotFound,
      ));
    }
    
    // 세션 등록 (중요!)
    await podService.sessionManager.registerSignedInUser(
      response.userInfo!,
      response.keyId!,
      response.key!,
    );
    
    return right(response.userInfo!);
  } on Exception catch (error, stackTrace) {
    Log.e(error.toString(), error: error, stackTrace: stackTrace);
    return left(UnexpectedFailure(error.toString()));
  }
}
```

### 5. 세션 등록 (핵심!)
```dart
// PodService.sessionManager.registerSignedInUser()
// 이 메서드가 호출되면:
// 1. 인증 키가 FlutterAuthenticationKeyManager에 저장됨
// 2. 이후 모든 Serverpod API 호출에 자동으로 인증 키가 포함됨
// 3. sessionManager.isSignedIn이 true가 됨
```

---

## 회원가입 플로우

### 1단계: 계정 생성 요청

#### 사용자 입력
```dart
// SignInWithEmailPage
void _onCreateAccountPressed(BuildContext context, SignInWithEmailState state) {
  if (state.formKey.currentState?.saveAndValidate() ?? false) {
    final email = state.formKey.currentState?.fields[FormKeys.email]?.value;
    final password = state.formKey.currentState?.fields[FormKeys.password]?.value;
    final username = state.formKey.currentState?.fields[FormKeys.username]?.value;
    
    context.read<SignInWithEmailBloc>().add(
      OnCreateAccountEvent(
        email: email,
        password: password,
        username: username,
      ),
    );
  }
}
```

#### BLoC 처리
```dart
// SignInWithEmailBloc
FutureOr<void> _onCreateAccount(
  OnCreateAccountEvent event,
  Emitter<SignInWithEmailState> emit,
) async {
  emit(state.copyWith(status: SignInWithEmailStatus.loading));
  
  final result = await CreateAccountUsecase().call(
    CreateAccountParam(
      email: event.email,
      password: event.password,
      username: event.username,
    ),
  );
  
  result.fold(
    (failure) {
      emit(state.copyWith(
        failure: failure,
        status: SignInWithEmailStatus.error,
      ));
    },
    (success) {
      // 성공 시 이메일 인증 화면으로 이동
      emit(state.copyWith(
        email: event.email,
        password: event.password,
        username: event.username,
        status: SignInWithEmailStatus.success,
      ));
      
      safeAdd(const OnPageStatusChangedSignInWithEmailEvent(
        PageStatus.confirmEmail,
      ));
    },
  );
}
```

#### UseCase 실행
```dart
// CreateAccountUsecase
Future<Either<Failure, bool>> call(CreateAccountParam param) async {
  // 1. 입력값 검증
  final emailValidation = validateEmailAddress(param.email);
  final passwordValidation = validatePassword(param.password);
  final nameValidation = validateCharacterLength(param.username, 3, 30);
  
  // 2. Repository 호출
  final result = await repo.createAccountRequest(
    param.username,
    param.email,
    param.password,
  );
  
  return result.fold(Left.new, Right.new);
}
```

#### Repository → Serverpod 호출
```dart
// SignInWithEmailRepository
Future<Either<Failure, bool>> createAccountRequest(
  String userName,
  String email,
  String password,
) async {
  try {
    // Serverpod 계정 생성 요청
    final result = await podService.email.createAccountRequest(
      userName,
      email,
      password,
    );
    
    if (!result) {
      return left(const CreateAccountRequestFailure.error(
        SignInWithEmailErrorMessages.createAccountRequestFailed,
      ));
    }
    
    return right(result);
  } on Exception catch (error, stackTrace) {
    Log.e(error.toString(), error: error, stackTrace: stackTrace);
    return left(UnexpectedFailure(error.toString()));
  }
}
```

**결과**: 이메일로 인증 코드가 전송됨

---

### 2단계: 이메일 인증 확인

#### 사용자 입력 (인증 코드)
```dart
// SignInWithEmailPage
void _onVerifyEmailPressed(BuildContext context, SignInWithEmailState state) {
  if (state.formKey.currentState?.saveAndValidate() ?? false) {
    final verificationCode = state.formKey.currentState
        ?.fields[FormKeys.verificationCode]?.value;
    
    context.read<SignInWithEmailBloc>().add(
      OnVerifyEmailEvent(verificationCode: verificationCode),
    );
  }
}
```

#### BLoC 처리
```dart
// SignInWithEmailBloc
FutureOr<void> _onVerifyEmail(
  OnVerifyEmailEvent event,
  Emitter<SignInWithEmailState> emit,
) async {
  emit(state.copyWith(status: SignInWithEmailStatus.loading));
  
  // 이메일 인증 확인
  final result = await const ConfirmEmailUsecase().call(
    ConfirmEmailParam(state.email ?? '', event.verificationCode),
  );
  
  await result.fold<Future<void>>(
    (failure) async {
      emit(state.copyWith(
        failure: failure,
        status: SignInWithEmailStatus.error,
      ));
    },
    (userInfo) async {
      // 인증 성공 후 자동 로그인 시도
      if ((state.email?.isNotEmpty ?? false) &&
          (state.password?.isNotEmpty ?? false)) {
        
        final loginResult = await const SignInWithEmailUsecase().call(
          SignInWithEmailParam(state.email!, state.password!),
        );
        
        await loginResult.fold<Future<void>>(
          (failure) async {
            emit(state.copyWith(
              failure: failure,
              status: SignInWithEmailStatus.error,
            ));
          },
          (user) async {
            emit(state.copyWith(
              status: SignInWithEmailStatus.success,
              verificationCode: event.verificationCode,
            ));
            
            // AuthBloc에 인증 이벤트 전달
            getIt<AuthBloc>().add(const AuthenticateEvent());
            
            // 로그인 화면으로 돌아가기
            safeAdd(const OnPageStatusChangedSignInWithEmailEvent(
              PageStatus.signIn,
            ));
          },
        );
        return;
      }
      
      // 비밀번호가 없으면 성공만 표시
      emit(state.copyWith(
        status: SignInWithEmailStatus.success,
        verificationCode: event.verificationCode,
      ));
    },
  );
}
```

#### Repository → Serverpod 호출
```dart
// SignInWithEmailRepository
Future<Either<Failure, UserInfo?>> createAccount(
  String email,
  String verificationCode,
) async {
  try {
    // Serverpod 계정 생성 완료
    final result = await podService.email.createAccount(
      email,
      verificationCode,
    );
    
    if (result == null) {
      return left(const CreateAccountFailure.error(
        SignInWithEmailErrorMessages.createAccountFailed,
      ));
    }
    
    return right(result);
  } on Exception catch (error, stackTrace) {
    Log.e(error.toString(), error: error, stackTrace: stackTrace);
    return left(UnexpectedFailure(error.toString()));
  }
}
```

**결과**: 계정이 활성화되고, 자동으로 로그인됨

---

## 주요 컴포넌트

### 1. PodService
```dart
// package/pod_service/lib/src/pod_service.dart
class PodService {
  static final PodService _instance = PodService._();
  static PodService get instance => _instance;
  
  late Client client;
  late SessionManager sessionManager;
  
  factory PodService.initialize({required String baseUrl}) {
    _instance.client = Client(
      baseUrl,
      authenticationKeyManager: FlutterAuthenticationKeyManager(),
      connectionTimeout: const Duration(minutes: 15),
      streamingConnectionTimeout: const Duration(minutes: 20),
    )..connectivityMonitor = FlutterConnectivityMonitor();
    
    _instance.sessionManager = SessionManager(
      caller: _instance.client.modules.auth,
    );
    
    return _instance;
  }
  
  // 이메일 인증 엔드포인트
  EndpointEmail get email => client.modules.auth.email;
}
```

### 2. SessionManager
- **역할**: 사용자 세션 상태 관리
- **주요 메서드**:
  - `registerSignedInUser()`: 로그인한 사용자 세션 등록
  - `signOutDevice()`: 로그아웃
  - `isSignedIn`: 로그인 상태 확인

### 3. Serverpod Email 인증 API
```dart
// 사용 가능한 메서드들:
podService.email.authenticate(email, password)           // 로그인
podService.email.createAccountRequest(userName, email, password)  // 회원가입 요청
podService.email.createAccount(email, verificationCode)  // 이메일 인증 완료
podService.email.initiatePasswordReset(email)            // 비밀번호 재설정 요청
podService.email.resetPassword(verificationCode, password) // 비밀번호 재설정 완료
```

---

## 코드 구조

### 디렉토리 구조
```
feature/common/sign_in_with_email/
├── lib/
│   ├── src/
│   │   ├── data/
│   │   │   └── repository/
│   │   │       └── sign_in_with_email_repository.dart  ← Serverpod 호출
│   │   ├── domain/
│   │   │   ├── usecases/
│   │   │   │   ├── sign_in_with_email_usecase.dart     ← 로그인 UseCase
│   │   │   │   ├── create_account_usecase.dart         ← 회원가입 UseCase
│   │   │   │   ├── confirm_email_usecase.dart          ← 이메일 인증 UseCase
│   │   │   │   ├── initiate_password_reset_usecase.dart
│   │   │   │   └── reset_password_usecase.dart
│   │   │   └── failures/                              ← 에러 처리
│   │   └── presentation/
│   │       ├── blocs/
│   │       │   └── sign_in_with_email/
│   │       │       └── sign_in_with_email_bloc.dart    ← 상태 관리
│   │       └── pages/
│   │           └── sign_in_with_email_page.dart        ← UI
```

---

## 핵심 포인트

### 1. 세션 관리
```dart
// 로그인 성공 시 반드시 호출해야 함
await podService.sessionManager.registerSignedInUser(
  userInfo,
  keyId,
  key,
);
```

### 2. 자동 로그인
- 회원가입 완료 후 이메일/비밀번호가 있으면 자동으로 로그인 시도
- 사용자 경험 향상

### 3. 에러 처리
- `Either<Failure, T>` 패턴 사용
- 각 단계별로 구체적인 Failure 타입 정의

### 4. 입력 검증
- UseCase 레벨에서 검증 수행
- 이메일, 비밀번호, 사용자명 등

### 5. 상태 관리
- BLoC 패턴 사용
- 페이지 상태별로 다른 UI 표시 (signIn, createAccount, confirmEmail 등)

---

## gear_freak에 적용 시 체크리스트

- [ ] `PodService` 클래스 생성
- [ ] `SessionManager` 초기화
- [ ] `SignInWithEmailRepository` 구현
- [ ] `SignInWithEmailUsecase` 구현
- [ ] `CreateAccountUsecase` 구현
- [ ] `ConfirmEmailUsecase` 구현
- [ ] BLoC 또는 Riverpod로 상태 관리
- [ ] UI 페이지 구현
- [ ] 입력 검증 로직 추가
- [ ] 에러 처리 구현

---

## 참고 파일 경로

- Repository: `/Users/pyowonsik/Downloads/workspace/kobic/feature/common/sign_in_with_email/lib/src/data/repository/sign_in_with_email_repository.dart`
- UseCase: `/Users/pyowonsik/Downloads/workspace/kobic/feature/common/sign_in_with_email/lib/src/domain/usecases/`
- BLoC: `/Users/pyowonsik/Downloads/workspace/kobic/feature/common/sign_in_with_email/lib/src/presentation/blocs/sign_in_with_email/sign_in_with_email_bloc.dart`
- UI: `/Users/pyowonsik/Downloads/workspace/kobic/feature/common/sign_in_with_email/lib/src/presentation/pages/sign_in_with_email_page.dart`
- PodService: `/Users/pyowonsik/Downloads/workspace/kobic/package/pod_service/lib/src/pod_service.dart`


