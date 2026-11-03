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

/// "Toy" tab — single responsive screen. A [LayoutBuilder] picks the
/// mobile layout below [kDesktopBreakpoint] and the wider desktop layout
/// at or above it — so resizing the window (e.g. on web/desktop) re-lays
/// the same screen out live, with no separate mobile/desktop widget
/// classes.
///
/// Every section renders only real data: there is no decorative hero or
/// marketing copy here any more, only the batch/process/end-of-life
/// values pulled from the REAL [DppProvider.processDetail] by
/// [_HomeContent.from] — see that class for exactly which field backs
/// which section.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final content = _HomeContent.from(
      context.watch<DppProvider>().processDetail,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= kDesktopBreakpoint;
        return isDesktop ? _buildDesktop(content) : _buildMobile(content);
      },
    );
  }

  Widget _buildMobile(_HomeContent content) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(22.w, 24.h, 22.w, 36.h),
      child: Column(
        // .stretch: _HomeCard/DetailList/SectionCard/StoryBox below have
        // no explicit width of their own, so .start would shrink-wrap
        // them instead of filling the available width.
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (content.hasHero) _HomeHero(content: content),
          if (content.madeOf.isNotEmpty) ...[
            const SectionTitle('What am I made of? 🧵'),
            DetailList(content.madeOf),
          ],
          if (content.passportFacts.isNotEmpty) ...[
            const SectionTitle('My little passport 📖'),
            DetailList(content.passportFacts),
          ],
        ],
      ),
    );
  }

  Widget _buildDesktop(_HomeContent content) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom: 45.h),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 1110.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (content.hasHero) _HomeHero(content: content, desktop: true),
            if (content.madeOf.isNotEmpty) ...[
              SectionTitle('What am I made of? 🧵', desktop: true),
              DetailList(content.madeOf, desktop: true),
            ],
            if (content.passportFacts.isNotEmpty) ...[
              SectionTitle('My little passport 📖', desktop: true),
              DetailList(content.passportFacts, desktop: true),
            ],
          ],
        ),
      ),
    );
  }
}

/// Translates the REAL [DppProcessDetailModel] into the UI shapes the
/// widgets above already know how to render ([ChipItem]/[DetailRow]/
/// [TinyRow]/[LinkRow]/[StoryBoxContent], all from `dpp_models.dart`), plus
/// a small set of hero-only strings consumed directly by [_HomeHero]. Kept
/// local to this screen — the data layer (`dpp_process_models.dart`) stays
/// free of any UI-shape opinions; this is purely a view-model.
///
/// Field mapping (confirmed with product owner 2026-10-26):
///  - `passportFacts`  ← `product_details`: product/style name, story
///    collection, category, composition, size (dimensions + unit),
///    country of origin, manufactured by, SKU, age grading.
///  - `productImage`   ← `product_details.product_image` — a real product
///    photo, shown when the batch's record actually has one.
///  - `madeOf`         ← every process's `material_details`: the only key
///    common to every entry is `material_category`; paired with
///    `material_subtype_composition` when a given entry also has it.
///  - `heroEyebrow`    ← `product_category_type`, falling back to
///    `story_collection` — whichever short real tag the batch actually has.
///  - `heroTitleMain` / `heroTitleAccent` ← both derived from the SAME real
///    `product_description` field. When it literally ends with
///    `product_name_style` (e.g. description "Velvet Treater Cake" ending
///    in style "Cake"), that trailing real word/phrase is split off as
///    `heroTitleAccent` so it can be styled as the one highlighted word —
///    no text is invented, it's the same API string, just split in two.
///    When there's no such match, the whole description is `heroTitleMain`
///    and `heroTitleAccent` is empty (no highlight is forced).
///  - `heroByline`     ← `manufactured_by`.
///  - `heroStyleCode` / `heroComposition` ← `style_code_sku` /
///    `composition_list`, shown as two compact rows under the hero title.
class _HomeContent {
  final String productImage;
  final String heroEyebrow;
  final String heroTitleMain;
  final String heroTitleAccent;
  final String heroByline;
  final String heroStyleCode;
  final String heroComposition;
  final List<DetailRow> madeOf;
  final List<DetailRow> passportFacts;

  const _HomeContent({
    required this.productImage,
    required this.heroEyebrow,
    required this.heroTitleMain,
    required this.heroTitleAccent,
    required this.heroByline,
    required this.heroStyleCode,
    required this.heroComposition,
    required this.madeOf,
    required this.passportFacts,
  });

  /// True when there's enough real data for the hero to be worth showing
  /// at all (an image, or at least a title).
  bool get hasHero =>
      productImage.isNotEmpty ||
      heroTitleMain.isNotEmpty ||
      heroTitleAccent.isNotEmpty;

  const factory _HomeContent.empty() = _HomeContent._empty;

  const _HomeContent._empty()
    : productImage = '',
      heroEyebrow = '',
      heroTitleMain = '',
      heroTitleAccent = '',
      heroByline = '',
      heroStyleCode = '',
      heroComposition = '',
      madeOf = const [],
      passportFacts = const [];

  factory _HomeContent.from(DppProcessDetailModel? pd) {
    if (pd == null) return const _HomeContent.empty();

    final batch = pd.batch;
    final product = pd.productDetails;

    // Size: dimensions + unit are two separate API fields, combined into
    // one row only when the batch actually reports a dimension (a unit
    // with no number isn't a real size).
    final sizeValue = product.toySizeDimensions > 0
        ? '${product.toySizeDimensions == product.toySizeDimensions.roundToDouble() ? product.toySizeDimensions.toInt() : product.toySizeDimensions}'
              '${product.toySizeUnit.isEmpty ? '' : ' ${product.toySizeUnit}'}'
        : '';

    final productName = product.productNameStyle.isNotEmpty
        ? product.productNameStyle
        : batch.productNameStyle;

    final passportFacts = <DetailRow>[
      if (productName.isNotEmpty) DetailRow('Product', productName),
      if (product.storyCollection.isNotEmpty)
        DetailRow('Collection', product.storyCollection),
      if (product.productCategoryType.isNotEmpty)
        DetailRow('Category', product.productCategoryType),
      if (product.compositionList.isNotEmpty)
        DetailRow('Composition', product.compositionList),
      if (sizeValue.isNotEmpty) DetailRow('Size', sizeValue),
      if (product.countryOfOrigin.isNotEmpty)
        DetailRow('Country of origin', product.countryOfOrigin),
      if (product.manufacturedBy.isNotEmpty)
        DetailRow('Manufactured by', product.manufacturedBy),
      if (product.styleCodeSku.isNotEmpty)
        DetailRow('SKU', product.styleCodeSku),
      if (product.ageGradingWarnings.isNotEmpty)
        DetailRow('Age grading', product.ageGradingWarnings),
    ];

    // Every DISTINCT material_category across every process — the only
    // key that happens to be shared by more than one process's (otherwise
    // heterogeneous) entries. Several processes can legitimately report
    // the same category (e.g. "Outer fabric" at both receipt and
    // cutting); a `Map` keyed on the category collapses those into one
    // row instead of showing it twice, keeping whichever occurrence
    // actually has a subtype/composition rather than a later, emptier
    // repeat shadowing a real value.
    final madeOfByCategory = <String, String>{};
    for (final p in pd.processes) {
      for (final m in p.materialDetails) {
        final category = m.str('material_category');
        final subtype = m.str('material_subtype_composition');
        if (category.isEmpty && subtype.isEmpty) continue;
        final key = category.isEmpty ? 'Material' : category;
        if (!madeOfByCategory.containsKey(key) ||
            (madeOfByCategory[key]!.isEmpty && subtype.isNotEmpty)) {
          madeOfByCategory[key] = subtype;
        }
      }
    }
    // Several categories can legitimately end up with the exact same real
    // composition text (e.g. an "Outer fabric" receipt step and a later
    // "Filling fiber" step both reporting "Virgin polyester plush").
    // Showing the identical value twice is redundant, so when that
    // happens only the LAST category to report that value is kept — it's
    // usually the more specific/final process step — while a category
    // with no value (nothing to dedupe) is always kept.
    final lastCategoryForValue = <String, String>{};
    for (final entry in madeOfByCategory.entries) {
      if (entry.value.isNotEmpty) lastCategoryForValue[entry.value] = entry.key;
    }
    final madeOf = <DetailRow>[
      for (final entry in madeOfByCategory.entries)
        if (entry.value.isEmpty ||
            lastCategoryForValue[entry.value] == entry.key)
          DetailRow(entry.key, entry.value.isEmpty ? '—' : entry.value),
    ];

    // The real product_description field is the source of the hero title
    // below. It used to also be echoed as a separate body paragraph under
    // the title, but that just repeated the same product name a second
    // time, so it's no longer shown anywhere.
    final description = product.productDescription;

    // The hero title is the same real `product_description` string, with
    // its trailing `product_name_style` word/phrase (when it really is a
    // suffix of the description) split off so it can be rendered as the
    // one highlighted word — no text is invented, just re-split.
    var titleMain = description.isNotEmpty ? description : productName;
    var titleAccent = '';
    final style = product.productNameStyle;
    if (description.isNotEmpty &&
        style.isNotEmpty &&
        description.length > style.length &&
        description.toLowerCase().trim().endsWith(style.toLowerCase().trim())) {
      final splitAt = description.length - style.length;
      titleMain = description.substring(0, splitAt);
      titleAccent = description.substring(splitAt);
    }

    final heroEyebrow = product.productCategoryType.isNotEmpty
        ? product.productCategoryType
        : product.storyCollection;

    return _HomeContent(
      productImage: product.productImage,
      heroEyebrow: heroEyebrow,
      heroTitleMain: titleMain,
      heroTitleAccent: titleAccent,
      heroByline: product.manufacturedBy,
      heroStyleCode: product.styleCodeSku,
      heroComposition: product.compositionList,
      madeOf: madeOf,
      passportFacts: passportFacts,
    );
  }
}

/// The hero — a full-width teal image panel topped by an overlapping
/// white "bottom sheet" card (drag handle, eyebrow label, serif title
/// with one real highlighted word, byline, divider, a couple of compact
/// detail rows). One widget, two sizes — picked by the `desktop` flag —
/// rather than separate mobile/desktop classes, since only the
/// dimensions differ, not the structure.
class _HomeHero extends StatelessWidget {
  final _HomeContent content;
  final bool desktop;
  const _HomeHero({required this.content, this.desktop = false});

  @override
  Widget build(BuildContext context) {
    final heroHeight = desktop ? 300.h : 230.h;
    final radius = desktop ? 26.r : 22.r;

    // No more overlap/negative-offset trick for the sheet: the image
    // panel and the white sheet are just two plain, adjacent Column
    // children sharing one outer ClipRRect (so the whole card still reads
    // as one rounded unit, image on top, sheet below) — simple, and with
    // no risk of a mystery gap from a layout box that doesn't match what
    // was actually painted.
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.paper,
          boxShadow: [
            BoxShadow(
              color: const Color(0x14101F1C),
              blurRadius: desktop ? 42 : 35,
              offset: Offset(0, (desktop ? 16 : 12).h),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (content.productImage.isNotEmpty)
              Container(
                height: heroHeight,
                width: double.infinity,
                color: AppColors.forest,
                child: Padding(
                  padding: EdgeInsets.all(20.w),
                  child: Image.network(
                    content.productImage,
                    // .contain, not .cover/.fill — the real product photo
                    // shows whole and undistorted on the teal background
                    // instead of being cropped or stretched.
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),
                ),
              ),
            Container(
              padding: EdgeInsets.fromLTRB(
                (desktop ? 26 : 20).w,
                16.h,
                (desktop ? 26 : 20).w,
                (desktop ? 20 : 16).h,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (content.heroEyebrow.isNotEmpty) ...[
                    Text(
                      content.heroEyebrow.toUpperCase(),
                      style: AppTextStyles.eyebrow,
                    ),
                    SizedBox(height: 8.h),
                  ],
                  if (content.heroTitleMain.isNotEmpty ||
                      content.heroTitleAccent.isNotEmpty)
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: content.heroTitleMain,
                            style: AppTextStyles.serifDisplay(
                              size: desktop ? 40 : 32,
                            ),
                          ),
                          if (content.heroTitleAccent.isNotEmpty)
                            TextSpan(
                              text: content.heroTitleAccent,
                              style: AppTextStyles.serifDisplay(
                                size: desktop ? 40 : 32,
                                color: AppColors.forest,
                                italic: true,
                              ),
                            ),
                        ],
                      ),
                    ),
                  if (content.heroByline.isNotEmpty) ...[
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Container(
                          width: 4.w,
                          height: 4.w,
                          margin: EdgeInsets.only(right: 7.w),
                          decoration: const BoxDecoration(
                            color: AppColors.muted,
                            shape: BoxShape.circle,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'by ${content.heroByline}',
                            style: AppTextStyles.body(
                              size: 14,
                              weight: FontWeight.w600,
                              color: AppColors.muted,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (content.heroStyleCode.isNotEmpty ||
                      content.heroComposition.isNotEmpty) ...[
                    SizedBox(height: 14.h),
                    Divider(height: 1, color: AppColors.border),
                    SizedBox(height: 10.h),
                  ],
                  if (content.heroStyleCode.isNotEmpty)
                    _HeroDetailRow('Style code', content.heroStyleCode),
                  if (content.heroComposition.isNotEmpty)
                    _HeroDetailRow('Composition', content.heroComposition),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One compact "label value" row inside the hero sheet — a lighter-weight
/// sibling of `DetailList`'s rows, sized to sit comfortably under the
/// title instead of forming its own separate card.
class _HeroDetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _HeroDetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 96.w,
            child: Text(label, style: AppTextStyles.detailLabel),
          ),
          Expanded(child: Text(value, style: AppTextStyles.detailValue)),
        ],
      ),
    );
  }
}
