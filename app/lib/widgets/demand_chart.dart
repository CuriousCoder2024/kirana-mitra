import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/models.dart';
import '../theme/theme.dart';
import '../util/format.dart';

/// Handoff §4.10. Painted directly: history line, dashed join, forecast line
/// with a paper-stroked peak dot and value, gradient band, tinted future half,
/// dashed festival line with a diya above the plot.
class DemandChart extends StatelessWidget {
  const DemandChart({
    super.key,
    required this.item,
    required this.weeks,
    required this.festivals,
    required this.futureLabel,
    this.height = 176,
  });

  final ForecastItem item;
  final List<String> weeks;
  final List<Festival> festivals;
  final String futureLabel;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _DemandPainter(
          item: item,
          weeks: weeks,
          festivals: festivals,
          futureLabel: futureLabel,
          textScaler: MediaQuery.textScalerOf(context),
        ),
      ),
    );
  }
}

class _DemandPainter extends CustomPainter {
  _DemandPainter({
    required this.item,
    required this.weeks,
    required this.festivals,
    required this.futureLabel,
    required this.textScaler,
  });

  final ForecastItem item;
  final List<String> weeks;
  final List<Festival> festivals;
  final String futureLabel;
  final TextScaler textScaler;

  static const _left = 30.0;
  static const _right = 8.0;
  static const _top = 26.0;
  static const _bottom = 22.0;

  @override
  void paint(Canvas canvas, Size size) {
    final h = item.historyWeekly.map((e) => e.toDouble()).toList();
    final f = item.forecastWeekly.map((e) => e.toDouble()).toList();
    final lo = item.lower.map((e) => e.toDouble()).toList();
    final up = item.upper.map((e) => e.toDouble()).toList();
    final n = h.length + f.length;
    if (n < 2) return;

    final maxRaw = [...h, ...f, ...up, 1.0].reduce(math.max);
    final maxY = (maxRaw / 40).ceil() * 40.0;
    final plot = Rect.fromLTRB(_left, _top, size.width - _right, size.height - _bottom);
    double x(num i) => plot.left + plot.width * (i / (n - 1));
    double y(double v) => plot.bottom - plot.height * (v / maxY);
    final hn = h.length;

    // Future wash.
    if (hn > 0 && f.isNotEmpty) {
      final washLeft = x(hn - 1);
      canvas.drawRect(
        Rect.fromLTRB(washLeft, plot.top, plot.right, plot.bottom),
        Paint()..color = KmColors.saffronWash,
      );
      _text(canvas, futureLabel, Offset(washLeft + 6, plot.top + 2), KmText.label.copyWith(color: KmColors.saffron, fontSize: 11));
    }

    // Grid and y labels.
    final grid = Paint()
      ..color = KmColors.sand
      ..strokeWidth = 1;
    for (var k = 0; k <= 4; k++) {
      final v = maxY * k / 4;
      final yy = y(v);
      canvas.drawLine(Offset(plot.left, yy), Offset(plot.right, yy), grid);
      _text(canvas, v.round().toString(), Offset(0, yy - 6), KmText.axis, width: _left - 6, align: TextAlign.right);
    }

    // X labels every second week.
    DateTime? first;
    try {
      if (weeks.isNotEmpty) first = DateTime.parse(weeks.first);
    } catch (_) {}
    for (var i = 0; i < n; i += 2) {
      final label = first == null
          ? (i < hn ? 'W${i - hn}' : 'W+${i - hn + 1}')
          : Fmt.dayMonth(first.add(Duration(days: 7 * (i - hn))));
      _text(canvas, label, Offset(x(i) - 20, plot.bottom + 6), KmText.axis, width: 40, align: TextAlign.center);
    }

    // Band.
    if (f.isNotEmpty && lo.length >= f.length && up.length >= f.length) {
      final path = Path();
      final startX = hn > 0 ? x(hn - 1) : x(0);
      final startY = hn > 0 ? y(h.last) : y(f.first);
      path.moveTo(startX, startY);
      for (var i = 0; i < f.length; i++) {
        path.lineTo(x(hn + i), y(up[i]));
      }
      for (var i = f.length - 1; i >= 0; i--) {
        path.lineTo(x(hn + i), y(lo[i]));
      }
      path.close();
      canvas.drawPath(
        path,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              KmColors.saffronBright.withValues(alpha: 0.35),
              KmColors.saffronBright.withValues(alpha: 0.08),
            ],
          ).createShader(plot),
      );
    }

    // History line and dots.
    final histPaint = Paint()
      ..color = KmColors.inkSoft
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    if (hn > 1) {
      final p = Path()..moveTo(x(0), y(h[0]));
      for (var i = 1; i < hn; i++) {
        p.lineTo(x(i), y(h[i]));
      }
      canvas.drawPath(p, histPaint);
    }
    for (var i = 0; i < hn; i++) {
      canvas.drawCircle(Offset(x(i), y(h[i])), 3.5, Paint()..color = KmColors.inkSoft);
    }

    // Dashed join from last history point to first forecast point.
    if (hn > 0 && f.isNotEmpty) {
      _dashedLine(
        canvas,
        Offset(x(hn - 1), y(h.last)),
        Offset(x(hn), y(f.first)),
        Paint()
          ..color = KmColors.saffron
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round,
        dash: 6,
        gap: 5,
      );
    }

    // Forecast line, dots and peak.
    final fcPaint = Paint()
      ..color = KmColors.saffron
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    if (f.length > 1) {
      final p = Path()..moveTo(x(hn), y(f[0]));
      for (var i = 1; i < f.length; i++) {
        p.lineTo(x(hn + i), y(f[i]));
      }
      canvas.drawPath(p, fcPaint);
    }
    var peak = -1;
    for (var i = 0; i < f.length; i++) {
      if (peak < 0 || f[i] > f[peak]) peak = i;
    }
    for (var i = 0; i < f.length; i++) {
      final c = Offset(x(hn + i), y(f[i]));
      final r = i == peak ? 6.0 : 4.5;
      canvas.drawCircle(c, r + 1.5, Paint()..color = KmColors.paper);
      canvas.drawCircle(c, r, Paint()..color = KmColors.saffron);
      if (i == peak) {
        _text(canvas, Fmt.int(f[i]), Offset(c.dx - 20, c.dy - 22), KmText.peakValue.copyWith(color: KmColors.saffron),
            width: 40, align: TextAlign.center);
      }
    }

    // Festival markers.
    if (first != null) {
      for (final fest in festivals) {
        DateTime d;
        try {
          d = DateTime.parse(fest.date);
        } catch (_) {
          continue;
        }
        final pos = hn + d.difference(first).inDays / 7;
        if (pos < 0 || pos > n - 1) continue;
        final fx = x(pos);
        _dashedLine(
          canvas,
          Offset(fx, plot.top),
          Offset(fx, plot.bottom),
          Paint()
            ..color = KmColors.haldi
            ..strokeWidth = 2,
          dash: 5,
          gap: 4,
        );
        _diya(canvas, Offset(fx, plot.top - 12));
      }
    }
  }

  void _diya(Canvas canvas, Offset c) {
    // A 20 dp lamp: haldi bowl with a saffronBright flame.
    final bowl = Path()
      ..moveTo(c.dx - 9, c.dy + 2)
      ..quadraticBezierTo(c.dx, c.dy + 12, c.dx + 9, c.dy + 2)
      ..close();
    canvas.drawPath(bowl, Paint()..color = KmColors.haldi);
    final flame = Path()
      ..moveTo(c.dx, c.dy - 9)
      ..quadraticBezierTo(c.dx + 5, c.dy - 2, c.dx, c.dy + 2)
      ..quadraticBezierTo(c.dx - 5, c.dy - 2, c.dx, c.dy - 9)
      ..close();
    canvas.drawPath(flame, Paint()..color = KmColors.saffronBright);
  }

  void _dashedLine(Canvas canvas, Offset a, Offset b, Paint paint, {required double dash, required double gap}) {
    final total = (b - a).distance;
    if (total == 0) return;
    final dir = (b - a) / total;
    var t = 0.0;
    while (t < total) {
      final end = math.min(t + dash, total);
      canvas.drawLine(a + dir * t, a + dir * end, paint);
      t += dash + gap;
    }
  }

  void _text(Canvas canvas, String s, Offset at, TextStyle style, {double? width, TextAlign align = TextAlign.left}) {
    final tp = TextPainter(
      text: TextSpan(text: s, style: style),
      textAlign: align,
      textDirection: TextDirection.ltr,
      textScaler: textScaler,
    )..layout(minWidth: width ?? 0, maxWidth: width ?? 200);
    tp.paint(canvas, at);
  }

  @override
  bool shouldRepaint(_DemandPainter old) =>
      old.item != item || old.weeks != weeks || old.festivals != festivals;
}

/// Legend row beneath the chart: Pichhle hafte · Anumaan · Range · festival.
class ChartLegend extends StatelessWidget {
  const ChartLegend({
    super.key,
    required this.history,
    required this.forecast,
    required this.band,
    required this.festivals,
  });

  final String history;
  final String forecast;
  final String band;
  final List<String> festivals;

  @override
  Widget build(BuildContext context) {
    Widget key(Widget swatch, String label) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [swatch, const SizedBox(width: 6), Text(label, style: KmText.legend)],
        );
    Widget line(Color c) => Container(width: 18, height: 3, color: c);
    return Wrap(
      spacing: 14,
      runSpacing: 6,
      children: [
        key(line(KmColors.inkSoft), history),
        key(line(KmColors.saffron), forecast),
        key(Container(width: 18, height: 12, color: KmColors.saffronBright.withValues(alpha: 0.25)), band),
        for (final f in festivals) key(Container(width: 3, height: 14, color: KmColors.haldi), f),
      ],
    );
  }
}
