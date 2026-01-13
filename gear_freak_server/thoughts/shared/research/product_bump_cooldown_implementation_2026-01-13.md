# 상품 끌어올리기 24시간 쿨다운 구현 연구

**연구일**: 2026-01-13
**연구자**: Claude Code
**프로젝트**: Gear Freak - 피트니스 장비 거래 플랫폼

## 연구 목표

현재 무제한으로 가능한 상품 끌어올리기(bump) 기능에 24시간 쿨다운을 구현하여, 사용자가 하루에 1회만 상품을 상단으로 올릴 수 있도록 제한합니다.

---

## 1. 현재 구조 분석

### 1.1 Product 스키마 현황

**파일**: `/gear_freak_server/lib/src/feature/product/model/product.spy.yaml`

```yaml
class: Product
table: product

fields:
  seller: User?, relation
  title: String
  category: ProductCategory
  price: int
  condition: ProductCondition
  description: String
  tradeMethod: TradeMethod
  baseAddress: String?
  detailAddress: String?
  imageUrls: List<String>?
  viewCount: int?
  favoriteCount: int?
  chatCount: int?
  createdAt: DateTime?
  updatedAt: DateTime?      # 현재 bump 시 갱신됨
  status: ProductStatus?
```

**주요 발견**:
- `lastBumpedAt` 필드가 **없음**
- `updatedAt`이 상품 수정과 bump 모두에 사용됨 (문제점)
- bump 전용 타임스탬프 필드 필요

### 1.2 현재 BumpProduct 로직

**파일**: `/gear_freak_server/lib/src/feature/product/service/product_service.dart`

```dart
Future<Product> bumpProduct(
  Session session,
  int productId,
  int userId,
) async {
  // 1. 상품 조회
  final product = await Product.db.findById(session, productId);
  if (product == null) {
    throw Exception('Product not found');
  }

  // 2. 권한 확인 (판매자만 가능)
  if (product.sellerId != userId) {
    throw Exception('Unauthorized: Only the seller can bump this product');
  }

  // 3. updatedAt을 현재 시간으로 갱신 (쿨다운 체크 없음)
  final now = DateTime.now().toUtc();
  final updatedProduct = product.copyWith(updatedAt: now);

  await Product.db.updateRow(
    session,
    updatedProduct,
    columns: (t) => [t.updatedAt],
  );

  return updatedProduct;
}
```

**문제점**:
1. **쿨다운 체크 없음**: 무제한 bump 가능
2. **updatedAt 오용**: 상품 수정과 bump를 구분할 수 없음
3. **히스토리 부재**: bump 이력 추적 불가

### 1.3 유사 패턴: ProductView (조회수 중복 방지)

**파일**: `/gear_freak_server/lib/src/feature/product/model/product_view.spy.yaml`

```yaml
class: ProductView
table: product_view

fields:
  user: User?, relation
  product: Product?, relation
  viewedAt: DateTime?

indexes:
  product_view_user_product_unique_idx:
    fields: userId, productId
    unique: true    # userId + productId 조합으로 중복 방지
```

**구현 로직** (`product_interaction_service.dart`):
```dart
Future<bool> incrementViewCount(
  Session session,
  int userId,
  int productId,
) async {
  // 기존 조회 기록 확인
  final existingView = await ProductView.db.findFirstRow(
    session,
    where: (v) => v.userId.equals(userId) & v.productId.equals(productId),
  );

  if (existingView != null) {
    return false;  // 이미 조회함, 증가하지 않음
  }

  // 조회 기록 추가
  final productView = ProductView(
    userId: userId,
    productId: productId,
    viewedAt: DateTime.now().toUtc(),
  );
  await ProductView.db.insertRow(session, productView);

  // viewCount 증가
  final currentCount = product.viewCount ?? 0;
  await Product.db.updateRow(
    session,
    product.copyWith(viewCount: currentCount + 1),
    columns: (t) => [t.viewCount],
  );

  return true;
}
```

**패턴 분석**:
- **별도 테이블** (ProductView)로 중복 방지
- **Unique Index** (userId + productId)로 무결성 보장
- **타임스탬프** (viewedAt)로 시간 기록
- 단, ProductView는 영구 기록 (쿨다운과는 다름)

---

## 2. 구현 방안 비교

### Option A: Product 테이블에 lastBumpedAt 컬럼 추가 ⭐ **권장**

#### 장점
1. **단순성**: 추가 테이블 없이 Product 내에서 완결
2. **성능**: JOIN 불필요, 단일 쿼리로 체크 가능
3. **직관성**: Product 데이터와 함께 관리
4. **유지보수**: 로직이 한 곳에 집중

#### 단점
1. **스키마 변경**: DB 마이그레이션 필요
2. **히스토리 부재**: 이전 bump 기록 추적 불가 (현재 시점만 저장)

#### 구현 방법

**1단계: product.spy.yaml 수정**
```yaml
fields:
  # ... 기존 필드들
  createdAt: DateTime?
  updatedAt: DateTime?      # 상품 수정 시만 갱신
  lastBumpedAt: DateTime?   # 마지막 bump 시간 (새로 추가)
  status: ProductStatus?

indexes:
  # ... 기존 인덱스들
  last_bumped_at_idx:
    fields: lastBumpedAt    # bump 시간 정렬용
```

**2단계: serverpod generate 실행**
```bash
cd gear_freak_server
serverpod generate
```

**3단계: bumpProduct 메서드 수정**
```dart
Future<Product> bumpProduct(
  Session session,
  int productId,
  int userId,
) async {
  // 1. 상품 조회
  final product = await Product.db.findById(session, productId);
  if (product == null) {
    throw Exception('Product not found');
  }

  // 2. 권한 확인
  if (product.sellerId != userId) {
    throw Exception('Unauthorized: Only the seller can bump this product');
  }

  // 3. 쿨다운 체크 (24시간)
  if (product.lastBumpedAt != null) {
    final now = DateTime.now().toUtc();
    final timeSinceLastBump = now.difference(product.lastBumpedAt!);

    if (timeSinceLastBump.inHours < 24) {
      final remainingHours = 24 - timeSinceLastBump.inHours;
      final remainingMinutes = (24 * 60) - timeSinceLastBump.inMinutes;
      final displayMinutes = remainingMinutes % 60;

      throw Exception(
        'Bump cooldown active. '
        'Please wait ${remainingHours}h ${displayMinutes}m before bumping again.'
      );
    }
  }

  // 4. lastBumpedAt 갱신 (updatedAt은 변경하지 않음)
  final now = DateTime.now().toUtc();
  final updatedProduct = product.copyWith(lastBumpedAt: now);

  await Product.db.updateRow(
    session,
    updatedProduct,
    columns: (t) => [t.lastBumpedAt],
  );

  return updatedProduct;
}
```

**4단계: 정렬 로직 수정** (`product_list_service.dart`)
```dart
// 기존: updatedAt 기준 정렬
orderBy: (t) => t.updatedAt,

// 변경: lastBumpedAt 우선, 없으면 createdAt
orderByList: (t) => [
  Order(
    column: t.lastBumpedAt,
    orderDescending: true
  ),
  Order(
    column: t.createdAt,
    orderDescending: true
  ),
],
```

---

### Option B: 별도 ProductBump 테이블 생성

#### 장점
1. **히스토리 추적**: 모든 bump 기록 저장 가능
2. **분석 가능**: bump 패턴 분석, 통계 산출
3. **Product 테이블 불변**: 기존 스키마 유지

#### 단점
1. **복잡도 증가**: 추가 테이블 관리
2. **JOIN 필요**: 쿨다운 체크 시 성능 저하 가능
3. **오버엔지니어링**: 현재 요구사항에 과도

#### 구조 설계 (참고용)
```yaml
class: ProductBump
table: product_bump

fields:
  user: User?, relation
  product: Product?, relation
  bumpedAt: DateTime?

indexes:
  product_bump_product_idx:
    fields: productId, bumpedAt
```

#### 쿨다운 체크 로직
```dart
// 최근 24시간 내 bump 기록 조회
final recentBump = await ProductBump.db.findFirstRow(
  session,
  where: (b) =>
    b.productId.equals(productId) &
    b.bumpedAt.after(DateTime.now().subtract(Duration(hours: 24))),
  orderBy: (b) => b.bumpedAt,
  orderDescending: true,
);

if (recentBump != null) {
  throw Exception('Cooldown active');
}
```

**평가**: 현재 요구사항에는 과도함. 추후 분석 필요 시 고려.

---

### Option C: updatedAt 활용 (비권장)

#### 현재 상태
- `updatedAt`은 상품 수정 시에도 갱신됨
- Bump와 수정을 구분할 수 없음

#### 문제점
```dart
// 시나리오:
// 1. 상품 bump → updatedAt 갱신 (OK)
// 2. 23시간 후 가격 수정 → updatedAt 갱신
// 3. 1시간 후 bump 시도 → 24시간 지났으므로 허용 (버그!)

// updatedAt으로는 마지막 bump 시간을 정확히 알 수 없음
```

**결론**: 이 옵션은 **부적합**. 전용 필드 필요.

---

## 3. 권장 구현 방법 (Option A)

### 3.1 전체 구현 단계

#### Phase 1: 백엔드 스키마 변경

**파일 목록**:
1. `/gear_freak_server/lib/src/feature/product/model/product.spy.yaml`
2. 생성: `/gear_freak_server/migrations/YYYYMMDDHHMMSS_add_last_bumped_at.sql`

**작업 내용**:
```yaml
# product.spy.yaml
fields:
  # ... 기존 필드들
  lastBumpedAt: DateTime?  # 추가

indexes:
  last_bumped_at_idx:      # 추가
    fields: lastBumpedAt
```

```bash
# 1. 코드 생성
cd gear_freak_server
serverpod generate

# 2. 마이그레이션 확인
# migrations/ 폴더에 자동 생성된 SQL 확인

# 3. DB 적용 (개발 환경)
serverpod create-migration
```

**마이그레이션 SQL 예상**:
```sql
-- Up migration
ALTER TABLE product ADD COLUMN last_bumped_at TIMESTAMP;
CREATE INDEX last_bumped_at_idx ON product (last_bumped_at DESC);

-- Down migration
DROP INDEX last_bumped_at_idx;
ALTER TABLE product DROP COLUMN last_bumped_at;
```

#### Phase 2: 백엔드 로직 수정

**파일**: `/gear_freak_server/lib/src/feature/product/service/product_service.dart`

```dart
/// 상품 상단으로 올리기 (24시간 쿨다운)
///
/// 상품의 lastBumpedAt을 현재 시간으로 갱신하여 최신순 정렬에서 상단으로 올립니다.
/// 마지막 bump로부터 24시간이 지나지 않으면 Exception을 던집니다.
///
/// [session]: Serverpod 세션
/// [productId]: 상품 ID
/// [userId]: 요청자 ID (권한 확인용)
/// Returns: 수정된 상품
/// Throws:
///   - Exception('Product not found') - 상품을 찾을 수 없는 경우
///   - Exception('Unauthorized...') - 권한이 없는 경우
///   - Exception('Bump cooldown active...') - 쿨다운 중인 경우
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
      // 남은 시간 계산
      final remainingMinutes = (24 * 60) - timeSinceLastBump.inMinutes;
      final remainingHours = remainingMinutes ~/ 60;
      final displayMinutes = remainingMinutes % 60;

      throw Exception(
        'Bump cooldown active. '
        'Please wait ${remainingHours}h ${displayMinutes}m before bumping again.'
      );
    }
  }

  // 4. lastBumpedAt을 현재 시간으로 갱신
  final now = DateTime.now().toUtc();
  final updatedProduct = product.copyWith(lastBumpedAt: now);

  await Product.db.updateRow(
    session,
    updatedProduct,
    columns: (t) => [t.lastBumpedAt],
  );

  session.log(
    'Product bumped: productId=$productId, userId=$userId',
    level: LogLevel.info,
  );

  return updatedProduct;
}
```

#### Phase 3: 정렬 로직 수정

**파일**: `/gear_freak_server/lib/src/feature/product/service/product_list_service.dart`

기존 정렬 방식:
```dart
case ProductSortOption.latest:
  orderBy: (t) => t.updatedAt,  // 수정 시간 기준
```

변경 방식:
```dart
case ProductSortOption.latest:
  // lastBumpedAt 우선, 없으면 createdAt
  orderByList: (t) => [
    Order(
      column: t.lastBumpedAt,
      orderDescending: true,
    ),
    Order(
      column: t.createdAt,
      orderDescending: true,
    ),
  ],
```

**이유**:
- Bump한 상품 우선 노출
- Bump 안 한 상품은 생성일 순
- `updatedAt`은 순수하게 수정 시간만 표시

#### Phase 4: 프론트엔드 에러 처리

**파일**: `/gear_freak_flutter/lib/feature/product/presentation/page/product_detail_page.dart`

```dart
/// 상단으로 올리기 처리
Future<void> _handleBump(pod.Product productData) async {
  if (!mounted) return;

  if (productData.id == null) {
    if (!mounted) return;
    GbSnackBar.showError(context, '상품 ID가 유효하지 않습니다');
    return;
  }

  // 쿨다운 사전 체크 (옵션)
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
  final bumpResult = await ref
      .read(productDetailNotifierProvider.notifier)
      .bumpProduct(productData.id!);

  if (!mounted) return;

  if (bumpResult) {
    if (!mounted) return;
    GbSnackBar.showSuccess(context, '상품이 상단으로 올라갔습니다');
  } else {
    // 실패
    if (!mounted) return;
    GbSnackBar.showError(context, '상품을 상단으로 올리는데 실패했습니다');
  }
}
```

**개선 사항**:
1. **사전 체크**: API 호출 전 쿨다운 확인
2. **남은 시간 표시**: 사용자 친화적 메시지
3. **Warning 스낵바**: 에러가 아닌 정보성 메시지

#### Phase 5: UseCase 에러 처리 개선

**파일**: `/gear_freak_flutter/lib/feature/product/domain/usecase/bump_product_usecase.dart`

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

    return Left(
      BumpProductFailure(
        '상품을 상단으로 올릴 수 없습니다.',
        exception: e,
      ),
    );
  }
}
```

**새 Failure 클래스** (`domain/failure.dart`):
```dart
class BumpCooldownFailure extends Failure {
  const BumpCooldownFailure(super.message, {super.exception});
}
```

---

### 3.2 UI/UX 개선 제안

#### 옵션 1: 버튼 비활성화 + 남은 시간 표시

```dart
// ProductDetailLoadedView.dart
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

#### 옵션 2: 실시간 카운트다운 타이머

```dart
class _BumpButtonState extends State<_BumpButton> {
  Timer? _countdownTimer;
  String _remainingTime = '';

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(
      const Duration(minutes: 1),
      (_) {
        if (!mounted) return;
        setState(() {
          _remainingTime = _getRemainingCooldownTime(widget.product);
        });
      },
    );
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  // ... 빌드 메서드
}
```

**권장**: 옵션 1 (간단하고 충분)

---

## 4. 예상 시나리오 및 엣지 케이스

### 4.1 정상 시나리오

```
1. 사용자가 상품 등록
   → lastBumpedAt: null
   → "상단으로 올리기" 버튼 활성화

2. 첫 bump 시도
   → lastBumpedAt: 2026-01-13 10:00:00 UTC
   → 성공, 스낵바: "상품이 상단으로 올라갔습니다"

3. 10분 후 재시도
   → 쿨다운 체크 실패 (23h 50m 남음)
   → 에러: "Please wait 23h 50m before bumping again"

4. 24시간 후 재시도
   → 쿨다운 체크 통과
   → lastBumpedAt: 2026-01-14 10:00:00 UTC
   → 성공
```

### 4.2 엣지 케이스

#### Case 1: 정확히 24시간 경계
```dart
// lastBumpedAt: 2026-01-13 10:00:00
// 현재 시간: 2026-01-14 09:59:59 (23h 59m 59s 후)
timeSinceLastBump.inHours = 23  // inHours는 소수점 버림
→ 쿨다운 체크 실패 (< 24)

// 현재 시간: 2026-01-14 10:00:00 (정확히 24h 후)
timeSinceLastBump.inHours = 24
→ 쿨다운 체크 통과 (>= 24)
```

**처리**: `.inHours`는 정수 비교이므로 정확히 24시간 필요 (의도대로 동작)

#### Case 2: 상품 수정 후 bump
```
1. lastBumpedAt: 2026-01-13 10:00:00
2. 23시간 후 상품 가격 수정
   → updatedAt: 2026-01-14 09:00:00 (갱신됨)
   → lastBumpedAt: 2026-01-13 10:00:00 (변경 없음)
3. 1시간 후 bump 시도
   → 쿨다운 체크: 24시간 경과 (lastBumpedAt 기준)
   → 성공
```

**처리**: `lastBumpedAt`과 `updatedAt`을 분리하여 정확한 쿨다운 관리

#### Case 3: 서버 시간대 차이
```dart
// 서버: UTC
// 클라이언트: Asia/Seoul (UTC+9)

// 해결책: 모든 DateTime을 UTC로 통일
final now = DateTime.now().toUtc();
```

**처리**: Serverpod는 기본적으로 UTC 사용, 일관성 유지

#### Case 4: 최초 bump (lastBumpedAt null)
```dart
if (product.lastBumpedAt != null) {
  // 쿨다운 체크
}
// lastBumpedAt이 null이면 쿨다운 체크 생략 (첫 bump)
```

**처리**: null 체크로 안전하게 처리

---

## 5. 데이터베이스 마이그레이션 전략

### 5.1 기존 데이터 처리

**상황**: 이미 존재하는 수천 개의 상품들은 `lastBumpedAt`이 null

**옵션 A: null 유지 (권장)**
```sql
-- 마이그레이션 시 기본값 설정 안 함
ALTER TABLE product ADD COLUMN last_bumped_at TIMESTAMP;

-- 기존 상품들: lastBumpedAt = null
-- → 첫 bump 즉시 가능 (새 상품과 동일)
```

**장점**: 단순, 공정

**옵션 B: createdAt으로 초기화**
```sql
-- 기존 상품들의 lastBumpedAt을 createdAt으로 설정
ALTER TABLE product ADD COLUMN last_bumped_at TIMESTAMP;
UPDATE product SET last_bumped_at = created_at WHERE last_bumped_at IS NULL;
```

**단점**: 기존 사용자에게 불리 (즉시 bump 불가능)

**권장**: 옵션 A

### 5.2 롤백 계획

```sql
-- Down migration
DROP INDEX IF EXISTS last_bumped_at_idx;
ALTER TABLE product DROP COLUMN IF EXISTS last_bumped_at;
```

**주의**: 롤백 시 bump 히스토리 손실 (복구 불가)

---

## 6. 테스트 계획

### 6.1 단위 테스트

**파일**: `/gear_freak_server/test/feature/product/service/product_service_test.dart`

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

  test('24시간 후 재시도는 성공', () async {
    // Given: 25시간 전에 bump한 상품
    final lastBump = DateTime.now().toUtc().subtract(Duration(hours: 25));
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
});
```

### 6.2 통합 테스트

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

  // Then: 상품 목록 정렬 순서 = A, C, B
  final products = await productListService.getPaginatedProducts(
    session,
    PaginationDto(
      page: 1,
      pageSize: 10,
      sortOption: ProductSortOption.latest,
    ),
  );

  expect(products.products[0].id, productA.id);
  expect(products.products[1].id, productC.id);
  expect(products.products[2].id, productB.id);
});
```

---

## 7. 성능 고려사항

### 7.1 인덱스 전략

```sql
-- lastBumpedAt 내림차순 인덱스 (정렬용)
CREATE INDEX last_bumped_at_idx ON product (last_bumped_at DESC NULLS LAST);

-- 복합 인덱스 (카테고리 + 정렬)
CREATE INDEX product_category_bump_idx
  ON product (category, last_bumped_at DESC NULLS LAST);
```

**효과**:
- 상품 목록 조회 시 INDEX SCAN 사용
- ORDER BY 성능 향상

### 7.2 쿼리 성능

**기존 (updatedAt)**:
```sql
SELECT * FROM product
ORDER BY updated_at DESC
LIMIT 20;
```

**변경 (lastBumpedAt + createdAt)**:
```sql
SELECT * FROM product
ORDER BY
  last_bumped_at DESC NULLS LAST,
  created_at DESC
LIMIT 20;
```

**분석**:
- NULLS LAST: null 값을 마지막에 배치
- 복합 정렬이지만 인덱스 사용으로 성능 유지

---

## 8. 보안 고려사항

### 8.1 권한 검증

```dart
// 현재 구현
if (product.sellerId != userId) {
  throw Exception('Unauthorized');
}
```

**충분함**: Serverpod의 인증 미들웨어와 결합

### 8.2 Rate Limiting

**추가 보호 계층 (선택사항)**:
```dart
// 쿨다운 외에 추가로 일일 최대 bump 횟수 제한
const int MAX_BUMPS_PER_DAY = 5;

// ProductBump 테이블이 있다면:
final todayBumps = await ProductBump.db.count(
  session,
  where: (b) =>
    b.productId.equals(productId) &
    b.bumpedAt.after(DateTime.now().subtract(Duration(days: 1))),
);

if (todayBumps >= MAX_BUMPS_PER_DAY) {
  throw Exception('Daily bump limit reached');
}
```

**평가**: 24시간 쿨다운만으로도 충분 (일일 1회로 자연스럽게 제한)

---

## 9. 배포 전략

### 9.1 Blue-Green 배포

```
1. Blue (현재): 쿨다운 없음
2. Green (새 버전): 쿨다운 24시간
3. 마이그레이션 적용: lastBumpedAt 컬럼 추가
4. Green 배포 및 검증
5. Blue → Green 전환
6. 모니터링
```

### 9.2 롤백 시나리오

```
1. 문제 발생 감지
2. Green → Blue 전환 (즉시)
3. 코드 롤백 (lastBumpedAt 무시)
4. DB 롤백은 보류 (데이터 유지)
```

**주의**: lastBumpedAt 컬럼은 유지 (롤백 후에도 무해)

---

## 10. 모니터링 및 알림

### 10.1 로그 수집

```dart
// 성공 로그
session.log(
  'Product bumped: productId=$productId, userId=$userId, '
  'lastBumpedAt=${product.lastBumpedAt}',
  level: LogLevel.info,
);

// 쿨다운 실패 로그
session.log(
  'Bump cooldown failed: productId=$productId, userId=$userId, '
  'remainingTime=${remainingHours}h ${remainingMinutes}m',
  level: LogLevel.warning,
);
```

### 10.2 메트릭

```
- bump_success_count: 성공한 bump 횟수
- bump_cooldown_failures: 쿨다운으로 실패한 횟수
- bump_avg_interval: 평균 bump 간격
```

---

## 11. 최종 권장사항

### 구현 방법: Option A (Product 테이블에 lastBumpedAt 추가)

**선택 이유**:
1. **단순성**: 최소한의 변경으로 요구사항 충족
2. **성능**: JOIN 없이 단일 테이블 쿼리
3. **유지보수성**: 로직이 한 곳에 집중
4. **확장성**: 추후 히스토리가 필요하면 별도 테이블 추가 가능

### 구현 우선순위

**Phase 1 (필수)**:
1. Product 스키마에 lastBumpedAt 추가
2. bumpProduct 메서드에 쿨다운 로직 구현
3. 정렬 로직 수정 (lastBumpedAt 우선)
4. 프론트엔드 에러 처리

**Phase 2 (권장)**:
5. UI 개선 (버튼 비활성화 + 남은 시간 표시)
6. 단위 테스트 작성
7. 통합 테스트 작성

**Phase 3 (선택)**:
8. 실시간 카운트다운 타이머
9. 일일 최대 bump 횟수 제한
10. 대시보드에 bump 통계 추가

### 예상 개발 시간

- Phase 1: 4-6시간
- Phase 2: 3-4시간
- Phase 3: 4-6시간

**총 추정**: 11-16시간

---

## 12. 참고 자료

### 관련 파일 목록

**백엔드**:
- `/gear_freak_server/lib/src/feature/product/model/product.spy.yaml`
- `/gear_freak_server/lib/src/feature/product/service/product_service.dart`
- `/gear_freak_server/lib/src/feature/product/service/product_list_service.dart`
- `/gear_freak_server/lib/src/feature/product/endpoint/product_endpoint.dart`

**프론트엔드**:
- `/gear_freak_flutter/lib/feature/product/domain/usecase/bump_product_usecase.dart`
- `/gear_freak_flutter/lib/feature/product/presentation/page/product_detail_page.dart`
- `/gear_freak_flutter/lib/feature/product/presentation/provider/product_detail_notifier.dart`

### 유사 패턴 참고
- ProductView (조회수 중복 방지): userId + productId unique index
- Favorite (찜 토글): 별도 테이블로 관리

---

## 13. 결론

상품 끌어올리기 24시간 쿨다운은 **Product 테이블에 lastBumpedAt 컬럼을 추가**하는 방식으로 구현하는 것이 가장 효율적입니다.

이 방식은:
- **간단하면서도 효과적**
- **성능 저하 없음**
- **확장 가능**
- **테스트 용이**

현재 ProductView 패턴을 참고하여 별도 테이블을 고려할 수도 있으나, 쿨다운 요구사항에는 과도한 엔지니어링입니다. 추후 히스토리 분석이 필요하면 그때 ProductBump 테이블을 추가해도 늦지 않습니다.

**다음 단계**: 이 연구 내용을 바탕으로 `/thoughts/shared/plans/` 폴더에 상세한 구현 계획서를 작성하고, Phase별로 구현을 진행하면 됩니다.

---

**문서 종료**
