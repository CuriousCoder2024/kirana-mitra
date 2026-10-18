import 'dart:math';

import '../l10n/languages.dart';
import '../models/models.dart';
import 'api_client.dart';

/// In-memory stand-in for the backend. Returns contract-shaped fixtures with
/// Hinglish replies and keeps enough state (stock, ledger, undo history)
/// that the whole demo flow works without a server.
class MockApiClient implements ApiClient {
  MockApiClient({this.latency = const Duration(milliseconds: 700)});

  final Duration latency;
  final _rng = Random(7);
  int _seq = 100;

  @override
  bool get isLive => false;

  String _id(String prefix) => '${prefix}_01HX${(_seq++).toString().padLeft(4, '0')}';

  String _now() => DateTime.now().toIso8601String();

  final List<StockItem> _stock = [
    StockItem(
      itemId: 'itm_parleg',
      name: 'Parle-G',
      packSize: '70g',
      quantity: 42,
      unit: 'packet',
      reorderLevel: 24,
      lowStock: false,
      updatedAt: '2026-10-18T09:12:00+05:30',
    ),
    StockItem(
      itemId: 'itm_maggi',
      name: 'Maggi',
      packSize: '70g',
      quantity: 6,
      unit: 'packet',
      reorderLevel: 12,
      lowStock: true,
      updatedAt: '2026-10-18T08:40:00+05:30',
    ),
    StockItem(
      itemId: 'itm_amul',
      name: 'Amul Butter',
      packSize: '100g',
      quantity: 9,
      unit: 'piece',
      reorderLevel: 10,
      lowStock: true,
      updatedAt: '2026-10-17T19:05:00+05:30',
    ),
    StockItem(
      itemId: 'itm_tata_salt',
      name: 'Tata Salt',
      packSize: '1kg',
      quantity: 30,
      unit: 'packet',
      reorderLevel: 10,
      lowStock: false,
      updatedAt: '2026-10-16T11:30:00+05:30',
    ),
    StockItem(
      itemId: 'itm_fortune',
      name: 'Fortune Oil',
      packSize: '1L',
      quantity: 14,
      unit: 'litre',
      reorderLevel: 8,
      lowStock: false,
      updatedAt: '2026-10-15T17:20:00+05:30',
    ),
    StockItem(
      itemId: 'itm_surf',
      name: 'Surf Excel',
      packSize: '500g',
      quantity: 4,
      unit: 'packet',
      reorderLevel: 6,
      lowStock: true,
      updatedAt: '2026-10-18T10:02:00+05:30',
    ),
  ];

  final Map<String, LedgerCustomer> _ledger = {
    'Gupta ji': const LedgerCustomer(
      customerName: 'Gupta ji',
      balance: 1200,
      lastEntryAt: '2026-10-17T18:30:00+05:30',
    ),
    'Sharma aunty': const LedgerCustomer(
      customerName: 'Sharma aunty',
      balance: 850,
      lastEntryAt: '2026-10-16T10:15:00+05:30',
    ),
    'Rahul': const LedgerCustomer(
      customerName: 'Rahul',
      balance: 2300,
      lastEntryAt: '2026-10-18T09:00:00+05:30',
    ),
  };

  /// message_id -> undo closure, newest last. Only the last 10 are undoable.
  final List<MapEntry<String, void Function()>> _undoable = [];

  /// Pending (not yet applied) replies waiting for /confirm.
  final Map<String, ExtractionReply> _pending = {};

  Future<void> _wait() => Future<void>.delayed(latency);

  @override
  Future<bool> healthz() async => true;

  @override
  Future<Shop> createShop({
    required String shopName,
    required String ownerName,
    required String language,
  }) async {
    await _wait();
    return Shop(
      shopId: _id('shp'),
      shopName: shopName,
      ownerName: ownerName,
      language: language,
      createdAt: _now(),
    );
  }

  // ---------------------------------------------------------------- chat --

  @override
  Future<ExtractionReply> chat({
    required String shopId,
    required String text,
  }) async {
    await _wait();
    return _interpret(text, transcript: null);
  }

  @override
  Future<ExtractionReply> voiceNote({
    required String shopId,
    required UploadBlob audio,
  }) async {
    await Future<void>.delayed(latency * 2);
    // We cannot hear the audio; rotate through realistic transcripts.
    const samples = [
      'Kal Parle-G ke 3 carton aaye',
      'Gupta ji ko 350 ka udhaar diya',
      'Aaj Maggi ke 10 packet bike',
      'Sharma aunty ne 500 rupaye de diye',
      'Maggi kitna bacha hai?',
    ];
    final transcript = samples[_rng.nextInt(samples.length)];
    return _interpret(transcript, transcript: transcript);
  }

  ExtractionReply _interpret(String raw, {required String? transcript}) {
    final text = raw.toLowerCase();
    final messageId = _id('msg');
    final lang = _detectLanguage(raw);

    bool hasAny(List<String> words) => words.any(text.contains);

    final amount = _firstNumber(text, skip: const ['carton', 'packet', 'kg']);
    final qty = _firstNumber(text);

    if (hasAny(['kitna', 'kitne', 'how much', 'how many', 'bacha', 'left', '?',
      'कितना', 'कितने'])) {
      final item = _matchStock(text);
      final reply = item == null
          ? 'Stock list mein woh item nahi mila. "Stock dekho" dabao.'
          : '${item.name} ${item.packSize ?? ''}: abhi ${item.quantity} ${item.unit} bache hain.'
              '${item.lowStock ? ' Kam hai, reorder kar lo.' : ''}';
      return ExtractionReply(
        messageId: messageId,
        intent: 'question',
        confidence: 0.9,
        transcript: transcript,
        language: lang,
        entities: Entities(items: item == null ? const [] : [EntityItem(name: item.name)]),
        applied: false,
        replyText: reply,
        quickActions: const [
          QuickAction(label: 'Stock dekho', action: 'open_stock'),
          QuickAction(label: 'Forecast dekho', action: 'open_forecast'),
        ],
      );
    }

    if (hasAny(['udhaar', 'udhar', 'baaki', 'credit', 'उधार', 'बाकी'])) {
      final paid = hasAny(['de diye', 'diya wapas', 'wapas', 'paid', 'chuka', 'de diya', 'लौटा', 'चुका']);
      final name = _guessCustomer(raw) ?? 'Customer';
      final amt = amount ?? 200;
      final confidence = amount == null ? 0.55 : 0.92;
      void apply() {
        final cur = _ledger[name];
        final delta = paid ? -amt : amt;
        _ledger[name] = LedgerCustomer(
          customerName: name,
          balance: max(0, (cur?.balance ?? 0) + delta),
          lastEntryAt: _now(),
        );
      }

      final total = () {
        final cur = _ledger[name]?.balance ?? 0;
        return paid ? max(0, cur - amt) : cur + amt;
      }();
      final reply = paid
          ? 'Samjha: $name ne ₹$amt wapas diye. Ab unka baaki ₹$total.'
          : 'Samjha: $name ko ₹$amt udhaar diya. Ab unka total ₹$total.';
      return _applyOrPend(
        messageId: messageId,
        intent: paid ? 'udhaar_paid' : 'udhaar_given',
        confidence: confidence,
        transcript: transcript,
        language: lang,
        entities: Entities(customerName: name, amount: amt, date: _today()),
        replyText: reply,
        apply: apply,
        undoText: paid
            ? 'Theek hai, $name ka ₹$amt payment hata diya.'
            : 'Theek hai, $name ka ₹$amt udhaar hata diya.',
        openAction: const QuickAction(label: 'Udhaar dekho', action: 'open_udhaar'),
      );
    }

    if (hasAny(['de diye', 'paise diye', 'rupaye de', 'paid', 'चुका', 'लौटा'])) {
      final name = _guessCustomer(raw) ?? 'Customer';
      final amt = amount ?? 100;
      void apply() {
        final cur = _ledger[name];
        _ledger[name] = LedgerCustomer(
          customerName: name,
          balance: max(0, (cur?.balance ?? 0) - amt),
          lastEntryAt: _now(),
        );
      }

      final after = max(0, (_ledger[name]?.balance ?? 0) - amt);
      return _applyOrPend(
        messageId: messageId,
        intent: 'udhaar_paid',
        confidence: 0.88,
        transcript: transcript,
        language: lang,
        entities: Entities(customerName: name, amount: amt, date: _today()),
        replyText: 'Samjha: $name ne ₹$amt de diye. Ab baaki ₹$after.',
        apply: apply,
        undoText: 'Theek hai, $name ka ₹$amt payment hata diya.',
        openAction: const QuickAction(label: 'Udhaar dekho', action: 'open_udhaar'),
      );
    }

    final isSale = hasAny(['bika', 'bike', 'becha', 'bech', 'sold', 'sale', 'बिका', 'बिके', 'बेचा']);
    final isStockIn = hasAny(['aaya', 'aaye', 'aayi', 'add', 'mangaya', 'received', 'came', 'stock', 'आया', 'आये', 'आए']);
    if (isSale || isStockIn) {
      final item = _matchStock(text);
      final name = item?.name ?? _guessItemName(raw);
      final unit = _guessUnit(text) ?? item?.unit ?? 'packet';
      final q = qty ?? 1;
      final perCarton = unit == 'carton' ? 12 : 1;
      final delta = (isSale ? -q : q) * perCarton;
      final confidence = qty == null ? 0.6 : 0.93;

      void apply() {
        final idx = _stock.indexWhere((s) => s.name == name);
        if (idx >= 0) {
          final s = _stock[idx];
          final nq = max(0, s.quantity + delta);
          _stock[idx] = s.copyWith(
            quantity: nq,
            lowStock: nq <= s.reorderLevel,
            updatedAt: _now(),
          );
        } else {
          _stock.insert(
            0,
            StockItem(
              itemId: _id('itm'),
              name: name,
              quantity: max(0, delta),
              unit: unit == 'carton' ? 'packet' : unit,
              reorderLevel: 10,
              lowStock: max(0, delta) <= 10,
              updatedAt: _now(),
            ),
          );
        }
      }

      final cur = _stock.where((s) => s.name == name).firstOrNull;
      final after = max(0, (cur?.quantity ?? 0) + delta);
      final afterUnit = cur?.unit ?? (unit == 'carton' ? 'packet' : unit);
      final reply = isSale
          ? 'Samjha: $name, $q $unit bika. Ab $after $afterUnit bache.'
              '${after <= (cur?.reorderLevel ?? 10) ? ' Kam ho raha hai!' : ''}'
          : 'Samjha: $name${item?.packSize != null ? ' ${item!.packSize}' : ''}, '
              '$q $unit stock mein add kiya. Ab total $after $afterUnit.';
      return _applyOrPend(
        messageId: messageId,
        intent: isSale ? 'sale' : 'stock_in',
        confidence: confidence,
        transcript: transcript,
        language: lang,
        entities: Entities(
          items: [
            EntityItem(name: name, packSize: item?.packSize, quantity: q, unit: unit),
          ],
          date: _today(),
        ),
        replyText: reply,
        apply: apply,
        undoText: isSale
            ? 'Theek hai, $name ki $q $unit sale hata di.'
            : 'Theek hai, $name ke $q $unit wapas hata diye.',
        openAction: const QuickAction(label: 'Stock dekho', action: 'open_stock'),
      );
    }

    return ExtractionReply(
      messageId: messageId,
      intent: 'unclear',
      confidence: 0.3,
      transcript: transcript,
      language: lang,
      entities: const Entities(),
      applied: false,
      replyText:
          'Thoda samajh nahi aaya. Aise bolo: "Parle-G ke 3 carton aaye", '
          '"Gupta ji ko 350 ka udhaar diya", ya "Maggi kitna bacha hai?"',
      quickActions: const [
        QuickAction(label: 'Stock dekho', action: 'open_stock'),
        QuickAction(label: 'Udhaar dekho', action: 'open_udhaar'),
      ],
    );
  }

  ExtractionReply _applyOrPend({
    required String messageId,
    required String intent,
    required double confidence,
    required String? transcript,
    required String language,
    required Entities entities,
    required String replyText,
    required void Function() apply,
    required String undoText,
    required QuickAction openAction,
  }) {
    if (confidence >= 0.7) {
      apply();
      _remember(messageId, undoText, entities);
      return ExtractionReply(
        messageId: messageId,
        intent: intent,
        confidence: confidence,
        transcript: transcript,
        language: language,
        entities: entities,
        applied: true,
        replyText: replyText,
        quickActions: [
          QuickAction(label: 'Undo', action: 'undo', payload: {'message_id': messageId}),
          openAction,
        ],
      );
    }
    final pending = ExtractionReply(
      messageId: messageId,
      intent: intent,
      confidence: confidence,
      transcript: transcript,
      language: language,
      entities: entities,
      applied: false,
      replyText: 'Pakka? $replyText',
      quickActions: [
        QuickAction(label: 'Haan, add karo', action: 'confirm', payload: {'message_id': messageId}),
        openAction,
      ],
    );
    _pending[messageId] = pending;
    _pendingApply[messageId] = (apply, undoText);
    return pending;
  }

  final Map<String, (void Function(), String)> _pendingApply = {};
  final Map<String, String> _undoText = {};

  void _remember(String messageId, String undoText, Entities entities) {
    _undoText[messageId] = undoText;
    // Snapshot state so undo restores exactly.
    final stockSnap = List<StockItem>.from(_stock);
    final ledgerSnap = Map<String, LedgerCustomer>.from(_ledger);
    _undoable.add(MapEntry(messageId, () {
      _stock
        ..clear()
        ..addAll(stockSnap);
      _ledger
        ..clear()
        ..addAll(ledgerSnap);
    }));
    if (_undoable.length > 10) _undoable.removeAt(0);
  }

  @override
  Future<ExtractionReply> confirm({
    required String shopId,
    required String messageId,
  }) async {
    await _wait();
    final pending = _pending.remove(messageId);
    final work = _pendingApply.remove(messageId);
    if (pending == null || work == null) {
      throw ApiException(code: 'not_found', message: 'Message not found', status: 404);
    }
    final (apply, undoText) = work;
    apply();
    _remember(messageId, undoText, pending.entities);
    return ExtractionReply(
      messageId: messageId,
      intent: pending.intent,
      confidence: 1,
      transcript: pending.transcript,
      language: pending.language,
      entities: pending.entities,
      applied: true,
      replyText: 'Ho gaya. ${pending.replyText.replaceFirst('Pakka? ', '')}',
      quickActions: [
        QuickAction(label: 'Undo', action: 'undo', payload: {'message_id': messageId}),
        ...pending.quickActions.where((a) => a.action != 'confirm'),
      ],
    );
  }

  @override
  Future<UndoReply> undo({
    required String shopId,
    required String messageId,
  }) async {
    await _wait();
    final idx = _undoable.indexWhere((e) => e.key == messageId);
    if (idx < 0) {
      throw ApiException(
        code: 'undo_expired',
        message: 'Yeh entry ab undo nahi ho sakti.',
        status: 409,
      );
    }
    // Undo this and anything after it (keeps state consistent).
    _undoable[idx].value();
    _undoable.removeRange(idx, _undoable.length);
    final text = _undoText.remove(messageId) ?? 'Theek hai, entry hata di.';
    final total = _ledger.values.fold<num>(0, (a, b) => a + b.balance);
    return UndoReply(undone: true, replyText: '$text Total udhaar ₹$total.');
  }

  // ------------------------------------------------------------- lookups --

  @override
  Future<StockResponse> stock(String shopId) async {
    await _wait();
    return StockResponse(items: List.unmodifiable(_stock));
  }

  @override
  Future<LedgerResponse> ledger(String shopId) async {
    await _wait();
    final customers = _ledger.values.toList()
      ..sort((a, b) => b.balance.compareTo(a.balance));
    return LedgerResponse(
      customers: customers,
      totalOutstanding: customers.fold<num>(0, (a, b) => a + b.balance),
    );
  }

  @override
  Future<ShelfScanResponse> shelfScan({
    required String shopId,
    required UploadBlob image,
  }) async {
    await Future<void>.delayed(latency * 2);
    final messageId = _id('msg');
    const scanned = [
      ScannedItem(name: 'Maggi', packSize: '70g', count: 6, confidence: 0.82),
      ScannedItem(name: 'Parle-G', packSize: '70g', count: 12, confidence: 0.78),
      ScannedItem(name: 'Tata Salt', packSize: '1kg', count: 3, confidence: 0.71),
    ];
    const low = [ScanLowStock(name: 'Maggi', count: 6, reorderLevel: 12)];
    const replyText =
        'Shelf mein dikha: Maggi 6, Parle-G 12, Tata Salt 3. '
        'Maggi kam hai, reorder kar lo. Stock yahi counts se update karun?';

    void apply() {
      for (final sc in scanned) {
        final idx = _stock.indexWhere((s) => s.name == sc.name);
        if (idx >= 0) {
          final s = _stock[idx];
          _stock[idx] = s.copyWith(
            quantity: sc.count,
            lowStock: sc.count <= s.reorderLevel,
            updatedAt: _now(),
          );
        } else {
          _stock.insert(
            0,
            StockItem(
              itemId: _id('itm'),
              name: sc.name,
              packSize: sc.packSize,
              quantity: sc.count,
              unit: 'packet',
              reorderLevel: 10,
              lowStock: sc.count <= 10,
              updatedAt: _now(),
            ),
          );
        }
      }
    }

    _pending[messageId] = ExtractionReply(
      messageId: messageId,
      intent: 'stock_in',
      confidence: 0.78,
      language: 'hi-Latn',
      entities: Entities(
        items: [
          for (final sc in scanned)
            EntityItem(name: sc.name, packSize: sc.packSize, quantity: sc.count, unit: 'packet'),
        ],
        date: _today(),
      ),
      applied: false,
      replyText: 'Pakka? Stock update kiya: Maggi 6, Parle-G 12, Tata Salt 3 packet.',
      quickActions: const [QuickAction(label: 'Stock dekho', action: 'open_stock')],
    );
    _pendingApply[messageId] = (apply, 'Theek hai, shelf scan wala update hata diya.');

    return ShelfScanResponse(
      messageId: messageId,
      items: scanned,
      lowStock: low,
      replyText: replyText,
      quickActions: [
        QuickAction(label: 'Haan, update karo', action: 'confirm', payload: {'message_id': messageId}),
        const QuickAction(label: 'Stock dekho', action: 'open_stock'),
      ],
    );
  }

  @override
  Future<ForecastResponse> forecast(String shopId) async {
    await _wait();
    return ForecastResponse(
      generatedAt: _now(),
      weeks: const ['2026-10-19', '2026-10-26', '2026-11-02', '2026-11-09'],
      festivals: const [
        Festival(name: 'Dhanteras', date: '2026-11-06'),
        Festival(name: 'Diwali', date: '2026-11-08'),
      ],
      items: const [
        ForecastItem(
          itemId: 'itm_parleg',
          name: 'Parle-G',
          unit: 'packet',
          historyWeekly: [40, 38, 45, 41],
          forecastWeekly: [44, 52, 90, 48],
          lower: [38, 44, 70, 40],
          upper: [50, 60, 110, 56],
          onHand: 42,
          reorderQty: 120,
          reorderReason: 'Diwali week demand ~2x',
        ),
        ForecastItem(
          itemId: 'itm_maggi',
          name: 'Maggi',
          unit: 'packet',
          historyWeekly: [30, 34, 31, 36],
          forecastWeekly: [36, 40, 58, 38],
          lower: [30, 33, 45, 31],
          upper: [42, 48, 72, 46],
          onHand: 6,
          reorderQty: 96,
          reorderReason: 'Stock khatam, Diwali guests',
        ),
        ForecastItem(
          itemId: 'itm_fortune',
          name: 'Fortune Oil',
          unit: 'litre',
          historyWeekly: [12, 11, 14, 13],
          forecastWeekly: [14, 18, 32, 15],
          lower: [11, 14, 24, 12],
          upper: [17, 22, 40, 19],
          onHand: 14,
          reorderQty: 48,
          reorderReason: 'Diwali sweets & frying ~2.5x',
        ),
        ForecastItem(
          itemId: 'itm_amul',
          name: 'Amul Butter',
          unit: 'piece',
          historyWeekly: [8, 9, 8, 10],
          forecastWeekly: [10, 12, 20, 11],
          lower: [8, 9, 15, 8],
          upper: [12, 15, 26, 14],
          onHand: 9,
          reorderQty: 36,
          reorderReason: 'Festive demand',
        ),
      ],
    );
  }

  @override
  Future<ReorderResponse> reorder(String shopId) async {
    await _wait();
    const lines = [
      ReorderLine(name: 'Parle-G 70g', qty: 120, unit: 'packet'),
      ReorderLine(name: 'Maggi 70g', qty: 96, unit: 'packet'),
      ReorderLine(name: 'Fortune Oil 1L', qty: 48, unit: 'litre'),
      ReorderLine(name: 'Amul Butter 100g', qty: 36, unit: 'piece'),
    ];
    final text = StringBuffer('Order for Gupta General Store (Diwali week):\n');
    for (final l in lines) {
      text.writeln('- ${l.name}: ${l.qty} ${l.unit}');
    }
    text.write('Please deliver by Thursday. Dhanyavaad!');
    final orderId = _id('ord');
    final url = 'https://wa.me/${_distributorPhone?.replaceAll(RegExp(r'[^0-9]'), '') ?? ''}?text=${Uri.encodeComponent(text.toString())}';
    _orders.insert(
      0,
      Order(
        orderId: orderId,
        shopId: shopId,
        createdAt: _now(),
        status: 'placed',
        source: 'manual',
        lines: [for (final l in lines) OrderLine(name: l.name, qty: l.qty, unit: l.unit)],
        text: text.toString(),
        whatsappUrl: url,
      ),
    );
    return ReorderResponse(orderId: orderId, lines: lines, text: text.toString(), whatsappUrl: url);
  }

  @override
  Future<DaySummary> summary(String shopId, {String? date}) async {
    await _wait();
    final low = _stock.where((s) => s.lowStock).toList();
    final outstanding = _ledger.values.fold<num>(0, (a, b) => a + b.balance);
    final lowNames = low.map((s) => s.name).join(', ');
    return DaySummary(
      date: date ?? _today(),
      salesTotal: 8450,
      entries: 23,
      lowStock: low,
      udhaarGiven: 350,
      udhaarReceived: 500,
      totalOutstanding: outstanding,
      replyText:
          'Aaj ka hisaab: bikri ₹8,450, 23 entries. Udhaar diya ₹350, aaya ₹500, '
          'kul baaki ₹$outstanding. Kam hai: $lowNames. Diwali 3 hafte door hai.',
    );
  }

  // ----------------------------------------------------------------- v1.1 --

  bool _autoRestock = false;
  String? _distributorPhone;
  final List<Order> _orders = [];
  final List<ServerMessage> _messages = [];
  bool _seededAuto = false;

  @override
  Future<LanguagesResponse> languages() async {
    await _wait();
    return const LanguagesResponse(languages: kLanguages);
  }

  @override
  Future<Shop> updateShop(String shopId, {bool? autoRestock, String? distributorPhone}) async {
    await _wait();
    if (autoRestock != null) _autoRestock = autoRestock;
    if (distributorPhone != null) _distributorPhone = distributorPhone.isEmpty ? null : distributorPhone;
    if (_autoRestock && !_seededAuto) _seedAutoOrder();
    return Shop(
      shopId: shopId,
      shopName: 'Gupta General Store',
      ownerName: 'Ramesh Gupta',
      language: 'hi-Latn',
      createdAt: _now(),
      autoRestock: _autoRestock,
      distributorPhone: _distributorPhone,
    );
  }

  /// The first time auto-restock is switched on, pretend the nightly run
  /// placed an order so Orders and the chat notice have something to show.
  void _seedAutoOrder() {
    _seededAuto = true;
    final messageId = _id('msg');
    final text = 'Auto order (Diwali week):\n- Parle-G 70g: 264 packet\n- Maggi 70g: 120 packet\nPlease deliver by Thursday.';
    _orders.insert(
      0,
      Order(
        orderId: _id('ord'),
        shopId: 'shp_mock',
        createdAt: _now(),
        status: 'placed',
        source: 'auto',
        messageId: messageId,
        lines: const [
          OrderLine(name: 'Parle-G 70g', qty: 264, unit: 'packet', rank: 1, coverDays: 1.9, demandRatio: 1.4),
          OrderLine(name: 'Maggi 70g', qty: 120, unit: 'packet', rank: 2, coverDays: 0.8, demandRatio: 1.6),
        ],
        text: text,
        whatsappUrl: 'https://wa.me/${_distributorPhone?.replaceAll(RegExp(r'[^0-9]'), '') ?? ''}?text=${Uri.encodeComponent(text)}',
      ),
    );
    _messages.insert(
      0,
      ServerMessage(
        messageId: messageId,
        createdAt: _now(),
        replyText: 'Raat ko auto order bheja: Parle-G 264 packet, Maggi 120 packet. Galat laga toh Undo dabao.',
        quickActions: [
          QuickAction(label: 'Undo', action: 'undo', payload: {'message_id': messageId}),
          const QuickAction(label: 'Orders dekho', action: 'open_orders'),
        ],
      ),
    );
    _undoable.add(MapEntry(messageId, () {
      final idx = _orders.indexWhere((o) => o.messageId == messageId);
      if (idx >= 0) _orders[idx] = _orders[idx].copyWith(status: 'cancelled');
    }));
    _undoText[messageId] = 'Theek hai, auto order cancel kar diya.';
  }

  @override
  Future<TopItemsResponse> topItems(String shopId, {int weeks = 2}) async {
    await _wait();
    return TopItemsResponse(
      generatedAt: _now(),
      items: const [
        TopItem(itemId: 'itm_parleg', name: 'Parle-G', unit: 'packet', rank: 1, forecastUnits: 301, historyUnits: 259, trendPct: 16, onHand: 42, coverDays: 1.9, demandRatio: 1.4, reorderQty: 264, reorderReason: 'Diwali week demand ~1.8x', autoRestockEligible: true),
        TopItem(itemId: 'itm_maggi', name: 'Maggi', unit: 'packet', rank: 2, forecastUnits: 172, historyUnits: 130, trendPct: 32, onHand: 6, coverDays: 0.8, demandRatio: 1.6, reorderQty: 120, reorderReason: 'Stock khatam, guests', autoRestockEligible: true),
        TopItem(itemId: 'itm_fortune', name: 'Fortune Oil', unit: 'litre', rank: 3, forecastUnits: 79, historyUnits: 50, trendPct: 58, onHand: 14, coverDays: 2.4, demandRatio: 1.3, reorderQty: 48, reorderReason: 'Diwali frying', autoRestockEligible: true),
        TopItem(itemId: 'itm_tata_salt', name: 'Tata Salt', unit: 'packet', rank: 4, forecastUnits: 60, historyUnits: 62, trendPct: -3, onHand: 30, coverDays: 7, demandRatio: 1.0, reorderQty: 0, reorderReason: null, autoRestockEligible: false),
        TopItem(itemId: 'itm_amul', name: 'Amul Butter', unit: 'piece', rank: 5, forecastUnits: 53, historyUnits: 35, trendPct: 51, onHand: 9, coverDays: 2.4, demandRatio: 1.2, reorderQty: 36, reorderReason: 'Festive demand', autoRestockEligible: false),
        TopItem(itemId: 'itm_surf', name: 'Surf Excel', unit: 'packet', rank: 6, forecastUnits: 22, historyUnits: 24, trendPct: -8, onHand: 4, coverDays: 2.5, demandRatio: 0.9, reorderQty: 12, reorderReason: null, autoRestockEligible: false),
      ],
    );
  }

  @override
  Future<OrdersResponse> orders(String shopId) async {
    await _wait();
    return OrdersResponse(orders: List.unmodifiable(_orders));
  }

  @override
  Future<MessagesResponse> messages(String shopId, {DateTime? since}) async {
    await _wait();
    return MessagesResponse(
      messages: _messages.where((m) {
        if (since == null) return true;
        final t = DateTime.tryParse(m.createdAt);
        return t == null || t.isAfter(since);
      }).toList(),
    );
  }

  @override
  Future<FeedbackReply> feedback({
    required String shopId,
    required String screen,
    required String rating,
    String? comment,
    required String appVersion,
    required String platform,
  }) async {
    await _wait();
    return FeedbackReply(
      feedbackId: _id('fb'),
      replyText: rating == 'up' ? 'Shukriya! Aapka feedback mil gaya.' : 'Shukriya, hum sudhaar karenge.',
    );
  }

  @override
  Future<FeedbackReply> feedbackVoice({
    required String shopId,
    required String screen,
    required String rating,
    required UploadBlob audio,
    required String appVersion,
    required String platform,
  }) async {
    await Future<void>.delayed(latency * 2);
    return FeedbackReply(feedbackId: _id('fb'), replyText: 'Shukriya! Aapki baat sun li.');
  }

  // -------------------------------------------------------------- helpers --

  String _today() {
    final d = DateTime.now();
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  String _detectLanguage(String s) {
    if (RegExp(r'[ऀ-ॿ]').hasMatch(s)) return 'hi';
    const hinglish = ['hai', 'ka', 'ko', 'ke', 'aaye', 'diya', 'kitna', 'bika', 'udhaar', 'karo'];
    final lower = s.toLowerCase();
    if (hinglish.any((w) => lower.split(RegExp(r'\s+')).contains(w))) return 'hi-Latn';
    return 'en';
  }

  num? _firstNumber(String text, {List<String> skip = const []}) {
    final m = RegExp(r'(\d+(?:\.\d+)?)').allMatches(text).toList();
    if (m.isEmpty) return null;
    return num.tryParse(m.last.group(1)!);
  }

  StockItem? _matchStock(String lower) {
    for (final s in _stock) {
      final key = s.name.toLowerCase();
      final alt = key.replaceAll('-', '').replaceAll(' ', '');
      if (lower.contains(key) || lower.replaceAll('-', '').replaceAll(' ', '').contains(alt)) {
        return s;
      }
      if (key.startsWith('maggi') && lower.contains('मैगी')) return s;
      if (key.startsWith('parle') && lower.contains('पारले')) return s;
    }
    return null;
  }

  String _guessItemName(String raw) {
    final words = raw
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty && !RegExp(r'^\d').hasMatch(w))
        .toList();
    const stop = {'kal', 'aaj', 'ke', 'ka', 'ki', 'aaye', 'aaya', 'bika', 'bike', 'add', 'karo', 'stock', 'mein', 'the', 'of', 'came', 'sold', 'packet', 'carton', 'kg', 'litre', 'piece', 'box'};
    final picked = words.where((w) => !stop.contains(w.toLowerCase())).take(2).join(' ');
    return picked.isEmpty ? 'Item' : picked;
  }

  String? _guessUnit(String lower) {
    for (final u in const ['carton', 'packet', 'kg', 'litre', 'liter', 'piece', 'box']) {
      if (lower.contains(u)) return u == 'liter' ? 'litre' : u;
    }
    if (lower.contains('पैकेट')) return 'packet';
    if (lower.contains('किलो')) return 'kg';
    return null;
  }

  String? _guessCustomer(String raw) {
    for (final name in _ledger.keys) {
      if (raw.toLowerCase().contains(name.toLowerCase().split(' ').first)) {
        return name;
      }
    }
    final m = RegExp(r'([A-Zऀ-ॿ][\wऀ-ॿ]+(?:\s(?:ji|aunty|bhai|uncle|जी))?)')
        .firstMatch(raw.replaceFirst(RegExp(r'^(Kal|Aaj|Today|Yesterday)\s'), ''));
    return m?.group(1);
  }
}
