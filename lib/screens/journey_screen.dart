import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../data/dpp_models.dart';
import '../data/dpp_process_models.dart';
import '../providers/dpp_provider.dart';
import '../main.dart' show kDesktopBreakpoint;
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class JourneyScreen extends StatelessWidget {
  const JourneyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final journey = _JourneyContent.from(
      context.watch<DppProvider>().processDetail,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= kDesktopBreakpoint;
        return isDesktop ? _buildDesktop(journey) : _buildMobile(journey);
      },
    );
  }

  Widget _buildMobile(_JourneyContent journey) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(22.w, 24.h, 22.w, 36.h),
      child: Column(
        // .stretch for consistency with the other screens' mobile
        // layouts (see Home/Impact) — no direct child here currently
        // needs intrinsic width, so this is a safe default.
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [_JourneyList(stops: journey.stops)],
      ),
    );
  }

  Widget _buildDesktop(_JourneyContent journey) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom: 45.h),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 1110.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [_JourneyGridDesktop(stops: journey.stops)],
        ),
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
                    color: isEven
                        ? AppColors.bubbleOddBg
                        : AppColors.bubbleEvenBg,
                    border: Border.all(
                      color: isEven
                          ? AppColors.bubbleOddBorder
                          : AppColors.bubbleEvenBorder,
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
                      style: AppTextStyles.display(
                        size: 20,
                        weight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      stop.place,
                      style: AppTextStyles.body(
                        size: 12,
                        weight: FontWeight.w700,
                        color: AppColors.placeText,
                      ),
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

/// Translates the REAL [DppProcessDetailModel] into the Journey tab's
/// stop-by-stop timeline. Kept local to this screen; the data layer stays
/// opinion-free.
///
/// Field mapping:
///  - One stop per manufacturing process the batch's data actually has,
///    in the fixed canonical order below (a process missing from this
///    particular batch is simply skipped, not shown empty).
///  - `title`       ← the process's real `process_name`.
///  - `place`       ← that process's first `transportation_details` entry:
///    `origin_from → destination_to · transport_mode` — real data.
///  - `emoji`       ← a fixed small icon per stage, used the same way the
///    section-title emojis elsewhere are — a label, not marketing copy.
class _JourneyContent {
  final List<JourneyStop> stops;
  const _JourneyContent({required this.stops});

  static const List<_StageMeta> _stages = [
    _StageMeta('Raw Material Receipt and Storage', '🌾'),
    _StageMeta('Cutting', '✂️'),
    _StageMeta('Embroidery', '🧵'),
    _StageMeta('Sewing', '🪡'),
    _StageMeta('Filling and Stuffing', '🧸'),
    _StageMeta('Toy Assembly', '🧩'),
    _StageMeta('Quality Inspection', '🔍'),
    _StageMeta('Packaging', '📦'),
  ];

  factory _JourneyContent.from(DppProcessDetailModel? pd) {
    if (pd == null) {
      return const _JourneyContent(stops: []);
    }

    final stops = <JourneyStop>[];
    for (final stage in _stages) {
      final process = pd.processByName(stage.processName);
      if (process == null) continue;

      final t = process.transportationDetails.isNotEmpty
          ? process.transportationDetails.first
          : null;
      final place = t == null
          ? ''
          : '${t.originFrom} → ${t.destinationTo}'
                '${t.transportMode.isEmpty ? '' : ' · ${t.transportMode}'}';

      stops.add(
        JourneyStop(
          emoji: stage.emoji,
          title: process.processName,
          description: '',
          place: place,
        ),
      );
    }

    return _JourneyContent(stops: stops);
  }
}

class _StageMeta {
  final String processName;
  final String emoji;
  const _StageMeta(this.processName, this.emoji);
}
