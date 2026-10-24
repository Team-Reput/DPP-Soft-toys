import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/dpp_models.dart';
import '../providers/dpp_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/common.dart';

/// "Brand" tab — brand story, certificates & records, and take-back info.
/// Mirrors `#brand` section in the source HTML. Content comes from
/// [DppProvider.brand].
class BrandScreen extends StatelessWidget {
  const BrandScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final brand =
        context.watch<DppProvider>().brand ?? BrandModel.fromJson(const {});

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 36),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const EyebrowHeading(
            eyebrow: '🐾 THE PEOPLE BEHIND THE PAWS',
            heading: 'A brand with\na little heart.',
            intro:
                'The grown-up corner for brand information, supplier '
                'documentation and what happens when playtime is over.',
          ),
          StoryBox.fromContent(brand.story),
          const SectionTitle('Behind the brand ✿'),
          _BehindTheBrandList(
            row: brand.behindTheBrand.isNotEmpty
                ? brand.behindTheBrand.first
                : const DetailRow('', ''),
            websiteRow: brand.websiteRow,
          ),
          const SectionTitle('Certificates & records 📜'),
          SectionCard(
            margin: EdgeInsets.zero,
            title: 'Paper trail, not approval badges',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(brand.certsIntro, style: AppTextStyles.sectionCardText),
                const SizedBox(height: 12),
                ChipsRow(brand.certChips),
              ],
            ),
          ),
          SectionCard(
            title: 'Supporting documents',
            child: Text(
              brand.supportingDocsText,
              style: AppTextStyles.sectionCardText,
            ),
          ),
          const SectionTitle('Take-back & goodbye ♻️'),
          SectionCard(
            margin: EdgeInsets.zero,
            title: 'Take-back initiative',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: AppTextStyles.sectionCardText,
                    children: [
                      TextSpan(
                        text: '${brand.takeBackHeadline} ',
                        style: AppTextStyles.sectionCardText
                            .copyWith(fontWeight: FontWeight.w700),
                      ),
                      TextSpan(text: brand.takeBackText),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  brand.takeBackEndOfLifeText,
                  style: AppTextStyles.sectionCardText,
                ),
              ],
            ),
          ),
          DisclaimerText(brand.disclaimer),
        ],
      ),
    );
  }
}

/// Mirrors the `.detail-list` under "Behind the brand" — one plain row
/// (brand story) and one row whose value is a tappable link.
class _BehindTheBrandList extends StatelessWidget {
  final DetailRow row;
  final LinkRow websiteRow;
  const _BehindTheBrandList({required this.row, required this.websiteRow});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.paper,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(19),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.border, width: 1),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(child: Text(row.label, style: AppTextStyles.detailLabel)),
                const SizedBox(width: 18),
                Flexible(
                  child: Text(
                    row.value,
                    style: AppTextStyles.detailValue,
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            child: LinkDetailRow(websiteRow, tiny: false),
          ),
        ],
      ),
    );
  }
}
