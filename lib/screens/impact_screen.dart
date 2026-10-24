import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/dpp_models.dart';
import '../providers/dpp_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/common.dart';

/// "Planet" tab — environmental footprint metrics.
/// Mirrors `#impact` section in the source HTML. Content comes from
/// [DppProvider.impact].
class ImpactScreen extends StatelessWidget {
  const ImpactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final impact =
        context.watch<DppProvider>().impact ?? ImpactModel.fromJson(const {});

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 36),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const EyebrowHeading(
            eyebrow: '🍃 A LIGHTER LITTLE FOOTPRINT',
            heading: 'Our planet\nmatters, too.',
            intro:
                'Every pet toy has a story about the resources used to make '
                'it. Here are the figures reported for this one.',
          ),
          _MetricGrid(metrics: impact.metrics),
          const NoteBox(
            label: 'For grown-ups:',
            text:
                'These are source-sheet estimates, not independently verified '
                'figures. Some source calculations conflict; use them as '
                'indicative values until reconciled.',
          ),
          SectionCard(
            title: '☀️ Where our energy came from',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Renewable sources such as solar and wind are listed in the '
                  'manufacturing records, alongside other energy sources.',
                  style: AppTextStyles.sectionCardText,
                ),
                const SizedBox(height: 12),
                const _RenewableProgressBar(),
                const SizedBox(height: 9),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '🌱 Renewable ${impact.renewableSharePercent}%',
                      style: AppTextStyles.body(
                        size: 11,
                        color: AppColors.progressLabel,
                      ),
                    ),
                    Text(
                      'Other ${impact.nonRenewableSharePercent}%',
                      style: AppTextStyles.body(
                        size: 11,
                        color: AppColors.progressLabel,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SectionCard(
            title: '♻️ What about scraps?',
            child: Text(
              'Fabric offcuts and sewing waste are recorded during production. '
              'The supplied total waste-per-piece figure is inconsistent with '
              'the stage records, so we have not displayed it as a reliable '
              'footprint.',
              style: AppTextStyles.sectionCardText,
            ),
          ),
          DisclaimerText(impact.disclaimer),
        ],
      ),
    );
  }
}

class _MetricGrid extends StatelessWidget {
  final List<MetricItem> metrics;
  const _MetricGrid({required this.metrics});

  static const List<Color> _bgColors = [
    AppColors.metric1Bg,
    AppColors.metric2Bg,
    AppColors.metric3Bg,
    AppColors.metric4Bg,
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 0.92,
      children: List.generate(metrics.length, (i) {
        final m = metrics[i];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _bgColors[i % _bgColors.length],
            border: Border.all(color: const Color(0xFFEEE2D1)),
            borderRadius: BorderRadius.circular(23),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(m.icon, style: const TextStyle(fontSize: 24)),
              RichText(
                text: TextSpan(
                  style: AppTextStyles.metricValue,
                  children: [
                    TextSpan(text: '${m.value} '),
                    TextSpan(text: m.unit, style: AppTextStyles.metricUnit),
                  ],
                ),
              ),
              Text(m.what, style: AppTextStyles.metricWhat),
            ],
          ),
        );
      }),
    );
  }
}

class _RenewableProgressBar extends StatelessWidget {
  const _RenewableProgressBar();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: Container(
        height: 14,
        color: AppColors.progressTrack,
        child: FractionallySizedBox(
          alignment: Alignment.centerLeft,
          // Reported renewable share is tiny (0.15%); keep a visible sliver.
          widthFactor: 0.03,
          child: Container(color: AppColors.progressFill),
        ),
      ),
    );
  }
}
