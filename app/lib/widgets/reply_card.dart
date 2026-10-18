import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/models.dart';
import '../state/chat_controller.dart';
import '../theme/theme.dart';
import '../util/format.dart';
import 'km_badge.dart';
import 'km_button.dart';
import 'km_chip.dart';

/// Handoff §4.5 (Samjha card), §4.6 (Pakka nahi card) and §5.4 (shelf-scan
/// result). One widget switches on the message kind and status.
class ReplyCard extends StatelessWidget {
  const ReplyCard({
    super.key,
    required this.message,
    required this.busy,
    required this.onConfirm,
    required this.onDecline,
    required this.onUndo,
    required this.onChip,
  });

  final ChatMessage message;
  final bool busy;
  final VoidCallback onConfirm;
  final VoidCallback onDecline;
  final VoidCallback onUndo;
  final void Function(QuickAction) onChip;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final navChips = message.quickActions
        .where((a) => a.action != 'confirm' && a.action != 'undo')
        .toList();
    final confirmLabel = message.quickActions
        .where((a) => a.action == 'confirm')
        .map((a) => a.label)
        .firstOrNull;

    if (message.kind == ChatKind.scan && message.scan != null) {
      return _Shell(
        stripe: KmColors.saffron,
        header: _Header(
          icon: Icons.photo_camera_rounded,
          color: KmColors.saffron,
          text: l.scanHeader(message.scan!.items.length),
        ),
        body: _CountList(
          scan: message.scan!,
          l: l,
          question: message.status == CardStatus.pending
              ? l.scanQuestion
              : null,
        ),
        footer: switch (message.status) {
          CardStatus.pending => _AskFooter(
            confirmLabel: confirmLabel ?? l.askNo,
            noLabel: l.askNo,
            busy: busy,
            onConfirm: onConfirm,
            onDecline: onDecline,
          ),
          CardStatus.applied => _ConfirmedFooter(
            line: l.scanConfirmed,
            undoLabel: l.undo,
            busy: busy,
            onUndo: onUndo,
            chips: navChips,
            onChip: onChip,
          ),
          _ => null,
        },
      );
    }

    final r = message.reply;
    if (r == null) return const SizedBox.shrink();
    final line = _LedgerLine.from(r, l);

    if (message.status == CardStatus.pending ||
        message.status == CardStatus.declined) {
      final question = switch (r.intent) {
        'udhaar_given' || 'udhaar_paid' => l.askUdhaar,
        'sale' => l.askSale,
        _ => l.askStock,
      };
      return _Shell(
        stripe: KmColors.haldi,
        header: _Header(
          icon: Icons.warning_amber_rounded,
          color: KmColors.haldiText,
          text: r.transcript == null || r.transcript!.isEmpty
              ? l.askHeader
              : '${l.askHeader} · ${l.askHeard(r.transcript!)}',
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (line != null)
              line.subjectRow()
            else
              Text(r.replyText, style: KmText.body),
            const SizedBox(height: 6),
            Text(question, style: KmText.caption),
          ],
        ),
        footer: message.status == CardStatus.pending
            ? _AskFooter(
                confirmLabel: confirmLabel ?? l.askNo,
                noLabel: l.askNo,
                busy: busy,
                onConfirm: onConfirm,
                onDecline: onDecline,
              )
            : null,
      );
    }

    // Applied (Samjha) or undone.
    final undone = message.status == CardStatus.undone;
    if (line == null || line.total == null) {
      // Parsing failed: reply_text as a bubble with Undo beneath (§4.5).
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PlainBubble(text: r.replyText),
          if (!undone) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              runSpacing: 8,
              children: [
                KmButton.undo(label: l.undo, onPressed: busy ? null : onUndo),
                for (final a in navChips)
                  KmChip(
                    label: a.label,
                    icon: KmChip.iconFor(a.action),
                    onTap: () => onChip(a),
                  ),
              ],
            ),
          ],
        ],
      );
    }
    return Opacity(
      opacity: undone ? 0.6 : 1,
      child: _Shell(
        stripe: KmColors.leaf,
        header: _Header(
          icon: Icons.check_circle_rounded,
          color: KmColors.leaf,
          text: l.confirmHeader,
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            line.subjectRow(),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(line.totalCaption, style: KmText.caption),
                Text(line.total!, style: KmText.numberM),
              ],
            ),
          ],
        ),
        footer: undone
            ? null
            : Wrap(
                spacing: 10,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  KmButton.undo(label: l.undo, onPressed: busy ? null : onUndo),
                  for (var i = 0; i < navChips.length; i++)
                    KmChip(
                      label: navChips[i].label,
                      icon: KmChip.iconFor(navChips[i].action),
                      onTap: () => onChip(navChips[i]),
                    ),
                ],
              ),
      ),
    );
  }
}

/// Subject / delta / total derived from an ExtractionReply (§4.5 data rules).
class _LedgerLine {
  const _LedgerLine({
    required this.subject,
    required this.delta,
    required this.deltaColor,
    required this.totalCaption,
    required this.total,
  });

  final String subject;
  final String delta;
  final Color deltaColor;
  final String totalCaption;
  final String? total;

  static _LedgerLine? from(ExtractionReply r, AppLocalizations l) {
    final e = r.entities;
    final item = e.items.isEmpty ? null : e.items.first;
    switch (r.intent) {
      case 'udhaar_given':
      case 'udhaar_paid':
        final name = e.customerName;
        if (name == null || name.isEmpty || e.amount == null) return null;
        final paid = r.intent == 'udhaar_paid';
        return _LedgerLine(
          subject: name,
          delta: '${paid ? '−' : '+'} ${Fmt.rupee(e.amount!)}',
          deltaColor: paid ? KmColors.leaf : KmColors.terracotta,
          totalCaption: l.confirmTotalUdhaar,
          total: _parseTotal(r.replyText, rupee: true),
        );
      case 'stock_in':
      case 'sale':
        if (item == null || item.name.isEmpty) return null;
        final sale = r.intent == 'sale';
        final qty = item.quantity == null ? '' : ' ${Fmt.qty(item.quantity!)}';
        final unit = item.unit == null ? '' : ' ${item.unit}';
        final subject = item.packSize == null || item.packSize!.isEmpty
            ? item.name
            : '${item.name} ${item.packSize}';
        return _LedgerLine(
          subject: subject,
          delta: '${sale ? '−' : '+'}$qty$unit',
          deltaColor: sale ? KmColors.terracotta : KmColors.ink,
          totalCaption: sale ? l.confirmTotalSale : l.confirmTotalStock,
          total: _parseTotal(r.replyText, rupee: false, unit: item.unit),
        );
    }
    return null;
  }

  /// The contract reply ends with "Ab total X" / "Total ₹X"; fall back to the
  /// last rupee amount, or "N unit bache" for stock.
  static String? _parseTotal(String text, {required bool rupee, String? unit}) {
    final lower = text.toLowerCase();
    final total = RegExp(
      r'(?:total|kul|कुल)\s*[:]?\s*₹?\s*([\d,]+)',
    ).allMatches(lower).lastOrNull;
    if (total != null) {
      final n = num.tryParse(total.group(1)!.replaceAll(',', ''));
      if (n != null) {
        return rupee ? Fmt.rupee(n) : '${Fmt.int(n)}${unit == null ? '' : ' $unit'}';
      }
    }
    if (rupee) {
      final m = RegExp(r'₹\s*([\d,]+)').allMatches(text).lastOrNull;
      final n = m == null
          ? null
          : num.tryParse(m.group(1)!.replaceAll(',', ''));
      return n == null ? null : Fmt.rupee(n);
    }
    final m = RegExp(
      r'(?:ab|अब)\s+([\d,]+)\s+(\S+)\s+(?:bache|बचे|hain|हैं)',
    ).firstMatch(lower);
    if (m != null) {
      final n = num.tryParse(m.group(1)!.replaceAll(',', ''));
      if (n != null) return '${Fmt.int(n)} ${m.group(2)}';
    }
    return null;
  }

  Widget subjectRow() => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Expanded(
        child: Text(
          subject,
          style: KmText.body,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      const SizedBox(width: 12),
      Text(delta, style: KmText.numberM.copyWith(color: deltaColor)),
    ],
  );
}

class _Shell extends StatelessWidget {
  const _Shell({
    required this.stripe,
    required this.header,
    required this.body,
    this.footer,
  });

  final Color stripe;
  final Widget header;
  final Widget body;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: KmColors.paper,
        borderRadius: BorderRadius.circular(KmRadius.card),
        border: Border.all(color: KmColors.sand),
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 6, color: stripe),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 16, 0),
                    child: header,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 6, 16, 10),
                    child: body,
                  ),
                  if (footer != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 0, 16, 12),
                      child: footer,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.icon, required this.color, required this.text});

  final IconData icon;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 22, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: KmText.body.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}

class _AskFooter extends StatelessWidget {
  const _AskFooter({
    required this.confirmLabel,
    required this.noLabel,
    required this.busy,
    required this.onConfirm,
    required this.onDecline,
  });

  final String confirmLabel;
  final String noLabel;
  final bool busy;
  final VoidCallback onConfirm;
  final VoidCallback onDecline;

  @override
  Widget build(BuildContext context) {
    // Haan carries an icon and a longer label, so it takes 3/5 of the row.
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: KmButton(
            variant: KmButtonVariant.leaf,
            size: KmButtonSize.small,
            icon: Icons.check_rounded,
            label: confirmLabel,
            block: true,
            onPressed: busy ? null : onConfirm,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 2,
          child: KmButton(
            variant: KmButtonVariant.outline,
            size: KmButtonSize.small,
            label: noLabel,
            block: true,
            onPressed: busy ? null : onDecline,
          ),
        ),
      ],
    );
  }
}

class _ConfirmedFooter extends StatelessWidget {
  const _ConfirmedFooter({
    required this.line,
    required this.undoLabel,
    required this.busy,
    required this.onUndo,
    required this.chips,
    required this.onChip,
  });

  final String line;
  final String undoLabel;
  final bool busy;
  final VoidCallback onUndo;
  final List<QuickAction> chips;
  final void Function(QuickAction) onChip;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.check_circle_rounded,
              size: 20,
              color: KmColors.leaf,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                line,
                style: KmText.body.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: KmColors.leaf,
                ),
              ),
            ),
            const SizedBox(width: 8),
            KmButton.undo(label: undoLabel, onPressed: busy ? null : onUndo),
          ],
        ),
        if (chips.isNotEmpty) ...[
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final a in chips)
                KmChip(
                  label: a.label,
                  icon: KmChip.iconFor(a.action),
                  onTap: () => onChip(a),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

/// Handoff §4.8: one row per scanned item, no table header.
class _CountList extends StatelessWidget {
  const _CountList({required this.scan, required this.l, this.question});

  final ShelfScanResponse scan;
  final AppLocalizations l;
  final String? question;

  @override
  Widget build(BuildContext context) {
    final lowByName = {for (final x in scan.lowStock) x.name: x};
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < scan.items.length; i++) ...[
          if (i > 0) const Divider(height: 1),
          Builder(
            builder: (context) {
              final it = scan.items[i];
              final low = lowByName[it.name];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            it.packSize == null || it.packSize!.isEmpty
                                ? it.name
                                : '${it.name} ${it.packSize}',
                            style: KmText.rowTitle,
                          ),
                          if (low != null)
                            Text(
                              l.reorderAt(Fmt.qty(low.reorderLevel)),
                              style: KmText.caption14,
                            ),
                        ],
                      ),
                    ),
                    if (low != null) ...[
                      KmBadge(
                        variant: KmBadgeVariant.low,
                        label: l.lowStockBadge,
                        inRow: true,
                      ),
                      const SizedBox(width: 10),
                    ],
                    Text(
                      Fmt.qty(it.count),
                      style: KmText.numberS.copyWith(
                        color: low != null ? KmColors.mirchi : KmColors.ink,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
        if (question != null) ...[
          const SizedBox(height: 8),
          Text(question!, style: KmText.caption),
        ],
      ],
    );
  }
}

class _PlainBubble extends StatelessWidget {
  const _PlainBubble({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 300),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: KmColors.paper,
        borderRadius: const BorderRadiusDirectional.only(
          topStart: Radius.circular(KmRadius.bubbleTight),
          topEnd: Radius.circular(KmRadius.card),
          bottomStart: Radius.circular(KmRadius.card),
          bottomEnd: Radius.circular(KmRadius.card),
        ),
        border: Border.all(color: KmColors.sand),
      ),
      child: Text(text, style: KmText.body),
    );
  }
}
