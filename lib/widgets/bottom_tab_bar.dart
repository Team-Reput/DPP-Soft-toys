import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class TabItem {
  final String icon;
  final String label;
  const TabItem(this.icon, this.label);
}

/// Shared tab list for both the mobile bottom bar and the desktop sidebar.
/// Mirrors the `.tabbar` buttons in the source HTML: Toy · Planet ·
/// Journey · Care · Brand.
const List<TabItem> kTabItems = [
  TabItem('🧸', 'Toy'),
  TabItem('🌱', 'Planet'),
  TabItem('🗺️', 'Journey'),
  TabItem('💗', 'Care'),
  TabItem('🌼', 'Brand'),
];

/// Mobile bottom navigation bar mirroring `.tabbar`/`.tab` in the source
/// Mobile HTML.
class BottomTabBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomTabBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const List<TabItem> items = kTabItems;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Mirrors the `@media(max-width:359px)` compact-tab rule.
        final compact = constraints.maxWidth < 359;
        return Container(
          height: 78.h,
          padding: EdgeInsets.only(
            left: (compact ? 4 : 8).w,
            right: (compact ? 4 : 8).w,
            top: 7.h,
            bottom: MediaQuery.of(context).padding.bottom > 10
                ? MediaQuery.of(context).padding.bottom
                : 10.h,
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
                offset: Offset(0, -10.h),
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
                    constraints: BoxConstraints(maxWidth: 100.w),
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
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          constraints: BoxConstraints(minWidth: compact ? 0 : 58.w),
          padding: EdgeInsets.symmetric(
            horizontal: (compact ? 2 : 5).w,
            vertical: 7.h,
          ),
          decoration: BoxDecoration(
            color: active ? AppColors.tabActiveBg : Colors.transparent,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                icon,
                style: TextStyle(fontSize: (compact ? 20 : 22).sp, height: 1.1),
              ),
              SizedBox(height: 3.h),
              Text(
                label,
                style:
                    (active
                            ? AppTextStyles.tabLabelActive
                            : AppTextStyles.tabLabel)
                        .copyWith(fontSize: (compact ? 9 : 10).sp),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
