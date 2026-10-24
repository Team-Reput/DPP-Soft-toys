import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../data/dpp_models.dart';
import '../providers/dpp_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/common.dart';

/// "Journey" tab — mobile layout. Vertical timeline with a connecting
/// dashed line. Mirrors `#journey`/`.journey` in the source Mobile HTML.
/// Content comes from [DppProvider.journey].
class JourneyScreenMobile extends StatelessWidget {
  const JourneyScreenMobile({super.key});

  @override
  Widget build(BuildContext context) {
    final journey =
        context.watch<DppProvider>().journey ?? JourneyModel.fromJson(const {});

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(22.w, 24.h, 22.w, 36.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EyebrowHeading(
            eyebrow: '🗺️ FOLLOW THE THREAD',
            heading: "A pet toy's\nlittle journey.",
            intro: journey.intro,
          ),
          _JourneyList(stops: journey.stops),
        ],
      ),
    );
  }
}

class _JourneyList extends StatelessWidget {
  final List<JourneyStop> stops;
  const _JourneyList({required this.stops});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(stops.length, (i) {
        final stop = stops[i];
        final isLast = i == stops.length - 1;
        final isEven = i % 2 == 1; // nth-child(even) in 1-indexed CSS
        return _JourneyStopRow(stop: stop, isLast: isLast, isEven: isEven);
      }),
    );
  }
}

class _JourneyStopRow extends StatelessWidget {
  final JourneyStop stop;
  final bool isLast;
  final bool isEven;

  const _JourneyStopRow({
    required this.stop,
    required this.isLast,
    required this.isEven,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Padding(
        padding: EdgeInsets.only(bottom: 17.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 48.w,
                  height: 48.h,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isEven ? AppColors.bubbleOddBg : AppColors.bubbleEvenBg,
                    border: Border.all(
                      color: isEven ? AppColors.bubbleOddBorder : AppColors.bubbleEvenBorder,
                    ),
                    borderRadius: BorderRadius.circular(17.r),
                  ),
                  child: Text(stop.emoji, style: TextStyle(fontSize: 23.sp)),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 0,
                      margin: EdgeInsets.symmetric(vertical: 2.h),
                      decoration: const BoxDecoration(
                        border: Border(
                          left: BorderSide(
                            color: AppColors.journeyLine,
                            width: 2,
                            style: BorderStyle.solid,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(width: 13.w),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(top: 2.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(stop.title, style: AppTextStyles.stopTitle),
                    SizedBox(height: 3.h),
                    Text(stop.description, style: AppTextStyles.stopText),
                    SizedBox(height: 6.h),
                    Text(stop.place, style: AppTextStyles.placeText),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
