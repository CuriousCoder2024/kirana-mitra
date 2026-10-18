import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_client.dart';
import 'dio_api_client.dart';
import 'mock_api_client.dart';

const bool kUseMock = bool.fromEnvironment('USE_MOCK');

/// Resolves once at startup: the real backend if `/healthz` answers, else the
/// mock. `--dart-define USE_MOCK=true` forces the mock.
final apiClientFutureProvider = FutureProvider<ApiClient>((ref) async {
  if (kUseMock) return MockApiClient();
  final live = DioApiClient();
  if (await live.healthz()) return live;
  debugPrint('Kirana Mitra: backend at ${live.baseUrl} not reachable, using mock');
  return MockApiClient();
});

/// Synchronous access once [apiClientFutureProvider] has resolved. The app
/// root waits for it before building any screen.
final apiClientProvider = Provider<ApiClient>((ref) {
  final async = ref.watch(apiClientFutureProvider);
  return async.value ?? MockApiClient();
});

final isDemoModeProvider = Provider<bool>((ref) => !ref.watch(apiClientProvider).isLive);
