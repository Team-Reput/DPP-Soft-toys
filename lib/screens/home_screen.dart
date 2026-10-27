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
          if (content.homeCardText.isNotEmpty ||
              content.productImage.isNotEmpty)
            _HomeCard(content: content),
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
            if (content.homeCardText.isNotEmpty ||
                content.productImage.isNotEmpty)
              _HomeCardDesktop(content: content),
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
/// [TinyRow]/[LinkRow]/[StoryBoxContent], all from `dpp_models.dart`). Kept
/// local to this screen — the data layer (`dpp_process_models.dart`) stays
/// free of any UI-shape opinions; this is purely a view-model.
///
/// Field mapping (confirmed with product owner 2026-10-26):
///  - `passportFacts`  ← `product_details`: product/style name, category,
///    country of origin, SKU, age grading.
///  - `productImage`   ← `product_details.product_image` — a real product
///    photo, shown when the batch's record actually has one.
///  - `madeOf`         ← every process's `material_details`: the only key
///    common to every entry is `material_category`; paired with
///    `material_subtype_composition` when a given entry also has it.
///  - `homeCardText`   ← generated sentence from batch facility + batch no.
///    + production window (no real marketing-copy equivalent exists).
class _HomeContent {
  final String homeCardText;
  final String productImage;
  final List<DetailRow> madeOf;
  final List<DetailRow> passportFacts;

  const _HomeContent({
    required this.homeCardText,
    required this.productImage,
    required this.madeOf,
    required this.passportFacts,
  });

  factory _HomeContent.from(DppProcessDetailModel? pd) {
    if (pd == null) {
      return const _HomeContent(
        homeCardText: '',
        productImage: '',
        madeOf: [],
        passportFacts: [],
      );
    }

    final batch = pd.batch;
    final product = pd.productDetails;

    final passportFacts = <DetailRow>[
      if (product.productNameStyle.isNotEmpty ||
          batch.productNameStyle.isNotEmpty)
        DetailRow(
          'Product',
          product.productNameStyle.isNotEmpty
              ? product.productNameStyle
              : batch.productNameStyle,
        ),
      if (product.productCategoryType.isNotEmpty)
        DetailRow('Category', product.productCategoryType),
      if (product.countryOfOrigin.isNotEmpty)
        DetailRow('Country of origin', product.countryOfOrigin),
      if (product.styleCodeSku.isNotEmpty)
        DetailRow('SKU', product.styleCodeSku),
      if (product.ageGradingWarnings.isNotEmpty)
        DetailRow('Age grading', product.ageGradingWarnings),
    ];

    // Every material_details entry, across every process, that has at
    // least a category or a subtype — the only two keys that happen to be
    // shared by more than one process's (otherwise heterogeneous) entries.
    final madeOf = <DetailRow>[];
    for (final p in pd.processes) {
      for (final m in p.materialDetails) {
        final category = m.str('material_category');
        final subtype = m.str('material_subtype_composition');
        if (category.isEmpty && subtype.isEmpty) continue;
        madeOf.add(
          DetailRow(
            category.isEmpty ? 'Material' : category,
            subtype.isEmpty ? '—' : subtype,
          ),
        );
      }
    }

    // The real product_description field, when the batch has one, is
    // literal API text — preferred over the generated batch-facts sentence
    // below, which only exists as a fallback when there's no real copy.
    final homeCardText = product.productDescription.isNotEmpty
        ? product.productDescription
        : (batch.manufacturingFacility.isEmpty && batch.batchNo.isEmpty
              ? ''
              : 'Crafted at '
                    '${batch.manufacturingFacility.isEmpty ? "our partner facility" : batch.manufacturingFacility}'
                    ', Batch ${batch.batchNo.isEmpty ? "—" : batch.batchNo} was '
                    'produced '
                    '${batch.manufacturingPeriodStart.isEmpty ? "" : batch.manufacturingPeriodStart}'
                    ' – '
                    '${batch.manufacturingPeriodEnd.isEmpty ? "" : batch.manufacturingPeriodEnd}.');

    return _HomeContent(
      homeCardText: homeCardText,
      productImage: product.productImage,
      madeOf: madeOf,
      passportFacts: passportFacts,
    );
  }
}

class _HomeCard extends StatelessWidget {
  final _HomeContent content;
  const _HomeCard({required this.content});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.paper,
        border: Border.all(color: const Color(0xFFF2E8D9)),
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0x17694E30),
            blurRadius: 35,
            offset: Offset(0, 12.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (content.productImage.isNotEmpty) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(16.r),
              child: Image.network(
                content.productImage,
                height: 180.h,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
            SizedBox(height: 14.h),
          ],
          if (content.homeCardText.isNotEmpty)
            Text(
              content.homeCardText,
              style: AppTextStyles.body(
                size: 12,
                color: AppColors.muted,
                height: 1.55,
              ),
            ),
        ],
      ),
    );
  }
}

class _HomeCardDesktop extends StatelessWidget {
  final _HomeContent content;
  const _HomeCardDesktop({required this.content});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 29.w, vertical: 27.h),
      decoration: BoxDecoration(
        color: AppColors.paper,
        border: Border.all(color: const Color(0xFFF2E8D9)),
        borderRadius: BorderRadius.circular(26.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0x17694E30),
            blurRadius: 42,
            offset: Offset(0, 16.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (content.productImage.isNotEmpty) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(18.r),
              child: Image.network(
                content.productImage,
                height: 260.h,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
            SizedBox(height: 16.h),
          ],
          if (content.homeCardText.isNotEmpty)
            Text(
              content.homeCardText,
              style: AppTextStyles.body(
                size: 13,
                color: AppColors.muted,
                height: 1.55,
              ),
            ),
        ],
      ),
    );
  }
}
