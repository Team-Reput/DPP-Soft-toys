import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../main.dart' show kDesktopBreakpoint;
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Top app header — brand mark + "pet passport" pill badge. A single
/// responsive widget: a [LayoutBuilder] picks the compact mobile bar
/// (`.apphead` in the source Mobile HTML) below [kDesktopBreakpoint] and
/// the full-width bordered bar (`.apphead` override in the source
/// Desktop HTML) at or above it, so resizing the window re-lays this out
/// live with no separate mobile/desktop widget classes.
class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  const AppHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= kDesktopBreakpoint;
        return isDesktop ? const _AppHeaderDesktop() : const _AppHeaderMobile();
      },
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(67.h);
}

class _AppHeaderMobile extends StatelessWidget {
  const _AppHeaderMobile();

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: 67.h),
      padding: EdgeInsets.fromLTRB(22.w, 14.h, 22.w, 14.h),
      color: AppColors.cream,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Transform.rotate(
                  angle: -0.14, // ~-8deg
                  child: Container(
                    width: 34.w,
                    height: 34.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEED5AF),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    alignment: Alignment.center,
                    child: Text('🐾', style: TextStyle(fontSize: 18.sp)),
                  ),
                ),
                SizedBox(width: 8.w),
                Flexible(
                  child: Text(
                    'avanti paws',
                    style: AppTextStyles.brand,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Flexible(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(100.r),
                border: Border.all(color: AppColors.passportBorder, width: 1),
              ),
              child: Text(
                '✦ PET PASSPORT',
                style: AppTextStyles.passportBadge,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AppHeaderDesktop extends StatelessWidget {
  const _AppHeaderDesktop();

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: 90.h),
      padding: EdgeInsets.symmetric(horizontal: 48.w, vertical: 22.h),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCF5),
        border: const Border(
          bottom: BorderSide(color: Color(0xFFE7DDCF), width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Transform.rotate(
                  angle: -0.14,
                  child: Container(
                    width: 44.w,
                    height: 44.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE4ECDD),
                      border: Border.all(color: const Color(0xFFD2DEC8)),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    alignment: Alignment.center,
                    child: Text('🐾', style: TextStyle(fontSize: 26.sp)),
                  ),
                ),
                SizedBox(width: 8.w),
                Flexible(
                  child: Text(
                    'avanti paws',
                    style: AppTextStyles.display(
                      size: 25,
                      weight: FontWeight.w600,
                      height: 1.0,
                    ).copyWith(letterSpacing: -1.1),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          Flexible(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 11.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(100.r),
                border: Border.all(color: AppColors.passportBorder, width: 1),
              ),
              child: Text(
                '✦ PET PASSPORT',
                style: AppTextStyles.body(
                  size: 11,
                  weight: FontWeight.w800,
                  color: AppColors.passportText,
                ).copyWith(letterSpacing: 0.8),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
