import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/theme.dart';

/// Handoff §4.13: saffron rounded square, cream awning with four scallops,
/// paper speech bubble with an ink mic. Painted natively so no SVG runtime.
class LogoMark extends StatelessWidget {
  const LogoMark({super.key, this.size = 36});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: const CustomPaint(painter: _LogoPainter()),
    );
  }
}

class _LogoPainter extends CustomPainter {
  const _LogoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final rect = Rect.fromLTWH(0, 0, s, s);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(s * 0.25)),
      Paint()..color = KmColors.saffron,
    );

    // Awning: a cream band across the top with four scallops hanging below.
    final awning = Paint()..color = KmColors.cream;
    final bandTop = s * 0.14;
    final bandBottom = s * 0.30;
    canvas.drawRect(Rect.fromLTRB(s * 0.12, bandTop, s * 0.88, bandBottom), awning);
    final scallopW = (s * 0.76) / 4;
    for (var i = 0; i < 4; i++) {
      final cx = s * 0.12 + scallopW * (i + 0.5);
      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, bandBottom), radius: scallopW / 2),
        0,
        math.pi,
        true,
        awning,
      );
    }

    // Speech bubble.
    final bubble = Paint()..color = KmColors.paper;
    final bubbleRect = Rect.fromLTRB(s * 0.22, s * 0.40, s * 0.78, s * 0.78);
    canvas.drawRRect(RRect.fromRectAndRadius(bubbleRect, Radius.circular(s * 0.14)), bubble);
    final tail = Path()
      ..moveTo(s * 0.32, s * 0.76)
      ..lineTo(s * 0.26, s * 0.90)
      ..lineTo(s * 0.46, s * 0.78)
      ..close();
    canvas.drawPath(tail, bubble);

    // Mic.
    final ink = Paint()..color = KmColors.ink;
    final micRect = Rect.fromLTRB(s * 0.44, s * 0.46, s * 0.56, s * 0.64);
    canvas.drawRRect(RRect.fromRectAndRadius(micRect, Radius.circular(s * 0.06)), ink);
    final stroke = Paint()
      ..color = KmColors.ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.035
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromLTRB(s * 0.40, s * 0.52, s * 0.60, s * 0.70),
      0,
      math.pi,
      false,
      stroke,
    );
    canvas.drawLine(Offset(s * 0.50, s * 0.70), Offset(s * 0.50, s * 0.74), stroke);
  }

  @override
  bool shouldRepaint(_LogoPainter oldDelegate) => false;
}
