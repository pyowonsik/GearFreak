import 'package:flutter/material.dart';

/// 최근 검색어 리스트 위젯
class SearchRecentSearchesListWidget extends StatelessWidget {
  /// SearchRecentSearchesListWidget 생성자
  ///
  /// [recentSearches]는 최근 검색어 목록입니다.
  /// [onSearchTap]는 검색어 클릭 콜백입니다.
  /// [onClearAll]는 전체 삭제 버튼 클릭 콜백입니다.
  /// [onDelete]는 개별 삭제 버튼 클릭 콜백입니다.
  const SearchRecentSearchesListWidget({
    required this.recentSearches,
    required this.onSearchTap,
    required this.onDelete,
    this.onClearAll,
    super.key,
  });

  /// 최근 검색어 목록
  final List<String> recentSearches;

  /// 검색어 클릭 콜백
  final ValueChanged<String> onSearchTap;

  /// 전체 삭제 버튼 클릭 콜백
  final VoidCallback? onClearAll;

  /// 개별 삭제 버튼 클릭 콜백
  final ValueChanged<String> onDelete;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 헤더
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '최근 검색어',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              if (onClearAll != null)
                TextButton(
                  onPressed: onClearAll,
                  child: const Text(
                    '전체 삭제',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const Divider(height: 1),
        // 최근 검색어 목록
        Expanded(
          child: ListView.builder(
            itemCount: recentSearches.length,
            itemBuilder: (context, index) {
              final query = recentSearches[index];
              return ListTile(
                leading: const Icon(
                  Icons.history,
                  color: Color(0xFF9CA3AF),
                ),
                title: Text(
                  query,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF1F2937),
                  ),
                ),
                trailing: IconButton(
                  icon: const Icon(
                    Icons.close,
                    color: Color(0xFF9CA3AF),
                    size: 20,
                  ),
                  onPressed: () {
                    onDelete(query);
                  },
                ),
                onTap: () {
                  onSearchTap(query);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
