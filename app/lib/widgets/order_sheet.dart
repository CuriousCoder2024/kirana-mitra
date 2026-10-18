import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/app_localizations.dart';
import '../models/models.dart';
import '../theme/theme.dart';
import 'km_button.dart';
import 'lang_chip.dart';

/// Handoff §5.9: the reorder text with WhatsApp, Copy and Share.
Future<void> showOrderSheet(BuildContext context, ReorderResponse order) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _OrderSheet(order: order),
  );
}

class _OrderSheet extends StatelessWidget {
  const _OrderSheet({required this.order});

  final ReorderResponse order;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 8, 20, 20 + MediaQuery.viewInsetsOf(context).bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SheetHandle(),
            const SizedBox(height: 14),
            Row(
              children: [
                const Icon(Icons.check_circle_rounded, size: 26, color: KmColors.leaf),
                const SizedBox(width: 10),
                Expanded(child: Text(l.orderReady, style: KmText.sheetTitle)),
                Text(l.orderItemCount(order.lines.length), style: KmText.caption14),
              ],
            ),
            const SizedBox(height: 14),
            CustomPaint(
              painter: _DashedBorderPainter(),
              child: Container(
                constraints: const BoxConstraints(maxHeight: 260),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: KmColors.cream, borderRadius: BorderRadius.circular(14)),
                child: SingleChildScrollView(
                  child: SelectableText(order.text, style: KmText.body.copyWith(fontSize: 16)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            KmButton(
              variant: KmButtonVariant.whatsapp,
              label: l.shareWhatsapp,
              block: true,
              onPressed: order.whatsappUrl.isEmpty
                  ? null
                  : () => launchUrl(Uri.parse(order.whatsappUrl), mode: LaunchMode.externalApplication),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: KmButton(
                    variant: KmButtonVariant.outline,
                    icon: Icons.copy_rounded,
                    label: l.copy,
                    block: true,
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: order.text));
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l.copied), duration: const Duration(seconds: 2)),
                        );
                      }
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: KmButton(
                    variant: KmButtonVariant.outline,
                    icon: Icons.ios_share_rounded,
                    label: l.share,
                    block: true,
                    onPressed: () => SharePlus.instance.share(ShareParams(text: order.text)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = KmColors.sand
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final path = Path()..addRRect(RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(14)));
    for (final metric in path.computeMetrics()) {
      var d = 0.0;
      while (d < metric.length) {
        canvas.drawPath(metric.extractPath(d, d + 6), paint);
        d += 10;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter old) => false;
}
