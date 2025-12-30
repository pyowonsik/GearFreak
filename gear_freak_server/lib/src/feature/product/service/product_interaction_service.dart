import 'package:gear_freak_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';

/// 상품 상호작용 서비스
/// 찜, 조회수 등 상품과 사용자 간의 상호작용 관련 비즈니스 로직을 처리합니다.
class ProductInteractionService {
  /// 찜 추가/제거 (토글)
  /// 반환값: true = 찜 추가됨, false = 찜 제거됨
  Future<bool> toggleFavorite(
    Session session,
    int userId,
    int productId,
  ) async {
    // 상품 존재 확인
    final product = await Product.db.findById(session, productId);
    if (product == null) {
      throw Exception('Product not found');
    }

    // 기존 찜 확인
    final existingFavorite = await Favorite.db.findFirstRow(
      session,
      where: (f) => f.userId.equals(userId) & f.productId.equals(productId),
    );

    if (existingFavorite != null) {
      // 찜 제거
      await Favorite.db.deleteRow(session, existingFavorite);

      // favoriteCount 감소
      final currentCount = product.favoriteCount ?? 0;
      final newCount = (currentCount - 1).clamp(0, double.infinity).toInt();
      await Product.db.updateRow(
        session,
        product.copyWith(favoriteCount: newCount),
        columns: (t) => [t.favoriteCount],
      );

      return false; // 찜 제거됨
    } else {
      // 찜 추가
      final favorite = Favorite(
        userId: userId,
        productId: productId,
        createdAt: DateTime.now(),
      );
      await Favorite.db.insertRow(session, favorite);

      // favoriteCount 증가
      final currentCount = product.favoriteCount ?? 0;
      await Product.db.updateRow(
        session,
        product.copyWith(favoriteCount: currentCount + 1),
        columns: (t) => [t.favoriteCount],
      );

      return true; // 찜 추가됨
    }
  }

  /// 찜 상태 조회
  Future<bool> isFavorite(Session session, int userId, int productId) async {
    final favorite = await Favorite.db.findFirstRow(
      session,
      where: (f) => f.userId.equals(userId) & f.productId.equals(productId),
    );
    return favorite != null;
  }

  /// 조회수 증가 (계정당 1회)
  /// 이미 조회한 경우에는 조회수를 증가시키지 않습니다.
  /// 반환값: true = 조회수 증가됨, false = 이미 조회함 (증가 안 됨)
  Future<bool> incrementViewCount(
    Session session,
    int userId,
    int productId,
  ) async {
    // 상품 존재 확인
    final product = await Product.db.findById(session, productId);
    if (product == null) {
      throw Exception('Product not found');
    }

    // 기존 조회 기록 확인
    final existingView = await ProductView.db.findFirstRow(
      session,
      where: (v) => v.userId.equals(userId) & v.productId.equals(productId),
    );

    if (existingView != null) {
      // 이미 조회한 경우 조회수 증가하지 않음
      return false;
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

    return true; // 조회수 증가됨
  }
}

