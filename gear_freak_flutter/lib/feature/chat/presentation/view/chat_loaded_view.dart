import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import 'package:gear_freak_flutter/common/presentation/component/component.dart';
import 'package:gear_freak_flutter/common/utils/format_utils.dart';
import 'package:gear_freak_flutter/common/utils/pagination_scroll_mixin.dart';
import 'package:gear_freak_flutter/feature/chat/di/chat_providers.dart';
import 'package:gear_freak_flutter/feature/chat/presentation/utils/chat_util.dart';
import 'package:gear_freak_flutter/feature/chat/presentation/widget/widget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

/// 채팅 로드 완료 상태 UI View
class ChatLoadedView extends ConsumerStatefulWidget {
  /// ChatLoadedView 생성자
  ///
  /// [chatRoom]는 채팅방 정보입니다.
  /// [messages]는 메시지 목록입니다.
  /// [participants]는 참여자 목록입니다.
  /// [pagination]는 페이지네이션 정보입니다.
  /// [product]는 상품 정보입니다.
  /// [currentUser]는 현재 사용자 정보입니다.
  /// [currentUserId]는 현재 사용자 ID입니다.
  /// [isLoadingMore]는 추가 메시지 로딩 중 여부입니다.
  /// [isImageUploading]는 이미지 업로드 중 여부입니다.
  /// [imageUploadError]는 이미지 업로드 에러 메시지입니다.
  /// [onLoadMore]는 이전 메시지 로드 콜백입니다.
  /// [onSendPressed]는 메시지 전송 콜백입니다.
  /// [convertMessages]는 메시지 변환 함수입니다.
  const ChatLoadedView({
    required this.chatRoom,
    required this.messages,
    required this.participants,
    required this.pagination,
    required this.currentUser,
    required this.currentUserId,
    required this.isLoadingMore,
    required this.onLoadMore,
    required this.onSendPressed,
    required this.convertMessages,
    this.product,
    this.isImageUploading = false,
    this.imageUploadError,
    super.key,
  });

  /// 채팅방 정보
  final pod.ChatRoom chatRoom;

  /// 메시지 목록
  final List<pod.ChatMessageResponseDto> messages;

  /// 참여자 목록
  final List<pod.ChatParticipantInfoDto> participants;

  /// 페이지네이션 정보
  final pod.PaginatedChatMessagesResponseDto? pagination;

  /// 상품 정보
  final pod.Product? product;

  /// 현재 사용자 정보
  final types.User currentUser;

  /// 현재 사용자 ID
  final int? currentUserId;

  /// 추가 메시지 로딩 중 여부
  final bool isLoadingMore;

  /// 이미지 업로드 중 여부
  final bool isImageUploading;

  /// 이미지 업로드 에러 메시지
  final String? imageUploadError;

  /// 이전 메시지 로드 콜백
  final VoidCallback? onLoadMore;

  /// 메시지 전송 콜백
  final void Function(types.PartialText) onSendPressed;

  /// 메시지 변환 함수
  final List<types.Message> Function(
    List<pod.ChatMessageResponseDto>,
    List<pod.ChatParticipantInfoDto>,
    int?,
  ) convertMessages;

  @override
  ConsumerState<ChatLoadedView> createState() => _ChatLoadedViewState();
}

class _ChatLoadedViewState extends ConsumerState<ChatLoadedView>
    with PaginationScrollMixin {
  final TextEditingController _messageController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // PaginationScrollMixin 초기화 (채팅용: reverse: true)
    initPaginationScroll(
      onLoadMore: () {
        widget.onLoadMore?.call();
      },
      getPagination: () => widget.pagination?.pagination,
      isLoading: () => widget.isLoadingMore,
      screenName: 'ChatLoadedView',
      reverse: true, // 채팅은 상단 스크롤 감지
    );
  }

  @override
  void dispose() {
    disposePaginationScroll();
    _messageController.dispose();
    super.dispose();
  }

  /// 메시지 전송
  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    widget.onSendPressed(
      types.PartialText(text: _messageController.text.trim()),
    );

    _messageController.clear();
  }

  /// 파일 첨부 옵션 표시
  Future<void> _showAttachmentOptions() async {
    if (!mounted) return;

    await GbBottomSheet.show(
      context: context,
      items: [
        GbBottomSheetItem(
          leading: Icons.photo_library,
          title: '이미지/동영상 선택하기',
          onTap: () => _pickMedia(ImageSource.gallery),
        ),
        GbBottomSheetItem(
          leading: Icons.camera_alt,
          title: '사진 촬영하기',
          onTap: () => _pickMedia(ImageSource.camera),
        ),
      ],
    );
  }

  /// 미디어 선택 (이미지/동영상)
  Future<void> _pickMedia(ImageSource source) async {
    if (!mounted) return;

    try {
      XFile? media;

      if (source == ImageSource.camera) {
        // 카메라: 이미지만 촬영
        media = await _imagePicker.pickImage(
          source: ImageSource.camera,
          imageQuality: 85,
        );
      } else {
        // 갤러리: 이미지와 동영상을 모두 선택할 수 있도록 pickMedia 사용
        media = await _imagePicker.pickMedia(
          imageQuality: 85,
        );
      }

      if (media != null && mounted) {
        await _uploadAndSendMedia(media);
      }
    } catch (e) {
      if (mounted) {
        debugPrint('미디어 선택 오류: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('이미지 선택에 실패했습니다.')),
        );
      }
    }
  }

  /// 미디어 업로드 및 메시지 전송 (이미지/동영상)
  Future<void> _uploadAndSendMedia(XFile media) async {
    if (!mounted) return;

    try {
      // 1. 파일 읽기
      final fileBytes = await media.readAsBytes();
      final fileName = media.path.split('/').last;
      final fileSize = fileBytes.length;

      // 2. 파일 타입 확인
      final isVideo = ChatUtil.isVideoFile(fileName);
      final contentType = ChatUtil.getContentType(fileName);

      // 3. 동영상인 경우 썸네일 생성
      Uint8List? thumbnailBytes;
      String? thumbnailFileName;

      if (isVideo) {
        debugPrint('🎬 동영상 썸네일 생성 중...');
        try {
          final thumbnail = await VideoThumbnail.thumbnailData(
            video: media.path,
            imageFormat: ImageFormat.JPEG,
            maxWidth: 300, // 이미지와 동일한 최대 너비
            quality: 75,
          );

          if (thumbnail != null) {
            thumbnailBytes = thumbnail;
            thumbnailFileName = '${fileName.split('.').first}_thumb.jpg';
            debugPrint(
              '✅ 썸네일 생성 완료: $thumbnailFileName (${thumbnailBytes.length} bytes)',
            );
          } else {
            debugPrint('⚠️ 썸네일 생성 실패: null 반환');
          }
        } catch (e) {
          debugPrint('❌ 썸네일 생성 오류: $e');
          // 썸네일 생성 실패해도 동영상 업로드는 진행
        }
      }

      debugPrint('📤 미디어 업로드 시작:');
      debugPrint('   - 파일명: $fileName');
      debugPrint('   - 파일 크기: $fileSize bytes');
      debugPrint('   - Content-Type: $contentType');
      debugPrint('   - 타입: ${isVideo ? "동영상" : "이미지"}');
      if (thumbnailBytes != null) {
        debugPrint(
          '   - 썸네일: $thumbnailFileName (${thumbnailBytes.length} bytes)',
        );
      }

      // 4. Notifier를 통해 S3 업로드 및 메시지 전송
      await ref.read(chatNotifierProvider.notifier).uploadAndSendMedia(
            chatRoomId: widget.chatRoom.id!,
            fileBytes: fileBytes,
            fileName: fileName,
            contentType: contentType,
            fileSize: fileSize,
            isVideo: isVideo,
            thumbnailBytes: thumbnailBytes,
            thumbnailFileName: thumbnailFileName,
          );

      // 상태는 실시간으로 업데이트되므로 여기서는 추가 처리 불필요
      // 에러는 ChatImageUploadError 상태로 관리됨
    } catch (e) {
      debugPrint('❌ 미디어 업로드 오류: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              ChatUtil.isVideoFile(media.path.split('/').last)
                  ? '동영상 전송 중 오류가 발생했습니다.'
                  : '이미지 전송 중 오류가 발생했습니다.',
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 상품 정보
    final productName = widget.product?.title ?? '상품 정보 없음';
    final price = widget.product != null
        ? '${formatPrice(widget.product!.price)}원'
        : '가격 정보 없음';

    // 메시지를 flutter_chat_types로 변환
    final convertedMessages = widget.convertMessages(
      widget.messages,
      widget.participants,
      widget.currentUserId,
    );

    return Stack(
      children: [
        Column(
          children: [
            // 상품 정보 카드
            ChatProductInfoCardWidget(
              productName: productName,
              price: price,
              product: widget.product,
            ),

            // 채팅 메시지 목록
            Expanded(
              child: ChatMessageListWidget(
                messages: convertedMessages,
                currentUserId: widget.currentUser.id,
                scrollController: scrollController!,
                isLoadingMore: widget.isLoadingMore,
              ),
            ),

            // 메시지 입력창
            ChatMessageInputWidget(
              controller: _messageController,
              onSend: _sendMessage,
              onAddPressed:
                  widget.isImageUploading ? null : _showAttachmentOptions,
            ),
          ],
        ),

        // 이미지 업로드 로딩 인디케이터
        if (widget.isImageUploading)
          Positioned.fill(
            child: ColoredBox(
              color: Colors.black.withValues(alpha: 0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ),

        // 이미지 업로드 에러 메시지
        if (widget.imageUploadError != null)
          Positioned(
            bottom: 80,
            left: 16,
            right: 16,
            child: Material(
              color: Colors.red,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.white),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.imageUploadError!,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () {
                        // 에러 메시지 닫기 (상태는 그대로 유지)
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
