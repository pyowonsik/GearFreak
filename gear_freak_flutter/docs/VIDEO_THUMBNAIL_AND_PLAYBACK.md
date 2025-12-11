# 동영상 썸네일 및 재생 기능 구현 가이드

## 개요

채팅에서 동영상 파일을 업로드하고 표시하는 기능입니다. 동영상 파일에서 썸네일을 생성하여 채팅 UI에 표시하고, 사용자가 탭하면 전체 화면에서 동영상을 재생할 수 있습니다.

## 전체 흐름

```
동영상 파일 선택
  ↓
VideoThumbnail.thumbnailData → 썸네일 이미지(JPEG) 생성
  ↓
썸네일 S3 업로드 → 썸네일 URL
동영상 S3 업로드 → 동영상 URL
  ↓
채팅 UI: 썸네일 이미지 표시 + 재생 버튼 오버레이
  ↓
탭 시: FullScreenVideoViewer → VideoPlayerController가 S3 동영상 URL로 재생
```

## 주요 컴포넌트

### 1. 썸네일 생성 (`chat_loaded_view.dart`)

**라이브러리**: `video_thumbnail: ^0.5.3`

```dart
// 동영상인 경우 썸네일 생성
if (isVideo) {
  final thumbnail = await VideoThumbnail.thumbnailData(
    video: media.path,
    imageFormat: ImageFormat.JPEG,
    maxWidth: 300, // 이미지와 동일한 최대 너비
    quality: 75,
  );
  
  if (thumbnail != null) {
    thumbnailBytes = thumbnail; // JPEG 바이트 데이터
    thumbnailFileName = '${fileName.split('.').first}_thumb.jpg';
  }
}
```

**설명**:
- `VideoThumbnail.thumbnailData`가 동영상 파일에서 썸네일 이미지를 생성합니다
- 반환값은 JPEG 형식의 바이트 데이터(`Uint8List`)입니다
- 썸네일은 300px 최대 너비, 75% 품질로 생성됩니다

### 2. S3 업로드 (`chat_notifier.dart`)

**썸네일 업로드**:
```dart
// 1. 썸네일 먼저 업로드
if (isVideo && thumbnailBytes != null && thumbnailFileName != null) {
  final thumbnailUploadResult = await uploadChatRoomImageUseCase(
    UploadChatRoomImageParams(
      chatRoomId: chatRoomId,
      fileName: thumbnailFileName,
      contentType: 'image/jpeg',
      fileSize: thumbnailBytes.length,
      fileBytes: thumbnailBytes,
    ),
  );
  
  // 썸네일 URL 생성
  thumbnailUrl = '$s3BaseUrl/${response.fileKey}';
}
```

**동영상 업로드**:
```dart
// 2. 동영상 파일 업로드
final uploadResult = await uploadChatRoomImageUseCase(
  UploadChatRoomImageParams(
    chatRoomId: chatRoomId,
    fileName: fileName,
    contentType: contentType, // video/quicktime, video/mp4 등
    fileSize: fileSize,
    fileBytes: fileBytes,
  ),
);

// 동영상 URL 생성
final fileUrl = '$s3BaseUrl/${response.fileKey}';
```

**메시지 전송**:
```dart
// 동영상인 경우 썸네일 URL을 content에 저장
final messageContent = isVideo && thumbnailUrl != null
    ? thumbnailUrl! // 썸네일 URL
    : fileName; // 이미지인 경우 파일 이름

await sendMessageUseCase(
  SendMessageParams(
    chatRoomId: chatRoomId,
    content: messageContent, // 썸네일 URL
    messageType: pod.MessageType.file, // 동영상은 file 타입
    attachmentUrl: fileUrl, // 실제 동영상 URL
    attachmentName: fileName,
    attachmentSize: fileSize,
  ),
);
```

**설명**:
- 썸네일과 동영상 모두 **Private S3 버킷**에 업로드됩니다
- 경로: `chatRoom/{chatRoomId}/{fileName}`
- 썸네일 URL은 메시지의 `content` 필드에 저장됩니다
- 동영상 URL은 메시지의 `attachmentUrl` 필드에 저장됩니다

### 3. 채팅 UI 표시 (`chat_message_bubble_widget.dart`)

**썸네일 이미지 표시**:
```dart
Stack(
  children: [
    // 썸네일 이미지 (S3 URL)
    CachedNetworkImage(
      imageUrl: imageUrl!, // 썸네일 URL
      cacheKey: _extractFileKeyFromUrl(imageUrl!),
      fit: BoxFit.cover,
      // ... 캐싱 최적화 설정
    ),
    // 동영상인 경우 재생 버튼 오버레이
    if (isVideo)
      Positioned.fill(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3), // 반투명 오버레이
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Icon(
              Icons.play_circle_filled,
              size: 48,
              color: Colors.white,
            ),
          ),
        ),
      ),
  ],
)
```

**설명**:
- 썸네일 이미지를 `CachedNetworkImage`로 표시합니다
- 동영상인 경우 `Stack`으로 재생 버튼 아이콘을 오버레이합니다
- 반투명 검은색 배경(`opacity: 0.3`)으로 오버레이 효과를 줍니다

### 4. 동영상 재생 (`full_screen_video_viewer.dart`)

**라이브러리**: `video_player: ^2.8.2`

**동영상 초기화 및 재생**:
```dart
Future<void> _initializeVideo() async {
  try {
    _controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.videoUrl), // S3 동영상 URL
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
    // 에러 처리
    setState(() {
      _hasError = true;
    });
  }
}
```

**UI 구성**:
```dart
_isInitialized && _controller != null
    ? AspectRatio(
        aspectRatio: _controller!.value.aspectRatio,
        child: VideoPlayer(_controller!),
      )
    : Stack(
        alignment: Alignment.center,
        children: [
          // 썸네일 배경 (반투명)
          if (widget.thumbnailUrl != null)
            Opacity(
              opacity: 0.3,
              child: CachedNetworkImage(
                imageUrl: widget.thumbnailUrl!,
                fit: BoxFit.contain,
              ),
            ),
          // 로딩 인디케이터
          const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 16),
              Text('동영상 로딩 중...'),
            ],
          ),
        ],
      )
```

**설명**:
- `VideoPlayerController.networkUrl`로 S3의 동영상 URL을 읽어옵니다
- 동영상이 초기화되면 자동으로 재생되고 반복됩니다
- 로딩 중에는 썸네일을 반투명 배경으로 표시하고 로딩 인디케이터를 보여줍니다

## 데이터 구조

### 메시지 변환 (`chat_util.dart`)

동영상 메시지는 다음과 같이 변환됩니다:

```dart
// 동영상인 경우
if (isVideoFile && isThumbnailUrl) {
  return types.ImageMessage(
    author: author,
    createdAt: message.createdAt.millisecondsSinceEpoch,
    id: message.id.toString(),
    name: 'VIDEO_URL:${message.attachmentUrl}|${message.attachmentName}',
    // 실제 동영상 URL과 파일 이름을 name에 저장
    size: message.attachmentSize?.toDouble() ?? 0,
    uri: message.content, // 썸네일 URL
  );
}
```

**설명**:
- `ImageMessage`로 변환하되, `name` 필드에 실제 동영상 URL을 저장합니다
- 형식: `"VIDEO_URL:{동영상URL}|{파일이름}"`
- `uri` 필드에는 썸네일 URL이 저장됩니다

### URL 파싱 (`chat_message_list_widget.dart`)

```dart
// name에서 동영상 URL 추출
if (message.name.startsWith('VIDEO_URL:')) {
  final parts = message.name.substring(10).split('|');
  if (parts.length >= 2) {
    videoUrl = parts[0]; // 실제 동영상 URL
    displayName = parts[1]; // 파일 이름
    isVideo = true;
  }
}
```

## 파일 구조

```
gear_freak_flutter/
├── lib/
│   ├── feature/
│   │   └── chat/
│   │       └── presentation/
│   │           ├── view/
│   │           │   └── chat_loaded_view.dart          # 썸네일 생성
│   │           ├── widget/
│   │           │   ├── chat_message_bubble_widget.dart # 썸네일 표시
│   │           │   └── chat_message_list_widget.dart   # URL 파싱
│   │           ├── provider/
│   │           │   └── chat_notifier.dart              # S3 업로드
│   │           └── utils/
│   │               └── chat_util.dart                  # 메시지 변환
│   └── common/
│       └── presentation/
│           └── widget/
│               └── full_screen_video_viewer.dart       # 동영상 재생
└── pubspec.yaml
```

## 지원하는 동영상 형식

현재 지원하는 동영상 확장자:
- `.mov` (video/quicktime)
- `.mp4` (video/mp4)
- `.avi` (video/x-msvideo)
- `.mkv` (video/x-matroska)
- `.webm` (video/webm)
- `.m4v` (video/x-m4v)
- `.3gp` (video/3gpp)

## 주요 특징

1. **썸네일 자동 생성**: 동영상 업로드 시 자동으로 썸네일을 생성합니다
2. **S3 업로드**: 썸네일과 동영상 모두 Private S3 버킷에 업로드됩니다
3. **캐싱 최적화**: `CachedNetworkImage`로 썸네일을 캐싱하여 성능을 최적화합니다
4. **Presigned URL**: Private 버킷의 동영상은 Presigned URL로 접근합니다
5. **자동 재생**: 전체 화면 뷰어에서 동영상이 자동으로 재생됩니다
6. **반복 재생**: 동영상이 끝나면 자동으로 반복 재생됩니다

## 에러 처리

1. **썸네일 생성 실패**: 썸네일 생성이 실패해도 동영상 업로드는 계속 진행됩니다
2. **썸네일 업로드 실패**: 썸네일 업로드가 실패해도 동영상 업로드는 계속 진행됩니다
3. **동영상 재생 실패**: 재생 실패 시 에러 메시지를 표시합니다

## 향후 개선 사항

- [ ] 동영상 재생 컨트롤 (일시정지, 재생, 진행바 등)
- [ ] 동영상 다운로드 기능
- [ ] 동영상 압축 (용량 최적화)
- [ ] 썸네일 재생성 기능
- [ ] 동영상 스트리밍 최적화

