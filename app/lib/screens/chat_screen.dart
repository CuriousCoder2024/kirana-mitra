import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../api/api_client.dart';
import '../api/api_provider.dart';
import '../l10n/app_localizations.dart';
import '../models/models.dart';
import '../state/chat_controller.dart';
import '../state/data_providers.dart';
import '../state/mic_state.dart';
import '../state/shop_prefs.dart';
import '../state/voice_actions.dart';
import '../theme/theme.dart';
import '../util/format.dart';
import '../widgets/day_chip.dart';
import '../widgets/hisaab_card.dart';
import '../widgets/km_button.dart';
import '../widgets/km_chip.dart';
import '../widgets/km_app_bar.dart';
import '../widgets/message_bubble.dart';
import '../widgets/mic.dart';
import '../widgets/order_sheet.dart';
import '../widgets/reply_card.dart';
import '../widgets/typing_indicator.dart';
import 'onboarding_screen.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _text = TextEditingController();
  final _focus = FocusNode();
  final _picker = ImagePicker();
  late final VoiceActions _voice = VoiceActions(ref);
  bool _typing = false;
  bool _ordering = false;

  /// Contract limit for POST /shelf-scan.
  static const int _maxImageBytes = 8 * 1024 * 1024;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final l = AppLocalizations.of(context);
      final prefs = ref.read(shopPrefsProvider);
      final name = prefs.ownerName.isEmpty ? 'ji' : prefs.ownerName.split(' ').first;
      final ctrl = ref.read(chatControllerProvider.notifier)
        ..networkErrorText = l.networkError
        ..comingSoonText = l.comingSoon
        ..scanFailedText = l.scanFailed
        ..declinedText = l.askDeclined;
      ctrl.addWelcome(prefs.language == 'hi-Latn' ? l.welcomeMessageHinglish(name) : l.welcomeMessage(name));
      if (ref.read(demoNoticePendingProvider)) {
        ref.read(demoNoticePendingProvider.notifier).set(false);
        ctrl.addBotNote(l.demoNotice);
      }
      ctrl.syncServerMessages();
    });
  }

  @override
  void dispose() {
    _text.dispose();
    _focus.dispose();
    _voice.dispose();
    super.dispose();
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg), duration: const Duration(seconds: 2)));
  }

  Future<void> _sendText() async {
    final t = _text.text;
    if (t.trim().isEmpty) return;
    _text.clear();
    setState(() => _typing = false);
    await ref.read(chatControllerProvider.notifier).sendText(t);
  }

  bool get _hasCamera =>
      !kIsWeb && (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS);

  Future<void> _pickPhoto() async {
    final l = AppLocalizations.of(context);
    final XFile? file;
    try {
      file = await _picker.pickImage(
        source: _hasCamera ? ImageSource.camera : ImageSource.gallery,
        maxWidth: 1600,
        imageQuality: 70,
      );
    } catch (_) {
      _snack(l.scanFailed);
      return;
    }
    if (file == null) return;
    final bytes = await file.readAsBytes();
    if (bytes.length > _maxImageBytes) {
      _snack(l.imageTooLarge);
      return;
    }
    final lowerName = file.name.toLowerCase();
    final mime = file.mimeType ?? (lowerName.endsWith('.png') ? 'image/png' : 'image/jpeg');
    await ref.read(chatControllerProvider.notifier).sendImage(
          UploadBlob(bytes: bytes, filename: file.name.isEmpty ? 'shelf.jpg' : file.name, mimeType: mime),
        );
  }

  Future<void> _chip(QuickAction a) async {
    final effect = ref.read(chatControllerProvider.notifier).chipEffect(a);
    if (!mounted || effect == null) return;
    switch (effect) {
      case NavigateEffect(:final route):
        context.go(route);
      case OpenUrlEffect(:final url):
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _orderFromHisaab() async {
    final l = AppLocalizations.of(context);
    setState(() => _ordering = true);
    try {
      final order = await ref.read(apiClientProvider).reorder(ref.read(shopPrefsProvider).shopId ?? '');
      ref.invalidate(ordersProvider);
      if (mounted) await showOrderSheet(context, order);
    } catch (_) {
      if (mounted) _snack(l.networkError);
    } finally {
      if (mounted) setState(() => _ordering = false);
    }
  }

  Future<void> _changeShop() async {
    await ref.read(shopPrefsProvider.notifier).reset();
    if (mounted) context.go('/onboarding');
  }

  String _dayLabel(AppLocalizations l, DateTime d) {
    final now = DateTime.now();
    if (Fmt.sameDay(d, now)) return l.todayChip(Fmt.dateShort(d));
    if (Fmt.sameDay(d, now.subtract(const Duration(days: 1)))) return l.yesterdayChip(Fmt.dateShort(d));
    return Fmt.dateShort(d);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final state = ref.watch(chatControllerProvider);
    final prefs = ref.watch(shopPrefsProvider);
    final recording = ref.watch(micStateProvider.select((s) => s.recording));
    final festival = ref.watch(forecastProvider).value?.festivals.firstOrNull;

    // Build the visual list (day chips + messages), newest last, then reverse.
    final rows = <Widget>[];
    DateTime? lastDay;
    for (final m in state.messages) {
      if (lastDay == null || !Fmt.sameDay(lastDay, m.at)) {
        rows.add(DayChip(label: _dayLabel(l, m.at)));
        lastDay = m.at;
      }
      rows.add(_row(m, state.busy, l, festival));
    }
    if (state.busy) rows.add(TypingIndicator(label: l.thinking));
    final reversed = rows.reversed.toList();

    return Scaffold(
      appBar: KmAppBar(
        showLogo: true,
        title: l.chatTitle,
        subtitle: prefs.shopName,
        actions: [
          PopupMenuButton<String>(
            iconSize: 26,
            tooltip: '',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 40),
            onSelected: (v) {
              if (v == 'hisaab') ref.read(chatControllerProvider.notifier).showHisaab();
              if (v == 'change') _changeShop();
            },
            itemBuilder: (_) => [
              PopupMenuItem(value: 'hisaab', child: Text(l.hisaabTitle)),
              PopupMenuItem(value: 'change', child: Text(l.changeShop)),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 150),
              opacity: recording ? 0.55 : 1,
              child: ListView.separated(
                reverse: true,
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                itemCount: reversed.length,
                separatorBuilder: (_, _) => const SizedBox(height: KmSpace.bubbleGap),
                itemBuilder: (context, i) => reversed[i],
              ),
            ),
          ),
          if (_typing)
            _TypeRow(
              controller: _text,
              focus: _focus,
              hint: l.typeMessageHint,
              sendLabel: l.send,
              busy: state.busy,
              onSend: _sendText,
              onClose: () => setState(() => _typing = false),
            )
          else
            MicDock(
              enabled: !state.busy,
              onStart: () => _voice.start(context),
              onSend: (d) => _voice.send(context, d),
              onCancel: () => _voice.cancel(context),
              onPhoto: _pickPhoto,
              onType: () {
                setState(() => _typing = true);
                WidgetsBinding.instance.addPostFrameCallback((_) => _focus.requestFocus());
              },
            ),
        ],
      ),
    );
  }

  Widget _row(ChatMessage m, bool busy, AppLocalizations l, Festival? festival) {
    final ctrl = ref.read(chatControllerProvider.notifier);
    switch (m.kind) {
      case ChatKind.reply:
      case ChatKind.scan:
        return Align(
          alignment: AlignmentDirectional.centerStart,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: ReplyCard(
              message: m,
              busy: busy,
              onConfirm: () => ctrl.confirm(m),
              onDecline: () => ctrl.decline(m),
              onUndo: () => ctrl.undo(m.id),
              onChip: _chip,
            ),
          ),
        );
      case ChatKind.hisaab:
        return Align(
          alignment: AlignmentDirectional.centerStart,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: HisaabCard(
              summary: m.summary!,
              festival: festival,
              ordering: _ordering,
              onOrder: _orderFromHisaab,
              onShare: () => SharePlus.instance.share(ShareParams(text: m.text)),
            ),
          ),
        );
      case ChatKind.text:
      case ChatKind.voice:
      case ChatKind.photo:
        final bubble = MessageBubble(message: m, voiceLabel: l.voiceNoteLabel);
        if (m.quickActions.isEmpty) return bubble;
        // Server notices (auto orders) carry chips: Undo as a button, the rest navigate.
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            bubble,
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final a in m.quickActions)
                  if (a.action == 'undo')
                    KmButton.undo(
                      label: l.undo,
                      onPressed: busy ? null : () => ctrl.undo(a.messageId ?? m.id),
                    )
                  else
                    KmChip(label: a.label, icon: KmChip.iconFor(a.action), onTap: () => _chip(a)),
              ],
            ),
          ],
        );
    }
  }
}

/// The on-demand text row that replaces the dock after "Likho".
class _TypeRow extends StatelessWidget {
  const _TypeRow({
    required this.controller,
    required this.focus,
    required this.hint,
    required this.sendLabel,
    required this.busy,
    required this.onSend,
    required this.onClose,
  });

  final TextEditingController controller;
  final FocusNode focus;
  final String hint;
  final String sendLabel;
  final bool busy;
  final VoidCallback onSend;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: KmColors.paper,
        border: Border(top: BorderSide(color: KmColors.sand)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 10, 8, 10),
          child: Row(
            children: [
              IconButton(
                onPressed: onClose,
                iconSize: 26,
                color: KmColors.inkSoft,
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                icon: const Icon(Icons.keyboard_hide_outlined),
              ),
              Expanded(
                child: TextField(
                  controller: controller,
                  focusNode: focus,
                  minLines: 1,
                  maxLines: 3,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => onSend(),
                  style: KmText.body,
                  decoration: InputDecoration(
                    hintText: hint,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    fillColor: KmColors.cream,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: KmColors.saffron,
                  borderRadius: BorderRadius.circular(KmRadius.button),
                  boxShadow: KmShadow.hard(KmColors.saffronShadow),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(KmRadius.button),
                    onTap: busy ? null : onSend,
                    child: Semantics(
                      button: true,
                      label: sendLabel,
                      child: const Icon(Icons.send_rounded, color: KmColors.white, size: 26),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
