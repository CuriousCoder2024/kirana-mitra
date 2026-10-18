import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/api_client.dart';
import '../api/api_provider.dart';
import '../models/models.dart';
import 'data_providers.dart';
import 'history_store.dart';
import 'shop_prefs.dart';

enum ChatRole { user, bot }

/// What a message renders as (handoff §4.4–4.6, §5.10).
enum ChatKind { text, voice, photo, reply, scan, hisaab }

/// Lifecycle of a reply card.
enum CardStatus { none, pending, applied, declined, undone }

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.role,
    required this.at,
    this.kind = ChatKind.text,
    this.text = '',
    this.transcript,
    this.quickActions = const [],
    this.isError = false,
    this.imageBytes,
    this.audioDuration,
    this.reply,
    this.scan,
    this.summary,
    this.status = CardStatus.none,
  });

  final String id;
  final ChatRole role;
  final DateTime at;
  final ChatKind kind;
  final String text;
  final String? transcript;
  final List<QuickAction> quickActions;
  final bool isError;
  final Uint8List? imageBytes;
  final Duration? audioDuration;

  /// Bot replies of kind [ChatKind.reply].
  final ExtractionReply? reply;

  /// Bot replies of kind [ChatKind.scan].
  final ShelfScanResponse? scan;

  /// Bot replies of kind [ChatKind.hisaab].
  final DaySummary? summary;
  final CardStatus status;

  ChatMessage copyWith({
    List<QuickAction>? quickActions,
    ExtractionReply? reply,
    CardStatus? status,
    String? text,
  }) =>
      ChatMessage(
        id: id,
        role: role,
        at: at,
        kind: kind,
        text: text ?? this.text,
        transcript: transcript,
        quickActions: quickActions ?? this.quickActions,
        isError: isError,
        imageBytes: imageBytes,
        audioDuration: audioDuration,
        reply: reply ?? this.reply,
        scan: scan,
        summary: summary,
        status: status ?? this.status,
      );
}

class ChatState {
  const ChatState({this.messages = const [], this.busy = false});

  final List<ChatMessage> messages;
  final bool busy;

  ChatState copyWith({List<ChatMessage>? messages, bool? busy}) =>
      ChatState(messages: messages ?? this.messages, busy: busy ?? this.busy);
}

/// Side effects a quick action asks the UI to perform.
sealed class ChatEffect {
  const ChatEffect();
}

class NavigateEffect extends ChatEffect {
  const NavigateEffect(this.route);
  final String route;
}

class OpenUrlEffect extends ChatEffect {
  const OpenUrlEffect(this.url);
  final String url;
}

class ChatController extends Notifier<ChatState> {
  int _seq = 0;

  @override
  ChatState build() => const ChatState();

  ApiClient get _api => ref.read(apiClientProvider);
  String get _shopId => ref.read(shopPrefsProvider).shopId ?? '';

  /// Strings the controller needs that live in the l10n file; the screen
  /// passes them in so the controller stays locale-agnostic.
  String networkErrorText = 'Server se baat nahi ho paayi. Phir se try karo.';
  String comingSoonText = 'Shelf scan jaldi aa raha hai!';
  String scanFailedText = 'Photo samajh nahi aayi, phir se try karo.';
  String declinedText = 'Theek hai, nahi likha.';

  String _nextId() => 'local_${_seq++}';

  /// The most recent reply that arrived from a tab's mic FAB, shown as a
  /// floating card for a few seconds (handoff §4.11).
  void addWelcome(String text) {
    if (state.messages.isNotEmpty) return;
    _append(ChatMessage(id: _nextId(), role: ChatRole.bot, text: text, at: DateTime.now()));
  }

  /// Appends a one-off bot bubble (demo notice, declined, etc.).
  void addBotNote(String text) {
    _append(ChatMessage(id: _nextId(), role: ChatRole.bot, text: text, at: DateTime.now()));
  }

  void _append(ChatMessage m) {
    state = state.copyWith(messages: [...state.messages, m]);
  }

  void _replace(String id, ChatMessage Function(ChatMessage) f) {
    state = state.copyWith(
      messages: [for (final m in state.messages) if (m.id == id) f(m) else m],
    );
  }

  void _setBusy(bool b) => state = state.copyWith(busy: b);

  void _botError(Object e, {String? fallback}) {
    final text = switch (e) {
      ApiException(status: 501 || 502) when fallback != null => fallback,
      ApiException(isNotImplemented: true) => comingSoonText,
      ApiException(isNetwork: true) => networkErrorText,
      ApiException(:final message) => message,
      _ => networkErrorText,
    };
    _append(ChatMessage(
      id: _nextId(),
      role: ChatRole.bot,
      text: text,
      isError: true,
      at: DateTime.now(),
    ));
  }

  ChatMessage _replyMessage(ExtractionReply r, {required String source}) {
    if (r.applied) {
      invalidateShopData(ref);
      ref.read(historyStoreProvider.notifier).record(r, source: source);
    }
    final isWrite = const {'stock_in', 'sale', 'udhaar_given', 'udhaar_paid'}.contains(r.intent);
    return ChatMessage(
      id: r.messageId.isEmpty ? _nextId() : r.messageId,
      role: ChatRole.bot,
      kind: isWrite ? ChatKind.reply : ChatKind.text,
      text: r.replyText,
      transcript: r.transcript,
      quickActions: r.quickActions,
      reply: r,
      status: !isWrite
          ? CardStatus.none
          : r.applied
              ? CardStatus.applied
              : CardStatus.pending,
      at: DateTime.now(),
    );
  }

  Future<ExtractionReply?> _send(
    Future<ExtractionReply> Function() call, {
    required String source,
    String? errorFallback,
  }) async {
    _setBusy(true);
    try {
      final r = await call();
      _append(_replyMessage(r, source: source));
      return r;
    } catch (e) {
      _botError(e, fallback: errorFallback);
      return null;
    } finally {
      _setBusy(false);
    }
  }

  Future<void> sendText(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || state.busy) return;
    _append(ChatMessage(id: _nextId(), role: ChatRole.user, text: trimmed, at: DateTime.now()));
    await _send(() => _api.chat(shopId: _shopId, text: trimmed), source: 'text');
  }

  /// Sends a voice note. Returns the reply so a tab FAB can float it.
  Future<ExtractionReply?> sendVoice(UploadBlob audio, {required Duration duration}) async {
    if (state.busy) return null;
    _append(ChatMessage(
      id: _nextId(),
      role: ChatRole.user,
      kind: ChatKind.voice,
      audioDuration: duration,
      at: DateTime.now(),
    ));
    return _send(() => _api.voiceNote(shopId: _shopId, audio: audio), source: 'voice');
  }

  Future<void> sendImage(UploadBlob image) async {
    if (state.busy) return;
    _append(ChatMessage(
      id: _nextId(),
      role: ChatRole.user,
      kind: ChatKind.photo,
      imageBytes: image.bytes,
      at: DateTime.now(),
    ));
    _setBusy(true);
    try {
      final r = await _api.shelfScan(shopId: _shopId, image: image);
      _append(ChatMessage(
        id: r.messageId.isEmpty ? _nextId() : r.messageId,
        role: ChatRole.bot,
        kind: ChatKind.scan,
        text: r.replyText,
        quickActions: r.quickActions,
        scan: r,
        status: CardStatus.pending,
        at: DateTime.now(),
      ));
    } catch (e) {
      _botError(e, fallback: scanFailedText);
    } finally {
      _setBusy(false);
    }
  }

  /// Fetches today's summary and appends the hisaab card (handoff §5.10).
  Future<void> showHisaab() async {
    if (state.busy) return;
    _setBusy(true);
    try {
      final s = await _api.summary(_shopId);
      _append(ChatMessage(
        id: _nextId(),
        role: ChatRole.bot,
        kind: ChatKind.hisaab,
        text: s.replyText,
        summary: s,
        at: DateTime.now(),
      ));
    } catch (e) {
      _botError(e);
    } finally {
      _setBusy(false);
    }
  }

  /// Handles a navigation chip. Returns an effect the screen must perform.
  ChatEffect? chipEffect(QuickAction action) => switch (action.action) {
        'open_stock' => const NavigateEffect('/stock'),
        'open_udhaar' => const NavigateEffect('/udhaar'),
        'open_forecast' => const NavigateEffect('/forecast'),
        'send_order' => action.whatsappUrl == null
            ? const NavigateEffect('/forecast')
            : OpenUrlEffect(action.whatsappUrl!),
        _ => null,
      };

  /// "Haan" on a Pakka-nahi or scan card: POST /confirm.
  Future<void> confirm(ChatMessage card) async {
    if (state.busy) return;
    final messageId = card.quickActions
            .where((a) => a.action == 'confirm')
            .map((a) => a.messageId)
            .firstWhere((id) => id != null, orElse: () => null) ??
        card.id;
    _setBusy(true);
    try {
      final r = await _api.confirm(shopId: _shopId, messageId: messageId);
      if (r.applied) {
        invalidateShopData(ref);
        ref.read(historyStoreProvider.notifier).record(r, source: card.kind == ChatKind.scan ? 'photo' : 'text');
      }
      _replace(card.id, (m) => m.copyWith(reply: r, status: CardStatus.applied, quickActions: r.quickActions));
    } catch (e) {
      _botError(e);
    } finally {
      _setBusy(false);
    }
  }

  /// "Nahi": posts nothing, collapses the footer, appends a bot bubble.
  void decline(ChatMessage card) {
    _replace(card.id, (m) => m.copyWith(status: CardStatus.declined, quickActions: const []));
    addBotNote(declinedText);
  }

  /// Undo button on a Samjha card or history row: POST /undo.
  Future<void> undo(String messageId) async {
    if (state.busy) return;
    _setBusy(true);
    try {
      final r = await _api.undo(shopId: _shopId, messageId: messageId);
      if (r.undone) {
        invalidateShopData(ref);
        ref.read(historyStoreProvider.notifier).markUndone(messageId);
      }
      final hasCard = state.messages.any((m) => m.id == messageId);
      if (hasCard) {
        _replace(messageId, (m) => m.copyWith(status: CardStatus.undone, quickActions: const []));
      }
      _append(ChatMessage(id: _nextId(), role: ChatRole.bot, text: r.replyText, at: DateTime.now()));
    } catch (e) {
      _botError(e);
    } finally {
      _setBusy(false);
    }
  }
}

final chatControllerProvider =
    NotifierProvider<ChatController, ChatState>(ChatController.new);

/// A reply that arrived from a tab's mic FAB, shown as a floating card for
/// six seconds on that tab (handoff §4.11).
class FloatingReply extends Notifier<ChatMessage?> {
  Timer? _timer;

  @override
  ChatMessage? build() {
    ref.onDispose(() => _timer?.cancel());
    return null;
  }

  void show(ChatMessage m) {
    _timer?.cancel();
    state = m;
    _timer = Timer(const Duration(seconds: 6), () => state = null);
  }

  void clear() {
    _timer?.cancel();
    state = null;
  }
}

final floatingReplyProvider = NotifierProvider<FloatingReply, ChatMessage?>(FloatingReply.new);
