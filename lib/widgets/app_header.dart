import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../main.dart' show kDesktopBreakpoint;
import '../providers/dpp_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Top app header — brand mark + "pet passport" pill badge. A single
/// responsive widget: a [LayoutBuilder] picks the compact mobile bar
/// (`.apphead` in the source Mobile HTML) below [kDesktopBreakpoint] and
/// the full-width bordered bar (`.apphead` override in the source
/// Desktop HTML) at or above it, so resizing the window re-lays this out
/// live with no separate mobile/desktop widget classes.
///
/// Shown as "`<brand name>` Passport" — built from the REAL
/// `brand_details.brand_name` from [DppProvider.processDetail], so it
/// never assumes a species (this app covers any pet product, and plenty
/// of pets — birds, fish, reptiles — don't have paws). Falls back to the
/// species-neutral "Pet Passport" only while no data has loaded yet.
class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  const AppHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final brandName = context
        .watch<DppProvider>()
        .processDetail
        ?.brandDetails
        .brandName;
    final name = (brandName == null || brandName.isEmpty)
        ? 'Pet Passport'
        : '$brandName Passport';

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= kDesktopBreakpoint;
        return isDesktop
            ? _AppHeaderDesktop(brandName: name)
            : _AppHeaderMobile(brandName: name);
      },
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(67.h);
}

class _AppHeaderMobile extends StatelessWidget {
  final String brandName;
  const _AppHeaderMobile({required this.brandName});

  @override
  Widget build(BuildContext context) {
    return Container(
      // A few extra `.h` of floor beyond the nominal 67.h: on narrower/
      // taller aspect ratios (e.g. 400x748) flutter_screenutil's `.sp`
      // (text/icon) and `.h` (box) scale factors diverge slightly, so the
      // Row's natural content can need a touch more than exactly 67.h —
      // this buffer absorbs that without visibly changing the bar's size.
      constraints: BoxConstraints(minHeight: 73.h),
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
                      color: AppColors.chipBg,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    alignment: Alignment.center,
                    child: Text('🐾', style: TextStyle(fontSize: 18.sp)),
                  ),
                ),
                SizedBox(width: 8.w),
                Flexible(
                  child: Text(
                    brandName,
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
  final String brandName;
  const _AppHeaderDesktop({required this.brandName});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: 90.h),
      padding: EdgeInsets.symmetric(horizontal: 48.w, vertical: 22.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
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
                      color: AppColors.chipBg,
                      border: Border.all(color: AppColors.passportBorder),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    alignment: Alignment.center,
                    child: Text('🐾', style: TextStyle(fontSize: 26.sp)),
                  ),
                ),
                SizedBox(width: 8.w),
                Flexible(
                  child: Text(
                    brandName,
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
