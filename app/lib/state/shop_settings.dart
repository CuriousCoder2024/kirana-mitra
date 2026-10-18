import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/api_provider.dart';
import '../models/models.dart';
import 'shop_prefs.dart';

/// Auto-restock switch and distributor phone (PATCH /shops/{shop_id}),
/// mirrored in shared_preferences so the Forecast card shows the last
/// saved values before the network answers.
class ShopSettings {
  const ShopSettings({this.autoRestock = false, this.distributorPhone = ''});

  final bool autoRestock;
  final String distributorPhone;

  ShopSettings copyWith({bool? autoRestock, String? distributorPhone}) => ShopSettings(
        autoRestock: autoRestock ?? this.autoRestock,
        distributorPhone: distributorPhone ?? this.distributorPhone,
      );
}

class ShopSettingsNotifier extends Notifier<ShopSettings> {
  static const _kAuto = 'auto_restock';
  static const _kPhone = 'distributor_phone';

  @override
  ShopSettings build() {
    final p = ref.watch(sharedPreferencesProvider).value;
    if (p == null) return const ShopSettings();
    return ShopSettings(autoRestock: p.getBool(_kAuto) ?? false, distributorPhone: p.getString(_kPhone) ?? '');
  }

  Future<Shop> save({required bool autoRestock, required String distributorPhone}) async {
    final shopId = ref.read(shopPrefsProvider).shopId ?? '';
    final shop = await ref.read(apiClientProvider).updateShop(
          shopId,
          autoRestock: autoRestock,
          distributorPhone: distributorPhone,
        );
    state = ShopSettings(autoRestock: shop.autoRestock, distributorPhone: shop.distributorPhone ?? distributorPhone);
    final p = await ref.read(sharedPreferencesProvider.future);
    await p.setBool(_kAuto, state.autoRestock);
    await p.setString(_kPhone, state.distributorPhone);
    return shop;
  }
}

final shopSettingsProvider = NotifierProvider<ShopSettingsNotifier, ShopSettings>(ShopSettingsNotifier.new);
