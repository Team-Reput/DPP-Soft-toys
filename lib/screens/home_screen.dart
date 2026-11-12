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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (content.hasHero) _HomeHero(content: content),
          if (content.madeOf.isNotEmpty) ...[
            const SectionTitle('What am I made of? 🧵'),
            _HomeDetailRows(rows: content.madeOf),
          ],
          if (content.passportFacts.isNotEmpty) ...[
            const SectionTitle('My little passport 📖'),
            _HomeDetailRows(rows: content.passportFacts),
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
              _HomeDetailRows(rows: content.madeOf, desktop: true),
            ],
            if (content.passportFacts.isNotEmpty) ...[
              SectionTitle('My little passport 📖', desktop: true),
              _HomeDetailRows(rows: content.passportFacts, desktop: true),
            ],
          ],
        ),
      ),
    );
  }
}

/// Same row/divider layout as the shared [DetailList] (also used by Care),
/// but with solid black label/value text, 3pt larger than `DetailList`'s
/// own sizes (12/14 → 15/17) — just the font change requested for this
/// screen, with no extra container/shadow this time. Kept local rather
/// than touching `DetailList` itself, since Care uses that widget's plain
/// look unchanged.
class _HomeDetailRows extends StatelessWidget {
  final List<DetailRow> rows;
  final bool desktop;
  const _HomeDetailRows({required this.rows, this.desktop = false});

  @override
  Widget build(BuildContext context) {
    final fontSize = (desktop ? 17 : 15).sp;
    return Column(
      children: List.generate(rows.length, (i) {
        final row = rows[i];
        if (row.label.isEmpty && row.value.isEmpty) {
          return const SizedBox.shrink();
        }
        final isLast = i == rows.length - 1;
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: (desktop ? 19 : 15).w,
            vertical: (desktop ? 17 : 13).h,
          ),
          decoration: BoxDecoration(
            border: isLast
                ? null
                : const Border(
                    bottom: BorderSide(
                      color: AppColors.border,
                      width: 1,
                      style: BorderStyle.solid,
                    ),
                  ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  row.label,
                  style: TextStyle(fontSize: fontSize, color: Colors.black),
                ),
              ),
              SizedBox(width: 18.w),
              Flexible(
                child: Text(
                  row.value,
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w700,
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

class _HomeContent {
  final String productImage;
  final String heroEyebrow;
  final String heroTitleMain;
  final String heroTitleAccent;
  final String brandName;
  final String heroStyleCode;
  final String heroComposition;
  final List<DetailRow> madeOf;
  final List<DetailRow> passportFacts;

  const _HomeContent({
    required this.productImage,
    required this.heroEyebrow,
    required this.heroTitleMain,
    required this.heroTitleAccent,
    required this.brandName,
    required this.heroStyleCode,
    required this.heroComposition,
    required this.madeOf,
    required this.passportFacts,
  });

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
      brandName = '',
      heroStyleCode = '',
      heroComposition = '',
      madeOf = const [],
      passportFacts = const [];

  factory _HomeContent.from(DppProcessDetailModel? pd) {
    if (pd == null) return const _HomeContent.empty();

    final batch = pd.batch;
    final product = pd.productDetails;
    final brand = pd.brandDetails;

    final sizeValue = product.toySizeDimensions > 0
        ? '${product.toySizeDimensions == product.toySizeDimensions.roundToDouble() ? product.toySizeDimensions.toInt() : product.toySizeDimensions}'
              '${product.toySizeUnit.isEmpty ? '' : ' ${product.toySizeUnit}'}'
        : '';

    final productName = product.productNameStyle.isNotEmpty
        ? product.productNameStyle
        : batch.productNameStyle;

    final passportFacts = <DetailRow>[
      if (product.storyCollection.isNotEmpty)
        DetailRow('Collection', product.storyCollection),
      if (product.productCategoryType.isNotEmpty)
        DetailRow('Category', product.productCategoryType),
      if (sizeValue.isNotEmpty) DetailRow('Size', sizeValue),
      if (product.countryOfOrigin.isNotEmpty)
        DetailRow('Country of origin', product.countryOfOrigin),
      if (product.manufacturedBy.isNotEmpty)
        DetailRow('Manufactured by', product.manufacturedBy),
    ];

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
      brandName: brand.brandName.isNotEmpty ? brand.brandName : brand.brandName,
      heroStyleCode: product.styleCodeSku,
      heroComposition: product.compositionList,
      madeOf: madeOf,
      passportFacts: passportFacts,
    );
  }
}

class _HomeHero extends StatelessWidget {
  final _HomeContent content;
  final bool desktop;
  const _HomeHero({required this.content, this.desktop = false});

  @override
  Widget build(BuildContext context) {
    final heroHeight = desktop ? 300.h : 230.h;
    final radius = desktop ? 26.r : 22.r;
    print('Brand name: ${content.brandName}');
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
                  if (content.brandName.isNotEmpty) ...[
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
                            'by ${content.brandName}',

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
