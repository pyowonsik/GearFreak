import 'package:flutter/material.dart';
import 'package:gear_freak_client/gear_freak_client.dart' as pod;
import 'package:gear_freak_flutter/common/presentation/component/component.dart';
import 'package:gear_freak_flutter/feature/product/presentation/utils/product_enum_helper.dart';

/// 상품 거래 정보 섹션 위젯
class ProductTradeInfoSectionWidget extends StatelessWidget {
  /// 상품 거래 정보 섹션 위젯 생성자
  const ProductTradeInfoSectionWidget({
    required this.selectedTradeMethod,
    required this.baseAddress,
    required this.detailAddressController,
    required this.onTradeMethodChanged,
    required this.onSearchAddress,
    this.isBaseAddressRequired = false,
    super.key,
  });

  /// 선택된 거래 방법
  final pod.TradeMethod selectedTradeMethod;

  /// 기본 주소
  final String? baseAddress;

  /// 상세 주소 컨트롤러
  final TextEditingController detailAddressController;

  /// 거래 방법 변경 콜백
  final void Function(pod.TradeMethod) onTradeMethodChanged;

  /// 주소 검색 콜백
  final Future<void> Function() onSearchAddress;

  /// 기본 주소 필수 여부 (직접 거래일 때만)
  final bool isBaseAddressRequired;

  @override
  Widget build(BuildContext context) {
    final isDirect = isDirectTrade(selectedTradeMethod);

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '거래 정보',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<pod.TradeMethod>(
            value: selectedTradeMethod,
            decoration: const InputDecoration(
              labelText: '거래 방법',
              border: OutlineInputBorder(),
            ),
            items: pod.TradeMethod.values.map((method) {
              return DropdownMenuItem<pod.TradeMethod>(
                value: method,
                child: Text(getTradeMethodLabel(method)),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                onTradeMethodChanged(value);
              }
            },
          ),
          if (isDirect) ...[
            const SizedBox(height: 16),
            // 기본 주소 검색
            InkWell(
              onTap: onSearchAddress,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: Color(0xFF6B7280),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        baseAddress ?? '주소 검색',
                        style: TextStyle(
                          fontSize: 16,
                          color: baseAddress == null
                              ? const Color(0xFF9CA3AF)
                              : const Color(0xFF1F2937),
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.search,
                      color: Color(0xFF9CA3AF),
                    ),
                  ],
                ),
              ),
            ),
            if (isBaseAddressRequired && baseAddress == null)
              Padding(
                padding: const EdgeInsets.only(top: 8, left: 12),
                child: Text(
                  '주소를 검색해주세요',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.red.shade700,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            // 상세 주소 입력
            GbTextFormField(
              controller: detailAddressController,
              labelText: '상세 주소',
              hintText: '예: 101동 201호',
              prefixIcon: const Icon(Icons.home),
              validator: (value) {
                if (isDirect &&
                    baseAddress != null &&
                    (value == null || value.isEmpty)) {
                  return '상세 주소를 입력해주세요';
                }
                return null;
              },
            ),
          ],
        ],
      ),
    );
  }
}
