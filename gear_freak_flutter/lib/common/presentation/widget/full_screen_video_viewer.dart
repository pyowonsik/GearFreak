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
        });
        // 자동 재생
        await _controller!.play();
        await _controller!.setLooping(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
    }
  }

  @override
  void dispose() {
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
                  ? AspectRatio(
                      aspectRatio: _controller!.value.aspectRatio,
                      child: VideoPlayer(_controller!),
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
    );
  }
}
