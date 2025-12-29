import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import 'package:gear_freak_flutter/common/s3/domain/usecase/upload_chat_room_image_usecase.dart';
import 'package:gear_freak_flutter/feature/chat/di/chat_providers.dart';
import 'package:gear_freak_flutter/feature/chat/domain/usecase/create_or_get_chat_room_usecase.dart';
import 'package:gear_freak_flutter/feature/chat/domain/usecase/get_chat_messages_usecase.dart';
import 'package:gear_freak_flutter/feature/chat/domain/usecase/get_chat_participants_usecase.dart';
import 'package:gear_freak_flutter/feature/chat/domain/usecase/get_chat_room_by_id_usecase.dart';
import 'package:gear_freak_flutter/feature/chat/domain/usecase/get_user_chat_rooms_by_product_id_usecase.dart';
import 'package:gear_freak_flutter/feature/chat/domain/usecase/join_chat_room_usecase.dart';
import 'package:gear_freak_flutter/feature/chat/domain/usecase/mark_chat_room_as_read_usecase.dart';
import 'package:gear_freak_flutter/feature/chat/domain/usecase/send_message_usecase.dart';
import 'package:gear_freak_flutter/feature/chat/domain/usecase/subscribe_chat_message_stream_usecase.dart';
import 'package:gear_freak_flutter/feature/chat/presentation/provider/chat_state.dart';
import 'package:gear_freak_flutter/feature/product/di/product_providers.dart';
import 'package:gear_freak_flutter/feature/product/domain/usecase/get_product_detail_usecase.dart';

/// 채팅 Notifier
/// Presentation Layer: Riverpod 상태 관리
class ChatNotifier extends StateNotifier<ChatState> {
  /// ChatNotifier 생성자
  ///
  /// [ref]는 Riverpod의 Ref 인스턴스입니다.
  /// [createOrGetChatRoomUseCase]는 채팅방 생성/조회 UseCase입니다.
  /// [getChatRoomByIdUseCase]는 채팅방 정보 조회 UseCase입니다.
  /// [getUserChatRoomsByProductIdUseCase]는 상품별 채팅방 목록 조회 UseCase입니다.
  /// [joinChatRoomUseCase]는 채팅방 참여 UseCase입니다.
  /// [getChatParticipantsUseCase]는 참여자 목록 조회 UseCase입니다.
  /// [getChatMessagesUseCase]는 메시지 조회 UseCase입니다.
  /// [sendMessageUseCase]는 메시지 전송 UseCase입니다.
  /// [subscribeChatMessageStreamUseCase]는 메시지 스트림 구독 UseCase입니다.
  /// [uploadChatRoomImageUseCase]는 채팅방 이미지 업로드 UseCase입니다.
  /// [getProductDetailUseCase]는 상품 상세 조회 UseCase입니다.
  /// [markChatRoomAsReadUseCase]는 채팅방 읽음 처리 UseCase입니다.
  ChatNotifier(
    this.ref,
    this.createOrGetChatRoomUseCase,
    this.getChatRoomByIdUseCase,
    this.getUserChatRoomsByProductIdUseCase,
    this.joinChatRoomUseCase,
    this.getChatParticipantsUseCase,
    this.getChatMessagesUseCase,
    this.sendMessageUseCase,
    this.subscribeChatMessageStreamUseCase,
    this.uploadChatRoomImageUseCase,
    this.getProductDetailUseCase,
    this.markChatRoomAsReadUseCase,
  ) : super(const ChatInitial()) {
    _messageStreamSubscription = null;
  }

  /// Riverpod Ref 인스턴스
  final Ref ref;

  /// 채팅방 생성/조회 UseCase
  final CreateOrGetChatRoomUseCase createOrGetChatRoomUseCase;

  /// 채팅방 정보 조회 UseCase
  final GetChatRoomByIdUseCase getChatRoomByIdUseCase;

  /// 상품별 채팅방 목록 조회 UseCase
  final GetUserChatRoomsByProductIdUseCase getUserChatRoomsByProductIdUseCase;

  /// 채팅방 참여 UseCase
  final JoinChatRoomUseCase joinChatRoomUseCase;

  /// 참여자 목록 조회 UseCase
  final GetChatParticipantsUseCase getChatParticipantsUseCase;

  /// 메시지 조회 UseCase
  final GetChatMessagesUseCase getChatMessagesUseCase;

  /// 메시지 전송 UseCase
  final SendMessageUseCase sendMessageUseCase;

  /// 메시지 스트림 구독 UseCase
  final SubscribeChatMessageStreamUseCase subscribeChatMessageStreamUseCase;

  /// 채팅방 이미지 업로드 UseCase
  final UploadChatRoomImageUseCase uploadChatRoomImageUseCase;

  /// 상품 상세 조회 UseCase
  final GetProductDetailUseCase getProductDetailUseCase;

  /// 채팅방 읽음 처리 UseCase
  final MarkChatRoomAsReadUseCase markChatRoomAsReadUseCase;

  /// 메시지 스트림 구독
  StreamSubscription<pod.ChatMessageResponseDto>? _messageStreamSubscription;

  // ==================== Public Methods (UseCase 호출) ====================

  /// 채팅방 생성 또는 조회 및 진입
  /// 상품 상세 화면에서 "1:1 채팅하기" 버튼 클릭 시 호출
  Future<void> createOrGetChatRoomAndEnter({
    required int productId,
    int? targetUserId,
  }) async {
    state = const ChatLoading();

    // 1. 채팅방 생성 또는 조회
    final createResult = await createOrGetChatRoomUseCase(
      CreateOrGetChatRoomParams(
        productId: productId,
        targetUserId: targetUserId,
      ),
    );

    await createResult.fold(
      (failure) async {
        state = ChatError(failure.message);
      },
      (response) async {
        if (!response.success || response.chatRoomId == null) {
          state = ChatError(response.message ?? '채팅방 생성에 실패했습니다.');
          return;
        }

        final chatRoomId = response.chatRoomId!;

        // 2. 새 채팅방이 생성된 경우 상품 정보 업데이트 (chatCount 반영)
        if (response.isNewChatRoom ?? false) {
          _updateProductAfterChatRoomCreated(productId);
        }

        // 3. 채팅방 로드 및 진입 (공통 로직)
        await _loadAndEnterChatRoom(chatRoomId);
      },
    );
  }

  /// 채팅방 ID로 직접 입장
  /// 채팅방 목록에서 기존 채팅방을 선택했을 때 호출
  Future<void> enterChatRoomByChatRoomId({
    required int chatRoomId,
  }) async {
    state = const ChatLoading();

    // 채팅방 로드 및 진입 (공통 로직)
    await _loadAndEnterChatRoom(chatRoomId);
  }

  /// 상품 정보만 로드 (채팅방이 없을 때)
  Future<void> loadProductInfo({
    required int productId,
    int? targetUserId,
  }) async {
    final productResult = await getProductDetailUseCase(productId);
    productResult.fold(
      (failure) {
        state = ChatError(failure.message);
      },
      (product) {
        state = ChatInitial(product: product);
      },
    );
  }

  /// 기존 채팅방 확인 및 로드
  /// 상품 ID와 판매자 ID로 기존 채팅방이 있는지 확인하고, 있으면 로드
  Future<void> checkAndLoadExistingChatRoom({
    required int productId,
    int? targetUserId,
  }) async {
    state = const ChatLoading();

    // 1. 해당 상품의 채팅방 목록 조회 (첫 페이지만)
    final chatRoomsResult = await getUserChatRoomsByProductIdUseCase(
      GetUserChatRoomsByProductIdParams(
        productId: productId,
        pagination: pod.PaginationDto(page: 1, limit: 20),
      ),
    );

    await chatRoomsResult.fold(
      (failure) async {
        // 채팅방 목록 조회 실패 시 상품 정보만 로드
        await loadProductInfo(
          productId: productId,
          targetUserId: targetUserId,
        );
      },
      (response) async {
        // 2. 기존 채팅방 찾기
        // targetUserId가 있으면 해당 사용자와의 1:1 채팅방 찾기
        pod.ChatRoom? existingChatRoom;
        if (targetUserId != null) {
          // 1:1 채팅방 찾기 (direct 타입이고 참여자가 2명인 방)
          try {
            existingChatRoom = response.chatRooms.firstWhere(
              (room) =>
                  room.chatRoomType == pod.ChatRoomType.direct &&
                  room.participantCount == 2,
            );
          } catch (e) {
            // 매칭되는 채팅방이 없으면 첫 번째 채팅방 사용
            existingChatRoom =
                response.chatRooms.isNotEmpty ? response.chatRooms.first : null;
          }
        } else {
          // targetUserId가 없으면 첫 번째 채팅방 사용
          existingChatRoom =
              response.chatRooms.isNotEmpty ? response.chatRooms.first : null;
        }

        if (existingChatRoom?.id != null) {
          // 3. 기존 채팅방이 있으면 해당 채팅방으로 입장
          await enterChatRoomByChatRoomId(
            chatRoomId: existingChatRoom!.id!,
          );
        } else {
          // 4. 기존 채팅방이 없으면 상품 정보만 로드 (빈 상태)
          await loadProductInfo(
            productId: productId,
            targetUserId: targetUserId,
          );
        }
      },
    );
  }

  /// 메시지 전송 (채팅방이 있는 경우)
  Future<void> sendMessage({
    required int chatRoomId,
    required String content,
    pod.MessageType messageType = pod.MessageType.text,
    String? attachmentUrl,
    String? attachmentName,
    int? attachmentSize,
  }) async {
    final result = await sendMessageUseCase(
      SendMessageParams(
        chatRoomId: chatRoomId,
        content: content,
        messageType: messageType,
        attachmentUrl: attachmentUrl,
        attachmentName: attachmentName,
        attachmentSize: attachmentSize,
      ),
    );

    result.fold(
      (failure) {
        // 에러는 스낵바로 표시 (호출하는 곳에서 처리)
      },
      (message) {
        // 새 메시지 이벤트 발행 (채팅방 목록 Notifier가 자동으로 반응)
        ref.read(newChatMessageProvider.notifier).state = message;
        // 이벤트 처리 후 초기화 (다음 메시지를 위해)
        Future.microtask(() {
          ref.read(newChatMessageProvider.notifier).state = null;
        });
      },
    );
  }

  /// 메시지 전송 (채팅방이 없는 경우, 카카오톡/당근마켓 방식)
  /// 첫 메시지 전송 시 채팅방 생성 후 메시지 전송
  Future<void> sendMessageWithoutChatRoom({
    required int productId,
    required String content,
    int? targetUserId,
    pod.MessageType messageType = pod.MessageType.text,
    String? attachmentUrl,
    String? attachmentName,
    int? attachmentSize,
  }) async {
    state = const ChatLoading();

    // 메시지 전송 (서버에서 채팅방이 없으면 생성)
    final result = await sendMessageUseCase(
      SendMessageParams(
        productId: productId,
        targetUserId: targetUserId,
        content: content,
        messageType: messageType,
        attachmentUrl: attachmentUrl,
        attachmentName: attachmentName,
        attachmentSize: attachmentSize,
      ),
    );

    await result.fold(
      (failure) async {
        state = ChatError(failure.message);
      },
      (message) async {
        // 메시지 전송 성공 후 채팅방 정보 로드
        final chatRoomId = message.chatRoomId;

        // 새 채팅방이 생성되었을 수 있으므로 상품 정보 업데이트 (chatCount 반영)
        _updateProductAfterChatRoomCreated(productId);

        // 채팅방 정보 조회 및 진입 (이미 스트림 연결 포함)
        await enterChatRoomByChatRoomId(chatRoomId: chatRoomId);

        // enterChatRoomByChatRoomId에서 이미 스트림을 연결하므로 추가 연결 불필요
        // 전송한 메시지는 enterChatRoomByChatRoomId에서 메시지 목록을 로드할 때 포함됨
      },
    );
  }

  /// 이전 메시지 로드 (페이지네이션)
  /// 채팅방에서는 위로 스크롤 시 다음 페이지(더 오래된 메시지)를 로드합니다.
  /// 서버는 orderDescending: true로 최신 메시지부터 반환하므로,
  /// page=1이 최신, page=2가 그 다음 오래된 메시지입니다.
  Future<void> loadMoreMessages(int chatRoomId) async {
    final currentState = state;
    if (currentState is! ChatLoaded || currentState is ChatLoadingMore) {
      return;
    }

    final pagination = currentState.pagination;
    // 채팅방은 위로 스크롤 시 더 오래된 메시지를 로드하므로 hasMore 확인
    if (pagination == null || pagination.pagination.hasMore != true) {
      return;
    }

    state = ChatLoadingMore(
      chatRoom: currentState.chatRoom,
      participants: currentState.participants,
      messages: currentState.messages,
      pagination: currentState.pagination,
      isStreamConnected: currentState.isStreamConnected,
      product: currentState.product,
    );

    final result = await getChatMessagesUseCase(
      GetChatMessagesParams(
        chatRoomId: chatRoomId,
        page: pagination.pagination.page + 1, // 다음 페이지 로드 (더 오래된 메시지)
        limit: pagination.pagination.limit,
      ),
    );

    result.fold(
      (failure) {
        // 에러 발생 시 이전 상태로 복구
        state = currentState;
      },
      (newPagination) {
        // 기존 메시지에 새 메시지 추가 (중복 제거)
        final existingIds = currentState.messages.map((m) => m.id).toSet();
        final newMessages = newPagination.messages
            .where((m) => !existingIds.contains(m.id))
            .toList();

        // 모든 메시지를 합치고 createdAt 기준 내림차순 정렬 (최신이 위)
        final updatedMessages = [
          ...currentState.messages,
          ...newMessages,
        ];
        _sortMessagesByCreatedAt(updatedMessages);

        state = currentState.copyWith(
          messages: updatedMessages,
          pagination: newPagination,
        );
      },
    );
  }

  /// 미디어 업로드 및 메시지 전송 (이미지/동영상)
  ///
  /// [chatRoomId]는 채팅방 ID입니다.
  /// [fileBytes]는 파일 바이트 데이터입니다.
  /// [fileName]은 파일 이름입니다.
  /// [contentType]은 파일의 Content-Type입니다.
  /// [fileSize]는 파일 크기입니다.
  /// [isVideo]는 동영상 파일인지 여부입니다.
  /// [thumbnailBytes]는 동영상 썸네일 바이트 데이터입니다. (동영상인 경우)
  /// [thumbnailFileName]는 썸네일 파일 이름입니다. (동영상인 경우)
  Future<void> uploadAndSendMedia({
    required int chatRoomId,
    required List<int> fileBytes,
    required String fileName,
    required String contentType,
    required int fileSize,
    required bool isVideo,
    Uint8List? thumbnailBytes,
    String? thumbnailFileName,
  }) async {
    final currentState = state;
    if (currentState is! ChatLoaded) {
      return;
    }

    try {
      // 1. 업로드 시작 상태로 변경
      state = ChatImageUploading(
        chatRoom: currentState.chatRoom,
        participants: currentState.participants,
        messages: currentState.messages,
        pagination: currentState.pagination,
        isStreamConnected: currentState.isStreamConnected,
        product: currentState.product,
        currentFileName: fileName,
      );

      // 2. 동영상인 경우 썸네일 먼저 업로드
      String? thumbnailUrl;
      if (isVideo && thumbnailBytes != null && thumbnailFileName != null) {
        debugPrint('📤 썸네일 업로드 시작...');
        final thumbnailUploadResult = await uploadChatRoomImageUseCase(
          UploadChatRoomImageParams(
            chatRoomId: chatRoomId,
            fileName: thumbnailFileName,
            contentType: 'image/jpeg',
            fileSize: thumbnailBytes.length,
            fileBytes: thumbnailBytes,
          ),
        );

        await thumbnailUploadResult.fold(
          (failure) async {
            debugPrint('❌ 썸네일 업로드 실패: ${failure.message}');
            // 썸네일 업로드 실패해도 동영상 업로드는 진행
          },
          (response) async {
            final s3BaseUrl = dotenv.env['S3_PRIVATE_BASE_URL'] ??
                'https://gear-freak-private-storage-3059875.s3.ap-northeast-2.amazonaws.com';
            thumbnailUrl = '$s3BaseUrl/${response.fileKey}';
            debugPrint('✅ 썸네일 업로드 완료: $thumbnailUrl');
          },
        );
      }

      // 3. 메인 파일 S3 업로드 (이미지 또는 동영상)
      final uploadResult = await uploadChatRoomImageUseCase(
        UploadChatRoomImageParams(
          chatRoomId: chatRoomId,
          fileName: fileName,
          contentType: contentType,
          fileSize: fileSize,
          fileBytes: fileBytes,
        ),
      );

      await uploadResult.fold(
        (failure) async {
          // 업로드 실패 시 에러 상태로 변경
          state = ChatImageUploadError(
            chatRoom: currentState.chatRoom,
            participants: currentState.participants,
            messages: currentState.messages,
            pagination: currentState.pagination,
            isStreamConnected: currentState.isStreamConnected,
            product: currentState.product,
            error: failure.message,
          );
        },
        (response) async {
          // 4. 업로드된 파일의 URL 생성 (Private 버킷)
          final s3BaseUrl = dotenv.env['S3_PRIVATE_BASE_URL'] ??
              'https://gear-freak-private-storage-3059875.s3.ap-northeast-2.amazonaws.com';
          final fileUrl = '$s3BaseUrl/${response.fileKey}';

          // 5. 메시지 전송 (동영상인 경우 썸네일 URL을 content에 포함)
          final messageContent = isVideo && thumbnailUrl != null
              ? thumbnailUrl! // 동영상인 경우 썸네일 URL을 content로 사용
              : fileName; // 이미지인 경우 파일 이름 사용

          final sendResult = await sendMessageUseCase(
            SendMessageParams(
              chatRoomId: chatRoomId,
              content: messageContent,
              messageType:
                  isVideo ? pod.MessageType.file : pod.MessageType.image,
              attachmentUrl: fileUrl,
              attachmentName: fileName,
              attachmentSize: fileSize,
            ),
          );

          // 6. 메시지 전송 결과 처리
          await sendResult.fold(
            (failure) async {
              // 메시지 전송 실패 시 에러 상태로 변경
              state = ChatImageUploadError(
                chatRoom: currentState.chatRoom,
                participants: currentState.participants,
                messages: currentState.messages,
                pagination: currentState.pagination,
                isStreamConnected: currentState.isStreamConnected,
                product: currentState.product,
                error: '메시지 전송에 실패했습니다: ${failure.message}',
              );
            },
            (sentMessage) async {
              // 메시지 전송 성공 시 메시지를 즉시 추가하고 상태 복원
              // (스트림을 통해 중복 수신될 수 있지만 중복 체크로 처리됨)
              final existingIds =
                  currentState.messages.map((m) => m.id).toSet();
              final updatedMessages = existingIds.contains(sentMessage.id)
                  ? currentState.messages
                  : [...currentState.messages, sentMessage];
              _sortMessagesByCreatedAt(updatedMessages);

              state = ChatLoaded(
                chatRoom: currentState.chatRoom,
                participants: currentState.participants,
                messages: updatedMessages,
                pagination: currentState.pagination,
                isStreamConnected: currentState.isStreamConnected,
                product: currentState.product,
              );
            },
          );
        },
      );
    } catch (e, stackTrace) {
      debugPrint('❌ 미디어 업로드 오류: $e');
      debugPrint('Stack trace: $stackTrace');
      state = ChatImageUploadError(
        chatRoom: currentState.chatRoom,
        participants: currentState.participants,
        messages: currentState.messages,
        pagination: currentState.pagination,
        isStreamConnected: currentState.isStreamConnected,
        product: currentState.product,
        error: '업로드 중 오류가 발생했습니다: $e',
      );
    }
  }

  /// 채팅방 읽음 처리 (뒤로가기 시 호출)
  Future<void> markChatRoomAsRead(int chatRoomId) async {
    final markReadResult = await markChatRoomAsReadUseCase(
      MarkChatRoomAsReadParams(chatRoomId: chatRoomId),
    );
    markReadResult.fold(
      (failure) {
        // 읽음 처리 실패해도 에러 표시하지 않음 (뒤로가기 중이므로)
        debugPrint('채팅방 읽음 처리 실패: ${failure.message}');
      },
      (_) {
        // 읽음 처리 성공 시 이벤트 발행 (채팅방 목록 Notifier가 자동으로 반응)
        ref.read(chatRoomReadProvider.notifier).state = chatRoomId;
        // 이벤트 처리 후 초기화 (다음 읽음 처리를 위해)
        Future.microtask(() {
          ref.read(chatRoomReadProvider.notifier).state = null;
        });
      },
    );
  }

  // ==================== Private Helper Methods ====================

  /// 채팅방 생성 후 상품 정보 업데이트 (chatCount 반영)
  void _updateProductAfterChatRoomCreated(int productId) {
    // 상품 정보를 다시 조회하여 updatedProductProvider에 이벤트 발행
    getProductDetailUseCase(productId).then((result) {
      result.fold(
        (failure) {
          debugPrint('채팅방 생성 후 상품 정보 조회 실패: ${failure.message}');
        },
        (updatedProduct) {
          debugPrint(
              '채팅방 생성 후 상품 정보 업데이트: productId=$productId, chatCount=${updatedProduct.chatCount}');
          // 상품 업데이트 이벤트 발행 (모든 목록 Provider가 자동으로 반응)
          ref.read(updatedProductProvider.notifier).state = updatedProduct;
          // 이벤트 처리 후 초기화 (다음 업데이트를 위해)
          Future.microtask(() {
            ref.read(updatedProductProvider.notifier).state = null;
          });
        },
      );
    });
  }

  /// 메시지를 createdAt 기준으로 내림차순 정렬 (최신이 위)
  void _sortMessagesByCreatedAt(List<pod.ChatMessageResponseDto> messages) {
    messages.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// 중복 메시지 확인 및 이벤트 발행
  /// 중복이 아닌 경우 이벤트를 발행하고 true를 반환합니다.
  bool _addMessageIfNotDuplicate(
    List<pod.ChatMessageResponseDto> messages,
    pod.ChatMessageResponseDto message,
  ) {
    final existingIds = messages.map((m) => m.id).toSet();
    if (!existingIds.contains(message.id)) {
      // 새 메시지 이벤트 발행 (채팅방 목록 Notifier가 자동으로 반응)
      ref.read(newChatMessageProvider.notifier).state = message;
      // 이벤트 처리 후 초기화 (다음 메시지를 위해)
      Future.microtask(() {
        ref.read(newChatMessageProvider.notifier).state = null;
      });
      return true;
    }
    return false;
  }

  /// 채팅방 로드 및 진입 (공통 로직)
  /// 채팅방 정보 조회부터 스트림 연결까지의 모든 공통 로직을 처리합니다.
  Future<void> _loadAndEnterChatRoom(int chatRoomId) async {
    // 1. 채팅방 정보 조회
    final roomResult = await getChatRoomByIdUseCase(
      GetChatRoomByIdParams(chatRoomId: chatRoomId),
    );

    await roomResult.fold(
      (failure) async {
        state = ChatError(failure.message);
      },
      (chatRoom) async {
        if (chatRoom == null) {
          state = const ChatError('채팅방 정보를 찾을 수 없습니다.');
          return;
        }

        // 2. 채팅방 참여
        final joinResult = await joinChatRoomUseCase(
          JoinChatRoomParams(chatRoomId: chatRoomId),
        );

        await joinResult.fold(
          (failure) async {
            state = ChatError(failure.message);
          },
          (joinResponse) async {
            if (!joinResponse.success) {
              state = ChatError(joinResponse.message ?? '채팅방 참여에 실패했습니다.');
              return;
            }

            // 3. 참여자 목록 조회
            final participantsResult = await getChatParticipantsUseCase(
              GetChatParticipantsParams(chatRoomId: chatRoomId),
            );

            final participants = participantsResult.fold(
              (failure) => <pod.ChatParticipantInfoDto>[],
              (list) => list,
            );

            // 4. 메시지 조회 (초기 로드)
            // 서버는 orderDescending: true로 최신 메시지부터 반환하므로 첫 페이지를 로드
            final messagesResult = await getChatMessagesUseCase(
              GetChatMessagesParams(
                chatRoomId: chatRoomId,
              ),
            );

            final messagesData = messagesResult.fold(
              (failure) => (
                messages: <pod.ChatMessageResponseDto>[],
                pagination: null as pod.PaginatedChatMessagesResponseDto?,
              ),
              (pagination) {
                // flutter_chat_ui는 내림차순(최신이 위)을 기대하므로 내림차순 정렬
                final sortedMessages = pagination.messages.toList();
                _sortMessagesByCreatedAt(sortedMessages);
                return (
                  messages: sortedMessages,
                  pagination: pagination,
                );
              },
            );

            // 5. 상품 정보 조회
            pod.Product? product;
            final productResult =
                await getProductDetailUseCase(chatRoom.productId);
            productResult.fold(
              (failure) {
                // 상품 정보 조회 실패해도 채팅은 계속 진행
              },
              (productData) {
                product = productData;
              },
            );

            // 6. 읽음 처리 (공통 메서드 호출)
            await markChatRoomAsRead(chatRoomId);

            // 7. 스트림 연결
            _connectMessageStream(chatRoomId);

            state = ChatLoaded(
              chatRoom: chatRoom,
              participants: participants,
              messages: messagesData.messages,
              pagination: messagesData.pagination,
              isStreamConnected: true,
              product: product,
            );
          },
        );
      },
    );
  }

  /// 메시지 스트림 연결
  void _connectMessageStream(int chatRoomId) {
    // 기존 스트림 해제
    _messageStreamSubscription?.cancel();

    // 새 스트림 구독
    final stream = subscribeChatMessageStreamUseCase(
      SubscribeChatMessageStreamParams(chatRoomId: chatRoomId),
    );

    _messageStreamSubscription = stream.listen(
      (message) {
        // 실시간 메시지 수신
        final currentState = state;

        // ChatLoaded를 상속한 모든 상태에서 메시지 추가 가능
        switch (currentState) {
          case ChatImageUploading(
              :final chatRoom,
              :final participants,
              :final messages,
              :final pagination,
              :final isStreamConnected,
              :final product,
              :final currentFileName
            ):
            // 중복 메시지 확인 및 이벤트 발행
            if (_addMessageIfNotDuplicate(messages, message)) {
              // 메시지 추가 후 createdAt 기준 내림차순 정렬 (최신이 위)
              final updatedMessages = [...messages, message];
              _sortMessagesByCreatedAt(updatedMessages);

              // 업로드 중이면 메시지만 추가하고 상태 유지
              state = ChatImageUploading(
                chatRoom: chatRoom,
                participants: participants,
                messages: updatedMessages,
                pagination: pagination,
                isStreamConnected: isStreamConnected,
                product: product,
                currentFileName: currentFileName,
              );
            }
          case ChatImageUploadError(
              :final chatRoom,
              :final participants,
              :final messages,
              :final pagination,
              :final isStreamConnected,
              :final product,
              :final error
            ):
            // 중복 메시지 확인 및 이벤트 발행
            if (_addMessageIfNotDuplicate(messages, message)) {
              // 메시지 추가 후 createdAt 기준 내림차순 정렬 (최신이 위)
              final updatedMessages = [...messages, message];
              _sortMessagesByCreatedAt(updatedMessages);

              // 에러 상태면 메시지만 추가하고 상태 유지
              state = ChatImageUploadError(
                chatRoom: chatRoom,
                participants: participants,
                messages: updatedMessages,
                pagination: pagination,
                isStreamConnected: isStreamConnected,
                product: product,
                error: error,
              );
            }
          case ChatLoaded(:final messages) || ChatLoadingMore(:final messages):
            // 중복 메시지 확인 및 이벤트 발행
            if (_addMessageIfNotDuplicate(messages, message)) {
              // 메시지 추가 후 createdAt 기준 내림차순 정렬 (최신이 위)
              final updatedMessages = [...messages, message];
              _sortMessagesByCreatedAt(updatedMessages);

              // 일반 ChatLoaded 또는 ChatLoadingMore 상태
              if (currentState is ChatLoaded) {
                state = currentState.copyWith(
                  messages: updatedMessages,
                );
              } else if (currentState is ChatLoadingMore) {
                state = ChatLoadingMore(
                  chatRoom: currentState.chatRoom,
                  participants: currentState.participants,
                  messages: updatedMessages,
                  pagination: currentState.pagination,
                  isStreamConnected: currentState.isStreamConnected,
                  product: currentState.product,
                );
              }
            }
          default:
            break;
        }
      },
      onError: (error) {
        // 에러 처리
        final currentState = state;
        if (currentState is ChatLoaded) {
          state = currentState.copyWith(isStreamConnected: false);
        }
      },
    );
  }

  @override
  void dispose() {
    _messageStreamSubscription?.cancel();
    super.dispose();
  }
}
