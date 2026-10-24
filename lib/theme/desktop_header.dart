import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Desktop top app header — spans the full width above both the sidebar
/// and the content column. Mirrors the desktop `.apphead` override in the
/// source Desktop HTML (`grid-column:1/3`, bottom border, bigger brand).
class DesktopHeader extends StatelessWidget {
  const DesktopHeader({super.key});

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
          Row(
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
              Text(
                'avanti paws',
                style: AppTextStyles.display(
                  size: 25,
                  weight: FontWeight.w600,
                  height: 1.0,
                ).copyWith(letterSpacing: -1.1),
              ),
            ],
          ),
          Container(
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
            ),
          ),
        ],
      ),
    );
  }
}
