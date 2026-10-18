import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/models.dart';
import 'shop_prefs.dart';

/// One applied entry kept locally. The contract has no per-customer history
/// endpoint yet (Phase 5 gap), so the app remembers the last 50 applied
/// replies per shop and builds the customer screen from them.
class HistoryEntry {
  const HistoryEntry({
    required this.messageId,
    required this.intent,
    required this.at,
    required this.source,
    this.customerName,
    this.amount,
    this.itemName,
    this.quantity,
    this.unit,
    this.undone = false,
  });

  final String messageId;
  final String intent;
  final DateTime at;

  /// voice | text | photo
  final String source;
  final String? customerName;
  final num? amount;
  final String? itemName;
  final num? quantity;
  final String? unit;
  final bool undone;

  bool get isUdhaar => intent == 'udhaar_given' || intent == 'udhaar_paid';

  HistoryEntry copyWith({bool? undone}) => HistoryEntry(
        messageId: messageId,
        intent: intent,
        at: at,
        source: source,
        customerName: customerName,
        amount: amount,
        itemName: itemName,
        quantity: quantity,
        unit: unit,
        undone: undone ?? this.undone,
      );

  factory HistoryEntry.fromReply(ExtractionReply r, {required String source}) {
    final item = r.entities.items.isEmpty ? null : r.entities.items.first;
    return HistoryEntry(
      messageId: r.messageId,
      intent: r.intent,
      at: DateTime.now(),
      source: source,
      customerName: r.entities.customerName,
      amount: r.entities.amount,
      itemName: item?.name,
      quantity: item?.quantity,
      unit: item?.unit,
    );
  }

  factory HistoryEntry.fromJson(Map<String, dynamic> j) => HistoryEntry(
        messageId: j['message_id'] as String,
        intent: j['intent'] as String,
        at: DateTime.tryParse(j['at'] as String? ?? '') ?? DateTime.now(),
        source: j['source'] as String? ?? 'text',
        customerName: j['customer_name'] as String?,
        amount: j['amount'] as num?,
        itemName: j['item_name'] as String?,
        quantity: j['quantity'] as num?,
        unit: j['unit'] as String?,
        undone: j['undone'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'message_id': messageId,
        'intent': intent,
        'at': at.toIso8601String(),
        'source': source,
        'customer_name': customerName,
        'amount': amount,
        'item_name': itemName,
        'quantity': quantity,
        'unit': unit,
        'undone': undone,
      };
}

class HistoryStore extends Notifier<List<HistoryEntry>> {
  static const _max = 50;

  String get _key => 'history_${ref.read(shopPrefsProvider).shopId ?? ''}';

  @override
  List<HistoryEntry> build() {
    final prefs = ref.watch(sharedPreferencesProvider).value;
    ref.watch(shopPrefsProvider.select((p) => p.shopId));
    final raw = prefs?.getString(_key);
    if (raw == null) return const [];
    try {
      return (jsonDecode(raw) as List)
          .map((e) => HistoryEntry.fromJson((e as Map).cast<String, dynamic>()))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<void> _persist() async {
    final p = await ref.read(sharedPreferencesProvider.future);
    await p.setString(_key, jsonEncode(state.map((e) => e.toJson()).toList()));
  }

  void record(ExtractionReply r, {required String source}) {
    if (!r.applied) return;
    final entry = HistoryEntry.fromReply(r, source: source);
    state = [entry, ...state.where((e) => e.messageId != r.messageId)].take(_max).toList();
    _persist();
  }

  void markUndone(String messageId) {
    state = [
      for (final e in state)
        if (e.messageId == messageId) e.copyWith(undone: true) else e,
    ];
    _persist();
  }

  /// Applied, not undone, newest first.
  List<HistoryEntry> get live => state.where((e) => !e.undone).toList();

  /// The last 10 applied messages are undoable per the contract.
  bool isUndoable(String messageId) =>
      live.take(10).any((e) => e.messageId == messageId);

  List<HistoryEntry> forCustomer(String name) =>
      live.where((e) => e.isUdhaar && (e.customerName ?? '').toLowerCase() == name.toLowerCase()).toList();
}

final historyStoreProvider =
    NotifierProvider<HistoryStore, List<HistoryEntry>>(HistoryStore.new);
