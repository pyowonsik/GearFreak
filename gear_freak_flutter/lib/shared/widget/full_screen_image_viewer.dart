import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 전체 화면 이미지 뷰어 위젯
class FullScreenImageViewer extends StatelessWidget {
  /// FullScreenImageViewer 생성자
  ///
  /// [imageUrl]은 표시할 이미지 URL입니다.
  const FullScreenImageViewer({
    required this.imageUrl,
    super.key,
  });

  /// 이미지 URL
  final String imageUrl;

  /// 전체 화면 이미지 뷰어 표시
  static Future<void> show({
    required BuildContext context,
    required String imageUrl,
  }) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black,
      pageBuilder: (context, animation, secondaryAnimation) =>
          FullScreenImageViewer(imageUrl: imageUrl),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
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
          child: InteractiveViewer(
            minScale: 0.5,
            maxScale: 4,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.contain,
                fadeInDuration: Duration.zero,
                fadeOutDuration: Duration.zero,
                placeholderFadeInDuration: Duration.zero,
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                ),
                errorWidget: (context, url, error) => const Center(
                  child: Icon(
                    Icons.broken_image_outlined,
                    size: 64,
                    color: Colors.white54,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
