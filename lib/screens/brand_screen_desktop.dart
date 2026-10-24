import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../data/dpp_models.dart';
import '../providers/dpp_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/common.dart';

/// "Brand" tab — desktop layout. Same vertical flow as mobile but wider,
/// larger type, and the brand sections capped at 850.w like the source
/// Desktop HTML's `#brand .detail-list`/`.section-card`/`.storybox`
/// overrides. Content comes from [DppProvider.brand].
class BrandScreenDesktop extends StatelessWidget {
  const BrandScreenDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    final brand =
        context.watch<DppProvider>().brand ?? BrandModel.fromJson(const {});

    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom: 45.h),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 1110.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const EyebrowHeading(
              eyebrow: '🐾 THE PEOPLE BEHIND THE PAWS',
              heading: 'A brand with\na little heart.',
              intro:
                  'The grown-up corner for brand information, supplier '
                  'documentation and what happens when playtime is over.',
              desktop: true,
            ),
            StoryBox.fromContent(brand.story, desktop: true),
            SectionTitle('Behind the brand ✿', desktop: true),
            _BehindTheBrandListDesktop(
              row: brand.behindTheBrand.isNotEmpty
                  ? brand.behindTheBrand.first
                  : const DetailRow('', ''),
              websiteRow: brand.websiteRow,
            ),
            SectionTitle('Certificates & records 📜', desktop: true),
            SectionCard(
              desktop: true,
              maxWidth: 850.w,
              margin: EdgeInsets.zero,
              title: 'Paper trail, not approval badges',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(brand.certsIntro),
                  SizedBox(height: 12.h),
                  ChipsRow(brand.certChips),
                ],
              ),
            ),
            SectionCard(
              desktop: true,
              maxWidth: 850.w,
              title: 'Supporting documents',
              child: Text(brand.supportingDocsText),
            ),
            SectionTitle('Take-back & goodbye ♻️', desktop: true),
            SectionCard(
              desktop: true,
              maxWidth: 850.w,
              margin: EdgeInsets.zero,
              title: 'Take-back initiative',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: AppTextStyles.body(size: 14, color: AppColors.sectionCardText, height: 1.65),
                      children: [
                        TextSpan(
                          text: '${brand.takeBackHeadline} ',
                          style: AppTextStyles.body(
                            size: 14,
                            color: AppColors.sectionCardText,
                            height: 1.65,
                            weight: FontWeight.w700,
                          ),
                        ),
                        TextSpan(text: brand.takeBackText),
                      ],
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Text(brand.takeBackEndOfLifeText),
                ],
              ),
            ),
            DisclaimerText(brand.disclaimer, desktop: true),
          ],
        ),
      ),
    );
  }
}

class _BehindTheBrandListDesktop extends StatelessWidget {
  final DetailRow row;
  final LinkRow websiteRow;
  const _BehindTheBrandListDesktop({required this.row, required this.websiteRow});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 850.w),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.paper,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(22.r),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 19.w, vertical: 17.h),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      row.label,
                      style: AppTextStyles.body(size: 14, color: AppColors.muted),
                    ),
                  ),
                  SizedBox(width: 18.w),
                  Flexible(
                    child: Text(
                      row.value,
                      style: AppTextStyles.body(size: 14, weight: FontWeight.w700, color: AppColors.ink),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 19.w, vertical: 8.h),
              child: LinkDetailRow(websiteRow, tiny: false),
            ),
          ],
        ),
      ),
    );
  }
}
