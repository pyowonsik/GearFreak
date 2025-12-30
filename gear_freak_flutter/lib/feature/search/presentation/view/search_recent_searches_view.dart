import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gear_freak_flutter/feature/search/di/search_providers.dart';
import 'package:gear_freak_flutter/feature/search/presentation/widget/widget.dart';
import 'package:gear_freak_flutter/shared/widget/widget.dart';

/// 최근 검색어 화면 View
class SearchRecentSearchesView extends ConsumerWidget {
  /// SearchRecentSearchesView 생성자
  ///
  /// [recentSearches]는 최근 검색어 목록입니다.
  /// [onSearchTap]는 검색어 클릭 콜백입니다.
  /// [onClearAll]는 전체 삭제 버튼 클릭 콜백입니다.
  /// [onDelete]는 개별 삭제 버튼 클릭 콜백입니다.
  const SearchRecentSearchesView({
    required this.onSearchTap,
    required this.onDelete,
    this.recentSearches,
    this.onClearAll,
    super.key,
  });

  /// 최근 검색어 목록 (null이면 FutureBuilder로 가져옴)
  final List<String>? recentSearches;

  /// 검색어 클릭 콜백
  final ValueChanged<String> onSearchTap;

  /// 전체 삭제 버튼 클릭 콜백
  final VoidCallback? onClearAll;

  /// 개별 삭제 버튼 클릭 콜백
  final ValueChanged<String> onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // recentSearches가 제공되면 바로 사용
    if (recentSearches != null) {
      if (recentSearches!.isEmpty) {
        return const GbEmptyView(
          icon: Icons.search,
          message: '상품을 검색해보세요',
        );
      }
      return SearchRecentSearchesListWidget(
        recentSearches: recentSearches!,
        onSearchTap: onSearchTap,
        onClearAll: onClearAll,
        onDelete: onDelete,
      );
    }

    // recentSearches가 없으면 FutureBuilder로 가져오기
    return FutureBuilder<List<String>>(
      future: ref.read(searchNotifierProvider.notifier).getRecentSearches(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const GbLoadingView();
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const GbEmptyView(
            icon: Icons.search,
            message: '상품을 검색해보세요',
          );
        }
        return SearchRecentSearchesListWidget(
          recentSearches: snapshot.data!,
          onSearchTap: onSearchTap,
          onClearAll: onClearAll,
          onDelete: onDelete,
        );
      },
    );
  }
}
