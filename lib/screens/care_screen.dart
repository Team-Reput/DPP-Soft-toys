import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/dpp_models.dart';
import '../providers/dpp_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/common.dart';

/// "Care" tab — care instructions + end-of-life note.
/// Mirrors `#care` section in the source HTML. Content comes from
/// [DppProvider.care].
class CareScreen extends StatelessWidget {
  const CareScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final care = context.watch<DppProvider>().care ?? CareModel.fromJson(const {});

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 36),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const EyebrowHeading(
            eyebrow: '💗 CUTE CARE FOR PAWS',
            heading: 'Keep the\ntail wags coming!',
            intro:
                'A little care helps keep this forest friend ready for more '
                'playtime, carrying, and cuddles.',
          ),
          _CareGrid(items: care.items),
          const SectionTitle('A happy little habit'),
          const _CareBanner(),
          const SizedBox(height: 14),
          SectionCard(
            title: 'When to retire the toy',
            child: Text(
              care.retireText,
              style: AppTextStyles.sectionCardText,
            ),
          ),
        ],
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
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 0.98,
      children: List.generate(items.length, (i) {
        final item = items[i];
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
          decoration: BoxDecoration(
            color: _bgColors[i % _bgColors.length],
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(item.emoji, style: const TextStyle(fontSize: 38)),
              const SizedBox(height: 10),
              Text(item.title, style: AppTextStyles.careTitle),
              const SizedBox(height: 5),
              Text(
                item.description,
                textAlign: TextAlign.center,
                style: AppTextStyles.careText,
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _CareBanner extends StatelessWidget {
  const _CareBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: AppColors.careBannerBg,
        borderRadius: BorderRadius.circular(23),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text('🌷', style: TextStyle(fontSize: 35)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Care for longer, play for longer.',
                  style: AppTextStyles.careBannerTitle,
                ),
                const SizedBox(height: 5),
                Text(
                  'Look after the toy and enjoy more happy moments together.',
                  style: AppTextStyles.careBannerText,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
