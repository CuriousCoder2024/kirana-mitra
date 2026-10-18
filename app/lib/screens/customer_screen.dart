import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/app_localizations.dart';
import '../state/chat_controller.dart';
import '../state/data_providers.dart';
import '../state/history_store.dart';
import '../state/shop_prefs.dart';
import '../state/voice_actions.dart';
import '../theme/theme.dart';
import '../util/format.dart';
import '../widgets/khata_card.dart';
import '../widgets/km_app_bar.dart';
import '../widgets/km_button.dart';
import '../widgets/km_row.dart';
import '../widgets/mic.dart';
import '../widgets/tab_scaffold.dart';

/// Handoff §5.7. History comes from the local cache of applied replies
/// because the contract has no per-customer endpoint yet (Phase 5 gap).
class CustomerScreen extends ConsumerStatefulWidget {
  const CustomerScreen({super.key, required this.name});

  final String name;

  @override
  ConsumerState<CustomerScreen> createState() => _CustomerScreenState();
}

class _CustomerScreenState extends ConsumerState<CustomerScreen> {
  late final VoiceActions _voice = VoiceActions(ref);

  @override
  void dispose() {
    _voice.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final prefs = ref.watch(shopPrefsProvider);
    final ledger = ref.watch(ledgerProvider).value;
    final customer = ledger?.customers.where((c) => c.customerName.toLowerCase() == widget.name.toLowerCase()).firstOrNull;
    final store = ref.watch(historyStoreProvider.notifier);
    ref.watch(historyStoreProvider);
    final entries = store.forCustomer(widget.name);
    final chat = ref.watch(chatControllerProvider);
    final balance = customer?.balance ?? 0;
    final first = entries.isEmpty ? Fmt.parse(customer?.lastEntryAt) : entries.last.at;
    final last = entries.isEmpty ? Fmt.parse(customer?.lastEntryAt) : entries.first.at;
    final reminder = l.reminderText(widget.name, prefs.shopName, Fmt.int(balance));

    return TabScaffold(
      showFab: false,
      micPrompt: l.paidPrompt,
      appBar: KmAppBar(
        title: widget.name,
        subtitle: l.customerSubtitle(first == null ? '—' : Fmt.dayMonth(first), entries.length),
        onBack: () => context.go('/udhaar'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(KmSpace.gutter, 12, KmSpace.gutter, 40),
        children: [
          KhataCard(
            label: l.balanceLabel,
            amount: Fmt.rupee(balance),
            line: last == null ? null : l.lastEntryAt('${Fmt.dayMonth(last)}, ${Fmt.time(last)}'),
          ),
          const SizedBox(height: KmSpace.cardGap),
          LayoutBuilder(
            builder: (context, c) {
              final remind = KmButton(
                variant: KmButtonVariant.whatsapp,
                icon: Icons.notifications_active_outlined,
                label: l.remindButton,
                block: true,
                onPressed: () => launchUrl(
                  Uri.parse('https://wa.me/?text=${Uri.encodeComponent(reminder)}'),
                  mode: LaunchMode.externalApplication,
                ),
              );
              final paid = HoldToTalk(
                enabled: !chat.busy,
                prompt: l.paidPrompt,
                onStart: () => _voice.start(context),
                onSend: (d) => _voice.send(context, d, float: true),
                onCancel: () => _voice.cancel(context),
                builder: (context, state) => KmButton(
                  variant: state.recording ? KmButtonVariant.undo : KmButtonVariant.leaf,
                  icon: state.recording ? Icons.mic_rounded : Icons.currency_rupee_rounded,
                  label: state.recording ? Fmt.timer(state.elapsed) : l.paidButton,
                  block: true,
                  onPressed: () {},
                ),
              );
              // Side by side when there is room (handoff §5.7), stacked on
              // narrow phones so neither label truncates.
              if (c.maxWidth < 400) {
                return Column(children: [remind, const SizedBox(height: 10), paid]);
              }
              return Row(children: [Expanded(child: remind), const SizedBox(width: 10), Expanded(child: paid)]);
            },
          ),
          const SizedBox(height: KmSpace.section),
          Text(l.historyLabel.toUpperCase(), style: KmText.sectionLabel),
          const SizedBox(height: 10),
          if (entries.isEmpty)
            Text(l.emptyLedger, style: KmText.caption)
          else
            KmRowGroup(
              children: [
                for (final e in entries)
                  KmRow(
                    minHeight: 64,
                    leading: Icon(
                      e.intent == 'udhaar_paid' ? Icons.south_west_rounded : Icons.north_east_rounded,
                      color: e.intent == 'udhaar_paid' ? KmColors.leaf : KmColors.terracotta,
                    ),
                    title: e.intent == 'udhaar_paid' ? l.entryPaid : l.entryGiven,
                    caption: '${Fmt.dayMonth(e.at)} · ${switch (e.source) {
                      'voice' => l.entrySourceVoice,
                      'photo' => l.entrySourcePhoto,
                      _ => l.entrySourceCash,
                    }}',
                    trailing: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${e.intent == 'udhaar_paid' ? '−' : '+'}${Fmt.rupee(e.amount ?? 0)}',
                          style: KmText.numberM.copyWith(color: e.intent == 'udhaar_paid' ? KmColors.leaf : KmColors.terracotta),
                        ),
                        if (store.isUndoable(e.messageId)) ...[
                          const SizedBox(height: 6),
                          SizedBox(
                            height: 40,
                            child: KmButton.undo(
                              label: l.undo,
                              onPressed: chat.busy ? null : () => ref.read(chatControllerProvider.notifier).undo(e.messageId),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
