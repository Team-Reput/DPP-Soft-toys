import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../data/dpp_models.dart';
import '../providers/dpp_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/common.dart';

/// "Care" tab — mobile layout. 2-column care grid. Mirrors `#care` in the
/// source Mobile HTML. Content comes from [DppProvider.care].
class CareScreenMobile extends StatelessWidget {
  const CareScreenMobile({super.key});

  @override
  Widget build(BuildContext context) {
    final care = context.watch<DppProvider>().care ?? CareModel.fromJson(const {});

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(22.w, 24.h, 22.w, 36.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const EyebrowHeading(
            eyebrow: '💗 CUTE CARE FOR PAWS',
            heading: 'Keep the\ntail wags coming!',
            intro:
                'A little care helps keep this forest friend ready for more '
                'playtime, carrying, and cuddles.',
          ),
          _CareGrid(items: care.items),
          const SectionTitle('A happy little habit'),
          const _CareBanner(),
          SizedBox(height: 14.h),
          SectionCard(
            title: 'When to retire the toy',
            child: Text(care.retireText, style: AppTextStyles.sectionCardText),
          ),
        ],
      ),
    );
  }
}

class _CareGrid extends StatelessWidget {
  final List<CareItem> items;
  const _CareGrid({required this.items});

  static const List<Color> _bgColors = [
    AppColors.care1Bg,
    AppColors.care2Bg,
    AppColors.care3Bg,
    AppColors.care4Bg,
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12.h,
      crossAxisSpacing: 12.w,
      childAspectRatio: 0.98,
      children: List.generate(items.length, (i) {
        final item = items[i];
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 18.h),
          decoration: BoxDecoration(
            color: _bgColors[i % _bgColors.length],
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(22.r),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(item.emoji, style: TextStyle(fontSize: 38.sp)),
              SizedBox(height: 10.h),
              Text(item.title, style: AppTextStyles.careTitle),
              SizedBox(height: 5.h),
              Text(
                item.description,
                textAlign: TextAlign.center,
                style: AppTextStyles.careText,
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _CareBanner extends StatelessWidget {
  const _CareBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(19.w),
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
                Text('Care for longer, play for longer.', style: AppTextStyles.careBannerTitle),
                SizedBox(height: 5.h),
                Text(
                  'Look after the toy and enjoy more happy moments together.',
                  style: AppTextStyles.careBannerText,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
