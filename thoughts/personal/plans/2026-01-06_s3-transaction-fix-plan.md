# S3 Image Upload Transaction Fix Plan

**날짜**: 2026-01-06
**작업자**: Claude Code (Sonnet 4.5)
**관련 Plan**: `2026-01-06_code-review-improvement-plan.md` (Section 1.6)
**예상 소요 시간**: 20분

---

## 작업 개요

프로필 이미지 업로드 시 기존 이미지를 먼저 삭제하고 새 이미지를 업로드하는 순서로 인해, 업로드 실패 시 기존 이미지까지 손실되는 문제를 수정합니다. 트랜잭션 패턴을 적용하여 새 이미지 업로드 성공 후에만 기존 이미지를 삭제하도록 변경합니다.

---

## 문제 분석

### 현재 상황

**파일**: `lib/feature/profile/presentation/provider/profile_notifier.dart`
**메서드**: `uploadProfileImage` (Line 120-198)

**현재 순서** (잘못됨):
```dart
Future<void> uploadProfileImage(...) async {
  // 1. 기존 이미지 먼저 삭제 ❌
  if (previousUploadedFileKey != null) {
    await deleteImageUseCase(...);  // 삭제됨
  }

  // 2. 새 이미지 업로드
  final result = await uploadImageUseCase(...);

  result.fold(
    (failure) {
      // 3. 업로드 실패! 💥
      // 문제: 기존 이미지는 이미 삭제되어 복구 불가능
      state = ProfileImageUploadError(...);
    },
    (success) {
      state = ProfileImageUploadSuccess(...);
    },
  );
}
```

### 문제 시나리오

#### Scenario 1: 네트워크 오류
```
사용자: 프로필 사진 변경 (현재: cat.jpg)
→ 새 사진 선택: dog.jpg

Step 1: cat.jpg를 S3에서 삭제 ✅
Step 2: dog.jpg 업로드 시작
Step 3: 네트워크 오류 발생 💥
Step 4: 업로드 실패

결과:
- cat.jpg: 삭제됨 (복구 불가)
- dog.jpg: 업로드 안 됨
- 사용자: 프로필 사진 없어짐 😱
```

#### Scenario 2: 서버 오류
```
사용자: 프로필 사진 변경

Step 1: 기존 이미지 삭제 ✅
Step 2: 새 이미지 업로드 → 서버 500 에러 💥

결과: 기존 이미지 손실 + 새 이미지 업로드 실패
```

#### Scenario 3: 파일 크기 초과
```
사용자: 10MB 이미지 선택 (허용: 5MB)

Step 1: 기존 이미지 삭제 ✅
Step 2: 업로드 시도 → 파일 크기 초과 에러 💥

결과: 기존 이미지 손실
```

---

## 해결 방안

### 트랜잭션 패턴 (Transaction Pattern)

**올바른 순서**:
```dart
Future<void> uploadProfileImage(...) async {
  // 1. 새 이미지 먼저 업로드 ✅
  final result = await uploadImageUseCase(...);

  result.fold(
    (failure) {
      // 2-A. 업로드 실패 → 기존 이미지 유지 ✅
      state = ProfileImageUploadError(...);
      // 기존 이미지는 그대로 유지됨
    },
    (success) {
      // 2-B. 업로드 성공 → 기존 이미지 삭제 ✅
      if (previousUploadedFileKey != null) {
        try {
          await deleteImageUseCase(previousUploadedFileKey);
        } catch (e) {
          // 삭제 실패해도 괜찮음 (새 이미지는 이미 업로드됨)
          debugPrint('기존 이미지 삭제 실패 (무시): $e');
        }
      }

      state = ProfileImageUploadSuccess(...);
    },
  );
}
```

### 개선 후 시나리오

#### Scenario 1: 네트워크 오류 (개선됨)
```
사용자: 프로필 사진 변경 (현재: cat.jpg)
→ 새 사진 선택: dog.jpg

Step 1: dog.jpg 업로드 시작
Step 2: 네트워크 오류 발생 💥
Step 3: 업로드 실패 감지

결과:
- cat.jpg: 그대로 유지 ✅
- dog.jpg: 업로드 안 됨
- 사용자: 기존 프로필 사진 유지, "업로드 실패" 메시지만 표시
```

#### Scenario 2: 성공 케이스
```
사용자: 프로필 사진 변경

Step 1: 새 이미지 업로드 성공 ✅
Step 2: 기존 이미지 삭제 ✅

결과: 정상적으로 프로필 사진 변경
```

---

## 수정 상세

### uploadProfileImage 메서드 수정

**파일**: `lib/feature/profile/presentation/provider/profile_notifier.dart`
**라인**: 120-198

**Before** (현재 코드):
```dart
Future<void> uploadProfileImage({
  required XFile imageFile,
  required String bucketType,
  required String prefix,
  String? previousUploadedFileKey,
}) async {
  final currentState = state;

  if (currentState is! ProfileLoaded) return;

  try {
    // ❌ 1. 기존 이미지 먼저 삭제
    if (previousUploadedFileKey != null) {
      try {
        await deleteImageUseCase(
          DeleteImageParams(
            fileKey: previousUploadedFileKey,
            bucketType: bucketType,
          ),
        );
      } catch (e) {
        debugPrint('⚠️ 기존 업로드 파일 S3 삭제 실패 (계속 진행): $e');
      }
    }

    // 2. 파일 정보 가져오기
    final fileName = imageFile.path.split('/').last;
    final fileBytes = await imageFile.readAsBytes();
    final fileSize = fileBytes.length;

    // 3. Content-Type 결정
    var contentType = 'image/jpeg';
    // ...

    // 4. Presigned URL 요청
    final request = pod.GeneratePresignedUploadUrlRequestDto(...);

    // 5. 업로드 시작
    state = ProfileImageUploading(...);

    // 6. UseCase 호출
    final result = await uploadImageUseCase(...);

    result.fold(
      (failure) {
        // ❌ 업로드 실패 시 이전 상태로 복원 불가 (이미 삭제됨)
        state = ProfileImageUploadError(...);
      },
      (response) {
        state = ProfileImageUploadSuccess(...);
      },
    );
  } catch (e) {
    // ❌ 예외 발생 시에도 이전 상태로 복원 불가
    state = ProfileImageUploadError(...);
  }
}
```

**After** (수정 코드):
```dart
Future<void> uploadProfileImage({
  required XFile imageFile,
  required String bucketType,
  required String prefix,
  String? previousUploadedFileKey,
}) async {
  final currentState = state;

  if (currentState is! ProfileLoaded) return;

  try {
    // 1. 파일 정보 가져오기
    final fileName = imageFile.path.split('/').last;
    final fileBytes = await imageFile.readAsBytes();
    final fileSize = fileBytes.length;

    // 2. Content-Type 결정
    var contentType = 'image/jpeg';
    if (fileName.toLowerCase().endsWith('.png')) {
      contentType = 'image/png';
    } else if (fileName.toLowerCase().endsWith('.webp')) {
      contentType = 'image/webp';
    }

    // 3. Presigned URL 요청 DTO 생성
    final request = pod.GeneratePresignedUploadUrlRequestDto(
      fileName: fileName,
      contentType: contentType,
      fileSize: fileSize,
      bucketType: bucketType,
      prefix: prefix,
    );

    // 4. 업로드 시작
    state = ProfileImageUploading(
      user: currentState.user,
      stats: currentState.stats,
      currentFileName: fileName,
    );

    // ✅ 5. 새 이미지 먼저 업로드
    final result = await uploadImageUseCase(
      UploadImageParams(
        request: request,
        fileBytes: fileBytes,
      ),
    );

    result.fold(
      (failure) {
        // ✅ 업로드 실패 → 기존 이미지 유지 (삭제 안 함)
        state = ProfileImageUploadError(
          user: currentState.user,
          stats: currentState.stats,
          error: failure.message,
        );
      },
      (response) {
        // ✅ 6. 업로드 성공 → 이제 기존 이미지 삭제
        if (previousUploadedFileKey != null) {
          // 기존 이미지 삭제는 백그라운드에서 처리 (실패해도 괜찮음)
          unawaited(
            deleteImageUseCase(
              DeleteImageParams(
                fileKey: previousUploadedFileKey,
                bucketType: bucketType,
              ),
            ).then(
              (_) => debugPrint('✅ 기존 이미지 S3 삭제 성공: $previousUploadedFileKey'),
              onError: (e) => debugPrint('⚠️ 기존 이미지 S3 삭제 실패 (무시): $e'),
            ),
          );
        }

        state = ProfileImageUploadSuccess(
          user: currentState.user,
          uploadedFileKey: response.fileKey,
          stats: currentState.stats,
        );
      },
    );
  } catch (e) {
    // ✅ 예외 발생 시에도 기존 이미지 유지
    state = ProfileImageUploadError(
      user: currentState.user,
      stats: currentState.stats,
      error: '이미지 업로드 중 오류가 발생했습니다: $e',
    );
  }
}
```

### 주요 변경 사항

1. **기존 이미지 삭제 위치 변경**
   - Before: 업로드 전 (Line 121-135)
   - After: 업로드 성공 후 (fold의 success 브랜치 내부)

2. **비동기 삭제 처리**
   - `unawaited()` 사용하여 백그라운드에서 삭제
   - 삭제 실패해도 사용자 경험에 영향 없음
   - 로그만 남기고 계속 진행

3. **에러 핸들링 개선**
   - 업로드 실패 시 기존 이미지 유지
   - 명확한 에러 메시지

---

## updateProfile 메서드 확인

**파일**: `lib/feature/profile/presentation/provider/profile_notifier.dart`
**라인**: 328-342

**현재 코드**:
```dart
// 기존 프로필 이미지가 있고, 제거하거나 새 이미지로 교체한 경우
if (existingImageFileKey != null) {
  try {
    await deleteImageUseCase(...);
    debugPrint('✅ 기존 프로필 이미지 S3 삭제 성공');
  } catch (e) {
    // S3 삭제 실패해도 프로필 업데이트는 성공했으므로 계속 진행
    debugPrint('❌ 기존 프로필 이미지 S3 삭제 실패: $e');
  }
}

state = ProfileUpdated(...);
```

**상태**: ✅ 이미 올바른 패턴
- 프로필 업데이트 API 호출 성공 후에 기존 이미지 삭제
- 삭제 실패해도 프로필 업데이트는 성공 상태 유지
- **수정 불필요**

---

## 테스트 시나리오

### 1. 정상 업로드
```
1. 사용자: 새 프로필 사진 선택
2. 앱: 새 이미지 업로드 시작
3. 서버: 업로드 성공
4. 앱: 기존 이미지 S3에서 삭제 (백그라운드)
5. 사용자: 새 프로필 사진으로 변경됨 ✅
```

### 2. 네트워크 오류
```
1. 사용자: 새 프로필 사진 선택
2. 앱: 새 이미지 업로드 시작
3. 네트워크: 연결 끊김 💥
4. 앱: 업로드 실패 감지
5. 결과: 기존 프로필 사진 유지 ✅
6. 사용자: "업로드 실패" 메시지 표시
```

### 3. 파일 크기 초과
```
1. 사용자: 10MB 이미지 선택
2. 앱: 업로드 시도
3. 서버: 파일 크기 초과 에러 반환
4. 결과: 기존 프로필 사진 유지 ✅
5. 사용자: "파일이 너무 큽니다" 메시지
```

### 4. 기존 이미지 삭제 실패 (중요하지 않음)
```
1. 사용자: 새 프로필 사진 선택
2. 앱: 새 이미지 업로드 성공 ✅
3. 앱: 기존 이미지 삭제 시도
4. S3: 삭제 실패 (이미 없거나 권한 문제)
5. 앱: 로그만 남기고 계속 진행
6. 결과: 새 프로필 사진으로 변경됨 ✅
7. 참고: S3에 orphan 파일이 남을 수 있지만 사용자 경험에는 영향 없음
```

---

## S3 Orphan 파일 처리

### 발생 가능한 케이스

업로드는 성공했지만 기존 이미지 삭제가 실패한 경우:
- S3에 사용되지 않는 파일이 남을 수 있음
- 예: `profile/user123_old.jpg` (더 이상 사용 안 함)

### 해결 방안

**Option 1: 무시** (권장)
- 스토리지 비용은 매우 낮음 (GB당 몇 센트)
- 사용자 경험에 영향 없음
- 간단하고 안전함

**Option 2: 정기 정리 (향후 고려)**
- 서버 측 배치 작업으로 orphan 파일 삭제
- 예: 30일 이상 미사용 파일 자동 삭제
- 복잡도 증가, 우선순위 낮음

**권장**: Option 1 (무시)

---

## 예상 효과

### Before (문제 상황)
```
성공률: 95%
실패 시: 기존 이미지 손실 💥
사용자: "내 프로필 사진이 사라졌어요!" 😱
```

### After (수정 후)
```
성공률: 95% (동일)
실패 시: 기존 이미지 유지 ✅
사용자: "업로드 실패했네요. 다시 시도해볼게요." 😊
```

### 구체적 개선

1. **데이터 손실 방지**
   - Before: 업로드 실패 시 기존 이미지 복구 불가능
   - After: 기존 이미지 항상 유지

2. **사용자 경험**
   - Before: 프로필 사진 없어짐 → 다시 업로드 필요
   - After: 기존 프로필 사진 유지 → 재시도만 하면 됨

3. **데이터 무결성**
   - Before: 불완전한 트랜잭션
   - After: 원자적 트랜잭션 (all-or-nothing)

---

## 관련 파일

### 수정 파일 (1개)
- `lib/feature/profile/presentation/provider/profile_notifier.dart`

### 수정 위치
- Line 120-198: `uploadProfileImage` 메서드

### 확인 파일 (수정 불필요)
- Line 328-342: `updateProfile` 메서드 - 이미 올바른 패턴 ✅

---

## 체크리스트

수정 전:
- [ ] 현재 브랜치 확인
- [ ] profile_notifier.dart 백업

수정 중:
- [ ] uploadProfileImage 메서드 수정
  - [ ] 기존 이미지 삭제 코드 제거 (Line 121-135)
  - [ ] fold의 success 브랜치에 삭제 로직 추가
  - [ ] unawaited() 사용
- [ ] updateProfile 메서드 확인 (수정 불필요 확인)
- [ ] 컴파일 에러 확인

수정 후:
- [ ] flutter analyze 실행
- [ ] 프로필 이미지 업로드 테스트
- [ ] 네트워크 오류 시뮬레이션 테스트
- [ ] 커밋 및 implement 파일 작성

---

## 참고 자료

### Transaction Pattern
```dart
// ✅ 올바른 트랜잭션 패턴
async function updateResource() {
  // 1. 새 리소스 생성
  const newResource = await createNew();

  if (newResource.success) {
    // 2. 성공 시에만 기존 리소스 삭제
    await deleteOld();
  }
}

// ❌ 잘못된 패턴
async function updateResource() {
  // 1. 기존 리소스 삭제
  await deleteOld();  // 위험!

  // 2. 새 리소스 생성
  await createNew();  // 실패하면 복구 불가
}
```

### Database Transaction 비유
```sql
-- ✅ 올바른 SQL 트랜잭션
BEGIN TRANSACTION;
  INSERT INTO new_data (...);  -- 1. 새 데이터 추가
  DELETE FROM old_data (...);  -- 2. 성공 시 기존 데이터 삭제
COMMIT;

-- ❌ 잘못된 패턴
BEGIN TRANSACTION;
  DELETE FROM old_data (...);  -- 1. 기존 데이터 삭제
  INSERT INTO new_data (...);  -- 2. 실패하면 데이터 손실
COMMIT;
```

---

## 예상 소요 시간

- 파일 읽기 및 분석: 5분
- 코드 수정: 10분
- 테스트: 3분
- 문서 작성: 2분
- **총 20분**

---

## 커밋 메시지 (제안)

```
fix: prevent data loss in profile image upload

- Upload new image before deleting old image
- Use transaction pattern to ensure data integrity
- Delete old image in background after successful upload
- Ignore old image deletion failures (user experience unchanged)

Before: Delete old image → Upload new image → Upload fails → Data loss
After: Upload new image → Success → Delete old image → Safe

This prevents users from losing their profile picture when upload
fails due to network errors, server errors, or file size issues.

Closes #[ISSUE_NUMBER]
```
