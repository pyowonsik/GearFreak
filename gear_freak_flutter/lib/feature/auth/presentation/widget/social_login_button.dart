import 'package:flutter/material.dart';

/// 소셜 로그인 버튼 타입
enum SocialLoginType {
  /// 구글 로그인
  google,

  /// 애플 로그인
  apple,

  /// 카카오 로그인
  kakao,
}

/// 소셜 로그인 버튼
class SocialLoginButton extends StatelessWidget {
  /// SocialLoginButton 생성자
  ///
  /// [type]은 소셜 로그인 타입입니다.
  /// [onPressed]는 버튼 클릭 시 호출되는 콜백입니다.
  const SocialLoginButton({
    required this.type,
    required this.onPressed,
    super.key,
    this.isLoading = false,
  });

  /// 소셜 로그인 타입
  final SocialLoginType type;

  /// 버튼 클릭 시 호출되는 콜백
  final VoidCallback? onPressed;

  /// 로딩 상태
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final config = _getConfig(type);

    return SizedBox(
      height: 56,
      width: double.infinity,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: config.backgroundColor,
          foregroundColor: config.textColor,
          side: BorderSide(
            color: config.borderColor,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: isLoading
            ? SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(config.textColor),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 아이콘
                  if (config.icon != null) ...[
                    config.icon!,
                    const SizedBox(width: 12),
                  ],
                  // 텍스트
                  Text(
                    config.text,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: config.textColor,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  /// 소셜 로그인 타입별 설정 반환
  _SocialLoginConfig _getConfig(SocialLoginType type) {
    switch (type) {
      case SocialLoginType.google:
        return _SocialLoginConfig(
          text: '구글로 로그인',
          backgroundColor: Colors.white,
          textColor: const Color(0xFF1F2937),
          borderColor: const Color(0xFFE5E7EB),
          icon: Image.asset(
            'assets/icons/google_logo.png',
            width: 24,
            height: 24,
            errorBuilder: (context, error, stackTrace) {
              // 아이콘이 없으면 구글 컬러 원형 아이콘 사용
              return Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF4285F4), // Blue
                      Color(0xFF34A853), // Green
                      Color(0xFFFBBC05), // Yellow
                      Color(0xFFEA4335), // Red
                    ],
                    stops: [0.0, 0.33, 0.66, 1.0],
                  ),
                ),
                child: const Icon(
                  Icons.g_mobiledata,
                  size: 16,
                  color: Colors.white,
                ),
              );
            },
          ),
        );
      case SocialLoginType.apple:
        return const _SocialLoginConfig(
          text: 'Apple로 로그인',
          backgroundColor: Colors.black,
          textColor: Colors.white,
          borderColor: Colors.black,
          icon: Icon(
            Icons.apple,
            size: 24,
            color: Colors.white,
          ),
        );
      case SocialLoginType.kakao:
        return _SocialLoginConfig(
          text: '카카오로 로그인',
          backgroundColor: const Color(0xFFFEE500),
          textColor: const Color(0xFF000000),
          borderColor: const Color(0xFFFEE500),
          icon: Image.asset(
            'assets/icons/kakao_logo.png',
            width: 24,
            height: 24,
            errorBuilder: (context, error, stackTrace) {
              // 아이콘이 없으면 텍스트로 대체
              return const Text(
                'K',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF000000),
                ),
              );
            },
          ),
        );
    }
  }
}

/// 소셜 로그인 버튼 설정
class _SocialLoginConfig {
  /// _SocialLoginConfig 생성자
  const _SocialLoginConfig({
    required this.text,
    required this.backgroundColor,
    required this.textColor,
    required this.borderColor,
    this.icon,
  });

  /// 버튼 텍스트
  final String text;

  /// 배경색
  final Color backgroundColor;

  /// 텍스트 색상
  final Color textColor;

  /// 테두리 색상
  final Color borderColor;

  /// 아이콘
  final Widget? icon;
}
