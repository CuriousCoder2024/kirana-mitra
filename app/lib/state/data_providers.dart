import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/api_provider.dart';
import '../models/models.dart';
import 'shop_prefs.dart';

final stockProvider = FutureProvider<StockResponse>((ref) {
  final shopId = ref.watch(shopPrefsProvider.select((p) => p.shopId)) ?? '';
  return ref.watch(apiClientProvider).stock(shopId);
});

final ledgerProvider = FutureProvider<LedgerResponse>((ref) {
  final shopId = ref.watch(shopPrefsProvider.select((p) => p.shopId)) ?? '';
  return ref.watch(apiClientProvider).ledger(shopId);
});

final forecastProvider = FutureProvider<ForecastResponse>((ref) {
  final shopId = ref.watch(shopPrefsProvider.select((p) => p.shopId)) ?? '';
  return ref.watch(apiClientProvider).forecast(shopId);
});

/// Call after anything that may have written to the ledger or stock.
void invalidateShopData(Ref ref) {
  ref.invalidate(stockProvider);
  ref.invalidate(ledgerProvider);
}

final topItemsProvider = FutureProvider<TopItemsResponse>((ref) {
  final shopId = ref.watch(shopPrefsProvider.select((p) => p.shopId)) ?? '';
  return ref.watch(apiClientProvider).topItems(shopId, weeks: 2);
});

final ordersProvider = FutureProvider<OrdersResponse>((ref) {
  final shopId = ref.watch(shopPrefsProvider.select((p) => p.shopId)) ?? '';
  return ref.watch(apiClientProvider).orders(shopId);
});
