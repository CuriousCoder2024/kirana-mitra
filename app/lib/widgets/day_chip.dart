import 'package:flutter/material.dart';

import '../theme/theme.dart';

/// Date separator in the chat list ("Aaj · Sat 18 Oct").
class DayChip extends StatelessWidget {
  const DayChip({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(color: KmColors.sand, borderRadius: BorderRadius.circular(99)),
        child: Text(label, style: KmText.status.copyWith(color: KmColors.ink)),
      ),
    );
  }
}
