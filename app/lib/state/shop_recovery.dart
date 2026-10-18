import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/api_client.dart';
import 'shop_prefs.dart';

/// Set when the shop was silently re-registered so the chat can say so.
class ShopRecovered extends Notifier<bool> {
  @override
  bool build() => false;

  void set(bool v) => state = v;
}

final shopRecoveredProvider = NotifierProvider<ShopRecovered, bool>(ShopRecovered.new);

/// Re-registers the saved shop after the backend forgot it (in-memory store,
/// redeploy). Re-keys the local history and message cursor to the new id,
/// stores it, and returns it. Null when the app is not onboarded.
Future<String?> recoverShop(Ref ref, ApiClient raw) async {
  final prefs = ref.read(shopPrefsProvider);
  final oldId = prefs.shopId;
  if (oldId == null || oldId.isEmpty) return null;
  final shop = await raw.createShop(
    shopName: prefs.shopName,
    ownerName: prefs.ownerName,
    language: prefs.language,
  );
  final p = await ref.read(sharedPreferencesProvider.future);
  for (final prefix in const ['history_', 'messages_seen_']) {
    final v = p.getString('$prefix$oldId');
    if (v != null) {
      await p.setString('$prefix${shop.shopId}', v);
      await p.remove('$prefix$oldId');
    }
  }
  await ref.read(shopPrefsProvider.notifier).setShop(shop);
  ref.read(shopRecoveredProvider.notifier).set(true);
  return shop.shopId;
}
