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
                // Everything else — the per-energy-source breakdown,
                // waste, and the production-detail grid — stays behind one
                // accordion so the card reads at a glance by default.
                if (stop.energyRows.isNotEmpty ||
                    stop.wasteRows.isNotEmpty ||
                    stop.productionRows.isNotEmpty) ...[
                  SizedBox(height: 10.h),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

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
      child: TinyRowsList(rows),
    );
  }
}

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

String _fmtDynamic(dynamic v) {
  if (v is num) return _fmtNum(v.toDouble());
  if (v is String) {
    final trimmed = v.trim();
    final asNum = double.tryParse(trimmed);
    return asNum != null ? _fmtNum(asNum) : trimmed;
  }
  return v?.toString() ?? '';
}

/// Hand-picked, friendlier English for production-detail keys the generic
/// humanizer would otherwise read awkwardly. Keyed by the field name with
/// any "po" word-segment already stripped.
const Map<String, String> _kProductionLabelOverrides = {
  'thread_issued': 'Thread issued',
  'material_composition': 'Material composition',
  'pieces_embroidered': 'Pieces embroidered',
  'monthly_thread_consumption': 'Monthly thread consumption',
  'thread_emissions_per_piece': 'Thread emissions per piece',
  'thread_consumption_per_piece': 'Thread consumption per piece',
  'stitch_type': 'Stitch type',
  'process_involved': 'Process involved',
  'cut_panels_input': 'Cut panels input',
  'thread_consumption': 'Thread consumed',
  'total_sewn_shells_issued': 'Shells sewn',
  'toys_stuffed': 'Toys stuffed',
  'filling_material': 'Filling material',
  'filling_fiber_used': 'Filling fiber used',
  'outer_fabric_gsm': 'Outer fabric weight (GSM)',
  'filling_per_piece': 'Filling per piece',
  'finished_toy_weight': 'Finished toy weight',
  'pieces_assembled': 'Pieces assembled',
  'outer_fabric_used_per_piece': 'Outer fabric used per piece',
  'outer_fabric_filling_composition': 'Outer fabric composition',
  'rejection_rate': 'Rejection rate',
  'units_passed': 'Units passed',
  'units_rejected': 'Units rejected',
  'units_reworked': 'Units reworked',
  'units_inspected': 'Units inspected',
  'number_of_packages': 'Packages produced',
  'packaging_material': 'Packaging material',
  'consumption_per_piece': 'Packaging per piece',
  'monthly_packaging_volume': 'Monthly packaging volume',
  'finished_product_packed': 'Units packed',
  'quantity_of_packaging_per': 'Packaging weight used',
};

/// Drops any "po" word-segment from a `snake_case` key — e.g.
/// `thread_issued_po` → `thread_issued` — used only to pick a nicer label;
/// the field's real value is never touched.
String _stripPoKey(String key) =>
    key.split('_').where((p) => p.toLowerCase() != 'po').join('_');

String _humanizeKey(String key) {
  final parts = key.split('_').where((p) => p.toLowerCase() != 'po').toList();
  if (parts.isEmpty) return '';
  final label = parts.join(' ');
  return label[0].toUpperCase() + label.substring(1);
}

/// Every real, non-empty field in one `production_details` entry — `id`
/// and `calculated_emission` excluded (shown separately, via the stage
/// emission total) — as label/value rows, "po" stripped from labels only.
List<TinyRow> _productionRows(ProcessFieldSet pd) {
  final raw = pd.raw;
  final keys = raw.keys.where((k) => k != 'id' && k != 'calculated_emission');
  final unitKeys = keys.where((k) => k.endsWith('_unit')).toSet();
  final baseKeys = keys.where((k) => !unitKeys.contains(k));
  final rows = <TinyRow>[];
  for (final bk in baseKeys) {
    final val = raw[bk];
    if (val == null || val.toString().trim().isEmpty) continue;
    final unitKey = '${bk}_unit';
    var unit = raw.containsKey(unitKey) ? (raw[unitKey]?.toString() ?? '') : '';
    if (bk == 'rejection_rate' && unit.isEmpty) unit = '%';
    final baseNoPo = _stripPoKey(bk);
    final label =
        _kProductionLabelOverrides[baseNoPo] ??
        _kProductionLabelOverrides[bk] ??
        _humanizeKey(bk);
    if (label.isEmpty) continue;
    final value = '${_fmtDynamic(val)}${unit.isEmpty ? '' : ' $unit'}';
    rows.add(TinyRow(label, value));
  }
  return rows;
}

List<TinyRow> _waterRows(ProcessModel p) => [
  for (final w in p.waterDetails)
    if (w.waterQuantity > 0)
      TinyRow(
        w.waterSource.isEmpty ? 'Water used' : w.waterSource,
        '${_fmtNum(w.waterQuantity)}${w.waterQuantityUnit.isEmpty ? '' : ' ${w.waterQuantityUnit}'}',
      ),
];

List<TinyRow> _wasteRows(ProcessModel p) => [
  for (final w in p.wasteDetails)
    if (w.wasteGenerated > 0)
      TinyRow(
        w.wasteType.isEmpty ? 'Waste generated' : w.wasteType,
        '${_fmtNum(w.wasteGenerated)}${w.wasteGeneratedUnit.isEmpty ? '' : ' ${w.wasteGeneratedUnit}'}',
      ),
];

/// Every energy source this stage reports, each with its measured
/// consumption AND its own emission — "Add all the emission and show".
List<TinyRow> _energyRows(ProcessModel p) => [
  for (final e in p.energyDetails)
    if (e.measuredConsumption > 0 || e.calculatedEmission > 0)
      TinyRow(
        e.energySource.isEmpty ? 'Energy used' : e.energySource,
        [
          if (e.measuredConsumption > 0)
            '${_fmtNum(e.measuredConsumption)}${e.energyUnit.isEmpty ? '' : ' ${e.energyUnit}'}',
          if (e.calculatedEmission > 0)
            '${_fmtNum(e.calculatedEmission)} kgCO₂e',
        ].join(' · '),
      ),
];

double _stageWaterTotal(ProcessModel p) =>
    p.waterDetails.fold(0.0, (s, w) => s + w.waterQuantity);
String _stageWaterUnit(ProcessModel p) =>
    p.waterDetails.isNotEmpty ? p.waterDetails.first.waterQuantityUnit : '';

double _stageWasteTotal(ProcessModel p) =>
    p.wasteDetails.fold(0.0, (s, w) => s + w.wasteGenerated);
String _stageWasteUnit(ProcessModel p) =>
    p.wasteDetails.isNotEmpty ? p.wasteDetails.first.wasteGeneratedUnit : '';

/// All of a stage's energy sources combined into ONE row — every source's
/// emission added together, and the sources themselves named in the
/// label (mixed units like kWh + L can't be summed into one quantity, so
/// the value carries the combined emission instead). The full per-source
/// breakdown still lives in `_energyRows`, just moved behind the
/// accordion rather than repeated here.
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

/// The single always-visible box: transport (stage 1 only, in the sample
/// data), water, energy (already combined), and the stage's total
/// emissions — in that order, each row only appearing when this stage
/// actually has that figure.
List<TinyRow> _summaryRows(
  ProcessModel p, {
  required String transportMode,
  required String distanceLabel,
}) {
  final rows = <TinyRow>[];
  if (transportMode.isNotEmpty || distanceLabel.isNotEmpty) {
    rows.add(
      TinyRow(
        'Transport',
        [transportMode, distanceLabel].where((s) => s.isNotEmpty).join(' · '),
      ),
    );
  }
  final waterTotal = _stageWaterTotal(p);
  if (waterTotal > 0) {
    final unit = _stageWaterUnit(p);
    rows.add(
      TinyRow('Water', '${_fmtNum(waterTotal)}${unit.isEmpty ? '' : ' $unit'}'),
    );
  }
  final energyRow = _energyCombinedRow(p);
  if (energyRow != null) rows.add(energyRow);
  final emissionTotal = _stageEmissionTotal(p);
  if (emissionTotal > 0) {
    rows.add(TinyRow('Emissions', '${_fmtNum(emissionTotal)} kgCO₂e'));
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

      // Transport mode/distance feed into the summary box's "Transport"
      // row (see `_summaryRows` below); destination is shown separately,
      // as the "📍 location" line under the process name. Both come from
      // this process's own transportation record — any missing piece is
      // just left out.
      final distanceStr = (t != null && t.distanceTravelled > 0)
          ? '${t.distanceTravelled.toStringAsFixed(t.distanceTravelled % 1 == 0 ? 0 : 1)} ${t.distanceUnit.isEmpty ? 'km' : t.distanceUnit}'
          : '';

      final productionDetails = process.productionDetails;
      final transportModeVal = t?.transportMode ?? '';

      stops.add(
        JourneyStop(
          emoji: stage.emoji,
          title: process.processName,
          description: '',
          place: place,
          index: i,
          subtitle: subtitle,
          // originLabel: pd.batch.manufacturingFacility,
          destinationLabel: t?.destinationTo ?? '',
          transportMode: transportModeVal,
          distanceLabel: distanceStr,
          summaryRows: _summaryRows(
            process,
            transportMode: transportModeVal,
            distanceLabel: distanceStr,
          ),
          waterRows: _waterRows(process),
          wasteRows: _wasteRows(process),
          energyRows: _energyRows(process),
          productionRows: productionDetails.isNotEmpty
              ? _productionRows(productionDetails.first)
              : const [],
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
