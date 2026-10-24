import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class TabItem {
  final String icon;
  final String label;
  const TabItem(this.icon, this.label);
}

/// Bottom navigation bar mirroring `.tabbar` / `.tab` in the source HTML:
/// Toy · Planet · Journey · Care · Brand.
class BottomTabBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomTabBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const List<TabItem> items = [
    TabItem('🧸', 'Toy'),
    TabItem('🌱', 'Planet'),
    TabItem('🗺️', 'Journey'),
    TabItem('💗', 'Care'),
    TabItem('🌼', 'Brand'),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Mirrors the `@media(max-width:359px)` compact-tab rule.
        final compact = constraints.maxWidth < 359;
        return Container(
          height: 78,
          padding: EdgeInsets.only(
            left: compact ? 4 : 8,
            right: compact ? 4 : 8,
            top: 7,
            bottom: MediaQuery.of(context).padding.bottom > 10
                ? MediaQuery.of(context).padding.bottom
                : 10,
          ),
          decoration: BoxDecoration(
            color: AppColors.tabBarBg,
            border: const Border(
              top: BorderSide(color: AppColors.tabBarBorder, width: 1),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0x10624B22),
                blurRadius: 26,
                offset: const Offset(0, -10),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(items.length, (i) {
              final active = i == currentIndex;
              final item = items[i];
              return Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 100),
                    child: _TabButton(
                      icon: item.icon,
                      label: item.label,
                      active: active,
                      compact: compact,
                      onTap: () => onTap(i),
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}

class _TabButton extends StatelessWidget {
  final String icon;
  final String label;
  final bool active;
  final bool compact;
  final VoidCallback onTap;

  const _TabButton({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          constraints: BoxConstraints(minWidth: compact ? 0 : 58),
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 2 : 5,
            vertical: 7,
          ),
          decoration: BoxDecoration(
            color: active ? AppColors.tabActiveBg : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                icon,
                style: TextStyle(fontSize: compact ? 20 : 22, height: 1.1),
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: (active ? AppTextStyles.tabLabelActive : AppTextStyles.tabLabel)
                    .copyWith(fontSize: compact ? 9 : 10),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
