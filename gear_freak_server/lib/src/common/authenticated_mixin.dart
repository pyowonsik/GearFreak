import 'package:serverpod/serverpod.dart';

/// 인증이 필요한 엔드포인트에 적용하는 mixin
///
/// 사용법:
/// ```dart
/// class UserEndpoint extends Endpoint with AuthenticatedMixin {
///   // 자동으로 requireLogin => true가 적용됨
/// }
/// ```
mixin AuthenticatedMixin on Endpoint {
  @override
  bool get requireLogin => true;
}
