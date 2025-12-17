import 'package:flutter/material.dart';
import 'package:gear_freak_flutter/common/presentation/component/component.dart';

/// 알림 리스트 화면
/// Presentation Layer: UI
class NotificationListScreen extends StatelessWidget {
  /// NotificationListScreen 생성자
  const NotificationListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: GbAppBar(
        title: Text('알림'),
      ),
      body: Center(
        child: Text(
          '알림 리스트',
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF9CA3AF),
          ),
        ),
      ),
    );
  }
}
