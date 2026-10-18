import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_client.dart';
import 'dio_api_client.dart';
import 'mock_api_client.dart';

const bool kUseMock = bool.fromEnvironment('USE_MOCK');

/// One mock instance for the whole session so its in-memory state persists.
final mockClientProvider = Provider<MockApiClient>((ref) => MockApiClient());

/// Resolves once at startup: the real backend if `GET /health` answers, else the
/// mock. `--dart-define USE_MOCK=true` forces the mock.
final apiClientFutureProvider = FutureProvider<ApiClient>((ref) async {
  if (kUseMock) return ref.watch(mockClientProvider);
  final live = DioApiClient();
  if (await live.healthz()) return live;
  debugPrint('Kirana Mitra: backend at ${live.baseUrl} not reachable, using mock');
  return ref.watch(mockClientProvider);
});

/// Flipped to true when the live backend fails after the startup check
/// (for example POST /shops times out), so the rest of the session stays
/// consistent on the mock instead of mixing a mock shop_id with live calls.
class ForceMock extends Notifier<bool> {
  @override
  bool build() => false;

  void enable() => state = true;
}

final forceMockProvider = NotifierProvider<ForceMock, bool>(ForceMock.new);

/// Synchronous access once [apiClientFutureProvider] has resolved. The app
/// root waits for it before building any screen.
final apiClientProvider = Provider<ApiClient>((ref) {
  if (ref.watch(forceMockProvider)) return ref.watch(mockClientProvider);
  final async = ref.watch(apiClientFutureProvider);
  return async.value ?? ref.watch(mockClientProvider);
});

final isDemoModeProvider = Provider<bool>((ref) => !ref.watch(apiClientProvider).isLive);
