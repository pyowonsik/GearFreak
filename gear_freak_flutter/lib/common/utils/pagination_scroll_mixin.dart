import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;

/// 페이지네이션 무한 스크롤을 위한 Mixin
///
/// 사용 예시:
/// ```dart
/// class _MyScreenState extends ConsumerState<MyScreen>
/// with PaginationScrollMixin {
///   @override
///   void initState() {
///     super.initState();
///     initPaginationScroll(
///       onLoadMore: () {
///         ref.read(myNotifierProvider.notifier).loadMoreProducts();
///       },
///       getPagination: () {
///         final state = ref.read(myNotifierProvider);
///         if (state is MyLoadedState) {
///           return state.result.pagination;
///         }
///         return null;
///       },
///       isLoading: () {
///         final state = ref.read(myNotifierProvider);
///         return state is MyLoadingMoreState;
///       },
///       screenName: 'MyScreen',
///       // reverse: true로 설정하면 상단 스크롤 감지 (채팅용)
///       reverse: false, // 기본값: 하단 스크롤 감지
///     );
///   }
///
///   @override
///   void dispose() {
///     disposePaginationScroll();
///     super.dispose();
///   }
/// }
/// ```
mixin PaginationScrollMixin<T extends StatefulWidget> on State<T> {
  ScrollController? _scrollController;
  VoidCallback? _onLoadMore;
  pod.PaginationDto? Function()? _getPagination;
  bool Function()? _isLoading;
  String? _screenName;
  bool _reverse = false; // false: 하단 스크롤 감지, true: 상단 스크롤 감지
  bool _hasLoggedNoMoreData = false;
  Timer? _debounceTimer;

  /// 페이지네이션 스크롤 초기화
  ///
  /// [getPagination]은 PaginationDto를 반환하는 함수입니다.
  /// 채팅의 경우: `() => widget.pagination?.pagination`
  /// 일반 리스트의 경우: `() => state.result.pagination`
  void initPaginationScroll({
    required VoidCallback onLoadMore,
    required pod.PaginationDto? Function() getPagination,
    required bool Function() isLoading,
    String? screenName,
    bool reverse = false, // false: 하단 스크롤 감지, true: 상단 스크롤 감지 (채팅용)
  }) {
    _onLoadMore = onLoadMore;
    _getPagination = getPagination;
    _isLoading = isLoading;
    _screenName = screenName;
    _reverse = reverse;
    _scrollController = ScrollController();
    _scrollController!.addListener(_onScroll);
  }

  /// 스크롤 컨트롤러 반환
  ScrollController? get scrollController => _scrollController;

  /// 스크롤 이벤트 핸들러
  void _onScroll() {
    // 스크롤 컨트롤러가 초기화되지 않았으면 무시
    if (_scrollController == null || !_scrollController!.hasClients) {
      return;
    }

    final position = _scrollController!.position;

    // 스크롤 가능한 상태인지 확인
    if (!position.hasContentDimensions) {
      return;
    }

    bool shouldLoadMore = false;
    final threshold = position.maxScrollExtent - 300;

    if (_reverse) {
      // 상단 스크롤 감지 (채팅용: reverse: true)
      // 위로 스크롤하면 pixels가 maxScrollExtent에 가까워짐
      // 상단 300px 이내에 도달하면 이전 메시지 로드
      if (position.pixels >= threshold && position.maxScrollExtent > 0) {
        shouldLoadMore = true;
      }
    } else {
      // 하단 스크롤 감지 (일반 리스트용: reverse: false)
      // 아래로 스크롤하면 pixels가 maxScrollExtent에 가까워짐
      // 하단 300px 이내에 도달하면 다음 페이지 로드
      if (position.pixels >= threshold && position.pixels > 0) {
        shouldLoadMore = true;
      }
    }

    if (shouldLoadMore) {
      // 디바운스: 이전 타이머 취소
      _debounceTimer?.cancel();
      debugPrint('🔥 디바운스 타이머 취소');

      // 300ms 후에 실행 (디바운스)
      _debounceTimer = Timer(const Duration(milliseconds: 300), () {
        debugPrint('🔥 디바운스 타이머 실행');
        final pagination = _getPagination?.call();
        final isLoading = _isLoading?.call() ?? false;

        // PaginationDto는 hasMore 사용
        final hasMoreData = pagination?.hasMore ?? false;

        // 로딩 중이 아니고, 더 불러올 데이터가 있을 때만 실행
        if (!isLoading && pagination != null && hasMoreData) {
          _hasLoggedNoMoreData = false; // 데이터가 있으면 플래그 리셋

          final screenName = _screenName ?? 'Screen';
          final scrollType = _reverse ? '상단' : '하단';
          debugPrint('📜 [$screenName] $scrollType 스크롤 감지: '
              'pixels=${position.pixels.toStringAsFixed(0)}, '
              'maxScrollExtent=${position.maxScrollExtent.toStringAsFixed(0)}, '
              'threshold=${threshold.toStringAsFixed(0)}');
          debugPrint('📦 [$screenName] 현재 페이지: ${pagination.page}, '
              '전체: ${pagination.totalCount}, hasMore: $hasMoreData');

          _onLoadMore?.call();
        } else if (pagination != null &&
            !hasMoreData &&
            !_hasLoggedNoMoreData) {
          // 더 이상 데이터가 없을 때 한 번만 로그 출력
          _hasLoggedNoMoreData = true;
          final screenName = _screenName ?? 'Screen';
          debugPrint('✅ [$screenName] 더 이상 불러올 데이터가 없습니다.');
        }
      });
    }
  }

  /// 스크롤 컨트롤러 정리
  void disposePaginationScroll() {
    _debounceTimer?.cancel();
    _debounceTimer = null;
    _scrollController?.removeListener(_onScroll);
    _scrollController?.dispose();
    _scrollController = null;
    _onLoadMore = null;
    _getPagination = null;
    _isLoading = null;
    _screenName = null;
    _reverse = false;
    _hasLoggedNoMoreData = false;
  }
}
