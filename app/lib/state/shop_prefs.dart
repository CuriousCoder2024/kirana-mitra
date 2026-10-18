import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/models.dart';

/// What we persist after onboarding.
class ShopPrefs {
  const ShopPrefs({
    this.shopId,
    this.shopName = '',
    this.ownerName = '',
    this.language = 'hi-Latn',
  });

  final String? shopId;
  final String shopName;
  final String ownerName;

  /// `hi`, `en` or `hi-Latn` (what the backend gets).
  final String language;

  bool get isOnboarded => shopId != null && shopId!.isNotEmpty;

  /// Hinglish uses the English UI strings; only `hi` switches the UI.
  Locale get locale => language == 'hi' ? const Locale('hi') : const Locale('en');

  static const _kShopId = 'shop_id';
  static const _kShopName = 'shop_name';
  static const _kOwnerName = 'owner_name';
  static const _kLanguage = 'language';

  static ShopPrefs fromStorage(SharedPreferences p) => ShopPrefs(
        shopId: p.getString(_kShopId),
        shopName: p.getString(_kShopName) ?? '',
        ownerName: p.getString(_kOwnerName) ?? '',
        language: p.getString(_kLanguage) ?? 'hi-Latn',
      );

  Future<void> save(SharedPreferences p) async {
    await p.setString(_kShopId, shopId ?? '');
    await p.setString(_kShopName, shopName);
    await p.setString(_kOwnerName, ownerName);
    await p.setString(_kLanguage, language);
  }

  static Future<void> clear(SharedPreferences p) async {
    for (final k in [_kShopId, _kShopName, _kOwnerName, _kLanguage]) {
      await p.remove(k);
    }
  }
}

final sharedPreferencesProvider = FutureProvider<SharedPreferences>(
  (ref) => SharedPreferences.getInstance(),
);

class ShopPrefsNotifier extends Notifier<ShopPrefs> {
  @override
  ShopPrefs build() {
    final prefs = ref.watch(sharedPreferencesProvider).value;
    return prefs == null ? const ShopPrefs() : ShopPrefs.fromStorage(prefs);
  }

  Future<void> setShop(Shop shop) async {
    state = ShopPrefs(
      shopId: shop.shopId,
      shopName: shop.shopName,
      ownerName: shop.ownerName,
      language: shop.language,
    );
    final p = await ref.read(sharedPreferencesProvider.future);
    await state.save(p);
  }

  Future<void> reset() async {
    final p = await ref.read(sharedPreferencesProvider.future);
    await ShopPrefs.clear(p);
    state = const ShopPrefs();
  }
}

final shopPrefsProvider =
    NotifierProvider<ShopPrefsNotifier, ShopPrefs>(ShopPrefsNotifier.new);
