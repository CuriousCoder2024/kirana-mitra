import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../state/chat_controller.dart';
import '../state/mic_state.dart';
import '../state/voice_actions.dart';
import '../theme/theme.dart';
import 'mic.dart';
import 'reply_card.dart';

/// Scaffold for Stock, Udhaar, Forecast and Customer: mic FAB 16 dp from the
/// edge and 32 dp above the nav bar, recording overlay, floating reply card.
class TabScaffold extends ConsumerStatefulWidget {
  const TabScaffold({
    super.key,
    required this.appBar,
    required this.body,
    this.micPrompt,
    this.showFab = true,
    this.bottomBar,
  });

  final PreferredSizeWidget appBar;
  final Widget body;
  final String? micPrompt;
  final bool showFab;

  /// Pinned under the body (the FAB sits above it), e.g. the order button.
  final Widget? bottomBar;

  @override
  ConsumerState<TabScaffold> createState() => _TabScaffoldState();
}

class _TabScaffoldState extends ConsumerState<TabScaffold> {
  late final VoiceActions _voice = VoiceActions(ref);

  @override
  void dispose() {
    _voice.dispose();
    super.dispose();
  }

  Future<void> _chip(ChatMessage card, dynamic action) async {
    final effect = ref.read(chatControllerProvider.notifier).chipEffect(action);
    ref.read(floatingReplyProvider.notifier).clear();
    if (!mounted || effect == null) return;
    switch (effect) {
      case NavigateEffect(:final route):
        context.go(route);
      case OpenUrlEffect(:final url):
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final recording = ref.watch(micStateProvider.select((s) => s.recording));
    final floating = ref.watch(floatingReplyProvider);
    final chat = ref.watch(chatControllerProvider);
    // Keep the floating card in sync with the chat message (status, chips).
    final card = floating == null ? null : chat.messages.where((m) => m.id == floating.id).firstOrNull ?? floating;

    return Scaffold(
      appBar: widget.appBar,
      body: Stack(
        children: [
          AnimatedOpacity(
            duration: const Duration(milliseconds: 150),
            opacity: recording ? 0.55 : 1,
            child: widget.body,
          ),
          if (card != null && !recording)
            Positioned(
              left: KmSpace.gutter,
              right: KmSpace.gutter + 76,
              bottom: 24,
              child: Material(
                color: Colors.transparent,
                child: ReplyCard(
                  message: card,
                  busy: chat.busy,
                  onConfirm: () => ref.read(chatControllerProvider.notifier).confirm(card),
                  onDecline: () {
                    ref.read(chatControllerProvider.notifier).decline(card);
                    ref.read(floatingReplyProvider.notifier).clear();
                  },
                  onUndo: () => ref.read(chatControllerProvider.notifier).undo(card.id),
                  onChip: (a) => _chip(card, a),
                ),
              ),
            ),
          const Positioned(left: 0, right: 0, bottom: 0, child: RecordingOverlay()),
        ],
      ),
      bottomNavigationBar: widget.bottomBar == null
          ? null
          : Container(
              decoration: const BoxDecoration(
                color: KmColors.paper,
                border: Border(top: BorderSide(color: KmColors.sand)),
              ),
              padding: const EdgeInsets.fromLTRB(KmSpace.gutter, 12, KmSpace.gutter, 12),
              child: SafeArea(top: false, child: widget.bottomBar!),
            ),
      floatingActionButton: widget.showFab
          ? Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: MicFab(
                enabled: !chat.busy,
                prompt: widget.micPrompt,
                onStart: () => _voice.start(context),
                onSend: (d) => _voice.send(context, d, float: true),
                onCancel: () => _voice.cancel(context),
              ),
            )
          : null,
    );
  }
}
