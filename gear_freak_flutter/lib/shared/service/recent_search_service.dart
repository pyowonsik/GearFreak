import 'package:shared_preferences/shared_preferences.dart';

/// 최근 검색어 관리 서비스
class RecentSearchService {
  /// SharedPreferences 키
  static const String _key = 'recent_searches';

  /// 최대 저장 개수
  static const int _maxCount = 10;

  /// 최근 검색어 저장
  ///
  /// [query]는 저장할 검색어입니다.
  /// 중복 제거 후 최상단에 추가합니다.
  Future<void> saveSearch(String query) async {
    if (query.trim().isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final searches = await getRecentSearches();

    // 중복 제거
    searches
      ..remove(query)
      // 최상단에 추가
      ..insert(0, query);

    // 최대 개수 제한
    if (searches.length > _maxCount) {
      searches.removeRange(_maxCount, searches.length);
    }

    // 저장
    await prefs.setStringList(_key, searches);
  }

  /// 최근 검색어 불러오기
  ///
  /// 저장된 검색어 리스트를 반환합니다.
  Future<List<String>> getRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? [];
  }

  /// 특정 검색어 삭제
  ///
  /// [query]는 삭제할 검색어입니다.
  Future<void> deleteSearch(String query) async {
    final prefs = await SharedPreferences.getInstance();
    final searches = await getRecentSearches();

    searches.remove(query);

    await prefs.setStringList(_key, searches);
  }

  /// 전체 검색어 삭제
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
