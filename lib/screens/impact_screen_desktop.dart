import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../data/dpp_models.dart';
import '../providers/dpp_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/common.dart';

/// "Planet" tab — desktop layout. 4-column metric grid, bigger cards.
/// Mirrors the desktop `#impact`/`.metric-grid` override in the source
/// Desktop HTML. Content comes from [DppProvider.impact].
class ImpactScreenDesktop extends StatelessWidget {
  const ImpactScreenDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    final impact =
        context.watch<DppProvider>().impact ?? ImpactModel.fromJson(const {});

    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom: 45.h),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 1110.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const EyebrowHeading(
              eyebrow: '🍃 A LIGHTER LITTLE FOOTPRINT',
              heading: 'Our planet\nmatters, too.',
              intro:
                  'Every pet toy has a story about the resources used to make '
                  'it. Here are the figures reported for this one.',
              desktop: true,
            ),
            _MetricGridDesktop(metrics: impact.metrics),
            NoteBox(
              desktop: true,
              label: 'For grown-ups:',
              text:
                  'These are source-sheet estimates, not independently '
                  'verified figures. Some source calculations conflict; use '
                  'them as indicative values until reconciled.',
            ),
            SectionCard(
              desktop: true,
              title: '☀️ Where our energy came from',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Renewable sources such as solar and wind are listed in '
                    'the manufacturing records, alongside other energy '
                    'sources.',
                  ),
                  SizedBox(height: 12.h),
                  SizedBox(
                    height: 18.h,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30.r),
                      child: Container(
                        color: AppColors.progressTrack,
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: 0.03,
                          child: Container(color: AppColors.progressFill),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 9.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '🌱 Renewable ${impact.renewableSharePercent}%',
                        style: AppTextStyles.body(size: 11, color: AppColors.progressLabel),
                      ),
                      Text(
                        'Other ${impact.nonRenewableSharePercent}%',
                        style: AppTextStyles.body(size: 11, color: AppColors.progressLabel),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SectionCard(
              desktop: true,
              title: '♻️ What about scraps?',
              child: const Text(
                'Fabric offcuts and sewing waste are recorded during '
                'production. The supplied total waste-per-piece figure is '
                'inconsistent with the stage records, so we have not '
                'displayed it as a reliable footprint.',
              ),
            ),
            DisclaimerText(impact.disclaimer, desktop: true),
          ],
        ),
      ),
    );
  }
}

class _MetricGridDesktop extends StatelessWidget {
  final List<MetricItem> metrics;
  const _MetricGridDesktop({required this.metrics});

  static const List<Color> _bgColors = [
    AppColors.metric1Bg,
    AppColors.metric2Bg,
    AppColors.metric3Bg,
    AppColors.metric4Bg,
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16.h,
      crossAxisSpacing: 16.w,
      childAspectRatio: 1.05,
      children: List.generate(metrics.length, (i) {
        final m = metrics[i];
        return Container(
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: _bgColors[i % _bgColors.length],
            border: Border.all(color: const Color(0xFFEEE2D1)),
            borderRadius: BorderRadius.circular(25.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(m.icon, style: TextStyle(fontSize: 29.sp)),
              RichText(
                text: TextSpan(
                  style: AppTextStyles.display(size: 32, weight: FontWeight.w600, letterSpacing: -0.8),
                  children: [
                    TextSpan(text: '${m.value} '),
                    TextSpan(
                      text: m.unit,
                      style: AppTextStyles.body(size: 12, weight: FontWeight.w700, color: AppColors.ink),
                    ),
                  ],
                ),
              ),
              Text(
                m.what,
                style: AppTextStyles.body(size: 13, color: AppColors.metricWhat, height: 1.35),
              ),
            ],
          ),
        );
      }),
    );
  }
}
