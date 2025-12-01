import 'package:flutter/material.dart';

/// 검색 텍스트 필드 위젯
class SearchTextFieldWidget extends StatefulWidget {
  /// SearchTextFieldWidget 생성자
  ///
  /// [controller]는 텍스트 입력 컨트롤러입니다.
  /// [focusNode]는 포커스 노드입니다.
  /// [onSubmitted]는 검색 제출 콜백입니다.
  /// [onChanged]는 텍스트 변경 콜백입니다.
  /// [onClear]는 지우기 버튼 클릭 콜백입니다.
  const SearchTextFieldWidget({
    required this.controller,
    required this.focusNode,
    required this.onSubmitted,
    this.onChanged,
    this.onClear,
    super.key,
  });

  /// 텍스트 입력 컨트롤러
  final TextEditingController controller;

  /// 포커스 노드
  final FocusNode focusNode;

  /// 검색 제출 콜백
  final ValueChanged<String> onSubmitted;

  /// 텍스트 변경 콜백
  final ValueChanged<String>? onChanged;

  /// 지우기 버튼 클릭 콜백
  final VoidCallback? onClear;

  @override
  State<SearchTextFieldWidget> createState() => _SearchTextFieldWidgetState();
}

class _SearchTextFieldWidgetState extends State<SearchTextFieldWidget> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: widget.controller,
        focusNode: widget.focusNode,
        decoration: InputDecoration(
          hintText: '리프팅 벨트, 보충제, 운동복을 검색해보세요',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: widget.controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: widget.onClear,
                )
              : null,
          filled: true,
          fillColor: const Color(0xFFF3F4F6),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        onSubmitted: widget.onSubmitted,
        onChanged: (value) {
          widget.onChanged?.call(value);
        },
      ),
    );
  }
}

