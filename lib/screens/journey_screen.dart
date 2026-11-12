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
                stop.title.isEmpty
                    ? const SizedBox.shrink()
                    : Text(
                        stop.title,
                        style: AppTextStyles.display(
                          size: desktop ? 23 : 19,
                          weight: FontWeight.w700,
                        ),
                      ),
                // Location, right under the process name — the batch's
                // manufacturing facility was dropped, so this is whichever
                // destination this stage's own transportation record
                // reports (only the first stage has one in the sample
                // data; later stages just omit the line).
                if (stop.destinationLabel.isNotEmpty) ...[
                  SizedBox(height: 3.h),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '📍',
                        style: TextStyle(fontSize: (desktop ? 13 : 12).sp),
                      ),
                      SizedBox(width: 4.w),
                      Flexible(
                        child: Text(
                          stop.destinationLabel,
                          style: AppTextStyles.body(
                            size: desktop ? 13 : 12,
                            weight: FontWeight.w600,
                            color: AppColors.journeyLocationText,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
                // Transport mode(s) this stage's leg(s) actually report —
                // e.g. "Sea, Road" for a stage with more than one leg —
                // shown right under the location line, not inside the
                // stat box below.
                if (stop.transportMode.isNotEmpty) ...[
                  SizedBox(height: 3.h),
                  Text(
                    'By ${stop.transportMode}',
                    style: AppTextStyles.body(
                      size: desktop ? 13 : 12,
                      weight: FontWeight.w600,
                      color: AppColors.journeyLocationText,
                    ),
                  ),
                ],
                if (stop.subtitle.isNotEmpty) ...[
                  SizedBox(height: 3.h),
                  Text(
                    stop.subtitle,
                    style: AppTextStyles.display(
                      size: desktop ? 16 : 14,
                      weight: FontWeight.w600,
                      color: AppColors.journeySubtitle,
                    ),
                  ),
                ],
                // One plain box holding every stat this stage has —
                // transport, water, energy (already combined into a
                // single line) and total emissions — as label/value rows,
                // not separate floating tags.
                if (stop.summaryRows.isNotEmpty) ...[
                  SizedBox(height: 12.h),
                  _JourneySummaryBox(rows: stop.summaryRows, desktop: desktop),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The always-visible stat box — transport / water / energy / emissions —
/// rendered as plain label/value rows inside one bordered surface, not as
/// separate pills or chips.
class _JourneySummaryBox extends StatelessWidget {
  final List<TinyRow> rows;
  final bool desktop;
  const _JourneySummaryBox({required this.rows, required this.desktop});

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: (desktop ? 16 : 14).w,
        vertical: (desktop ? 6 : 4).h,
      ),
      decoration: BoxDecoration(
        color: AppColors.noteBg,
        border: Border.all(color: AppColors.noteBorder),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: _JourneyStatRows(rows),
    );
  }
}

/// A Journey-screen-only variant of the shared [TinyRowsList] — same
/// row/divider layout, but solid black label & value text, 3pt larger
/// than the shared `tinyRowLabel`/`tinyRowValue` styles (11 → 14), as
/// requested for this screen specifically. Deliberately local rather
/// than changing `TinyRowsList`/`AppTextStyles.tinyRowLabel`/
/// `tinyRowValue` themselves, since those are shared with the Brand
/// screen's certificate rows, which this request doesn't touch.
class _JourneyStatRows extends StatelessWidget {
  final List<TinyRow> rows;
  const _JourneyStatRows(this.rows);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(rows.length, (i) {
        final row = rows[i];
        if (row.label.isEmpty && row.value.isEmpty) {
          return const SizedBox.shrink();
        }
        final isLast = i == rows.length - 1;
        return Container(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          decoration: BoxDecoration(
            border: isLast
                ? null
                : const Border(
                    bottom: BorderSide(
                      color: AppColors.tinyRowBorder,
                      width: 1,
                    ),
                  ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  row.label,
                  style: AppTextStyles.body(size: 14, color: Colors.black),
                ),
              ),
              SizedBox(width: 10.w),
              Flexible(
                child: Text(
                  row.value,
                  style: AppTextStyles.body(
                    size: 14,
                    weight: FontWeight.w700,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

/// "Show details" accordion — the per-energy-source breakdown, waste, and
/// the production-detail grid, each its own labelled block, only inside
// ════════════════════════════════════════════════════════════════════════
// Per-process data helpers — water/waste/energy pulled straight off the
// process's own API lists, production-detail rows with the "PO" wording
// stripped from LABELS only (values are untouched), and a stage emission
// total summed across every detail list that carries a real
// `calculated_emission`. Mirrors the HTML prototype's `production_rows()` /
// `stage_emission_total()` so the Flutter and HTML copies agree.
// ════════════════════════════════════════════════════════════════════════

/// Thousands-grouped number formatting (no extra package): "950000" → "950,000";
/// "0.016" stays "0.016" (small emission figures keep up to 3 decimals
/// instead of being rounded away); whole numbers drop the decimal point.
String _fmtNum(double v) {
  final isInt = v == v.roundToDouble();
  var fixed = isInt ? v.toInt().toString() : v.toStringAsFixed(3);
  if (!isInt && fixed.contains('.')) {
    fixed = fixed.replaceFirst(RegExp(r'0+$'), '');
    fixed = fixed.replaceFirst(RegExp(r'\.$'), '');
  }
  final parts = fixed.split('.');
  final neg = parts[0].startsWith('-');
  final digits = neg ? parts[0].substring(1) : parts[0];
  final buf = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i != 0 && (digits.length - i) % 3 == 0) buf.write(',');
    buf.write(digits[i]);
  }
  final grouped = '${neg ? '-' : ''}$buf';
  return parts.length > 1 ? '$grouped.${parts[1]}' : grouped;
}

double _stageWaterTotal(ProcessModel p) =>
    p.waterDetails.fold(0.0, (s, w) => s + w.waterQuantity);
String _stageWaterUnit(ProcessModel p) =>
    p.waterDetails.isNotEmpty ? p.waterDetails.first.waterQuantityUnit : '';

double _stageWasteTotal(ProcessModel p) =>
    p.wasteDetails.fold(0.0, (s, w) => s + w.wasteGenerated);
String _stageWasteUnit(ProcessModel p) =>
    p.wasteDetails.isNotEmpty ? p.wasteDetails.first.wasteGeneratedUnit : '';

/// A stage's waste, combined into ONE summary row — same idea as
/// [_energyCombinedRow]. Shown whenever the stage has ANY real waste
/// record (a type, a quantity, or an emission — never requiring all
/// three, since a real record like Packaging's "Plastic" waste can carry
/// only a type + emission with no quantity). The value prefers the
/// summed quantity when there is one, falling back to the combined
/// emission, so the row is never blank when there's real data to show —
/// and this returns null (no row at all) only when the stage truly has
/// no waste records, matching the SizedBox.shrink() convention used
/// everywhere else on this screen.
TinyRow? _wasteCombinedRow(ProcessModel p) {
  if (p.wasteDetails.isEmpty) return null;
  final hasType = p.wasteDetails.any((w) => w.wasteType.isNotEmpty);
  final quantityTotal = _stageWasteTotal(p);
  final emissionTotal = p.wasteDetails.fold(
    0.0,
    (s, w) => s + w.calculatedEmission,
  );
  if (!hasType && quantityTotal <= 0 && emissionTotal <= 0) return null;
  // Always labelled plainly "Waste" — e.g. a Packaging-stage record typed
  // "Plastic" is still shown under "Waste", not its raw type name.
  final unit = _stageWasteUnit(p);
  final value = quantityTotal > 0
      ? '${_fmtNum(quantityTotal)}${unit.isEmpty ? '' : ' $unit'}'
      : (emissionTotal > 0 ? '${_fmtNum(emissionTotal)} kgCO₂e' : '—');
  return TinyRow('Waste', value);
}

/// Every transportation leg this stage reports, combined into one
/// "Transport Emission" row — every leg's `calculated_emission` summed
/// together (e.g. the Raw Material stage's Sea + Road legs). The modes
/// themselves (Sea, Road, ...) are shown separately, just under the
/// stage's location line, not repeated here.
TinyRow? _transportEmissionRow(ProcessModel p) {
  if (p.transportationDetails.isEmpty) return null;
  final total = p.transportationDetails.fold(
    0.0,
    (s, t) => s + t.calculatedEmission,
  );
  if (total <= 0) return null;
  return TinyRow('Transport Emission', '${_fmtNum(total)} kgCO₂e');
}

/// All of a stage's energy sources combined into ONE row — every source's
/// emission added together, and the sources themselves named in the
/// label (mixed units like kWh + L can't be summed into one quantity, so
/// the value carries the combined emission instead).
TinyRow? _energyCombinedRow(ProcessModel p) {
  if (p.energyDetails.isEmpty) return null;
  final sources = <String>{
    for (final e in p.energyDetails)
      if (e.energySource.isNotEmpty) e.energySource,
  };
  final combinedEmission = p.energyDetails.fold(
    0.0,
    (s, e) => s + e.calculatedEmission,
  );
  if (sources.isEmpty && combinedEmission <= 0) return null;
  final label = sources.isEmpty ? 'Energy' : sources.join(' + ');
  final value = combinedEmission > 0
      ? '${_fmtNum(combinedEmission)} kgCO₂e'
      : '—';
  return TinyRow(label, value);
}

/// The single always-visible box, in this fixed order: energy (combined),
/// water, waste (combined), then the stage's total emissions — each row
/// only appearing when this stage actually has that figure (e.g. no waste
/// record at all → [_wasteCombinedRow] returns null → no row, rather than
/// a blank/broken line).
List<TinyRow> _summaryRows(ProcessModel p) {
  final rows = <TinyRow>[];
  final energyRow = _energyCombinedRow(p);
  if (energyRow != null) rows.add(energyRow);
  final waterTotal = _stageWaterTotal(p);
  if (waterTotal > 0) {
    final unit = _stageWaterUnit(p);
    rows.add(
      TinyRow(
        'Water Consumption',
        '${_fmtNum(waterTotal)}${unit.isEmpty ? '' : ' $unit'}',
      ),
    );
  }
  final transportRow = _transportEmissionRow(p);
  if (transportRow != null) rows.add(transportRow);
  final wasteRow = _wasteCombinedRow(p);
  if (wasteRow != null) rows.add(wasteRow);
  final emissionTotal = _stageEmissionTotal(p);
  if (emissionTotal > 0) {
    rows.add(TinyRow('Carbon Emission', '${_fmtNum(emissionTotal)} kgCO₂e'));
  }
  return rows;
}

/// Every `calculated_emission` this stage reports, across water, waste,
/// energy, material, transport and production details — the one figure
/// that rolls all of a stage's emissions into a single pill.
double _stageEmissionTotal(ProcessModel p) {
  var total = 0.0;
  for (final w in p.waterDetails) total += w.calculatedEmission;
  for (final w in p.wasteDetails) total += w.calculatedEmission;
  for (final e in p.energyDetails) total += e.calculatedEmission;
  for (final m in p.materialDetails) total += m.calculatedEmission;
  for (final t in p.transportationDetails) total += t.calculatedEmission;
  for (final pd in p.productionDetails) total += pd.calculatedEmission;
  return total;
}

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

      // A stage can report more than one transportation leg (e.g. an
      // overseas leg into the country, then a domestic leg to the
      // facility) — every leg is kept, not just the first. `place` and
      // the header's "📍 location" line use the LAST leg's destination:
      // wherever the shipment actually ends up after every hop.
      final legs = process.transportationDetails;
      final lastLeg = legs.isNotEmpty ? legs.last : null;
      final firstLeg = legs.isNotEmpty ? legs.first : null;
      final place = firstLeg == null
          ? ''
          : legs
                .map(
                  (t) =>
                      '${t.originFrom} → ${t.destinationTo}'
                      '${t.transportMode.isEmpty ? '' : ' · ${t.transportMode}'}',
                )
                .join('; ');

      // Every distinct mode this stage's leg(s) use (e.g. "Sea, Road" for
      // a stage with an overseas + a domestic leg) — shown under the
      // location line, separately from the combined emission figure in
      // the stat box.
      final modes = <String>{
        for (final t in legs)
          if (t.transportMode.isNotEmpty) t.transportMode,
      };
      final modesLabel = modes.join(', ');

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

      stops.add(
        JourneyStop(
          emoji: stage.emoji,
          title: process.processName,
          description: '',
          place: place,
          index: i,
          subtitle: subtitle,
          // originLabel: pd.batch.manufacturingFacility,
          destinationLabel: lastLeg?.destinationTo ?? '',
          transportMode: modesLabel,
          summaryRows: _summaryRows(process),
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
