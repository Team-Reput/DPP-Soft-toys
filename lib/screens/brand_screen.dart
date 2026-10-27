import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../data/dpp_models.dart';
import '../data/dpp_process_models.dart';
import '../providers/dpp_provider.dart';
import '../main.dart' show kDesktopBreakpoint;
import '../widgets/common.dart';

/// "Brand" tab — single responsive screen. A [LayoutBuilder] switches
/// between the mobile flow and a wider desktop flow (sections capped at
/// 850.w) — one file, one widget, reflows live on resize.
///
/// Content comes from the REAL [DppProvider.processDetail] now —
/// `brand_details`, `product_details`, and every certification found
/// across its processes. See [_BrandContent.from]. (The passport-link row
/// and the take-back/goodbye and supporting-documents sections that used
/// to live here have been removed/moved — take-back & goodbye now lives
/// on the Care tab, and the other two were dropped outright.)
class BrandScreen extends StatelessWidget {
  const BrandScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final brand = _BrandContent.from(
      context.watch<DppProvider>().processDetail,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= kDesktopBreakpoint;
        return isDesktop ? _buildDesktop(brand) : _buildMobile(brand);
      },
    );
  }

  Widget _buildMobile(_BrandContent brand) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(22.w, 24.h, 22.w, 36.h),
      child: Column(
        // .stretch: SectionCard below has no explicit width of its own,
        // so .start would shrink-wrap it instead of filling the
        // available width (same bug as the Home hero).
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (brand.story != StoryBoxContent.empty)
            StoryBox.fromContent(brand.story),
          if (brand.behindTheBrand.isNotEmpty) ...[
            const SectionTitle('Behind the brand ✿'),
            DetailList(brand.behindTheBrand),
          ],
          if (brand.certChips.isNotEmpty) ...[
            const SectionTitle('Certificates & records 📜'),
            SectionCard(
              margin: EdgeInsets.zero,
              child: ChipsRow(brand.certChips),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDesktop(_BrandContent brand) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom: 45.h),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 1110.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (brand.story != StoryBoxContent.empty)
              StoryBox.fromContent(brand.story, desktop: true),
            if (brand.behindTheBrand.isNotEmpty) ...[
              SectionTitle('Behind the brand ✿', desktop: true),
              DetailList(brand.behindTheBrand, desktop: true),
            ],
            if (brand.certChips.isNotEmpty) ...[
              SectionTitle('Certificates & records 📜', desktop: true),
              SectionCard(
                desktop: true,
                maxWidth: 850.w,
                margin: EdgeInsets.zero,
                child: ChipsRow(brand.certChips),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Translates the REAL [DppProcessDetailModel] into the Brand tab's shapes.
/// Kept local to this screen; the data layer stays opinion-free.
///
/// Field mapping:
///  - `story`                → generated from `brand_details` (name,
///    status, brand code) — no real narrative field exists.
///  - `behindTheBrand`       → `brand_details.brand_name` plus
///    `product_details.manufactured_by`/`country_of_origin`/
///    `story_collection`, each row only shown when the batch has it.
///  - `certChips`            → every distinct certification `standard`
///    found anywhere across the batch's processes (same dedup logic as the
///    Home tab's chips); the card is hidden when there are none.
class _BrandContent {
  final StoryBoxContent story;
  final List<DetailRow> behindTheBrand;
  final List<ChipItem> certChips;

  const _BrandContent({
    required this.story,
    required this.behindTheBrand,
    required this.certChips,
  });

  factory _BrandContent.from(DppProcessDetailModel? pd) {
    if (pd == null) {
      return const _BrandContent(
        story: StoryBoxContent.empty,
        behindTheBrand: [],
        certChips: [],
      );
    }

    final bd = pd.brandDetails;
    final product = pd.productDetails;

    final story = bd.brandName.isEmpty
        ? StoryBoxContent.empty
        : StoryBoxContent(
            emoji: '🐾',
            title: bd.brandName,
            text:
                '${bd.brandName} is a '
                '${bd.status.isEmpty ? "registered" : bd.status.toLowerCase()} '
                'brand on the Reput DPP network'
                '${bd.brandCode.isEmpty ? '' : ' (brand code ${bd.brandCode})'}.',
          );

    final behindTheBrand = <DetailRow>[
      if (bd.brandName.isNotEmpty) DetailRow('Brand', bd.brandName),
      if (product.manufacturedBy.isNotEmpty)
        DetailRow('Manufactured by', product.manufacturedBy),
      if (product.countryOfOrigin.isNotEmpty)
        DetailRow('Country of origin', product.countryOfOrigin),
      if (product.storyCollection.isNotEmpty)
        DetailRow('Collection', product.storyCollection),
    ];

    // Every distinct certification standard across the batch's processes
    // (same aggregation as the Home tab's chips).
    final seen = <String>{};
    final certChips = <ChipItem>[];
    for (final p in pd.processes) {
      for (final c in p.certifications) {
        if (c.standard.isEmpty || !seen.add(c.standard)) continue;
        certChips.add(ChipItem('✓', c.standard));
      }
    }

    return _BrandContent(
      story: story,
      behindTheBrand: behindTheBrand,
      certChips: certChips,
    );
  }
}
