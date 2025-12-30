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
  bool _isLoadingMore = false; // 로딩 중 플래그 (중복 로드 방지)
  Timer? _loadingCheckTimer; // 로딩 완료 체크 타이머

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

    // 이미 로딩 중이면 무시 (중복 로드 방지)
    if (_isLoadingMore) {
      return;
    }

    var shouldLoadMore = false;
    const threshold = 300.0; // 하단/상단에서 300px 전

    if (_reverse) {
      // 상단 스크롤 감지 (채팅용: reverse: true)
      // reverse: true인 ListView에서는 extentBefore가 상단까지의 거리를 의미
      // 위로 스크롤하면 extentBefore가 작아짐
      // 하지만 실제 동작을 보면 extentBefore가 하단까지의 거리일 수도 있음
      // 따라서 pixels가 maxScrollExtent에 가까울 때 (상단에 가까울 때) 로드
      // reverse: true에서는 pixels가 클수록 상단에 가까움
      final distanceToTop = position.pixels;
      if (distanceToTop >= position.maxScrollExtent - threshold &&
          position.maxScrollExtent > 0) {
        shouldLoadMore = true;
      }
    } else {
      // 하단 스크롤 감지 (일반 리스트용: reverse: false)
      // extentAfter: 하단까지 남은 거리
      if (position.extentAfter <= threshold && position.extentAfter > 0) {
        shouldLoadMore = true;
      }
    }

    if (shouldLoadMore) {
      // 디바운스: 이전 타이머 취소
      _debounceTimer?.cancel();
      debugPrint('🔥 디바운스 타이머 취소');

      // 100ms 후에 실행 (디바운스)
      _debounceTimer = Timer(const Duration(milliseconds: 100), () {
        debugPrint('🔥 디바운스 타이머 실행');
        final pagination = _getPagination?.call();
        final isLoading = _isLoading?.call() ?? false;

        // PaginationDto는 hasMore 사용
        final hasMoreData = pagination?.hasMore ?? false;

        // 로딩 중이 아니고, 더 불러올 데이터가 있을 때만 실행
        if (!isLoading &&
            !_isLoadingMore &&
            pagination != null &&
            hasMoreData) {
          _isLoadingMore = true; // 로딩 시작 플래그 설정
          _hasLoggedNoMoreData = false;

          final screenName = _screenName ?? 'Screen';
          final scrollType = _reverse ? '상단' : '하단';
          final position = _scrollController?.position;
          debugPrint('📜 [$screenName] $scrollType 스크롤 감지: '
              'extentAfter='
              '${position?.extentAfter.toStringAsFixed(0) ?? 'N/A'}, '
              'extentBefore='
              '${position?.extentBefore.toStringAsFixed(0) ?? 'N/A'}, '
              'maxScrollExtent='
              '${position?.maxScrollExtent.toStringAsFixed(0) ?? 'N/A'}');
          debugPrint('📦 [$screenName] 현재 페이지: ${pagination.page}, '
              '전체: ${pagination.totalCount}, hasMore: $hasMoreData');

          _onLoadMore?.call();

          // 로딩 완료 후 플래그 리셋 (isLoading이 false가 될 때까지 대기)
          // 주기적으로 체크하여 isLoading이 false가 되면 플래그 리셋
          _checkAndResetLoadingFlag();
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

  /// 로딩 완료 체크 및 플래그 리셋
  void _checkAndResetLoadingFlag() {
    // 기존 타이머 취소
    _loadingCheckTimer?.cancel();

    // 200ms마다 체크하여 isLoading이 false가 되면 플래그 리셋
    _loadingCheckTimer =
        Timer.periodic(const Duration(milliseconds: 200), (timer) {
      final isLoading = _isLoading?.call() ?? false;
      if (!isLoading) {
        _isLoadingMore = false;
        timer.cancel();
        _loadingCheckTimer = null;
        debugPrint('✅ 로딩 완료: 플래그 리셋');
      }
    });
  }

  /// 스크롤 컨트롤러 정리
  void disposePaginationScroll() {
    _debounceTimer?.cancel();
    _debounceTimer = null;
    _loadingCheckTimer?.cancel();
    _loadingCheckTimer = null;
    _scrollController?.removeListener(_onScroll);
    _scrollController?.dispose();
    _scrollController = null;
    _onLoadMore = null;
    _getPagination = null;
    _isLoading = null;
    _screenName = null;
    _reverse = false;
    _hasLoggedNoMoreData = false;
    _isLoadingMore = false; // 플래그 리셋
  }
}
