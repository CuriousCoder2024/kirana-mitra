import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/models.dart';
import '../theme/theme.dart';
import '../util/format.dart';
import 'km_button.dart';

/// Handoff §5.10: evening summary card rendered in the chat.
class HisaabCard extends StatelessWidget {
  const HisaabCard({
    super.key,
    required this.summary,
    required this.onOrder,
    required this.onShare,
    this.festival,
    this.ordering = false,
  });

  final DaySummary summary;
  final VoidCallback onOrder;
  final VoidCallback onShare;
  final Festival? festival;
  final bool ordering;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final date = Fmt.parse(summary.date) ?? DateTime.now();
    final lowNames = summary.lowStock.map((s) => s.name).join(', ');
    String? festivalLine;
    if (festival != null) {
      final fd = Fmt.parse(festival!.date);
      if (fd != null) {
        final weeks = (fd.difference(DateTime.now()).inDays / 7).ceil();
        festivalLine = l.hisaabFestival(festival!.name, weeks.toString());
      }
    }

    Widget tile(String label, String value, Color valueColor, {Color fill = KmColors.cream}) => Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: fill, borderRadius: BorderRadius.circular(14)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: KmText.status),
              const SizedBox(height: 4),
              Text(value, style: KmText.numberS.copyWith(color: valueColor)),
            ],
          ),
        );

    return Container(
      decoration: BoxDecoration(
        color: KmColors.paper,
        borderRadius: BorderRadius.circular(KmRadius.card),
        border: Border.all(color: KmColors.sand),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: KmColors.ink,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const Icon(Icons.receipt_long_rounded, size: 24, color: KmColors.saffronBright),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l.hisaabTitle, style: KmText.heading.copyWith(fontSize: 18, color: KmColors.white)),
                      Text(
                        l.hisaabSubtitle(Fmt.dateShort(date), summary.entries),
                        style: KmText.status.copyWith(color: KmColors.white.withValues(alpha: 0.85)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l.hisaabSales, style: KmText.body.copyWith(fontSize: 16, color: KmColors.inkSoft)),
                const SizedBox(height: 2),
                Text(Fmt.rupee(summary.salesTotal), style: KmText.numberL.copyWith(color: KmColors.leaf)),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(child: tile(l.hisaabGiven, '+${Fmt.rupee(summary.udhaarGiven)}', KmColors.terracotta)),
                    const SizedBox(width: 10),
                    Expanded(child: tile(l.hisaabReceived, Fmt.rupee(summary.udhaarReceived), KmColors.leaf)),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: tile(l.hisaabOutstanding, Fmt.rupee(summary.totalOutstanding), KmColors.ink)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: tile(l.hisaabLow, summary.lowStock.length.toString(), KmColors.mirchi, fill: KmColors.mirchiTint),
                    ),
                  ],
                ),
                if (lowNames.isNotEmpty || festivalLine != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    [if (lowNames.isNotEmpty) l.hisaabLowItems(lowNames), ?festivalLine].join(' '),
                    style: KmText.caption,
                  ),
                ],
                const SizedBox(height: 14),
                KmButton(
                  size: KmButtonSize.small,
                  icon: Icons.shopping_cart_checkout_rounded,
                  label: l.hisaabOrderButton,
                  block: true,
                  loading: ordering,
                  onPressed: onOrder,
                ),
                const SizedBox(height: 8),
                KmButton(
                  variant: KmButtonVariant.outline,
                  size: KmButtonSize.small,
                  icon: Icons.send_rounded,
                  label: l.hisaabShareButton,
                  block: true,
                  onPressed: onShare,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
