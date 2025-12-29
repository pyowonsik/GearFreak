# 시간 포맷 함수 사용 가이드

앱에서 사용하는 시간 포맷 함수들과 각각의 사용 위치를 정리한 문서입니다.

## 📋 시간 포맷 함수 목록

### 1. `formatRelativeTime` (format_utils.dart)

**용도**: 상품, 알림, 후기 등 일반적인 상대 시간 표시

**포맷 형식**:

- 1분 미만: `"방금 전"`
- 1분 이상, 60분 미만: `"5분 전"`, `"10분 전"`
- 1시간 이상, 24시간 미만: `"1시간 전"`, `"2시간 전"`, `"18시간 전"`
- 1일 이상, 7일 미만: `"1일 전"`, `"2일 전"`, `"6일 전"`
- 1주 이상, 4주 이하 (28일 이하): `"1주일 전"`, `"2주일 전"`, `"4주일 전"`
- 29일 이상, 365일 미만: `"1개월 전"`, `"2개월 전"`, `"3개월 전"`, ... `"12개월 전"`
- 1년 이상: `"1년 전"`, `"2년 전"`, ...

**사용 위치**:

- `gear_freak_flutter/lib/feature/product/presentation/screen/product_detail_screen.dart`
  - 상품 상세 화면: 상품 업데이트 시간 표시 (line 520)
- `gear_freak_flutter/lib/feature/product/presentation/widget/product_card_widget.dart`
  - 상품 카드 위젯: 상품 목록에서 상품 업데이트 시간 표시 (line 111)
- `gear_freak_flutter/lib/feature/notification/presentation/widget/notification_item_widget.dart`
  - 알림 아이템 위젯: 알림 생성 시간 표시 (line 114)
- `gear_freak_flutter/lib/feature/review/presentation/screen/review_list_screen.dart`
  - 후기 목록 화면: 후기 생성 시간 표시 (line 448)
- `gear_freak_flutter/lib/feature/review/presentation/screen/other_user_review_list_screen.dart`
  - 다른 사용자 후기 목록 화면: 후기 생성 시간 표시 (line 286)
- `gear_freak_flutter/lib/feature/profile/presentation/widget/other_user_profile_review_section_widget.dart`
  - 다른 사용자 프로필 후기 섹션: 후기 생성 시간 표시 (line 191)

**예시**:

```dart
formatRelativeTime(product.updatedAt ?? product.createdAt)
// 출력: "2시간 전", "1일 전", "1개월 전", "1년 전"
```

---

### 2. `formatChatRoomTime` (chat_room_util.dart)

**용도**: 채팅방 목록의 마지막 활동 시간 표시

**포맷 형식**:

- 24시간 이내 (오늘): `"오후 2:30"` (시간만 표시)
- 1일 이상, 7일 미만: `"1일 전"`, `"2일 전"`, ...
- 1주 이상, 4주 이하: `"1주일 전"`, `"2주일 전"`, ...
- 29일 이상, 365일 미만: `"1개월 전"`, `"2개월 전"`, `"3개월 전"`, ...
- 1년 이상: `"1년 전"`, `"2년 전"`, ...

**사용 위치**:

- `gear_freak_flutter/lib/feature/chat/presentation/widget/chat_room_item_widget.dart`
  - 채팅방 아이템 위젯: 채팅방의 `lastActivityAt` 표시 (line 248)

**예시**:

```dart
ChatRoomUtil.formatChatRoomTime(chatRoom.lastActivityAt!)
// 출력: "오후 2:30" (24시간 이내) 또는 "1일 전", "1개월 전" (그 외)
```

---

### 3. `formatChatMessageTime` (chat_util.dart)

**용도**: 채팅 메시지의 시간 표시 (시간만)

**포맷 형식**:

- 항상 시간만 표시: `"오전 10:30"`, `"오후 2:30"`

**사용 위치**:

- `gear_freak_flutter/lib/feature/chat/presentation/widget/chat_message_list_widget.dart`
  - 채팅 메시지 목록 위젯: 각 메시지의 시간 표시 (line 101, 106)

**예시**:

```dart
ChatUtil.formatChatMessageTime(DateTime.fromMillisecondsSinceEpoch(message.createdAt!))
// 출력: "오후 2:30"
```

**참고**: 채팅 메시지에서는 날짜 구분선(`formatChatMessageDateSeparator`)과 함께 사용됩니다.

---

### 4. `formatChatMessageDateSeparator` (chat_util.dart)

**용도**: 채팅 메시지 목록의 날짜 구분선 표시

**포맷 형식**:

- 오늘: `"오늘"`
- 어제: `"어제"`
- 올해: `"1월 15일"`
- 작년 이전: `"2023년 1월 15일"`

**사용 위치**:

- `gear_freak_flutter/lib/feature/chat/presentation/widget/chat_message_list_widget.dart`
  - 채팅 메시지 목록 위젯: 날짜가 바뀔 때 구분선으로 표시 (line 46)

**예시**:

```dart
ChatUtil.formatChatMessageDateSeparator(dateTime)
// 출력: "오늘", "어제", "1월 15일", "2023년 1월 15일"
```

---

## 📝 요약

| 함수명                           | 위치                | 사용처           | 주요 특징                               |
| -------------------------------- | ------------------- | ---------------- | --------------------------------------- |
| `formatRelativeTime`             | format_utils.dart   | 상품, 알림, 후기 | 상대 시간 표시 (방금 전 ~ N년 전)       |
| `formatChatRoomTime`             | chat_room_util.dart | 채팅방 목록      | 24시간 이내는 시간만, 그 외는 상대 시간 |
| `formatChatMessageTime`          | chat_util.dart      | 채팅 메시지      | 시간만 표시 (오전/오후 HH:MM)           |
| `formatChatMessageDateSeparator` | chat_util.dart      | 채팅 메시지      | 날짜 구분선용 (오늘/어제/날짜)          |

---

## 🔄 시간 포맷 선택 가이드

1. **상품, 알림, 후기 목록/상세**: `formatRelativeTime` 사용
2. **채팅방 목록**: `formatChatRoomTime` 사용 (24시간 이내는 시간만, 그 외는 상대 시간)
3. **채팅 메시지**:
   - 날짜 구분선: `formatChatMessageDateSeparator` 사용
   - 메시지 시간: `formatChatMessageTime` 사용 (시간만)

---

## ⚠️ 추가 참고사항

### 기타

- 모든 시간 포맷 함수는 한국 시간 기준으로 작성되었습니다.
- `formatRelativeTime`은 null 값을 처리하며, null인 경우 `"시간 정보 없음"`을 반환합니다.
- 채팅 메시지의 날짜 구분선은 메시지 목록에서 날짜가 바뀔 때만 표시됩니다.
