import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../data/dpp_models.dart';
import '../providers/dpp_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/common.dart';

/// "Journey" tab — desktop layout. A 2-column grid of standalone stop
/// cards (no connecting line). Mirrors the desktop `.journey`/`.stop`
/// override in the source Desktop HTML. Content comes from
/// [DppProvider.journey].
class JourneyScreenDesktop extends StatelessWidget {
  const JourneyScreenDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    final journey =
        context.watch<DppProvider>().journey ?? JourneyModel.fromJson(const {});

    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom: 45.h),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 1110.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            EyebrowHeading(
              eyebrow: '🗺️ FOLLOW THE THREAD',
              heading: "A pet toy's\nlittle journey.",
              intro: journey.intro,
              desktop: true,
            ),
            _JourneyGridDesktop(stops: journey.stops),
          ],
        ),
      ),
    );
  }
}

class _JourneyGridDesktop extends StatelessWidget {
  final List<JourneyStop> stops;
  const _JourneyGridDesktop({required this.stops});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 14.h,
      crossAxisSpacing: 25.w,
      childAspectRatio: 2.3,
      children: stops.map((stop) {
        return Container(
          padding: EdgeInsets.all(23.w),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFDF7),
            border: Border.all(color: const Color(0xFFE9DECF)),
            borderRadius: BorderRadius.circular(23.r),
            boxShadow: [
              BoxShadow(
                color: const Color(0x0D64563C),
                blurRadius: 18,
                offset: Offset(0, 5.h),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 53.w,
                height: 53.h,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.bubbleEvenBg,
                  border: Border.all(color: AppColors.bubbleEvenBorder),
                  borderRadius: BorderRadius.circular(17.r),
                ),
                child: Text(stop.emoji, style: TextStyle(fontSize: 25.sp)),
              ),
              SizedBox(width: 13.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      stop.title,
                      style: AppTextStyles.display(size: 20, weight: FontWeight.w600),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      stop.description,
                      style: AppTextStyles.body(size: 14, color: AppColors.stopText, height: 1.5),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      stop.place,
                      style: AppTextStyles.body(size: 12, weight: FontWeight.w700, color: AppColors.placeText),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
