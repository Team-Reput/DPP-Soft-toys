import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class TabItem {
  final String icon;
  final String label;
  const TabItem(this.icon, this.label);
}

/// Shared tab list for [AppNavBar]. Mirrors the `.tabbar` buttons in the
/// source HTML: Toy · Planet · Journey · Care · Brand.
const List<TabItem> kTabItems = [
  TabItem('🧸', 'Toy'),
  TabItem('🌱', 'Planet'),
  TabItem('🗺️', 'Journey'),
  TabItem('💗', 'Care'),
  TabItem('🌼', 'Brand'),
];

/// App navigation bar — one widget, two renderings picked by the caller
/// (`AppNavBar.bottom(...)` or `AppNavBar.side(...)`), replacing the old
/// separate `BottomTabBar`/`DesktopSideNav` widget classes. [PassportShell]
/// decides which one to place (bottom pill bar in its mobile Column,
/// side rail in its desktop Row) from a single top-level breakpoint
/// check, so there is still only one navigation component to maintain.
class AppNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool _vertical;

  const AppNavBar.bottom({
    super.key,
    required this.currentIndex,
    required this.onTap,
  }) : _vertical = false;

  const AppNavBar.side({
    super.key,
    required this.currentIndex,
    required this.onTap,
  }) : _vertical = true;

  static const List<TabItem> items = kTabItems;

  @override
  Widget build(BuildContext context) {
    return _vertical
        ? _SideNav(currentIndex: currentIndex, onTap: onTap)
        : _BottomBar(currentIndex: currentIndex, onTap: onTap);
  }
}

/// Mobile bottom navigation bar mirroring `.tabbar`/`.tab` in the source
/// Mobile HTML.
class _BottomBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _BottomBar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Mirrors the `@media(max-width:359px)` compact-tab rule.
        final compact = constraints.maxWidth < 359;
        return Container(
          // A few extra `.h` of floor beyond the nominal 78.h, same reason
          // as `_AppHeaderMobile`'s buffer: on narrower/taller aspect
          // ratios the icon+label Column's natural content can need a
          // touch more than exactly 78.h once `.sp` vs `.h` scale factors
          // diverge, which was the source of the residual (~2px) overflow
          // in `passport_shell.dart`'s outer Column even after that fix.
          constraints: BoxConstraints(minHeight: 85.h),
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
                color: const Color(0x12101F1C),
                blurRadius: 26,
                offset: Offset(0, -10.h),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(kTabItems.length, (i) {
              final active = i == currentIndex;
              final item = kTabItems[i];
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

/// Desktop left sidebar navigation — a fixed-width vertical rail with one
/// row per tab (icon + label, side by side) and a tagline footer. Mirrors
/// the desktop `.tabbar`/`.tab` override in the source Desktop HTML
/// (`grid-column:1`, vertical stack, `::after` tagline).
class _SideNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _SideNav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 244.w,
      padding: EdgeInsets.symmetric(vertical: 38.h, horizontal: 20.w),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: AppColors.border, width: 1)),
      ),
      // A Column + Spacer() needs the tab list to fit in whatever's left
      // after the tagline — on a short window that can still overflow.
      // Scrolling the tab list (and pinning the tagline below it, outside
      // the scroll view) means a short window scrolls instead of erroring.
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < kTabItems.length; i++) ...[
                    _SideNavTab(
                      item: kTabItems[i],
                      active: i == currentIndex,
                      onTap: () => onTap(i),
                    ),
                    SizedBox(height: 8.h),
                  ],
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 5.w, bottom: 0),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 180.w),
              child: Text(
                '✿  Little things, loved longer.',
                style: AppTextStyles.display(
                  size: 15,
                  weight: FontWeight.w400,
                  color: const Color(0xFF7F8B87),
                  height: 1.6,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SideNavTab extends StatelessWidget {
  final TabItem item;
  final bool active;
  final VoidCallback onTap;

  const _SideNavTab({
    required this.item,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18.r),
        hoverColor: const Color(0xFFEFF8F6),
        child: Container(
          constraints: BoxConstraints(minHeight: 60.h),
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 15.h),
          decoration: BoxDecoration(
            color: active ? AppColors.tabActiveBg : Colors.transparent,
            borderRadius: BorderRadius.circular(18.r),
          ),
          child: Row(
            children: [
              Text(item.icon, style: TextStyle(fontSize: 25.sp)),
              SizedBox(width: 18.w),
              Text(
                item.label,
                style: AppTextStyles.body(
                  size: 14,
                  weight: FontWeight.w800,
                  color: active
                      ? const Color(0xFF1F5A50)
                      : AppColors.tabInactive,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
