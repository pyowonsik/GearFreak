import 'package:flutter/material.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;

/// 상품 판매 상태 드롭다운 위젯
class ProductStatusDropdownWidget extends StatelessWidget {
  /// ProductStatusDropdownWidget 생성자
  ///
  /// [currentStatus]는 현재 상품 상태입니다.
  /// [onStatusChanged]는 상태 변경 콜백입니다.
  const ProductStatusDropdownWidget({
    required this.currentStatus,
    required this.onStatusChanged,
    super.key,
  });

  /// 현재 상품 상태
  final pod.ProductStatus currentStatus;

  /// 상태 변경 콜백
  final ValueChanged<pod.ProductStatus> onStatusChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<pod.ProductStatus>(
        value: currentStatus,
        underline: const SizedBox.shrink(),
        icon: const Icon(
          Icons.arrow_drop_down,
          color: Color(0xFF6B7280),
          size: 20,
        ),
        isDense: true,
        items: const [
          DropdownMenuItem(
            value: pod.ProductStatus.selling,
            child: Text('판매중'),
          ),
          DropdownMenuItem(
            value: pod.ProductStatus.reserved,
            child: Text('예약'),
          ),
          DropdownMenuItem(
            value: pod.ProductStatus.sold,
            child: Text('판매완료'),
          ),
        ],
        onChanged: (newStatus) {
          if (newStatus != null && newStatus != currentStatus) {
            onStatusChanged(newStatus);
          }
        },
        style: const TextStyle(
          fontSize: 13,
          color: Color(0xFF1F2937),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
