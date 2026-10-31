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

/// "Journey" tab — single responsive screen. A [LayoutBuilder] switches
/// between a single-column mobile stack and a wider desktop 2-column
/// layout of the same numbered white/teal cards — one file, one widget,
/// reflows live on resize.
///
/// Content comes from the REAL [DppProvider.processDetail] now: each stop
/// is one of the batch's actual manufacturing processes, in a fixed
/// canonical order, with its "place" built from that process's real
/// transportation record. See [_JourneyContent.from].
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
      children: [
        for (var i = 0; i < stops.length; i++) ...[
          _JourneyCard(stop: stops[i]),
          if (i != stops.length - 1) SizedBox(height: 16.h),
        ],
      ],
    );
  }
}

class _JourneyGridDesktop extends StatelessWidget {
  final List<JourneyStop> stops;
  const _JourneyGridDesktop({required this.stops});

  @override
  Widget build(BuildContext context) {
    // A `Wrap` of explicitly-sized cards, not `GridView.count` — each
    // card's height depends on how many chips it has, and a fixed
    // `childAspectRatio` risks overflowing exactly like the shell's
    // earlier RenderFlex bugs. `Wrap` lets each card size to its own
    // content instead.
    return LayoutBuilder(
      builder: (context, constraints) {
        final gap = 20.w;
        final cardWidth = (constraints.maxWidth - gap) / 2;
        return Wrap(
          spacing: gap,
          runSpacing: 20.h,
          children: stops
              .map(
                (stop) => SizedBox(
                  width: cardWidth,
                  child: _JourneyCard(stop: stop, desktop: true),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

/// One journey stop, rendered the same way on mobile and desktop: a white
/// rounded card with a teal numbered badge, the process name, the first
/// material it uses, and an icon-led route row (🏭 facility → mode/distance
/// → 🏁 destination) — all real data, nothing decorative. (The old
/// count-based chip row — "1 material"/"1 transport"/"1 cert" — was
/// dropped: raw counts with no detail behind them weren't meaningful.)
class _JourneyCard extends StatelessWidget {
  final JourneyStop stop;
  final bool desktop;
  const _JourneyCard({required this.stop, this.desktop = false});

  @override
  Widget build(BuildContext context) {
    final badgeSize = (desktop ? 48 : 42).w;
    return Container(
      padding: EdgeInsets.all((desktop ? 24 : 18).w),
      decoration: BoxDecoration(
        color: AppColors.journeyCardBg,
        border: Border.all(color: AppColors.journeyCardBorder),
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0x0D1F2937),
            blurRadius: 24,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: badgeSize,
            height: badgeSize,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.journeyBadgeBg,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Text(
              stop.index.toString().padLeft(2, '0'),
              style: AppTextStyles.body(
                size: desktop ? 16 : 14,
                weight: FontWeight.w800,
                color: AppColors.journeyBadgeText,
              ),
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stop.title,
                  style: AppTextStyles.display(
                    size: desktop ? 23 : 19,
                    weight: FontWeight.w700,
                  ),
                ),
                if (stop.subtitle.isNotEmpty) ...[
                  SizedBox(height: 4.h),
                  Text(
                    stop.subtitle,
                    style: AppTextStyles.display(
                      size: desktop ? 16 : 14,
                      weight: FontWeight.w600,
                      color: AppColors.journeySubtitle,
                    ),
                  ),
                ],
                if (stop.originLabel.isNotEmpty ||
                    stop.destinationLabel.isNotEmpty) ...[
                  SizedBox(height: 10.h),
                  _RouteRow(stop: stop, desktop: desktop),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Icon-led "route" strip — origin node, a mode/distance pill in the
/// middle, and a destination node — in place of a one-line sentence.
/// Any piece missing from the real data (no facility, no transport record,
/// no distance) is simply left out rather than shown blank.
class _RouteRow extends StatelessWidget {
  final JourneyStop stop;
  final bool desktop;
  const _RouteRow({required this.stop, required this.desktop});

  static String _modeIcon(String mode) {
    switch (mode.toLowerCase()) {
      case 'road':
        return '🚚';
      case 'sea':
      case 'ship':
      case 'ocean':
        return '🚢';
      case 'air':
        return '✈️';
      case 'rail':
      case 'train':
        return '🚆';
      default:
        return '📦';
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasBoth =
        stop.originLabel.isNotEmpty && stop.destinationLabel.isNotEmpty;
    final labelStyle = AppTextStyles.body(
      size: desktop ? 12 : 11,
      weight: FontWeight.w700,
      color: AppColors.journeyLocationText,
    );

    Widget node(String icon, String label) => Flexible(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: TextStyle(fontSize: (desktop ? 13 : 12).sp)),
          SizedBox(width: 4.w),
          Flexible(
            child: Text(
              label,
              style: labelStyle,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 6.w,
      runSpacing: 6.h,
      children: [
        if (stop.originLabel.isNotEmpty) node('🏭', stop.originLabel),
        if (hasBoth)
          Text(
            '→',
            style: TextStyle(
              fontSize: (desktop ? 13 : 12).sp,
              color: AppColors.journeyPin,
              fontWeight: FontWeight.w700,
            ),
          ),
        if (stop.transportMode.isNotEmpty || stop.distanceLabel.isNotEmpty)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 5.h),
            decoration: BoxDecoration(
              color: AppColors.journeyChipBg,
              border: Border.all(color: AppColors.journeyChipBorder),
              borderRadius: BorderRadius.circular(100.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _modeIcon(stop.transportMode),
                  style: TextStyle(fontSize: (desktop ? 12 : 11).sp),
                ),
                SizedBox(width: 4.w),
                Text(
                  [
                    stop.transportMode,
                    stop.distanceLabel,
                  ].where((s) => s.isNotEmpty).join(' · '),
                  style: AppTextStyles.body(
                    size: desktop ? 11 : 10,
                    weight: FontWeight.w700,
                    color: AppColors.journeyChipText,
                  ),
                ),
              ],
            ),
          ),
        if (hasBoth)
          Text(
            '→',
            style: TextStyle(
              fontSize: (desktop ? 13 : 12).sp,
              color: AppColors.journeyPin,
              fontWeight: FontWeight.w700,
            ),
          ),
        if (stop.destinationLabel.isNotEmpty) node('🏁', stop.destinationLabel),
      ],
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
    var i = 0;
    for (final stage in _stages) {
      final process = pd.processByName(stage.processName);
      if (process == null) continue;
      i++;

      final t = process.transportationDetails.isNotEmpty
          ? process.transportationDetails.first
          : null;
      final place = t == null
          ? ''
          : '${t.originFrom} → ${t.destinationTo}'
                '${t.transportMode.isEmpty ? '' : ' · ${t.transportMode}'}';

      // Subtitle: the first material entry with a category/subtype — same
      // aggregation the Home tab's "What am I made of?" uses.
      var subtitle = '';
      for (final m in process.materialDetails) {
        final category = m.str('material_category');
        final subtype = m.str('material_subtype_composition');
        if (category.isNotEmpty || subtype.isNotEmpty) {
          subtitle = category.isNotEmpty ? category : subtype;
          break;
        }
      }

      // Route row pieces — rendered as an icon-led "origin → mode/distance
      // → destination" strip instead of a sentence (see `_RouteRow` below).
      // Origin is the batch's real `manufacturing_facility`; destination,
      // mode and distance come from this process's own transportation
      // record. Any missing piece is just left out of the row.
      final distanceStr = (t != null && t.distanceTravelled > 0)
          ? '${t.distanceTravelled.toStringAsFixed(t.distanceTravelled % 1 == 0 ? 0 : 1)} ${t.distanceUnit.isEmpty ? 'km' : t.distanceUnit}'
          : '';

      stops.add(
        JourneyStop(
          emoji: stage.emoji,
          title: process.processName,
          description: '',
          place: place,
          index: i,
          subtitle: subtitle,
          originLabel: pd.batch.manufacturingFacility,
          destinationLabel: t?.destinationTo ?? '',
          transportMode: t?.transportMode ?? '',
          distanceLabel: distanceStr,
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
