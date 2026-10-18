import 'package:flutter/material.dart';

import '../theme/theme.dart';

/// Handoff §4.9: terracotta ledger card with a stitched spine.
class KhataCard extends StatelessWidget {
  const KhataCard({
    super.key,
    required this.label,
    required this.amount,
    this.line,
  });

  final String label;
  final String amount;
  final String? line;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: KmColors.terracotta,
        borderRadius: BorderRadius.circular(KmRadius.khata),
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(
              width: 10,
              child: CustomPaint(painter: _SpinePainter()),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label.toUpperCase(),
                      style: KmText.label.copyWith(
                        color: KmColors.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.56,
                      ),
                    ),
                    const SizedBox(height: 8),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(amount, style: KmText.ledgerAmount),
                    ),
                    if (line != null && line!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        line!,
                        style: KmText.caption.copyWith(color: KmColors.white),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SpinePainter extends CustomPainter {
  const _SpinePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = KmColors.terracottaSpine;
    for (double y = 4; y < size.height; y += 16) {
      canvas.drawRect(Rect.fromLTWH(0, y, size.width, 8), paint);
    }
  }

  @override
  bool shouldRepaint(_SpinePainter oldDelegate) => false;
}
