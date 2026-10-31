import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../data/dpp_models.dart';
import '../data/dpp_process_models.dart';
import '../providers/dpp_provider.dart';
import '../main.dart' show kDesktopBreakpoint;
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/common.dart';

/// "Planet" tab — single responsive screen. A [LayoutBuilder] switches
/// between a 2-column mobile metric grid and a wider 4-column desktop
/// grid — one file, one widget, reflows live on resize.
///
/// Content comes from the REAL [DppProvider.processDetail] now, aggregated
/// across every manufacturing process by [_ImpactContent.from] — see that
/// class for exactly which real fields are summed into each metric.
class ImpactScreen extends StatelessWidget {
  const ImpactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final impact = _ImpactContent.from(
      context.watch<DppProvider>().processDetail,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= kDesktopBreakpoint;
        return isDesktop ? _buildDesktop(impact) : _buildMobile(impact);
      },
    );
  }

  Widget _buildMobile(_ImpactContent impact) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(22.w, 24.h, 22.w, 36.h),
      child: Column(
        // .stretch: SectionCard below has no explicit width of its own,
        // so .start would shrink-wrap it instead of filling the
        // available width.
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _MetricGrid(metrics: impact.metrics),
          SectionCard(
            title: '☀️ Where our energy came from',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _RenewableProgressBar(percent: impact.renewableSharePercent),
                SizedBox(height: 9.h),
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
        ],
      ),
    );
  }

  Widget _buildDesktop(_ImpactContent impact) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom: 45.h),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 1110.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _MetricGridDesktop(metrics: impact.metrics),
            SectionCard(
              desktop: true,
              title: '☀️ Where our energy came from',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 18.h,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30.r),
                      child: Container(
                        color: AppColors.progressTrack,
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: (impact.renewableSharePercent / 100)
                              .clamp(0.0, 1.0),
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
          ],
        ),
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
      mainAxisSpacing: 12.h,
      crossAxisSpacing: 12.w,
      childAspectRatio: 0.92,
      children: List.generate(metrics.length, (i) {
        final m = metrics[i];
        return Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: _bgColors[i % _bgColors.length],
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(23.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(m.icon, style: TextStyle(fontSize: 24.sp)),
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
  final double percent;
  const _RenewableProgressBar({required this.percent});

  @override
  Widget build(BuildContext context) {
    // A real 0% should still show a thin sliver rather than vanish
    // entirely, matching the original design's always-visible fill.
    final widthFactor = (percent / 100).clamp(0.0, 1.0);
    return ClipRRect(
      borderRadius: BorderRadius.circular(30.r),
      child: Container(
        height: 14.h,
        color: AppColors.progressTrack,
        child: FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: widthFactor < 0.03 ? 0.03 : widthFactor,
          child: Container(color: AppColors.progressFill),
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
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(25.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(m.icon, style: TextStyle(fontSize: 29.sp)),
              RichText(
                text: TextSpan(
                  style: AppTextStyles.display(
                    size: 32,
                    weight: FontWeight.w600,
                    letterSpacing: -0.8,
                  ),
                  children: [
                    TextSpan(text: '${m.value} '),
                    TextSpan(
                      text: m.unit,
                      style: AppTextStyles.body(
                        size: 12,
                        weight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                m.what,
                style: AppTextStyles.body(
                  size: 13,
                  color: AppColors.metricWhat,
                  height: 1.35,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

/// Translates the REAL [DppProcessDetailModel] into the Planet tab's 4-metric
/// grid + renewable-share progress bar, by summing across every
/// manufacturing process. Kept local to this screen; the data layer stays
/// opinion-free.
///
/// Field mapping:
///  - Water metric    ← sum of every process's `water_details.water_quantity`.
///  - Waste metric     ← sum of every process's `waste_details.waste_generated`.
///  - Energy metric    ← sum of every process's `energy_details.measured_consumption`.
///  - Emissions metric ← sum of `calculated_emission` across every detail
///    list (waste/water/energy/transportation/material/production) in
///    every process — the only field every single detail type shares.
///  - Renewable share  ← share of total energy `measured_consumption` whose
///    `energy_details.renewable_energy` is "Yes".
class _ImpactContent {
  final List<MetricItem> metrics;
  final double renewableSharePercent;
  final double nonRenewableSharePercent;

  const _ImpactContent({
    required this.metrics,
    required this.renewableSharePercent,
    required this.nonRenewableSharePercent,
  });

  factory _ImpactContent.from(DppProcessDetailModel? pd) {
    if (pd == null) {
      return const _ImpactContent(
        metrics: [],
        renewableSharePercent: 0,
        nonRenewableSharePercent: 0,
      );
    }

    double totalWater = 0;
    double totalWaste = 0;
    double totalEnergy = 0;
    double totalEmission = 0;
    double renewableEnergy = 0;
    String waterUnit = 'L';
    String wasteUnit = 'kg';
    String energyUnit = 'kWh';

    for (final p in pd.processes) {
      for (final w in p.waterDetails) {
        totalWater += w.waterQuantity;
        totalEmission += w.calculatedEmission;
        if (w.waterQuantityUnit.isNotEmpty) waterUnit = w.waterQuantityUnit;
      }
      for (final w in p.wasteDetails) {
        totalWaste += w.wasteGenerated;
        totalEmission += w.calculatedEmission;
        if (w.wasteGeneratedUnit.isNotEmpty) wasteUnit = w.wasteGeneratedUnit;
      }
      for (final e in p.energyDetails) {
        totalEnergy += e.measuredConsumption;
        totalEmission += e.calculatedEmission;
        if (e.energyUnit.isNotEmpty) energyUnit = e.energyUnit;
        if (e.renewableEnergy.toLowerCase() == 'yes') {
          renewableEnergy += e.measuredConsumption;
        }
      }
      for (final t in p.transportationDetails) {
        totalEmission += t.calculatedEmission;
      }
      for (final m in p.materialDetails) {
        totalEmission += m.calculatedEmission;
      }
      for (final prod in p.productionDetails) {
        totalEmission += prod.calculatedEmission;
      }
    }

    final renewablePct = totalEnergy > 0
        ? double.parse(
            ((renewableEnergy / totalEnergy) * 100).toStringAsFixed(1),
          )
        : 0.0;
    final nonRenewablePct = totalEnergy > 0
        ? double.parse((100 - renewablePct).toStringAsFixed(1))
        : 0.0;

    final metrics = <MetricItem>[
      MetricItem(
        icon: '💧',
        value: _fmt(totalWater),
        unit: waterUnit,
        what: 'Water used across production',
      ),
      MetricItem(
        icon: '🗑️',
        value: _fmt(totalWaste),
        unit: wasteUnit,
        what: 'Waste generated across production',
      ),
      MetricItem(
        icon: '⚡',
        value: _fmt(totalEnergy),
        unit: energyUnit,
        what: 'Energy consumed across production',
      ),
      MetricItem(
        icon: '🌫️',
        value: _fmt(totalEmission),
        unit: 'kgCO₂e',
        what: 'Total emissions reported',
      ),
    ];

    return _ImpactContent(
      metrics: metrics,
      renewableSharePercent: renewablePct,
      nonRenewableSharePercent: nonRenewablePct,
    );
  }

  static String _fmt(double v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);
}
