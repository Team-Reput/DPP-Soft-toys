import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../data/dpp_models.dart';
import '../data/dpp_process_models.dart';
import '../providers/dpp_provider.dart';
import '../main.dart' show kDesktopBreakpoint;
import '../theme/app_colors.dart';
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
            _BehindTheBrandCard(rows: brand.behindTheBrand),
          ],
          if (brand.certifications.isNotEmpty) ...[
            const SectionTitle('Certificates & records 📜'),
            for (final cert in brand.certifications) ...[
              _CertCard(cert: cert),
              SizedBox(height: 10.h),
            ],
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
              _BehindTheBrandCard(rows: brand.behindTheBrand, desktop: true),
            ],
            if (brand.certifications.isNotEmpty) ...[
              SectionTitle('Certificates & records 📜', desktop: true),
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 850.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final cert in brand.certifications) ...[
                      _CertCard(cert: cert, desktop: true),
                      SizedBox(height: 12.h),
                    ],
                  ],
                ),
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
///  - `certifications`       → every distinct certification (by `standard`,
///    first occurrence wins) found anywhere across the batch's processes —
///    each one rendered as its own expandable card with whatever of
///    issuer/issue date/certificate ID/validity/document name the record
///    actually has, plus a "View certificate" link when a verification URL
///    or uploaded evidence URL is present. The section is hidden when
///    there are none.
class _BrandContent {
  final StoryBoxContent story;
  final List<DetailRow> behindTheBrand;
  final List<_CertEntry> certifications;

  const _BrandContent({
    required this.story,
    required this.behindTheBrand,
    required this.certifications,
  });

  factory _BrandContent.from(DppProcessDetailModel? pd) {
    if (pd == null) {
      return const _BrandContent(
        story: StoryBoxContent.empty,
        behindTheBrand: [],
        certifications: [],
      );
    }

    final bd = pd.brandDetails;
    final product = pd.productDetails;

    final story = bd.brandName.isEmpty
        ? StoryBoxContent.empty
        : StoryBoxContent(
            emoji: '',
            imageAsset: 'assets/brand_logo.jpg',
            title: bd.brandName,
            text:
                '',
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

    // Every distinct certification standard across the batch's processes —
    // the same standard can legitimately show up on more than one process
    // (e.g. verified at both receipt and finishing), so only the first
    // real record for a given standard is kept.
    final seen = <String>{};
    final certifications = <_CertEntry>[];
    for (final p in pd.processes) {
      for (final c in p.certifications) {
        if (c.standard.isEmpty || !seen.add(c.standard)) continue;
        certifications.add(
          _CertEntry(
            standard: c.standard,
            rows: [
              if (c.issuedBy.isNotEmpty) TinyRow('Issued by', c.issuedBy),
              if (c.issueDate.isNotEmpty) TinyRow('Issue date', c.issueDate),
              if (c.certificateId.isNotEmpty)
                TinyRow('Certificate ID', c.certificateId),
              if (c.validityExpiryDate.isNotEmpty)
                TinyRow('Valid until', c.validityExpiryDate),
              if (c.documentCertificateName.isNotEmpty)
                TinyRow('Document', c.documentCertificateName),
            ],
            // Prefer a real verification URL over the raw uploaded-evidence
            // file — both are real API fields, but verificationUrl is the
            // one meant for a human to open and check.
            link: c.verificationUrl.isNotEmpty
                ? LinkRow('Certificate', 'View certificate', c.verificationUrl)
                : c.uploadEvidence.isNotEmpty
                ? LinkRow('Certificate', 'View evidence', c.uploadEvidence)
                : LinkRow.empty,
          ),
        );
      }
    }

    return _BrandContent(
      story: story,
      behindTheBrand: behindTheBrand,
      certifications: certifications,
    );
  }
}

/// The "Behind the brand" section, lifted off the plain row-list look
/// (shared [DetailList], also used on Home/Care) into its own big,
/// shadowed card for this screen — black, 3pt-larger label/value text
/// (12/14 → 15/17) as requested. Deliberately a local widget rather than
/// changing the shared `DetailList` itself, since Home and Care use that
/// widget too and neither was asked for this styling.
class _BehindTheBrandCard extends StatelessWidget {
  final List<DetailRow> rows;
  final bool desktop;
  const _BehindTheBrandCard({required this.rows, this.desktop = false});

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) return const SizedBox.shrink();
    final fontSize = (desktop ? 17 : 15).sp;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: (desktop ? 24 : 18).w,
        vertical: (desktop ? 8 : 6).h,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular((desktop ? 28 : 22).r),
        boxShadow: [
          BoxShadow(
            color: const Color(0x14101F1C),
            blurRadius: 24,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: Column(
        children: List.generate(rows.length, (i) {
          final row = rows[i];
          if (row.label.isEmpty && row.value.isEmpty) {
            return const SizedBox.shrink();
          }
          final isLast = i == rows.length - 1;
          return Container(
            padding: EdgeInsets.symmetric(vertical: (desktop ? 17 : 13).h),
            decoration: BoxDecoration(
              border: isLast
                  ? null
                  : const Border(
                      bottom: BorderSide(color: AppColors.border, width: 1),
                    ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    row.label,
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
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
      ),
    );
  }
}

/// One certification's display data — real [CertificationDetail] fields
/// reshaped for [_CertCard], with every field independently optional (a
/// certificate record can legitimately have some fields and not others).
class _CertEntry {
  final String standard;
  final List<TinyRow> rows;
  final LinkRow link;
  const _CertEntry({
    required this.standard,
    required this.rows,
    required this.link,
  });
}

/// One expandable certificate card — a checkmark + the standard name as
/// the always-visible header, expanding to reveal whichever of issuer/
/// dates/certificate ID/document name are actually present, plus a
/// "View certificate" link when there's a real URL for it.
class _CertCard extends StatelessWidget {
  final _CertEntry cert;
  final bool desktop;
  const _CertCard({required this.cert, this.desktop = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: (desktop ? 18 : 14).w,
        vertical: (desktop ? 6 : 4).h,
      ),
      decoration: BoxDecoration(
        color: AppColors.paper,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: ExpandableSection(
        label: '✓ ${cert.standard}',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (cert.rows.isNotEmpty) TinyRowsList(cert.rows),
            if (cert.link != LinkRow.empty) LinkDetailRow(cert.link),
          ],
        ),
      ),
    );
  }
}
