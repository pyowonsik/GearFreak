import 'package:gear_freak_flutter/feature/review/data/datasource/review_remote_datasource.dart';
import 'package:gear_freak_flutter/feature/review/domain/repository/review_repository.dart';

/// 리뷰 리포지토리 구현
/// Data Layer: Repository 구현
class ReviewRepositoryImpl implements ReviewRepository {
  /// ReviewRepositoryImpl 생성자
  const ReviewRepositoryImpl(this.remoteDataSource);

  /// 원격 데이터 소스
  final ReviewRemoteDataSource remoteDataSource;

  // TODO: Repository 메서드 구현
}

