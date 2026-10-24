import 'package:dpp_soft_toys/widgets/bottom_tab_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Desktop left sidebar navigation — a fixed-width vertical rail with one
/// row per tab (icon + label, side by side) and a tagline footer. Mirrors
/// the desktop `.tabbar`/`.tab` override in the source Desktop HTML
/// (`grid-column:1`, vertical stack, `::after` tagline).
class DesktopSideNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const DesktopSideNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 244.w,
      padding: EdgeInsets.symmetric(vertical: 38.h, horizontal: 20.w),
      decoration: const BoxDecoration(
        color: Color(0xFFFFFCF5),
        border: Border(right: BorderSide(color: Color(0xFFE7DDCF), width: 1)),
      ),
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
          const Spacer(),
          Padding(
            padding: EdgeInsets.only(left: 5.w, bottom: 0),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 180.w),
              child: Text(
                '✿  Little things, loved longer.',
                style: AppTextStyles.display(
                  size: 15,
                  weight: FontWeight.w400,
                  color: const Color(0xFF9A8B77),
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
        hoverColor: const Color(0xFFF4EEDF),
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
                      ? const Color(0xFF436447)
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
