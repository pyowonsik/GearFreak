import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';

/// 전체 화면 동영상 뷰어 위젯
class FullScreenVideoViewer extends StatefulWidget {
  /// FullScreenVideoViewer 생성자
  ///
  /// [videoUrl]은 재생할 동영상 URL입니다.
  /// [thumbnailUrl]은 썸네일 이미지 URL입니다. (선택적)
  const FullScreenVideoViewer({
    required this.videoUrl,
    this.thumbnailUrl,
    super.key,
  });

  /// 동영상 URL
  final String videoUrl;

  /// 썸네일 이미지 URL
  final String? thumbnailUrl;

  /// 전체 화면 동영상 뷰어 표시
  static Future<void> show({
    required BuildContext context,
    required String videoUrl,
    String? thumbnailUrl,
  }) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black,
      pageBuilder: (context, animation, secondaryAnimation) =>
          FullScreenVideoViewer(
        videoUrl: videoUrl,
        thumbnailUrl: thumbnailUrl,
      ),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  }

  @override
  State<FullScreenVideoViewer> createState() => _FullScreenVideoViewerState();
}

class _FullScreenVideoViewerState extends State<FullScreenVideoViewer> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  bool _showControls = true;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      _controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl),
      );

      await _controller!.initialize();

      if (mounted) {
        setState(() {
          _isInitialized = true;
          _isPlaying = true;
        });
        // 자동 재생
        await _controller!.play();
        await _controller!.setLooping(true);

        // 컨트롤러 리스너 추가 (재생 상태 업데이트)
        _controller!.addListener(_videoListener);

        // 3초 후 컨트롤 자동 숨김
        _hideControlsAfterDelay();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
    }
  }

  void _videoListener() {
    if (_controller != null && mounted) {
      setState(() {
        _isPlaying = _controller!.value.isPlaying;
      });
    }
  }

  void _hideControlsAfterDelay() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _controller != null && _controller!.value.isPlaying) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  void _togglePlayPause() {
    if (_controller == null) return;

    setState(() {
      _showControls = true;
    });

    if (_controller!.value.isPlaying) {
      _controller!.pause();
    } else {
      _controller!.play();
    }

    // 3초 후 다시 숨김
    _hideControlsAfterDelay();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _controller?.removeListener(_videoListener);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: _togglePlayPause,
          child: Center(
            child: _hasError
                ? const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.white54,
                      ),
                      SizedBox(height: 16),
                      Text(
                        '동영상 재생에 실패했습니다',
                        style: TextStyle(color: Colors.white54),
                      ),
                    ],
                  )
                : _isInitialized && _controller != null
                    ? Stack(
                        alignment: Alignment.center,
                        children: [
                          // 동영상 플레이어
                          AspectRatio(
                            aspectRatio: _controller!.value.aspectRatio,
                            child: VideoPlayer(_controller!),
                          ),
                          // 컨트롤 오버레이 (하단 고정)
                          Positioned.fill(
                            child: GestureDetector(
                              onTap: _togglePlayPause,
                              behavior: HitTestBehavior.translucent,
                              child: AnimatedOpacity(
                                opacity: _showControls ? 1.0 : 0.0,
                                duration: const Duration(milliseconds: 300),
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        Colors.black.withValues(alpha: 0.6),
                                      ],
                                    ),
                                  ),
                                  child: SafeArea(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        // 재생/일시정지 버튼
                                        IconButton(
                                          onPressed: _togglePlayPause,
                                          icon: Icon(
                                            _isPlaying
                                                ? Icons.pause_circle_filled
                                                : Icons.play_circle_filled,
                                            size: 64,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        // 진행바 및 시간 표시
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 24,
                                            vertical: 16,
                                          ),
                                          child: Column(
                                            children: [
                                              // 진행바
                                              VideoProgressIndicator(
                                                _controller!,
                                                allowScrubbing: true,
                                                colors:
                                                    const VideoProgressColors(
                                                  playedColor: Colors.white,
                                                  bufferedColor: Colors.white38,
                                                  backgroundColor:
                                                      Colors.white24,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              // 시간 표시
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    _formatDuration(
                                                      _controller!
                                                          .value.position,
                                                    ),
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                  Text(
                                                    _formatDuration(
                                                      _controller!
                                                          .value.duration,
                                                    ),
                                                    style: const TextStyle(
                                                      color: Colors.white70,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : Stack(
                        alignment: Alignment.center,
                        children: [
                          // 썸네일 배경 (반투명하게)
                          if (widget.thumbnailUrl != null)
                            Opacity(
                              opacity: 0.3,
                              child: CachedNetworkImage(
                                imageUrl: widget.thumbnailUrl!,
                                fit: BoxFit.contain,
                                width: double.infinity,
                                height: double.infinity,
                              ),
                            ),
                          // 로딩 인디케이터 (중앙에)
                          const Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(
                                color: Colors.white,
                              ),
                              SizedBox(height: 16),
                              Text(
                                '동영상 로딩 중...',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
          ),
        ),
      ),
    );
  }
}
