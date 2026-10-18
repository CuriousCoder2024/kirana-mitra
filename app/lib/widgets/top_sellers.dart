import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/models.dart';
import '../theme/theme.dart';
import '../util/format.dart';
import 'km_badge.dart';
import 'km_row.dart';

/// Ranked list of GET /top-items with trend arrows and an "Auto" badge on
/// auto-restock-eligible items.
class TopSellersList extends StatelessWidget {
  const TopSellersList({super.key, required this.items});

  final List<TopItem> items;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return KmRowGroup(
      children: [
        for (var i = 0; i < items.length; i++)
          KmRow(
            minHeight: 64,
            leading: Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: i < 3 ? KmColors.saffronTint : KmColors.cream,
                borderRadius: BorderRadius.circular(KmRadius.tile),
              ),
              // Backends that omit `rank` still return the list sorted.
              child: Text('#${items[i].rank > 0 ? items[i].rank : i + 1}', style: KmText.tileLetter.copyWith(fontSize: 18)),
            ),
            title: items[i].name,
            caption: [
              l.unitsPerFortnight(Fmt.int(items[i].forecastUnits), items[i].unit),
              l.coverDays(Fmt.qty(items[i].coverDays)),
              if (items[i].demandRatio > 0) '×${items[i].demandRatio}',
            ].join(' · '),
            trailing: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                _Trend(pct: items[i].trendPct),
                if (items[i].autoRestockEligible) ...[
                  const SizedBox(height: 4),
                  KmBadge(variant: KmBadgeVariant.ok, label: l.autoBadge, inRow: true),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

class _Trend extends StatelessWidget {
  const _Trend({required this.pct});

  final num pct;

  @override
  Widget build(BuildContext context) {
    final up = pct >= 0;
    final color = up ? KmColors.leaf : KmColors.mirchi;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(up ? Icons.trending_up_rounded : Icons.trending_down_rounded, size: 22, color: color),
        const SizedBox(width: 4),
        Text('${up ? '+' : ''}${Fmt.int(pct)}%', style: KmText.numberS.copyWith(color: color)),
      ],
    );
  }
}
