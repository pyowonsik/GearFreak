import 'package:gear_freak_client/gear_freak_client.dart';
import 'package:serverpod_flutter/serverpod_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Serverpod Client Provider
/// 전역에서 사용하는 Serverpod Client를 제공합니다.
final clientProvider = Provider<Client>((ref) {
  const serverUrlFromEnv = String.fromEnvironment('SERVER_URL');
  final serverUrl =
      serverUrlFromEnv.isEmpty ? 'http://$localhost:8080/' : serverUrlFromEnv;

  return Client(serverUrl)..connectivityMonitor = FlutterConnectivityMonitor();
});
