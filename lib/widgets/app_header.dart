import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Mobile top app header — brand mark + "pet passport" pill badge.
/// Mirrors `.apphead` in the source Mobile HTML.
class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  const AppHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 67.h,
      padding: EdgeInsets.fromLTRB(22.w, 18.h, 22.w, 10.h),
      color: AppColors.cream,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
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
              Text('avanti paws', style: AppTextStyles.brand),
            ],
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(100.r),
              border: Border.all(color: AppColors.passportBorder, width: 1),
            ),
            child: Text('✦ PET PASSPORT', style: AppTextStyles.passportBadge),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(67.h);
}
