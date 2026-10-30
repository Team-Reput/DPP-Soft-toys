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

/// "Care" tab — single responsive screen. A [LayoutBuilder] switches
/// between a 2-column mobile care grid and a wider 4-column desktop grid
/// (with a bigger banner) — one file, one widget, reflows live on
/// resize.
///
/// Content comes from the REAL [DppProvider.processDetail] now: one care
/// tile per real `wash_care` instruction, and the retire-the-toy copy from
/// `end_of_life.disposal_instructions`. See [_CareContent.from].
class CareScreen extends StatelessWidget {
  const CareScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final care = _CareContent.from(context.watch<DppProvider>().processDetail);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= kDesktopBreakpoint;
        return isDesktop ? _buildDesktop(care) : _buildMobile(care);
      },
    );
  }

  Widget _buildMobile(_CareContent care) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(22.w, 24.h, 22.w, 36.h),
      child: Column(
        // .stretch: SectionCard below has no explicit width of its own,
        // so .start would shrink-wrap it instead of filling the
        // available width (same bug as the Home hero).
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _CareGrid(items: care.items),
          if (care.retireText.isNotEmpty)
            SectionCard(
              title: 'When to retire the toy',
              child: Text(
                care.retireText,
                style: AppTextStyles.sectionCardText,
              ),
            ),
          if (care.takeBack.isNotEmpty ||
              care.takeBackLink != LinkRow.empty) ...[
            const SectionTitle('Take-back & goodbye ♻️'),
            if (care.takeBack.isNotEmpty) DetailList(care.takeBack),
            if (care.takeBackLink != LinkRow.empty)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                child: LinkDetailRow(care.takeBackLink, tiny: false),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildDesktop(_CareContent care) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom: 45.h),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 1110.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CareGridDesktop(items: care.items),
            if (care.retireText.isNotEmpty)
              SectionCard(
                desktop: true,
                maxWidth: 850.w,
                title: 'When to retire the toy',
                child: Text(care.retireText),
              ),
            if (care.takeBack.isNotEmpty ||
                care.takeBackLink != LinkRow.empty) ...[
              SectionTitle('Take-back & goodbye ♻️', desktop: true),
              if (care.takeBack.isNotEmpty)
                DetailList(care.takeBack, desktop: true),
              if (care.takeBackLink != LinkRow.empty)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  child: LinkDetailRow(care.takeBackLink, tiny: false),
                ),
            ],
          ],
        ),
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
            ],
          ),
        );
      }),
    );
  }
}

class _CareGridDesktop extends StatelessWidget {
  final List<CareItem> items;
  const _CareGridDesktop({required this.items});

  static const List<Color> _bgColors = [
    AppColors.care1Bg,
    AppColors.care2Bg,
    AppColors.care3Bg,
    AppColors.care4Bg,
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16.h,
      crossAxisSpacing: 16.w,
      childAspectRatio: 0.9,
      children: List.generate(items.length, (i) {
        final item = items[i];
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 25.h),
          decoration: BoxDecoration(
            color: _bgColors[i % _bgColors.length],
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(22.r),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(item.emoji, style: TextStyle(fontSize: 45.sp)),
              SizedBox(height: 10.h),
              Text(
                item.title,
                style: AppTextStyles.display(size: 20, weight: FontWeight.w600),
              ),
            ],
          ),
        );
      }),
    );
  }
}

/// Translates the REAL [DppProcessDetailModel] into the Care tab's grid +
/// "when to retire" card. Kept local to this screen; the data layer stays
/// opinion-free.
///
/// Field mapping:
///  - `items` ← one tile per real `wash_care[].instruction` (e.g. "Hand
///    wash", "Surface clean"). The emoji is guessed from keywords in the
///    instruction text (no icon field exists on the real record).
///  - `retireText` ← `end_of_life.disposal_instructions`; the "When to
///    retire the toy" card is only shown when the batch actually has one.
///  - `takeBack`/`takeBackLink` ← literal label/value rows (and a link)
///    built straight from `end_of_life.takeback_program_status`,
///    `can_be_donated_or_reused`, `material_separation_instructions`,
///    `packaging_recycling_instructions`, `takeback_description_url` —
///    each one only appears when that field is actually present on the
///    batch.
class _CareContent {
  final List<CareItem> items;
  final String retireText;
  final List<DetailRow> takeBack;
  final LinkRow takeBackLink;

  const _CareContent({
    required this.items,
    required this.retireText,
    required this.takeBack,
    required this.takeBackLink,
  });

  factory _CareContent.from(DppProcessDetailModel? pd) {
    if (pd == null) {
      return const _CareContent(
        items: [],
        retireText: '',
        takeBack: [],
        takeBackLink: LinkRow.empty,
      );
    }

    final items = pd.washCare
        .where((w) => w.instruction.isNotEmpty)
        .map(
          (w) => CareItem(
            emoji: _emojiFor(w.instruction),
            title: w.instruction,
            description: '',
          ),
        )
        .toList();

    final eol = pd.endOfLife;
    final takeBack = <DetailRow>[
      if (eol.takebackProgramStatus.isNotEmpty)
        DetailRow('Take-back program', eol.takebackProgramStatus),
      if (eol.canBeDonatedOrReused.isNotEmpty)
        DetailRow('Can be donated or reused', eol.canBeDonatedOrReused),
      if (eol.materialSeparationInstructions.isNotEmpty)
        DetailRow('Material separation', eol.materialSeparationInstructions),
      if (eol.packagingRecyclingInstructions.isNotEmpty)
        DetailRow('Packaging recycling', eol.packagingRecyclingInstructions),
    ];
    final takeBackLink = eol.takebackDescriptionUrl.isEmpty
        ? LinkRow.empty
        : LinkRow(
            'Take-back details',
            'View online',
            eol.takebackDescriptionUrl,
          );

    return _CareContent(
      items: items,
      retireText: eol.disposalInstructions,
      takeBack: takeBack,
      takeBackLink: takeBackLink,
    );
  }

  static String _emojiFor(String instruction) {
    final s = instruction.toLowerCase();
    if (s.contains('hand wash')) return '🧼';
    if (s.contains('machine wash')) return '🧺';
    if (s.contains('surface clean') || s.contains('spot clean')) return '🧽';
    if (s.contains('dry clean')) return '🏬';
    if (s.contains('bleach')) return '🚫';
    if (s.contains('iron')) return '🔥';
    if (s.contains('tumble') || s.contains('dry')) return '🌬️';
    return '🧵';
  }
}
