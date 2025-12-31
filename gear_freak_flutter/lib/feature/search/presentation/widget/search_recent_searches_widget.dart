import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gear_freak_flutter/feature/search/di/search_providers.dart';
import 'package:gear_freak_flutter/feature/search/presentation/presentation.dart';

/// 최근 검색어 위젯
///
/// 검색 필드에 포커스가 있을 때 표시되는 최근 검색어 목록입니다.
class SearchRecentSearchesWidget extends ConsumerWidget {
  /// SearchRecentSearchesWidget 생성자
  ///
  /// [searchController]는 검색 필드의 TextEditingController입니다.
  /// [searchFocusNode]는 검색 필드의 FocusNode입니다.
  const SearchRecentSearchesWidget({
    required this.searchController,
    required this.searchFocusNode,
    super.key,
  });

  /// 검색 필드의 TextEditingController
  final TextEditingController searchController;

  /// 검색 필드의 FocusNode
  final FocusNode searchFocusNode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchState = ref.watch(searchNotifierProvider);

    // SearchInitial 상태면 바로 사용, 아니면 FutureBuilder로 가져오기
    final recentSearches =
        searchState is SearchInitial ? searchState.recentSearches : null;

    return SearchRecentSearchesView(
      recentSearches: recentSearches,
      onSearchTap: (query) {
        // 검색어 입력
        searchController.text = query;
        // 검색 실행
        ref.read(searchNotifierProvider.notifier).searchProducts(query);
        // 포커스 해제
        searchFocusNode.unfocus();
      },
      onClearAll: () {
        ref.read(searchNotifierProvider.notifier).clearAllRecentSearches();
      },
      onDelete: (query) {
        ref.read(searchNotifierProvider.notifier).deleteRecentSearch(query);
      },
    );
  }
}
