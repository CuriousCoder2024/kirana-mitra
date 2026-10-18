import 'package:flutter/material.dart';

import '../theme/theme.dart';

class KmNavItem {
  const KmNavItem({required this.icon, required this.selectedIcon, required this.label});

  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

/// Handoff §4.14: 72 dp paper bar with a 56 × 32 saffronTint pill behind the
/// selected icon.
class KmNavBar extends StatelessWidget {
  const KmNavBar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<KmNavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: KmColors.paper,
        border: Border(top: BorderSide(color: KmColors.sand)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: KmSize.navBar,
          child: Row(
            children: [
              for (var i = 0; i < items.length; i++)
                Expanded(
                  child: _NavButton(
                    item: items[i],
                    selected: i == selectedIndex,
                    onTap: () => onSelected(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({required this.item, required this.selected, required this.onTap});

  final KmNavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? KmColors.terracotta : KmColors.inkSoft;
    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 56,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? KmColors.saffronTint : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(selected ? item.selectedIcon : item.icon, size: 26, color: color),
            ),
            const SizedBox(height: 4),
            Text(item.label, style: KmText.navLabel.copyWith(color: color)),
          ],
        ),
      ),
    );
  }
}
