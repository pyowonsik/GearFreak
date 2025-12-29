# 중복 제출/실행 방지 필요 위치 정리

> **작성일**: 2025-01-XX  
> **목적**: 사용자 액션으로 인한 중복 API 호출 및 상태 변경 방지  
> **총 개수**: 24개 위치

---

## 📊 개요

### 통계

- **총 24개 위치**에 중복 방지 패턴 적용 필요
- **높은 우선순위**: 9개 (데이터 생성/수정/삭제)
- **중간 우선순위**: 10개 (업로드/전송/삭제)
- **낮은 우선순위**: 5개 (UI 액션)

### 이미 구현된 곳

- ✅ **리뷰 작성** (`write_review_screen.dart`) - `_isSubmitting` 플래그 사용
- ✅ **페이지네이션** (`pagination_scroll_mixin.dart`) - `_isLoadingMore` + 디바운스
- ✅ **소셜 로그인 버튼** (`social_login_button.dart`) - `isLoading` prop 사용

---

## 🔴 높은 우선순위 (9개)

데이터 생성/수정/삭제 작업으로, 중복 실행 시 데이터 무결성 문제 발생 가능

### 1. 상품 등록

- **파일**: `gear_freak_flutter/lib/feature/product/presentation/screen/create_product_screen.dart`
- **메서드**: `_submitProduct()` (라인 204-248)
- **현재 상태**: Provider 상태(`isCreating`)만 체크, 빠른 연타 시 중복 제출 가능
- **문제점**: UI 레벨 방어만 있어 실제 API 호출 전 중복 방지 없음

```dart
// 현재 코드
final isCreating = state is CreateProductCreating;
return TextButton(
  onPressed: isCreating ? null : _submitProduct,
  // ...
);
```

### 2. 상품 수정

- **파일**: `gear_freak_flutter/lib/feature/product/presentation/screen/update_product_screen.dart`
- **메서드**: `_submitProduct()` (라인 301-347)
- **현재 상태**: Provider 상태(`isUpdating`)만 체크, 빠른 연타 시 중복 제출 가능
- **문제점**: UI 레벨 방어만 있어 실제 API 호출 전 중복 방지 없음

### 3. 프로필 수정

- **파일**: `gear_freak_flutter/lib/feature/profile/presentation/screen/edit_profile_screen.dart`
- **메서드**: `_saveProfile()` (라인 135-146)
- **현재 상태**: Provider 상태(`isUpdating`)만 체크, 빠른 연타 시 중복 제출 가능
- **문제점**: UI 레벨 방어만 있어 실제 API 호출 전 중복 방지 없음

### 4. 상품 삭제

- **파일**: `gear_freak_flutter/lib/feature/product/presentation/screen/product_detail_screen.dart`
- **메서드**: `_handleDelete()` (라인 108-156)
- **현재 상태**: 다이얼로그 확인 있지만, 확인 후 빠른 연타 시 중복 실행 가능
- **문제점**: 다이얼로그 대기 중에도 중복 호출 가능

### 5. 상단 올리기 (Bump)

- **파일**: `gear_freak_flutter/lib/feature/product/presentation/screen/product_detail_screen.dart`
- **메서드**: `_handleBump()` (라인 81-105)
- **현재 상태**: 중복 방지 없음
- **문제점**: 빠른 연타 시 여러 번 API 호출 가능

### 6. 상태 변경

- **파일**: `gear_freak_flutter/lib/feature/product/presentation/screen/product_detail_screen.dart`
- **메서드**: `_handleStatusChange()` (라인 744-804)
- **현재 상태**: 다이얼로그 확인 있지만, 확인 후 빠른 연타 시 중복 실행 가능
- **문제점**: 다이얼로그 대기 중에도 중복 호출 가능

### 7. 회원가입

- **파일**: `gear_freak_flutter/lib/feature/auth/presentation/screen/signup_screen.dart`
- **메서드**: `_handleSignup()` (라인 41-61)
- **현재 상태**: Provider 상태(`isLoading`)만 체크, 빠른 연타 시 중복 제출 가능
- **문제점**: UI 레벨 방어만 있어 실제 API 호출 전 중복 방지 없음

### 8. 알림 삭제

- **파일**: `gear_freak_flutter/lib/feature/notification/presentation/screen/notification_list_screen.dart`
- **메서드**: `onNotificationDelete` (라인 157-163)
- **현재 상태**: 중복 방지 없음
- **문제점**: Slidable 액션에서 빠른 연타 시 여러 번 삭제 API 호출 가능

### 9. 알림 읽음 처리

- **파일**: `gear_freak_flutter/lib/feature/notification/presentation/screen/notification_list_screen.dart`
- **메서드**: `markAsRead()` (라인 232-234)
- **현재 상태**: 중복 방지 없음
- **문제점**: 빠른 연타 시 여러 번 읽음 처리 API 호출 가능

---

## 🟡 중간 우선순위 (10개)

업로드/전송/삭제 작업으로, 중복 실행 시 불필요한 리소스 사용 및 사용자 경험 저하

### 10. 이미지 추가 (상품 등록)

- **파일**: `gear_freak_flutter/lib/feature/product/presentation/screen/create_product_screen.dart`
- **메서드**: `_addImage()` (라인 156-181)
- **현재 상태**: 순차 업로드 중 중복 호출 가능
- **문제점**: 이미지 선택 중 다시 선택 버튼 클릭 시 중복 업로드 가능

### 11. 이미지 추가 (상품 수정)

- **파일**: `gear_freak_flutter/lib/feature/product/presentation/screen/update_product_screen.dart`
- **메서드**: `_addImage()` (라인 234-259)
- **현재 상태**: 순차 업로드 중 중복 호출 가능
- **문제점**: 이미지 선택 중 다시 선택 버튼 클릭 시 중복 업로드 가능

### 12. 프로필 이미지 선택

- **파일**: `gear_freak_flutter/lib/feature/profile/presentation/screen/edit_profile_screen.dart`
- **메서드**: `_pickImage()` (라인 45-132)
- **현재 상태**: 업로드 중 중복 선택 가능
- **문제점**: 이미지 선택 및 업로드 중 다시 선택 시 중복 업로드 가능

### 13. 채팅 메시지 전송

- **파일**: `gear_freak_flutter/lib/feature/chat/presentation/screen/chat_screen.dart`
- **메서드**: `_handleSendPressed()` (라인 83-102)
- **현재 상태**: 중복 방지 없음
- **문제점**: 빠른 연타 시 동일 메시지 여러 번 전송 가능
- **참고**: flutter_chat_ui 라이브러리가 일부 처리할 수도 있지만 확인 필요

### 14. 미디어 업로드 (채팅)

- **파일**: `gear_freak_flutter/lib/feature/chat/presentation/view/chat_loaded_view.dart`
- **메서드**: `_uploadAndSendMedia()` (라인 191-273)
- **현재 상태**: 업로드 중 중복 선택 가능
- **문제점**: 미디어 업로드 중 다시 첨부 버튼 클릭 시 중복 업로드 가능

### 15. 이미지 제거 (상품 등록)

- **파일**: `gear_freak_flutter/lib/feature/product/presentation/screen/create_product_screen.dart`
- **메서드**: `_removeNewImage()` (라인 184-202)
- **현재 상태**: 중복 방지 없음
- **문제점**: 빠른 연타 시 동일 이미지 여러 번 삭제 API 호출 가능

### 16. 이미지 제거 (상품 수정)

- **파일**: `gear_freak_flutter/lib/feature/product/presentation/screen/update_product_screen.dart`
- **메서드**: `_removeNewImage()` (라인 279-298)
- **현재 상태**: 중복 방지 없음
- **문제점**: 빠른 연타 시 동일 이미지 여러 번 삭제 API 호출 가능

### 17. 프로필 이미지 제거

- **파일**: `gear_freak_flutter/lib/feature/profile/presentation/screen/edit_profile_screen.dart`
- **메서드**: `_pickImage()` 내부 (라인 94-123)
- **현재 상태**: 중복 방지 없음
- **문제점**: 이미지 삭제 중 다시 삭제 버튼 클릭 시 중복 삭제 API 호출 가능

### 18. 채팅방 알림 설정 변경

- **파일**: `gear_freak_flutter/lib/feature/chat/presentation/widget/chat_room_item_widget.dart`
- **메서드**: `onPressed` (라인 70-99)
- **현재 상태**: 다이얼로그 확인 있지만, 확인 후 빠른 연타 시 중복 실행 가능
- **문제점**: 다이얼로그 대기 중에도 중복 호출 가능

### 19. 채팅방 나가기

- **파일**: `gear_freak_flutter/lib/feature/chat/presentation/widget/chat_room_item_widget.dart`
- **메서드**: `onPressed` (라인 135-184)
- **현재 상태**: 다이얼로그 확인 있지만, 확인 후 빠른 연타 시 중복 실행 가능
- **문제점**: 다이얼로그 대기 중에도 중복 호출 가능

---

## 🟢 낮은 우선순위 (5개)

UI 액션으로, 중복 실행 시 사용자 경험 저하만 발생 (데이터 무결성 문제는 낮음)

### 20. 찜하기 토글

- **파일**: `gear_freak_flutter/lib/feature/product/presentation/screen/product_detail_screen.dart`
- **메서드**: `toggleFavorite()` (라인 686-692)
- **현재 상태**: 낙관적 업데이트는 있지만 중복 방지 없음
- **문제점**: 빠른 연타 시 여러 번 API 호출 가능 (낙관적 업데이트로 UI는 즉시 반영되지만 서버 요청은 중복)

### 21. 로그아웃

- **파일**: `gear_freak_flutter/lib/feature/profile/presentation/screen/profile_screen.dart`
- **메서드**: `_handleLogout()` (라인 73-105)
- **현재 상태**: 다이얼로그 확인 있지만, 확인 후 빠른 연타 시 중복 실행 가능
- **문제점**: 다이얼로그 대기 중에도 중복 호출 가능

### 22. 소셜 로그인

- **파일**: `gear_freak_flutter/lib/feature/auth/presentation/screen/login_screen.dart`
- **메서드**: 각 로그인 버튼 (라인 115-188)
- **현재 상태**: `isLoading`만 체크
- **문제점**: Provider 상태 변경 전 빠른 연타 시 중복 로그인 시도 가능

### 23. 최근 검색어 삭제

- **파일**: `gear_freak_flutter/lib/feature/search/presentation/screen/search_screen.dart`
- **메서드**: `deleteRecentSearch()` (라인 131-132)
- **현재 상태**: 중복 방지 없음
- **문제점**: 빠른 연타 시 동일 검색어 여러 번 삭제 시도 가능

### 24. 최근 검색어 전체 삭제

- **파일**: `gear_freak_flutter/lib/feature/search/presentation/screen/search_screen.dart`
- **메서드**: `clearAllRecentSearches()` (라인 128-129)
- **현재 상태**: 중복 방지 없음
- **문제점**: 빠른 연타 시 여러 번 전체 삭제 시도 가능

---

## 🎨 적용할 패턴

### 패턴 1: 로컬 플래그 (가장 안전하고 권장)

```dart
class _MyScreenState extends ConsumerState<MyScreen> {
  bool _isSubmitting = false;

  Future<void> _submit() async {
    // 중복 방지 체크
    if (_isSubmitting) return;

    // 플래그 설정
    setState(() {
      _isSubmitting = true;
    });

    try {
      // API 호출
      await ref.read(myNotifierProvider.notifier).doSomething();

      // 성공 처리
      if (mounted) {
        // 성공 피드백
      }
    } catch (e) {
      // 에러 처리
      if (mounted) {
        GbSnackBar.showError(context, '오류가 발생했습니다: $e');
      }
    } finally {
      // 플래그 리셋
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: _isSubmitting ? null : _submit,
      child: _isSubmitting
          ? const CircularProgressIndicator()
          : const Text('제출'),
    );
  }
}
```

### 패턴 2: 다이얼로그 + 플래그 (확인이 필요한 경우)

```dart
class _MyScreenState extends ConsumerState<MyScreen> {
  bool _isDeleting = false;

  Future<void> _handleDelete() async {
    // 중복 방지 체크 (다이얼로그 전에도)
    if (_isDeleting) return;

    // 다이얼로그 표시
    final shouldDelete = await GbDialog.show(
      context: context,
      title: '삭제',
      content: '정말 삭제하시겠습니까?',
      confirmText: '삭제',
      confirmColor: Colors.red,
    );

    // 다이얼로그 취소 또는 중복 방지 재확인
    if (shouldDelete != true || !mounted || _isDeleting) return;

    // 플래그 설정
    setState(() {
      _isDeleting = true;
    });

    try {
      // 삭제 API 호출
      await ref.read(myNotifierProvider.notifier).delete();

      // 성공 처리
      if (mounted) {
        GbSnackBar.showSuccess(context, '삭제되었습니다');
      }
    } catch (e) {
      // 에러 처리
      if (mounted) {
        GbSnackBar.showError(context, '삭제 실패: $e');
      }
    } finally {
      // 플래그 리셋
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }
}
```

### 패턴 3: 업로드 중 플래그 (이미지/미디어 업로드)

```dart
class _MyScreenState extends ConsumerState<MyScreen> {
  bool _isUploading = false;

  Future<void> _addImage(List<XFile> images) async {
    // 중복 방지 체크
    if (_isUploading) {
      GbSnackBar.showWarning(context, '이미지 업로드 중입니다');
      return;
    }

    // 플래그 설정
    setState(() {
      _isUploading = true;
    });

    try {
      final notifier = ref.read(myNotifierProvider.notifier);

      // 순차 업로드
      for (final image in images) {
        await notifier.uploadImage(
          imageFile: File(image.path),
          prefix: 'product',
        );

        // 업로드 성공 시 처리
        final currentState = ref.read(myNotifierProvider);
        if (currentState is UploadSuccess) {
          setState(() {
            _selectedImages.add(image);
          });
        } else if (currentState is UploadError) {
          if (!mounted) return;
          GbSnackBar.showError(
            context,
            '${image.name} 업로드 실패: ${currentState.error}',
          );
          break;
        }
      }
    } finally {
      // 플래그 리셋
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }
}
```

---

## ✅ 체크리스트

각 위치에 다음 사항을 확인하고 적용:

- [ ] 로컬 플래그 변수 추가 (`bool _isSubmitting = false;`)
- [ ] 메서드 시작 부분에 중복 방지 체크 추가 (`if (_isSubmitting) return;`)
- [ ] try-finally 블록으로 플래그 관리
- [ ] mounted 체크 후 플래그 리셋
- [ ] UI에서 플래그 상태에 따라 버튼 비활성화
- [ ] 다이얼로그가 있는 경우, 다이얼로그 전후 모두 중복 방지 체크

---

## 📝 참고사항

### 중복 방지가 불필요한 경우

다음과 같은 경우는 중복 방지가 불필요합니다:

1. **단순 네비게이션**: `context.push()`, `context.go()` 등
2. **읽기 전용 액션**: 데이터 조회, 목록 로드 등
3. **onRefresh, onRetry**: 로딩 상태로 이미 관리됨
4. **이미 구현된 곳**: 리뷰 작성, 페이지네이션 등

### 우선순위별 적용 권장 순서

1. **1단계**: 높은 우선순위 9개 (데이터 무결성 문제)
2. **2단계**: 중간 우선순위 10개 (리소스 사용 및 UX)
3. **3단계**: 낮은 우선순위 5개 (UX 개선)

---

## 🔗 관련 파일

- **이미 구현된 예시**: `write_review_screen.dart` (라인 45-127)
- **페이지네이션 예시**: `pagination_scroll_mixin.dart` (라인 51-52, 93-95)

---

**작성 완료**: 모든 위치 확인 완료, 더 이상 추가 없음 ✅
