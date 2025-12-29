import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import 'package:gear_freak_flutter/common/service/pod_service.dart';

/// 상품 원격 데이터 소스
class ProductRemoteDataSource {
  /// ProductRemoteDataSource 생성자
  const ProductRemoteDataSource();

  /// Serverpod Client
  pod.Client get _client => PodService.instance.client;

  /// 🧪 Mock 데이터 사용 여부 (테스트용)
  static const bool _useMockData = false;

  /// 🧪 Mock 상품 데이터 생성
  List<pod.Product> _generateMockProducts({
    required int totalCount,
    int? sellerId,
    pod.ProductCategory? category,
    String? title,
  }) {
    final products = <pod.Product>[];
    final now = DateTime.now();
    final categories = [
      pod.ProductCategory.equipment,
      pod.ProductCategory.supplement,
      pod.ProductCategory.clothing,
      pod.ProductCategory.shoes,
      pod.ProductCategory.etc,
    ];
    final conditions = [
      pod.ProductCondition.brandNew,
      pod.ProductCondition.usedExcellent,
      pod.ProductCondition.usedGood,
      pod.ProductCondition.usedFair,
    ];
    final tradeMethods = [
      pod.TradeMethod.direct,
      pod.TradeMethod.delivery,
      pod.TradeMethod.both,
    ];

    final productNames = [
      '벤치프레스 세트',
      '덤벨 10kg',
      '프로틴 2kg',
      '크레아틴',
      '운동화',
      '조깅화',
      '운동복 상의',
      '운동복 하의',
      '헬스장비 세트',
      '보충제 패키지',
      '바벨',
      '원판 20kg',
      '요가매트',
      '아령 세트',
      '풀업바',
      '운동장갑',
      '벨트',
      '스트랩',
      '보호대',
      '기타 운동용품',
    ];

    // 다양한 날짜 범위 정의 (테스트용)
    // 200개 데이터를 다양한 시간 범위에 분산
    // 방금 전, 분 단위(1~59분), 시간 단위(1~23시간), 일 단위(1~6일), 주 단위(1~3주),
    // 개월 단위(1~12개월), 년 단위(1년 이상) 포함
    final dateRanges = <Duration>[];
    for (var i = 0; i < totalCount; i++) {
      Duration timeAgo;
      if (i == 0) {
        // 0: 방금 전 (30초 전)
        timeAgo = Duration(seconds: 30);
      } else if (i < 60) {
        // 1-59: 1분 전 ~ 59분 전 (분 단위 테스트)
        timeAgo = Duration(minutes: i);
      } else if (i < 83) {
        // 60-82: 1시간 전 ~ 23시간 전 (시간 단위 테스트)
        timeAgo = Duration(hours: i - 59);
      } else if (i < 89) {
        // 83-88: 1일 전 ~ 6일 전 (일 단위 테스트)
        timeAgo = Duration(days: i - 82);
      } else if (i < 92) {
        // 89-91: 1주일 전, 2주일 전, 3주일 전 (주 단위 테스트)
        timeAgo = Duration(days: (i - 88) * 7);
      } else if (i < 104) {
        // 92-103: 1개월 전 ~ 12개월 전 (개월 단위 테스트)
        final months = i - 91;
        timeAgo = Duration(days: months * 30); // 대략 30일 기준
      } else if (i < 114) {
        // 104-113: 1년 전 ~ 10년 전 (년 단위 테스트)
        final years = i - 103;
        timeAgo = Duration(days: years * 365);
      } else {
        // 114-199: 11년 전 ~ 96년 전 (더 긴 년 단위)
        final years = 11 + (i - 113);
        timeAgo = Duration(days: years * 365);
      }
      dateRanges.add(timeAgo);
    }

    for (var i = 0; i < totalCount; i++) {
      final productId = i + 1;
      final productName = productNames[i % productNames.length];
      final productTitle = title != null && title.isNotEmpty
          ? '$productName - $title'
          : '$productName ${productId}';

      final timeAgo = dateRanges[i];
      final createdAtDate = now.subtract(timeAgo);
      // updatedAt은 createdAt과 같거나 그 이후로 설정
      // 분/시간 단위인 경우: 약간의 차이만 두기, 일 단위 이상인 경우: 최대 30일 차이
      DateTime updatedAtDate;
      if (timeAgo.inDays == 0) {
        // 분/시간 단위인 경우: createdAt과 동일 또는 최대 몇 분 차이
        final minutesOffset = (i % 10); // 0~9분 차이
        updatedAtDate = createdAtDate.add(Duration(minutes: minutesOffset));
      } else if (timeAgo.inDays > 30) {
        // 30일 이상인 경우: 최대 30일 차이
        final updateOffsetDays = i % 31;
        final updateOffset = Duration(days: updateOffsetDays);
        updatedAtDate = now.subtract(timeAgo - updateOffset);
      } else {
        // 1일 이상 30일 이하인 경우: timeAgo보다 작은 차이
        final updateOffsetDays = i % timeAgo.inDays.clamp(1, 31);
        final updateOffset = Duration(days: updateOffsetDays);
        updatedAtDate = now.subtract(timeAgo - updateOffset);
      }

      // 설명용 날짜 정보 생성
      String dateInfo;
      if (timeAgo.inMinutes < 1) {
        dateInfo = '방금 전 생성';
      } else if (timeAgo.inMinutes < 60) {
        dateInfo = '${timeAgo.inMinutes}분 전 생성';
      } else if (timeAgo.inHours < 24) {
        dateInfo = '${timeAgo.inHours}시간 전 생성';
      } else if (timeAgo.inDays < 7) {
        dateInfo = '${timeAgo.inDays}일 전 생성';
      } else if (timeAgo.inDays < 28) {
        dateInfo = '${timeAgo.inDays ~/ 7}주일 전 생성';
      } else if (timeAgo.inDays < 365) {
        final months = timeAgo.inDays ~/ 30;
        dateInfo = '${months}개월 전 생성';
      } else {
        final years = timeAgo.inDays ~/ 365;
        dateInfo = '${years}년 전 생성';
      }

      products.add(
        pod.Product(
          id: productId,
          sellerId: sellerId ?? 2,
          title: productTitle,
          category: category ?? categories[i % categories.length],
          price: 10000 + (i % 49) * 10000, // 10,000 ~ 500,000
          condition: conditions[i % conditions.length],
          description:
              '상품 설명입니다. 상태가 좋고 깨끗하게 보관했습니다. $productTitle ($dateInfo)',
          tradeMethod: tradeMethods[i % tradeMethods.length],
          baseAddress: [
            '서울특별시 강남구',
            '서울특별시 서초구',
            '서울특별시 송파구',
            '서울특별시 마포구',
            '서울특별시 용산구',
          ][i % 5],
          detailAddress: '${i % 100 + 1}동 ${i % 20 + 1}호',
          imageUrls: [
            'https://picsum.photos/seed/$productId/400',
            'https://picsum.photos/seed/${productId + 100}/400',
          ],
          viewCount: i % 501,
          favoriteCount: i % 51,
          chatCount: i % 21,
          createdAt: createdAtDate,
          updatedAt: updatedAtDate,
          status: i % 10 == 0
              ? pod.ProductStatus.reserved
              : i % 10 == 1
                  ? pod.ProductStatus.sold
                  : pod.ProductStatus.selling,
        ),
      );
    }

    return products;
  }

  /// 페이지네이션된 상품 목록 조회
  Future<pod.PaginatedProductsResponseDto> getPaginatedProducts(
    pod.PaginationDto pagination,
  ) async {
    if (_useMockData) {
      await Future<void>.delayed(const Duration(milliseconds: 500));

      const totalMockProducts = 200;
      final allProducts = _generateMockProducts(
        totalCount: totalMockProducts,
        category: pagination.category,
        title: pagination.title,
      );

      // 정렬 처리
      var sortedProducts = List<pod.Product>.from(allProducts);
      switch (pagination.sortBy) {
        case pod.ProductSortBy.latest:
          sortedProducts.sort((a, b) {
            final aDate = a.updatedAt ?? a.createdAt ?? DateTime(1970);
            final bDate = b.updatedAt ?? b.createdAt ?? DateTime(1970);
            return bDate.compareTo(aDate);
          });
          break;
        case pod.ProductSortBy.priceAsc:
          sortedProducts.sort((a, b) => a.price.compareTo(b.price));
          break;
        case pod.ProductSortBy.priceDesc:
          sortedProducts.sort((a, b) => b.price.compareTo(a.price));
          break;
        case pod.ProductSortBy.popular:
          sortedProducts.sort((a, b) {
            final aCount = a.favoriteCount ?? 0;
            final bCount = b.favoriteCount ?? 0;
            return bCount.compareTo(aCount);
          });
          break;
        default:
          break;
      }

      // 페이지네이션 처리
      final offset = (pagination.page - 1) * pagination.limit;
      final endIndex =
          (offset + pagination.limit).clamp(0, sortedProducts.length);
      final paginatedProducts = sortedProducts.sublist(
        offset.clamp(0, sortedProducts.length),
        endIndex,
      );

      final totalPages = (totalMockProducts / pagination.limit).ceil();
      final hasMore = pagination.page < totalPages;

      return pod.PaginatedProductsResponseDto(
        products: paginatedProducts,
        pagination: pod.PaginationDto(
          page: pagination.page,
          limit: pagination.limit,
          totalCount: totalMockProducts,
          hasMore: hasMore,
          category: pagination.category,
          sortBy: pagination.sortBy,
        ),
      );
    }

    try {
      return await _client.product.getPaginatedProducts(pagination);
    } catch (e) {
      throw Exception('상품 목록을 불러오는데 실패했습니다: $e');
    }
  }

  /// 상품 상세 조회
  Future<pod.Product> getProductDetail(int id) async {
    if (_useMockData) {
      await Future<void>.delayed(const Duration(milliseconds: 300));
      final mockProducts = _generateMockProducts(totalCount: 200);
      final product = mockProducts.firstWhere(
        (p) => p.id == id,
        orElse: () => mockProducts.first,
      );
      return product;
    }

    try {
      return await _client.product.getProduct(id);
    } catch (e) {
      throw Exception('상품 상세를 불러오는데 실패했습니다: $e');
    }
  }

  /// 찜 추가/제거 (토글)
  /// 반환값: true = 찜 추가됨, false = 찜 제거됨
  Future<bool> toggleFavorite(int productId) async {
    try {
      return await _client.product.toggleFavorite(productId);
    } catch (e) {
      throw Exception('찜 상태를 변경하는데 실패했습니다: $e');
    }
  }

  /// 찜 상태 조회
  Future<bool> isFavorite(int productId) async {
    try {
      return await _client.product.isFavorite(productId);
    } catch (e) {
      throw Exception('찜 상태를 조회하는데 실패했습니다: $e');
    }
  }

  /// 조회수 증가 (계정당 1회)
  /// 반환값: true = 조회수 증가됨, false = 이미 조회함 (증가 안 됨)
  Future<bool> incrementViewCount(int productId) async {
    try {
      return await _client.product.incrementViewCount(productId);
    } catch (e) {
      throw Exception('조회수를 증가하는데 실패했습니다: $e');
    }
  }

  /// 상품 생성
  Future<pod.Product> createProduct(pod.CreateProductRequestDto request) async {
    try {
      return await _client.product.createProduct(request);
    } catch (e) {
      throw Exception('상품을 생성하는데 실패했습니다: $e');
    }
  }

  /// 상품 수정
  Future<pod.Product> updateProduct(pod.UpdateProductRequestDto request) async {
    try {
      return await _client.product.updateProduct(request);
    } catch (e) {
      throw Exception('상품을 수정하는데 실패했습니다: $e');
    }
  }

  /// 상품 삭제
  Future<void> deleteProduct(int productId) async {
    try {
      return await _client.product.deleteProduct(productId);
    } catch (e) {
      throw Exception('상품을 삭제하는데 실패했습니다: $e');
    }
  }

  /// 내가 등록한 상품 목록 조회
  Future<pod.PaginatedProductsResponseDto> getMyProducts(
    pod.PaginationDto pagination,
  ) async {
    if (_useMockData) {
      await Future<void>.delayed(const Duration(milliseconds: 500));
      const totalMockProducts = 50;
      final allProducts = _generateMockProducts(
        totalCount: totalMockProducts,
        sellerId: 2, // 현재 사용자 ID
      );

      // 정렬 처리
      var sortedProducts = List<pod.Product>.from(allProducts);
      sortedProducts.sort((a, b) {
        final aDate = a.updatedAt ?? a.createdAt ?? DateTime(1970);
        final bDate = b.updatedAt ?? b.createdAt ?? DateTime(1970);
        return bDate.compareTo(aDate);
      });

      // 페이지네이션 처리
      final offset = (pagination.page - 1) * pagination.limit;
      final endIndex =
          (offset + pagination.limit).clamp(0, sortedProducts.length);
      final paginatedProducts = sortedProducts.sublist(
        offset.clamp(0, sortedProducts.length),
        endIndex,
      );

      final totalPages = (totalMockProducts / pagination.limit).ceil();
      final hasMore = pagination.page < totalPages;

      return pod.PaginatedProductsResponseDto(
        products: paginatedProducts,
        pagination: pod.PaginationDto(
          page: pagination.page,
          limit: pagination.limit,
          totalCount: totalMockProducts,
          hasMore: hasMore,
        ),
      );
    }

    try {
      return await _client.product.getMyProducts(pagination);
    } catch (e) {
      throw Exception('내 상품 목록을 불러오는데 실패했습니다: $e');
    }
  }

  /// 내가 관심목록한 상품 목록 조회
  Future<pod.PaginatedProductsResponseDto> getMyFavoriteProducts(
    pod.PaginationDto pagination,
  ) async {
    if (_useMockData) {
      await Future<void>.delayed(const Duration(milliseconds: 500));
      const totalMockProducts = 30;
      final allProducts = _generateMockProducts(
        totalCount: totalMockProducts,
        sellerId: 1, // 다른 판매자의 상품들
      );

      // 페이지네이션 처리
      final offset = (pagination.page - 1) * pagination.limit;
      final endIndex = (offset + pagination.limit).clamp(0, allProducts.length);
      final paginatedProducts = allProducts.sublist(
        offset.clamp(0, allProducts.length),
        endIndex,
      );

      final totalPages = (totalMockProducts / pagination.limit).ceil();
      final hasMore = pagination.page < totalPages;

      return pod.PaginatedProductsResponseDto(
        products: paginatedProducts,
        pagination: pod.PaginationDto(
          page: pagination.page,
          limit: pagination.limit,
          totalCount: totalMockProducts,
          hasMore: hasMore,
        ),
      );
    }

    try {
      return await _client.product.getMyFavoriteProducts(pagination);
    } catch (e) {
      throw Exception('찜 목록을 불러오는데 실패했습니다: $e');
    }
  }

  /// 상품 상태 변경
  Future<pod.Product> updateProductStatus(
    pod.UpdateProductStatusRequestDto request,
  ) async {
    try {
      return await _client.product.updateProductStatus(request);
    } catch (e) {
      throw Exception('상품 상태를 변경하는데 실패했습니다: $e');
    }
  }

  /// 상품 통계 조회 (판매중, 거래완료, 관심목록 개수)
  Future<pod.ProductStatsDto> getProductStats() async {
    if (_useMockData) {
      await Future<void>.delayed(const Duration(milliseconds: 300));
      return pod.ProductStatsDto(
        sellingCount: 35,
        soldCount: 15,
        favoriteCount: 30,
        reviewCount: 0,
      );
    }

    try {
      return await _client.product.getProductStats();
    } catch (e) {
      throw Exception('상품 통계를 불러오는데 실패했습니다: $e');
    }
  }

  /// 다른 사용자의 상품 통계 조회 (판매중, 거래완료, 관심목록 개수, 후기 개수)
  /// [userId]는 조회할 사용자의 ID입니다.
  Future<pod.ProductStatsDto> getProductStatsByUserId(int userId) async {
    if (_useMockData) {
      await Future<void>.delayed(const Duration(milliseconds: 300));
      return pod.ProductStatsDto(
        sellingCount: 25,
        soldCount: 10,
        favoriteCount: 20,
        reviewCount: 15,
      );
    }

    try {
      return await _client.product.getProductStatsByUserId(userId);
    } catch (e) {
      throw Exception('상품 통계를 불러오는데 실패했습니다: $e');
    }
  }

  /// 다른 사용자의 상품 목록 조회 (페이지네이션)
  /// [userId]는 조회할 사용자의 ID입니다.
  /// (selling + reserved 포함).
  Future<pod.PaginatedProductsResponseDto> getProductsByUserId(
    int userId,
    pod.PaginationDto pagination,
  ) async {
    if (_useMockData) {
      await Future<void>.delayed(const Duration(milliseconds: 500));
      const totalMockProducts = 40;
      final allProducts = _generateMockProducts(
        totalCount: totalMockProducts,
        sellerId: userId,
      );

      // 페이지네이션 처리
      final offset = (pagination.page - 1) * pagination.limit;
      final endIndex = (offset + pagination.limit).clamp(0, allProducts.length);
      final paginatedProducts = allProducts.sublist(
        offset.clamp(0, allProducts.length),
        endIndex,
      );

      final totalPages = (totalMockProducts / pagination.limit).ceil();
      final hasMore = pagination.page < totalPages;

      return pod.PaginatedProductsResponseDto(
        products: paginatedProducts,
        pagination: pod.PaginationDto(
          page: pagination.page,
          limit: pagination.limit,
          totalCount: totalMockProducts,
          hasMore: hasMore,
        ),
      );
    }

    try {
      return await _client.product.getProductsByUserId(userId, pagination);
    } catch (e) {
      throw Exception('다른 사용자의 상품 목록을 불러오는데 실패했습니다: $e');
    }
  }

  /// 상품 상단으로 올리기 (updatedAt 갱신)
  Future<pod.Product> bumpProduct(int productId) async {
    try {
      return await _client.product.bumpProduct(productId);
    } catch (e) {
      throw Exception('상품을 상단으로 올리는데 실패했습니다: $e');
    }
  }
}
