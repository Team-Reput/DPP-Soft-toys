import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../data/dpp_models.dart';
import '../providers/dpp_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/common.dart';

/// "Care" tab — desktop layout. 4-column care grid, bigger cards & banner.
/// Mirrors the desktop `.care-list`/`.care-banner` override in the source
/// Desktop HTML. Content comes from [DppProvider.care].
class CareScreenDesktop extends StatelessWidget {
  const CareScreenDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    final care = context.watch<DppProvider>().care ?? CareModel.fromJson(const {});

    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom: 45.h),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 1110.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const EyebrowHeading(
              eyebrow: '💗 CUTE CARE FOR PAWS',
              heading: 'Keep the\ntail wags coming!',
              intro:
                  'A little care helps keep this forest friend ready for more '
                  'playtime, carrying, and cuddles.',
              desktop: true,
            ),
            _CareGridDesktop(items: care.items),
            SectionTitle('A happy little habit', desktop: true),
            _CareBannerDesktop(),
            SizedBox(height: 14.h),
            SectionCard(
              desktop: true,
              maxWidth: 850.w,
              title: 'When to retire the toy',
              child: Text(care.retireText),
            ),
          ],
        ),
      ),
    );
  }
}

class _CareGridDesktop extends StatelessWidget {
  final List<CareItem> items;
  const _CareGridDesktop({required this.items});

  static const List<Color> _bgColors = [
    AppColors.care1Bg,
    AppColors.care2Bg,
    AppColors.care3Bg,
    AppColors.care4Bg,
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16.h,
      crossAxisSpacing: 16.w,
      childAspectRatio: 0.9,
      children: List.generate(items.length, (i) {
        final item = items[i];
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 25.h),
          decoration: BoxDecoration(
            color: _bgColors[i % _bgColors.length],
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(22.r),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(item.emoji, style: TextStyle(fontSize: 45.sp)),
              SizedBox(height: 10.h),
              Text(item.title, style: AppTextStyles.display(size: 20, weight: FontWeight.w600)),
              SizedBox(height: 5.h),
              Text(
                item.description,
                textAlign: TextAlign.center,
                style: AppTextStyles.body(size: 13, color: AppColors.careText, height: 1.45),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _CareBannerDesktop extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: 850.w),
      padding: EdgeInsets.all(26.w),
      decoration: BoxDecoration(
        color: AppColors.careBannerBg,
        borderRadius: BorderRadius.circular(23.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text('🌷', style: TextStyle(fontSize: 35.sp)),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Care for longer, play for longer.',
                  style: AppTextStyles.display(size: 22, weight: FontWeight.w600),
                ),
                SizedBox(height: 5.h),
                Text(
                  'Look after the toy and enjoy more happy moments together.',
                  style: AppTextStyles.body(size: 14, color: AppColors.careBannerText, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
