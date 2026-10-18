import 'package:flutter/material.dart';

import '../theme/theme.dart';

/// Three bouncing dots inside a bot bubble.
class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key, required this.label});

  final String label;

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final animate = !MediaQuery.disableAnimationsOf(context);
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Semantics(
        label: widget.label,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 5),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
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
          child: AnimatedBuilder(
            animation: _c,
            builder: (context, _) => Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) {
                final t = ((_c.value * 3) - i).clamp(0.0, 1.0);
                final dy = animate ? -6 * (t < 0.5 ? t * 2 : (1 - t) * 2) : 0.0;
                return Transform.translate(
                  offset: Offset(0, dy),
                  child: Container(
                    width: 10,
                    height: 10,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: const BoxDecoration(color: KmColors.saffron, shape: BoxShape.circle),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
