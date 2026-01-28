# 스크린샷 및 데모 준비 가이드

README 포트폴리오용 스크린샷과 GIF 데모를 준비하기 위한 가이드입니다.

## 필요한 스크린샷 (최소 4장)

### 1. 홈 화면 (`screenshots/home.png`)
- 상품 목록이 보이는 메인 화면
- 카테고리 필터, 정렬 옵션 포함

### 2. 상품 상세 (`screenshots/product_detail.png`)
- 상품 이미지, 가격, 설명이 보이는 화면
- 찜하기 버튼, 채팅하기 버튼 포함

### 3. 채팅 (`screenshots/chat.png`)
- 실시간 채팅 화면
- 메시지 주고받는 모습

### 4. 프로필/마이페이지 (`screenshots/profile.png`)
- 사용자 프로필 화면
- 내 상품, 찜 목록, 리뷰 등

### 추가 권장 스크린샷 (선택)
- `screenshots/login.png` - 로그인 화면 (소셜 로그인 버튼들)
- `screenshots/product_create.png` - 상품 등록 화면
- `screenshots/notifications.png` - 알림 목록 화면
- `screenshots/search.png` - 검색 화면

## GIF 데모 (선택, 2-3개)

### 1. 로그인 플로우 (`demo/login_flow.gif`)
- 소셜 로그인 선택 -> 로그인 완료 -> 홈 화면 이동

### 2. 상품 플로우 (`demo/product_flow.gif`)
- 상품 목록 스크롤 -> 상품 선택 -> 상세 화면 -> 찜하기 또는 채팅

### 3. 채팅 플로우 (`demo/chat_flow.gif`)
- 채팅방 입장 -> 메시지 전송 -> 실시간 수신

## 촬영 팁

### 스크린샷
- **해상도**: 1080x1920 (또는 기기 기본 해상도)
- **형식**: PNG 권장
- **데이터**: 실제 사용자 정보가 아닌 테스트 데이터 사용
- **상태바**: 시간, 배터리 등 깔끔하게 정리

### GIF 데모
- **도구**:
  - Mac: Kap (https://getkap.co/)
  - Windows: ScreenToGif (https://www.screentogif.com/)
  - 크로스플랫폼: LICEcap
- **설정**:
  - FPS: 15fps 권장
  - 너비: 300-400px
  - 파일 크기: 5MB 이하

### iOS 시뮬레이터 캡처
```bash
# 스크린샷
xcrun simctl io booted screenshot screenshot.png

# 비디오 녹화 (GIF 변환 필요)
xcrun simctl io booted recordVideo video.mp4
```

### Android 에뮬레이터 캡처
```bash
# 스크린샷
adb exec-out screencap -p > screenshot.png

# 비디오 녹화
adb shell screenrecord /sdcard/video.mp4
adb pull /sdcard/video.mp4
```

## 파일 저장 위치

```
docs/
├── screenshots/
│   ├── home.png
│   ├── product_detail.png
│   ├── chat.png
│   └── profile.png
└── demo/
    ├── login_flow.gif
    ├── product_flow.gif
    └── chat_flow.gif
```

## 체크리스트

스크린샷 준비 완료 확인:

- [ ] home.png - 홈 화면
- [ ] product_detail.png - 상품 상세
- [ ] chat.png - 채팅 화면
- [ ] profile.png - 프로필 화면
- [ ] (선택) GIF 데모 1개 이상

## 주의사항

- 개인정보가 포함되지 않도록 테스트 계정 사용
- 이미지 파일 크기가 너무 크지 않도록 최적화
- GitHub에서 이미지가 정상적으로 로드되는지 확인
