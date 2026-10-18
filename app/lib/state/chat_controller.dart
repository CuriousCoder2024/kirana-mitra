import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/api_client.dart';
import '../api/api_provider.dart';
import '../models/models.dart';
import 'data_providers.dart';
import 'shop_prefs.dart';

enum ChatRole { user, bot }

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.role,
    required this.text,
    this.transcript,
    this.quickActions = const [],
    this.isError = false,
    this.isVoice = false,
    this.imageBytes,
    required this.at,
  });

  final String id;
  final ChatRole role;
  final String text;

  /// Voice only: what the backend heard, shown in italic above the reply.
  final String? transcript;
  final List<QuickAction> quickActions;
  final bool isError;
  final bool isVoice;
  final Uint8List? imageBytes;
  final DateTime at;

  ChatMessage copyWith({List<QuickAction>? quickActions}) => ChatMessage(
        id: id,
        role: role,
        text: text,
        transcript: transcript,
        quickActions: quickActions ?? this.quickActions,
        isError: isError,
        isVoice: isVoice,
        imageBytes: imageBytes,
        at: at,
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

  String _nextId() => 'local_${_seq++}';

  void addWelcome(String text) {
    if (state.messages.isNotEmpty) return;
    _append(ChatMessage(
      id: _nextId(),
      role: ChatRole.bot,
      text: text,
      at: DateTime.now(),
    ));
  }

  void _append(ChatMessage m) {
    state = state.copyWith(messages: [...state.messages, m]);
  }

  void _setBusy(bool b) => state = state.copyWith(busy: b);

  void _botError(Object e) {
    final text = switch (e) {
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

  void _botReply(ExtractionReply r) {
    if (r.applied) invalidateShopData(ref);
    _append(ChatMessage(
      id: r.messageId.isEmpty ? _nextId() : r.messageId,
      role: ChatRole.bot,
      text: r.replyText,
      transcript: r.transcript,
      quickActions: r.quickActions,
      at: DateTime.now(),
    ));
  }

  Future<void> sendText(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || state.busy) return;
    _append(ChatMessage(
      id: _nextId(),
      role: ChatRole.user,
      text: trimmed,
      at: DateTime.now(),
    ));
    _setBusy(true);
    try {
      _botReply(await _api.chat(shopId: _shopId, text: trimmed));
    } catch (e) {
      _botError(e);
    } finally {
      _setBusy(false);
    }
  }

  Future<void> sendVoice(UploadBlob audio, {required String placeholder}) async {
    if (state.busy) return;
    _append(ChatMessage(
      id: _nextId(),
      role: ChatRole.user,
      text: placeholder,
      isVoice: true,
      at: DateTime.now(),
    ));
    _setBusy(true);
    try {
      _botReply(await _api.voiceNote(shopId: _shopId, audio: audio));
    } catch (e) {
      _botError(e);
    } finally {
      _setBusy(false);
    }
  }

  Future<void> sendImage(UploadBlob image, {required String placeholder}) async {
    if (state.busy) return;
    _append(ChatMessage(
      id: _nextId(),
      role: ChatRole.user,
      text: placeholder,
      imageBytes: image.bytes,
      at: DateTime.now(),
    ));
    _setBusy(true);
    try {
      final r = await _api.shelfScan(shopId: _shopId, image: image);
      _append(ChatMessage(
        id: r.messageId.isEmpty ? _nextId() : r.messageId,
        role: ChatRole.bot,
        text: r.replyText,
        quickActions: r.quickActions,
        at: DateTime.now(),
      ));
    } catch (e) {
      _botError(e);
    } finally {
      _setBusy(false);
    }
  }

  /// Handles a chip tap. Returns an effect the screen must perform, if any.
  Future<ChatEffect?> tapAction(ChatMessage from, QuickAction action) async {
    switch (action.action) {
      case 'open_stock':
        return const NavigateEffect('/stock');
      case 'open_udhaar':
        return const NavigateEffect('/udhaar');
      case 'open_forecast':
        return const NavigateEffect('/forecast');
      case 'send_order':
        final url = action.whatsappUrl;
        return url == null ? const NavigateEffect('/forecast') : OpenUrlEffect(url);
      case 'confirm':
        await _confirm(from, action.messageId ?? from.id);
        return null;
      case 'undo':
        await _undo(from, action.messageId ?? from.id);
        return null;
      default:
        return null;
    }
  }

  void _removeChips(ChatMessage from) {
    state = state.copyWith(
      messages: [
        for (final m in state.messages)
          if (m.id == from.id) m.copyWith(quickActions: const []) else m,
      ],
    );
  }

  Future<void> _confirm(ChatMessage from, String messageId) async {
    if (state.busy) return;
    _removeChips(from);
    _setBusy(true);
    try {
      _botReply(await _api.confirm(shopId: _shopId, messageId: messageId));
    } catch (e) {
      _botError(e);
    } finally {
      _setBusy(false);
    }
  }

  Future<void> _undo(ChatMessage from, String messageId) async {
    if (state.busy) return;
    _removeChips(from);
    _setBusy(true);
    try {
      final r = await _api.undo(shopId: _shopId, messageId: messageId);
      if (r.undone) invalidateShopData(ref);
      _append(ChatMessage(
        id: _nextId(),
        role: ChatRole.bot,
        text: r.replyText,
        at: DateTime.now(),
      ));
    } catch (e) {
      _botError(e);
    } finally {
      _setBusy(false);
    }
  }
}

final chatControllerProvider =
    NotifierProvider<ChatController, ChatState>(ChatController.new);
