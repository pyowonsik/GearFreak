# 상품 끌어올리기 24시간 쿨다운 구현 계획

**날짜**: 2026-01-13
**기반 문서**: thoughts/shared/research/product_bump_cooldown_implementation_2026-01-13.md
**담당자**: Claude Code
**프로젝트**: Gear Freak - 피트니스 장비 거래 플랫폼

---

## 1. 요구사항 정리

### 1.1 기능 요구사항

**핵심 기능**: 상품 끌어올리기(bump) 기능에 24시간 쿨다운 적용

**현재 문제점**:
- 사용자가 무제한으로 상품을 상단에 올릴 수 있음
- `updatedAt` 필드가 상품 수정과 bump를 구분하지 못함
- 쿨다운 체크 로직이 전혀 없음
- bump 히스토리 추적 불가

**목표**:
- 하루에 1회만 상품을 상단으로 올릴 수 있도록 제한
- 마지막 bump 시간을 정확히 추적
- 사용자 친화적인 에러 메시지 (남은 시간 표시)
- 정렬 로직 개선 (bump한 상품 우선 노출)

### 1.2 비기능 요구사항

**성능**:
- 추가 JOIN 없이 단일 쿼리로 쿨다운 체크
- 인덱스를 통한 정렬 성능 최적화
- 기존 쿼리 성능에 영향 없음

**유지보수성**:
- 단순하고 명확한 구조
- 최소한의 스키마 변경
- 롤백 가능한 마이그레이션

**확장성**:
- 추후 히스토리 추적 기능 추가 가능
- 쿨다운 시간 변경 용이

---

## 2. 기술적 접근

### 2.1 선택한 방법: Option A (Product 테이블에 lastBumpedAt 추가)

**선택 이유**:
1. **단순성**: 별도 테이블 없이 Product 내에서 완결
2. **성능**: JOIN 불필요, 단일 쿼리로 체크 가능
3. **직관성**: 상품 데이터와 함께 관리
4. **유지보수**: 로직이 한 곳에 집중

**대안 (Option B: ProductBump 테이블)**:
- 장점: 히스토리 추적 가능, 분석 용이
- 단점: 복잡도 증가, JOIN 필요, 오버엔지니어링
- 결론: 현재 요구사항에는 과도함. 추후 필요 시 추가 고려

### 2.2 핵심 변경사항

**1. 스키마 변경**:
```yaml
# product.spy.yaml
fields:
  lastBumpedAt: DateTime?  # 마지막 bump 시간 (새로 추가)

indexes:
  last_bumped_at_idx:      # 정렬 성능 최적화용
    fields: lastBumpedAt
```

**2. 쿨다운 로직**:
```dart
// 24시간 쿨다운 체크
if (product.lastBumpedAt != null) {
  final timeSinceLastBump = now.difference(product.lastBumpedAt!);
  if (timeSinceLastBump.inHours < 24) {
    // 남은 시간 계산 및 에러 발생
    throw Exception('Bump cooldown active. Please wait ...');
  }
}
```

**3. 정렬 로직 변경**:
```dart
// 기존: updatedAt 기준
orderBy: (t) => t.updatedAt

// 변경: lastBumpedAt 우선, 없으면 createdAt
orderByList: (t) => [
  Order(column: t.lastBumpedAt, orderDescending: true),
  Order(column: t.createdAt, orderDescending: true),
]
```

### 2.3 타임존 처리

- **서버**: 모든 DateTime을 UTC로 통일 (`DateTime.now().toUtc()`)
- **클라이언트**: 표시 시 로컬 시간으로 변환
- **Serverpod**: 기본적으로 UTC 사용하므로 일관성 유지

---

## 3. 구현 단계

### Phase 1: 백엔드 스키마 및 마이그레이션

**목표**: Product 테이블에 lastBumpedAt 컬럼 추가 및 인덱스 생성

**작업 목록**:
- [ ] `product.spy.yaml` 수정
  - [ ] `lastBumpedAt: DateTime?` 필드 추가 (nullable)
  - [ ] `last_bumped_at_idx` 인덱스 추가
- [ ] `serverpod generate` 실행하여 Dart 코드 생성
- [ ] 마이그레이션 SQL 확인 및 검증
  - [ ] ALTER TABLE 구문 확인
  - [ ] CREATE INDEX 구문 확인
  - [ ] Down migration 확인
- [ ] 개발 환경에서 마이그레이션 테스트
  - [ ] 마이그레이션 적용
  - [ ] 기존 데이터 확인 (lastBumpedAt = null)
  - [ ] 롤백 테스트

**수정 파일**:
- `/gear_freak_server/lib/src/feature/product/model/product.spy.yaml`

**생성 파일**:
- `/gear_freak_server/migrations/YYYYMMDDHHMMSS_add_last_bumped_at.sql`

**예상 SQL**:
```sql
-- Up migration
ALTER TABLE product ADD COLUMN last_bumped_at TIMESTAMP;
CREATE INDEX last_bumped_at_idx ON product (last_bumped_at DESC);
COMMENT ON COLUMN product.last_bumped_at IS '마지막 끌어올리기 시간';

-- Down migration
DROP INDEX IF EXISTS last_bumped_at_idx;
ALTER TABLE product DROP COLUMN IF EXISTS last_bumped_at;
```

**검증 방법**:
- [ ] 마이그레이션 적용 후 `\d product` 실행하여 컬럼 확인
- [ ] 기존 상품의 `lastBumpedAt`이 null인지 확인
- [ ] 인덱스가 생성되었는지 확인

**예상 소요 시간**: 1-2시간

---

### Phase 2: 백엔드 비즈니스 로직 구현

**목표**: bumpProduct 메서드에 24시간 쿨다운 로직 추가

**작업 목록**:
- [ ] `product_service.dart`의 `bumpProduct` 메서드 수정
  - [ ] 쿨다운 체크 로직 추가 (24시간)
  - [ ] 남은 시간 계산 로직 추가 (시간, 분)
  - [ ] 에러 메시지 개선 (남은 시간 포함)
  - [ ] `lastBumpedAt` 갱신 (`updatedAt`은 변경하지 않음)
  - [ ] 로그 추가 (성공/실패 모두)
- [ ] JSDoc 주석 업데이트
  - [ ] 쿨다운 정책 명시
  - [ ] Exception 케이스 문서화

**수정 파일**:
- `/gear_freak_server/lib/src/feature/product/service/product_service.dart`

**상세 구현 내용**:
```dart
Future<Product> bumpProduct(
  Session session,
  int productId,
  int userId,
) async {
  // 1. 기존 상품 조회
  final product = await Product.db.findById(session, productId);
  if (product == null) {
    throw Exception('Product not found');
  }

  // 2. 권한 확인 (판매자만 상단으로 올리기 가능)
  if (product.sellerId != userId) {
    throw Exception('Unauthorized: Only the seller can bump this product');
  }

  // 3. 쿨다운 체크 (24시간)
  if (product.lastBumpedAt != null) {
    final now = DateTime.now().toUtc();
    final timeSinceLastBump = now.difference(product.lastBumpedAt!);

    if (timeSinceLastBump.inHours < 24) {
      // 남은 시간 계산 (분 단위까지)
      final remainingMinutes = (24 * 60) - timeSinceLastBump.inMinutes;
      final remainingHours = remainingMinutes ~/ 60;
      final displayMinutes = remainingMinutes % 60;

      session.log(
        'Bump cooldown failed: productId=$productId, userId=$userId, '
        'remainingTime=${remainingHours}h ${displayMinutes}m',
        level: LogLevel.warning,
      );

      throw Exception(
        'Bump cooldown active. '
        'Please wait ${remainingHours}h ${displayMinutes}m before bumping again.'
      );
    }
  }

  // 4. lastBumpedAt을 현재 시간으로 갱신 (updatedAt은 변경하지 않음)
  final now = DateTime.now().toUtc();
  final updatedProduct = product.copyWith(lastBumpedAt: now);

  await Product.db.updateRow(
    session,
    updatedProduct,
    columns: (t) => [t.lastBumpedAt],  // lastBumpedAt만 갱신
  );

  session.log(
    'Product bumped: productId=$productId, userId=$userId, '
    'lastBumpedAt=$now',
    level: LogLevel.info,
  );

  return updatedProduct;
}
```

**예외 처리**:
- `Exception('Product not found')`: 상품이 존재하지 않음
- `Exception('Unauthorized...')`: 판매자가 아님
- `Exception('Bump cooldown active...')`: 쿨다운 중 (새로 추가)

**검증 방법**:
- [ ] 첫 bump는 즉시 성공
- [ ] 24시간 이내 재시도 시 에러 메시지 확인 (남은 시간 포함)
- [ ] 24시간 후 재시도 성공
- [ ] `updatedAt`은 변경되지 않고 `lastBumpedAt`만 갱신됨
- [ ] 로그가 정상적으로 기록됨

**예상 소요 시간**: 2-3시간

---

### Phase 3: 정렬 로직 수정

**목표**: 상품 목록 정렬을 lastBumpedAt 기준으로 변경

**작업 목록**:
- [ ] `product_list_service.dart`의 정렬 로직 수정
  - [ ] `ProductSortBy.latest` 케이스 수정
  - [ ] `orderByList` 사용 (복합 정렬)
  - [ ] NULLS LAST 처리 확인
- [ ] `ProductSortUtil` 유틸리티 수정 (있는 경우)

**수정 파일**:
- `/gear_freak_server/lib/src/feature/product/service/product_list_service.dart`
- `/gear_freak_server/lib/src/feature/product/util/product_filter_util.dart` (필요 시)

**상세 구현 내용**:

현재 코드:
```dart
Future<List<Product>> _findProductsWithSort(
  Session session, {
  required WhereExpressionBuilder<ProductTable>? where,
  required ProductSortBy sortBy,
  required int limit,
  required int offset,
}) async {
  final orderByAndDesc = ProductSortUtil.getOrderByAndDescending(sortBy);

  // orderBy: (t) => t.updatedAt (기존)
}
```

변경 코드:
```dart
// ProductSortUtil에 새로운 정렬 옵션 추가
class ProductSortUtil {
  static (Column Function(ProductTable), bool) getOrderByAndDescending(
    ProductSortBy sortBy,
  ) {
    switch (sortBy) {
      case ProductSortBy.latest:
        // lastBumpedAt 우선, 없으면 createdAt
        // 단, Serverpod는 단일 orderBy만 지원하므로
        // lastBumpedAt으로 정렬하되 null은 createdAt 사용
        return ((t) => t.lastBumpedAt, true);
      // ... 다른 케이스들
    }
  }
}

// 또는 orderByList 지원하는 경우:
orderByList: (t) => [
  Order(column: t.lastBumpedAt, orderDescending: true),
  Order(column: t.createdAt, orderDescending: true),
]
```

**주의사항**:
- Serverpod가 `orderByList`를 지원하는지 확인 필요
- 지원하지 않으면 SQL 쿼리 직접 작성 고려
- NULLS LAST는 PostgreSQL 기본 동작이지만 명시적으로 지정 권장

**정렬 우선순위**:
1. `lastBumpedAt`이 있는 상품: lastBumpedAt 내림차순
2. `lastBumpedAt`이 null인 상품: createdAt 내림차순

**검증 방법**:
- [ ] 3개 상품 생성 (A: 3일 전, B: 2일 전, C: 1일 전)
- [ ] A를 bump
- [ ] 목록 조회 시 순서: A, C, B
- [ ] B를 bump
- [ ] 목록 조회 시 순서: B, A, C

**예상 소요 시간**: 2-3시간

---

### Phase 4: 프론트엔드 에러 처리 및 UX 개선

**목표**: 쿨다운 에러를 사용자 친화적으로 처리

#### 4.1 Failure 클래스 추가

**작업 목록**:
- [ ] `product_failure.dart`에 `BumpCooldownFailure` 추가
  - [ ] 쿨다운 관련 에러를 별도로 구분
  - [ ] 에러 메시지에 남은 시간 포함

**수정 파일**:
- `/gear_freak_flutter/lib/feature/product/domain/failures/product_failure.dart`

**구현 내용**:
```dart
/// 상품 끌어올리기 쿨다운 실패
class BumpCooldownFailure extends ProductFailure {
  /// BumpCooldownFailure 생성자
  const BumpCooldownFailure(
    super.message, {
    super.exception,
    super.stackTrace,
  });

  @override
  String toString() => 'BumpCooldownFailure: $message';
}
```

#### 4.2 UseCase 에러 처리 개선

**작업 목록**:
- [ ] `bump_product_usecase.dart` 수정
  - [ ] 쿨다운 에러를 `BumpCooldownFailure`로 구분
  - [ ] 에러 메시지 파싱 및 전달

**수정 파일**:
- `/gear_freak_flutter/lib/feature/product/domain/usecase/bump_product_usecase.dart`

**구현 내용**:
```dart
@override
Future<Either<Failure, pod.Product>> call(int productId) async {
  try {
    final product = await repository.bumpProduct(productId);
    return Right(product);
  } on Exception catch (e) {
    // 쿨다운 에러 구분
    final errorMessage = e.toString();
    if (errorMessage.contains('Bump cooldown active')) {
      return Left(
        BumpCooldownFailure(
          errorMessage.replaceAll('Exception: ', ''),
          exception: e,
        ),
      );
    }

    // 일반 에러
    return Left(
      BumpProductFailure(
        '상품을 상단으로 올릴 수 없습니다.',
        exception: e,
      ),
    );
  }
}
```

#### 4.3 Notifier 에러 처리

**작업 목록**:
- [ ] `product_detail_notifier.dart`의 `bumpProduct` 메서드 수정
  - [ ] `BumpCooldownFailure` 구분 처리
  - [ ] 에러 메시지 반환 (UI에서 표시용)

**수정 파일**:
- `/gear_freak_flutter/lib/feature/product/presentation/provider/product_detail_notifier.dart`

**구현 내용**:
```dart
/// 상품 상단으로 올리기 (updatedAt 갱신)
/// 반환값:
/// - null: 성공
/// - String: 실패 (에러 메시지)
Future<String?> bumpProduct(int productId) async {
  final result = await bumpProductUseCase(productId);

  return result.fold(
    (failure) {
      debugPrint('상품 상단으로 올리기 실패: ${failure.message}');

      // 쿨다운 에러인 경우 서버 메시지 그대로 반환
      if (failure is BumpCooldownFailure) {
        return failure.message;
      }

      // 일반 에러
      return '상품을 상단으로 올리는데 실패했습니다';
    },
    (updatedProduct) {
      debugPrint('상품 상단으로 올리기 성공: $productId');
      // 성공 시 상품 정보 업데이트
      final currentState = state;
      if (currentState is ProductDetailLoaded) {
        state = currentState.copyWith(product: updatedProduct);
        // 상품 업데이트 이벤트 발행
        ref.read(updatedProductProvider.notifier).state = updatedProduct;
        Future.microtask(() {
          ref.read(updatedProductProvider.notifier).state = null;
        });
      }
      return null; // 성공
    },
  );
}
```

#### 4.4 Page 사용자 피드백

**작업 목록**:
- [ ] `product_detail_page.dart`의 `_handleBump` 메서드 수정
  - [ ] 쿨다운 사전 체크 (API 호출 전)
  - [ ] 결과에 따른 스낵바 표시
  - [ ] Warning 스낵바 사용 (에러가 아닌 정보성)

**수정 파일**:
- `/gear_freak_flutter/lib/feature/product/presentation/page/product_detail_page.dart`

**구현 내용**:
```dart
/// 상단으로 올리기 처리
Future<void> _handleBump(pod.Product productData) async {
  if (productData.id == null) {
    if (!mounted) return;
    GbSnackBar.showError(context, '상품 ID가 유효하지 않습니다');
    return;
  }

  // 쿨다운 사전 체크 (API 호출 전)
  if (productData.lastBumpedAt != null) {
    final now = DateTime.now().toUtc();
    final timeSinceLastBump = now.difference(productData.lastBumpedAt!);

    if (timeSinceLastBump.inHours < 24) {
      final remainingMinutes = (24 * 60) - timeSinceLastBump.inMinutes;
      final remainingHours = remainingMinutes ~/ 60;
      final displayMinutes = remainingMinutes % 60;

      if (!mounted) return;
      GbSnackBar.showWarning(
        context,
        '상품을 올리려면 ${remainingHours}시간 ${displayMinutes}분 후에 시도하세요',
      );
      return;
    }
  }

  // 상단으로 올리기 API 호출
  final errorMessage = await ref
      .read(productDetailNotifierProvider.notifier)
      .bumpProduct(productData.id!);

  if (!mounted) return;

  if (errorMessage == null) {
    // 성공
    GbSnackBar.showSuccess(context, '상품이 상단으로 올라갔습니다');
  } else {
    // 실패 (쿨다운 또는 일반 에러)
    if (errorMessage.contains('wait') || errorMessage.contains('시간')) {
      // 쿨다운 메시지
      GbSnackBar.showWarning(context, errorMessage);
    } else {
      // 일반 에러
      GbSnackBar.showError(context, errorMessage);
    }
  }
}
```

**개선 사항**:
1. **사전 체크**: API 호출 전에 클라이언트에서 쿨다운 확인
2. **남은 시간 표시**: 사용자가 언제 다시 시도할 수 있는지 명확히 알 수 있음
3. **Warning 스낵바**: 에러가 아닌 정보성 메시지로 부드러운 UX

**검증 방법**:
- [ ] 첫 bump 시 "상품이 상단으로 올라갔습니다" 성공 메시지
- [ ] 10분 후 재시도 시 "23시간 50분 후에 시도하세요" 경고 메시지
- [ ] 24시간 후 재시도 시 성공 메시지
- [ ] 다른 사용자의 상품 bump 시 권한 에러

**예상 소요 시간**: 3-4시간

---

### Phase 5 (선택): UI/UX 고급 개선

**목표**: 버튼 상태 표시 및 실시간 카운트다운

**우선순위**: Medium (필수는 아니지만 권장)

#### 5.1 버튼 비활성화 + 남은 시간 표시

**작업 목록**:
- [ ] `product_detail_loaded_view.dart` 수정
  - [ ] 쿨다운 체크 헬퍼 메서드 추가
  - [ ] 남은 시간 계산 메서드 추가
  - [ ] 버튼 텍스트 및 활성화 상태 동적 변경

**수정 파일**:
- `/gear_freak_flutter/lib/feature/product/presentation/view/product_detail_loaded_view.dart`

**구현 내용**:
```dart
Widget _buildBumpButton(pod.Product product) {
  final canBump = _canBumpProduct(product);
  final remainingTime = _getRemainingCooldownTime(product);

  return ElevatedButton(
    onPressed: canBump ? () => _handleBump(product) : null,
    child: Text(
      canBump
        ? '상단으로 올리기'
        : '쿨다운 중 ($remainingTime)'
    ),
  );
}

bool _canBumpProduct(pod.Product product) {
  if (product.lastBumpedAt == null) return true;

  final timeSinceLastBump = DateTime.now()
    .toUtc()
    .difference(product.lastBumpedAt!);

  return timeSinceLastBump.inHours >= 24;
}

String _getRemainingCooldownTime(pod.Product product) {
  if (product.lastBumpedAt == null) return '';

  final remainingMinutes = (24 * 60) -
    DateTime.now().toUtc().difference(product.lastBumpedAt!).inMinutes;

  if (remainingMinutes <= 0) return '';

  final hours = remainingMinutes ~/ 60;
  final minutes = remainingMinutes % 60;

  return '${hours}시간 ${minutes}분 남음';
}
```

#### 5.2 실시간 카운트다운 (옵션)

**작업 목록**:
- [ ] StatefulWidget으로 분리
- [ ] Timer를 사용한 1분마다 갱신
- [ ] dispose에서 Timer 정리

**구현 내용**:
```dart
class _BumpButton extends StatefulWidget {
  const _BumpButton({required this.product, required this.onPressed});

  final pod.Product product;
  final VoidCallback onPressed;

  @override
  State<_BumpButton> createState() => _BumpButtonState();
}

class _BumpButtonState extends State<_BumpButton> {
  Timer? _countdownTimer;
  String _remainingTime = '';

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _updateRemainingTime();
    _countdownTimer = Timer.periodic(
      const Duration(minutes: 1),
      (_) {
        if (!mounted) return;
        setState(() {
          _updateRemainingTime();
        });
      },
    );
  }

  void _updateRemainingTime() {
    _remainingTime = _getRemainingCooldownTime(widget.product);
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canBump = _canBumpProduct(widget.product);

    return ElevatedButton(
      onPressed: canBump ? widget.onPressed : null,
      child: Text(
        canBump
          ? '상단으로 올리기'
          : '쿨다운 중 ($_remainingTime)'
      ),
    );
  }

  // _canBumpProduct, _getRemainingCooldownTime 메서드
}
```

**권장**: 옵션 1 (버튼 비활성화)만으로도 충분. 실시간 카운트다운은 UX 개선이 크지 않고 복잡도만 증가.

**검증 방법**:
- [ ] 쿨다운 중일 때 버튼이 비활성화됨
- [ ] 버튼 텍스트에 남은 시간 표시
- [ ] 24시간 경과 후 버튼이 활성화됨
- [ ] (실시간 타이머) 1분마다 자동으로 시간 갱신

**예상 소요 시간**: 2-3시간

---

### Phase 6: 테스트

**목표**: 모든 시나리오에 대한 테스트 작성 및 검증

#### 6.1 백엔드 단위 테스트

**작업 목록**:
- [ ] `product_service_test.dart` 작성
  - [ ] 첫 bump는 즉시 성공
  - [ ] 24시간 이내 재시도는 실패
  - [ ] 24시간 후 재시도는 성공
  - [ ] 다른 사용자는 bump 불가
  - [ ] lastBumpedAt이 올바르게 갱신됨
  - [ ] updatedAt은 변경되지 않음

**생성 파일**:
- `/gear_freak_server/test/feature/product/service/product_service_test.dart`

**테스트 케이스**:
```dart
group('bumpProduct', () {
  test('첫 bump는 즉시 성공', () async {
    // Given: lastBumpedAt = null인 상품
    final product = await createTestProduct(lastBumpedAt: null);

    // When: bump 시도
    final result = await productService.bumpProduct(
      session,
      product.id!,
      sellerId,
    );

    // Then: 성공, lastBumpedAt 설정됨
    expect(result.lastBumpedAt, isNotNull);
    expect(result.updatedAt, product.updatedAt); // updatedAt 변경 없음
  });

  test('24시간 이내 재시도는 실패', () async {
    // Given: 1시간 전에 bump한 상품
    final lastBump = DateTime.now().toUtc().subtract(Duration(hours: 1));
    final product = await createTestProduct(lastBumpedAt: lastBump);

    // When: bump 시도
    // Then: Exception 발생
    expect(
      () => productService.bumpProduct(session, product.id!, sellerId),
      throwsA(isA<Exception>().having(
        (e) => e.toString(),
        'message',
        contains('Bump cooldown active'),
      )),
    );
  });

  test('정확히 24시간 후 재시도는 성공', () async {
    // Given: 24시간 전에 bump한 상품
    final lastBump = DateTime.now().toUtc().subtract(Duration(hours: 24));
    final product = await createTestProduct(lastBumpedAt: lastBump);

    // When: bump 시도
    final result = await productService.bumpProduct(
      session,
      product.id!,
      sellerId,
    );

    // Then: 성공, lastBumpedAt 갱신됨
    expect(result.lastBumpedAt!.isAfter(lastBump), isTrue);
  });

  test('25시간 후 재시도는 성공', () async {
    // Given: 25시간 전에 bump한 상품
    final lastBump = DateTime.now().toUtc().subtract(Duration(hours: 25));
    final product = await createTestProduct(lastBumpedAt: lastBump);

    // When: bump 시도
    final result = await productService.bumpProduct(
      session,
      product.id!,
      sellerId,
    );

    // Then: 성공
    expect(result.lastBumpedAt!.isAfter(lastBump), isTrue);
  });

  test('다른 사용자는 bump 불가', () async {
    // Given: 다른 판매자의 상품
    final product = await createTestProduct(sellerId: otherUserId);

    // When: bump 시도 (권한 없음)
    // Then: Unauthorized Exception
    expect(
      () => productService.bumpProduct(session, product.id!, currentUserId),
      throwsA(isA<Exception>().having(
        (e) => e.toString(),
        'message',
        contains('Unauthorized'),
      )),
    );
  });

  test('에러 메시지에 남은 시간 포함', () async {
    // Given: 2시간 전에 bump한 상품
    final lastBump = DateTime.now().toUtc().subtract(Duration(hours: 2));
    final product = await createTestProduct(lastBumpedAt: lastBump);

    // When & Then: 에러 메시지에 "22h"가 포함됨
    expect(
      () => productService.bumpProduct(session, product.id!, sellerId),
      throwsA(isA<Exception>().having(
        (e) => e.toString(),
        'message',
        allOf([
          contains('Bump cooldown active'),
          contains('22h'),
        ]),
      )),
    );
  });
});
```

#### 6.2 통합 테스트 (정렬 검증)

**작업 목록**:
- [ ] `product_list_service_test.dart` 작성
  - [ ] bump한 상품이 최상단에 노출됨
  - [ ] bump하지 않은 상품은 생성일 순
  - [ ] 여러 상품을 bump한 경우 최근 bump 순

**테스트 케이스**:
```dart
test('bump 후 상품 목록에서 최상단 노출', () async {
  // Given: 3개의 상품 (A: 3일 전, B: 2일 전, C: 1일 전 생성)
  final productA = await createTestProduct(
    createdAt: DateTime.now().subtract(Duration(days: 3)),
  );
  final productB = await createTestProduct(
    createdAt: DateTime.now().subtract(Duration(days: 2)),
  );
  final productC = await createTestProduct(
    createdAt: DateTime.now().subtract(Duration(days: 1)),
  );

  // When: A를 bump
  await productService.bumpProduct(session, productA.id!, sellerId);

  // Then: 상품 목록 정렬 순서 = A (bumped), C (latest), B (oldest)
  final products = await productListService.getPaginatedProducts(
    session,
    PaginationDto(
      page: 1,
      limit: 10,
      sortBy: ProductSortBy.latest,
    ),
  );

  expect(products.products[0].id, productA.id);
  expect(products.products[1].id, productC.id);
  expect(products.products[2].id, productB.id);
});

test('여러 상품 bump 시 최근 bump 순', () async {
  // Given: 3개 상품 생성
  final productA = await createTestProduct();
  final productB = await createTestProduct();
  final productC = await createTestProduct();

  // When: A, B를 순서대로 bump (1분 간격)
  await productService.bumpProduct(session, productA.id!, sellerId);
  await Future.delayed(Duration(minutes: 1));
  await productService.bumpProduct(session, productB.id!, sellerId);

  // Then: 정렬 순서 = B (최근 bump), A (이전 bump), C (bump 안 함)
  final products = await productListService.getPaginatedProducts(
    session,
    PaginationDto(page: 1, limit: 10, sortBy: ProductSortBy.latest),
  );

  expect(products.products[0].id, productB.id);
  expect(products.products[1].id, productA.id);
  expect(products.products[2].id, productC.id);
});
```

#### 6.3 수동 테스트 시나리오

**시나리오 1: 정상 흐름**
1. [ ] 상품 등록
2. [ ] "상단으로 올리기" 버튼 클릭
3. [ ] 성공 메시지 확인: "상품이 상단으로 올라갔습니다"
4. [ ] 10분 후 재시도
5. [ ] 경고 메시지 확인: "23시간 50분 후에 시도하세요"
6. [ ] 24시간 후 재시도
7. [ ] 성공 메시지 확인

**시나리오 2: 권한 확인**
1. [ ] 사용자 A가 상품 등록
2. [ ] 사용자 B가 해당 상품 상세 페이지 접근
3. [ ] "상단으로 올리기" 버튼이 보이지 않음 (판매자만 표시)

**시나리오 3: 정렬 확인**
1. [ ] 3개 상품 등록 (A, B, C)
2. [ ] 상품 목록에서 순서 확인: C, B, A (최신순)
3. [ ] A를 bump
4. [ ] 상품 목록 새로고침
5. [ ] 순서 확인: A, C, B

**시나리오 4: 엣지 케이스**
1. [ ] 상품 bump
2. [ ] 23시간 후 상품 정보 수정 (가격 변경)
3. [ ] 1시간 후 bump 시도
4. [ ] 성공 확인 (수정은 쿨다운에 영향 없음)

**예상 소요 시간**: 3-4시간

---

## 4. 리스크 및 대응

### 4.1 기존 데이터 처리

**리스크**: 이미 존재하는 상품들의 `lastBumpedAt`이 null

**대응**:
- **선택 A (권장)**: null 유지
  - 기존 상품들도 첫 bump는 즉시 가능
  - 새 상품과 동일한 규칙 적용
  - 공정하고 단순함
- **선택 B**: `createdAt`으로 초기화
  - 기존 사용자에게 불리 (즉시 bump 불가)
  - 복잡한 마이그레이션 필요
  - **비권장**

**결론**: 선택 A 채택

### 4.2 정렬 로직 변경으로 인한 UX 변화

**리스크**: 사용자들이 예상과 다른 정렬 순서에 혼란

**영향**:
- bump한 상품이 상단에 노출 (의도된 동작)
- bump 안 한 상품은 생성일 순 (기존과 유사)
- `updatedAt`은 수정 시간만 표시 (더 명확)

**대응**:
- UI에 bump 시간 표시 고려 (Phase 5)
- 사용자 가이드 제공 (선택사항)
- 점진적 배포로 모니터링

**평가**: 큰 리스크 아님. 오히려 UX 개선

### 4.3 타임존 문제

**리스크**: 서버와 클라이언트의 시간대 불일치

**대응**:
- 서버: 모든 DateTime을 UTC로 통일
- 클라이언트: 표시 시 로컬 시간으로 변환
- Serverpod: 기본적으로 UTC 사용

**검증**:
- 다양한 타임존에서 테스트
- 정확히 24시간 체크 확인

### 4.4 Serverpod orderByList 지원 여부

**리스크**: Serverpod가 복합 정렬을 지원하지 않을 수 있음

**대응 방법**:
1. **방법 A**: `orderByList` 사용 (지원하는 경우)
   ```dart
   orderByList: (t) => [
     Order(column: t.lastBumpedAt, orderDescending: true),
     Order(column: t.createdAt, orderDescending: true),
   ]
   ```

2. **방법 B**: SQL 직접 작성 (지원하지 않는 경우)
   ```dart
   final products = await session.db.query(
     '''
     SELECT * FROM product
     ORDER BY
       last_bumped_at DESC NULLS LAST,
       created_at DESC
     LIMIT $limit OFFSET $offset
     ''',
   );
   ```

3. **방법 C**: COALESCE 사용
   ```sql
   ORDER BY COALESCE(last_bumped_at, created_at) DESC
   ```
   단, 이 방법은 lastBumpedAt과 createdAt을 완전히 동등하게 취급하므로 의도와 다를 수 있음

**조사 필요**: Phase 3 시작 전 Serverpod 문서 확인

### 4.5 롤백 전략

**리스크**: 배포 후 예상치 못한 문제 발생

**롤백 계획**:
1. **코드 롤백** (즉시):
   - 이전 버전으로 배포
   - `lastBumpedAt` 필드는 무시 (에러 발생 안 함)
2. **DB 롤백** (보류):
   - `lastBumpedAt` 컬럼은 유지 (데이터 손실 방지)
   - 추후 문제 해결 후 재배포 가능
3. **완전 롤백** (최후의 수단):
   ```sql
   DROP INDEX IF EXISTS last_bumped_at_idx;
   ALTER TABLE product DROP COLUMN IF EXISTS last_bumped_at;
   ```
   - 주의: bump 히스토리 손실 (복구 불가)

**모니터링**:
- bump 성공/실패 카운트
- 쿨다운 실패 빈도
- 정렬 쿼리 성능

---

## 5. 전체 검증 계획

### 5.1 기능 검증

**쿨다운 로직**:
- [ ] 첫 bump는 즉시 성공
- [ ] 1시간 후 재시도 실패 (23h 남음)
- [ ] 12시간 후 재시도 실패 (12h 남음)
- [ ] 24시간 후 재시도 성공
- [ ] 25시간 후 재시도 성공

**권한 검증**:
- [ ] 판매자만 bump 가능
- [ ] 다른 사용자는 버튼 미표시 (UI)
- [ ] 다른 사용자는 API 호출 실패 (권한 에러)

**정렬 검증**:
- [ ] bump한 상품이 최상단
- [ ] 여러 상품 bump 시 최근 순
- [ ] bump 안 한 상품은 생성일 순

**에러 메시지**:
- [ ] 쿨다운 메시지에 남은 시간 포함
- [ ] 클라이언트 사전 체크 메시지
- [ ] 서버 에러 메시지

### 5.2 성능 검증

**쿼리 성능**:
- [ ] 상품 목록 조회 시간 측정 (1000개 상품 기준)
- [ ] 인덱스 사용 확인 (EXPLAIN ANALYZE)
- [ ] bump API 응답 시간 (<200ms)

**부하 테스트**:
- [ ] 100명 동시 bump 시도
- [ ] 1000명 동시 목록 조회
- [ ] 메모리 사용량 모니터링

### 5.3 호환성 검증

**타임존**:
- [ ] UTC+9 (한국)에서 테스트
- [ ] UTC+0 (런던)에서 테스트
- [ ] UTC-8 (LA)에서 테스트

**플랫폼**:
- [ ] Android에서 테스트
- [ ] iOS에서 테스트
- [ ] Web에서 테스트 (선택)

### 5.4 회귀 테스트

**기존 기능 검증**:
- [ ] 상품 생성 정상 동작
- [ ] 상품 수정 정상 동작
- [ ] 상품 삭제 정상 동작
- [ ] 상품 목록 조회 정상 동작
- [ ] 상품 상세 조회 정상 동작
- [ ] 찜 토글 정상 동작

---

## 6. 배포 계획

### 6.1 배포 순서

1. **개발 환경 배포** (1일차)
   - [ ] 백엔드 마이그레이션 적용
   - [ ] 백엔드 코드 배포
   - [ ] 프론트엔드 코드 배포
   - [ ] 기능 테스트 수행

2. **스테이징 환경 배포** (2일차)
   - [ ] 운영 데이터 복사본으로 테스트
   - [ ] 성능 테스트
   - [ ] 부하 테스트
   - [ ] 회귀 테스트

3. **운영 환경 배포** (3일차)
   - [ ] 백엔드 마이그레이션 적용 (점검 시간 활용)
   - [ ] 백엔드 배포
   - [ ] 프론트엔드 배포
   - [ ] 스모크 테스트
   - [ ] 모니터링 24시간

### 6.2 롤백 기준

다음 상황 시 즉시 롤백:
- [ ] bump API 응답 시간 > 1초
- [ ] 상품 목록 조회 성능 50% 이상 저하
- [ ] 쿨다운 체크 실패율 > 10%
- [ ] 치명적 버그 발견 (데이터 손실, 크래시 등)

### 6.3 모니터링 지표

**성능 지표**:
- bump API 평균 응답 시간
- 상품 목록 조회 평균 응답 시간
- DB 쿼리 실행 시간

**비즈니스 지표**:
- 일일 bump 시도 횟수
- 쿨다운 실패 횟수
- bump 성공률

**에러 지표**:
- 쿨다운 에러 발생 빈도
- 권한 에러 발생 빈도
- 예상치 못한 에러

---

## 7. 예상 개발 시간

### Phase별 소요 시간

| Phase | 작업 내용 | 예상 시간 | 우선순위 |
|-------|----------|----------|---------|
| Phase 1 | 백엔드 스키마 및 마이그레이션 | 1-2시간 | 필수 |
| Phase 2 | 백엔드 비즈니스 로직 구현 | 2-3시간 | 필수 |
| Phase 3 | 정렬 로직 수정 | 2-3시간 | 필수 |
| Phase 4 | 프론트엔드 에러 처리 및 UX | 3-4시간 | 필수 |
| Phase 5 | UI/UX 고급 개선 | 2-3시간 | 권장 |
| Phase 6 | 테스트 | 3-4시간 | 필수 |
| **합계 (필수)** | | **11-16시간** | |
| **합계 (권장 포함)** | | **13-19시간** | |

### 일정 계획 (2-3일)

**1일차** (6-8시간):
- Phase 1: 스키마 변경 (1-2h)
- Phase 2: 백엔드 로직 (2-3h)
- Phase 3: 정렬 로직 (2-3h)

**2일차** (5-7시간):
- Phase 4: 프론트엔드 에러 처리 (3-4h)
- Phase 5: UI/UX 개선 (2-3h, 선택)

**3일차** (3-4시간):
- Phase 6: 테스트 (3-4h)
- 배포 준비

---

## 8. 체크리스트

### 시작 전 확인사항
- [ ] 연구 문서 숙지 완료
- [ ] 개발 환경 준비 완료 (DB, 서버, 클라이언트)
- [ ] git 브랜치 생성: `feature/product-bump-cooldown`
- [ ] 백업 생성: 현재 DB 스냅샷

### Phase 완료 체크
- [ ] Phase 1 완료 (스키마 변경)
- [ ] Phase 2 완료 (백엔드 로직)
- [ ] Phase 3 완료 (정렬 로직)
- [ ] Phase 4 완료 (프론트엔드 에러 처리)
- [ ] Phase 5 완료 (UI/UX 개선, 선택)
- [ ] Phase 6 완료 (테스트)

### 최종 배포 전 확인
- [ ] 모든 테스트 통과
- [ ] 코드 리뷰 완료
- [ ] 문서 업데이트 (API 문서, README)
- [ ] 롤백 계획 수립
- [ ] 모니터링 대시보드 준비
- [ ] 배포 공지 (내부 팀)

---

## 9. 참고 자료

### 관련 파일 목록

**백엔드**:
- `/gear_freak_server/lib/src/feature/product/model/product.spy.yaml`
- `/gear_freak_server/lib/src/feature/product/service/product_service.dart`
- `/gear_freak_server/lib/src/feature/product/service/product_list_service.dart`
- `/gear_freak_server/lib/src/feature/product/endpoint/product_endpoint.dart`

**프론트엔드**:
- `/gear_freak_flutter/lib/feature/product/domain/usecase/bump_product_usecase.dart`
- `/gear_freak_flutter/lib/feature/product/domain/failures/product_failure.dart`
- `/gear_freak_flutter/lib/feature/product/presentation/provider/product_detail_notifier.dart`
- `/gear_freak_flutter/lib/feature/product/presentation/page/product_detail_page.dart`
- `/gear_freak_flutter/lib/feature/product/presentation/view/product_detail_loaded_view.dart`

### 유사 패턴 참고
- **ProductView**: 조회수 중복 방지 (별도 테이블 + Unique Index)
- **Favorite**: 찜 토글 (별도 테이블로 관리)
- 차이점: bump는 히스토리보다 최신 상태가 중요하므로 Product 테이블 내 필드로 충분

### 연구 문서
- `/gear_freak_server/thoughts/shared/research/product_bump_cooldown_implementation_2026-01-13.md`

---

## 10. 다음 단계

이 계획서가 승인되면:

1. **즉시 시작**: Phase 1 (스키마 변경)
2. **일일 보고**: 각 Phase 완료 시 진행 상황 공유
3. **블로커 보고**: 예상치 못한 문제 발생 시 즉시 알림

---

## 11. 결론

상품 끌어올리기 24시간 쿨다운은 **Product 테이블에 lastBumpedAt 컬럼을 추가**하는 방식으로 구현합니다.

**핵심 장점**:
- **단순하면서도 효과적**: 최소한의 변경으로 요구사항 충족
- **성능 저하 없음**: JOIN 불필요, 인덱스를 통한 최적화
- **확장 가능**: 추후 히스토리 추적 기능 추가 용이
- **테스트 용이**: 명확한 로직, 단위 테스트 가능

**예상 효과**:
1. 무분별한 bump 방지로 공정한 노출 기회 제공
2. 사용자 친화적인 에러 메시지로 UX 개선
3. bump한 상품 우선 노출로 활발한 거래 촉진
4. 정렬 로직 개선으로 더 직관적인 목록 제공

**리스크 평가**: Low
- 기존 기능에 영향 없음
- 롤백 가능
- 단계별 테스트로 안정성 확보

이 계획서를 바탕으로 Phase별로 구현을 진행하면 2-3일 내에 안정적으로 기능을 완성할 수 있습니다.

---

**문서 종료**
