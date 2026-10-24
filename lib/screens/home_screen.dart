import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../data/dpp_models.dart';
import '../providers/dpp_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/common.dart';

/// "Toy" tab — hero illustration + product intro.
/// Mirrors `#home` section in the source HTML. Content comes from
/// [DppProvider.toy], populated from either a real scanned-QR backend
/// response or the bundled demo seed.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final toy = context.watch<DppProvider>().toy ?? ToyModel.fromJson(const {});

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Hero(),
          _HomeCard(toy: toy),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 1, 22, 36),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionTitle('What am I made of? 🧵'),
                DetailList(toy.madeOf),
                const SectionTitle('My little passport 📖'),
                DetailList(toy.passportFacts),
                SectionCard(
                  margin: const EdgeInsets.only(top: 14),
                  child: ExpandableSection(
                    label: toy.petParentToggleLabel,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TinyRowsList(toy.petParentRows),
                        LinkDetailRow(toy.petParentWebsite),
                        DisclaimerText(toy.petParentDisclaimer),
                      ],
                    ),
                  ),
                ),
                const SectionTitle('A little note from the forest'),
                StoryBox.fromContent(toy.story),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(36)),
      child: Container(
        color: AppColors.heroBg,
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Dashed ring behind the bear (decorative; simplified as a
            // plain translucent circle to avoid a custom dash painter).
            Positioned(
              top: 70,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 340,
                  height: 340,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.heroDashedRing,
                      width: 1,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 21,
              top: 157,
              child: Transform.rotate(
                angle: -0.28,
                child: const Text(
                  '✿',
                  style: TextStyle(fontSize: 40, color: Color(0xFFF1B887)),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '✳ THE FOREST FRIENDS COLLECTION',
                  style: AppTextStyles.body(
                    size: 11,
                    weight: FontWeight.w800,
                    color: AppColors.forest,
                  ).copyWith(letterSpacing: 1.9),
                ),
                const SizedBox(height: 9),
                RichText(
                  text: TextSpan(
                    style: AppTextStyles.display(
                      size: 38,
                      height: 1.04,
                      color: AppColors.heroHeading,
                      letterSpacing: -1.0,
                    ),
                    children: [
                      const TextSpan(text: 'A little bear,\n'),
                      TextSpan(
                        text: 'a lot of love.',
                        style: TextStyle(color: AppColors.heroAccent),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 239,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Transform.rotate(
                        angle: -0.087, // ~-5deg
                        child: SizedBox(
                          width: 265,
                          height: 280,
                          child: SvgPicture.asset('assets/teddy_bear.svg'),
                        ),
                      ),
                      Positioned(
                        right: 20,
                        bottom: 20,
                        child: Transform.rotate(
                          angle: 0.227, // ~13deg
                          child: Container(
                            height: 76,
                            width: 76,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: AppColors.heroStampBg,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.heroStampBorder,
                                width: 2,
                                style: BorderStyle.solid,
                              ),
                            ),
                            child: Text(
                              '10 INCH\nOF HUGS\n♡',
                              textAlign: TextAlign.center,
                              style: AppTextStyles.display(
                                size: 12,
                                height: 1.1,
                                color: AppColors.heroStampText,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeCard extends StatelessWidget {
  final ToyModel toy;
  const _HomeCard({required this.toy});

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -17),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.paper,
          border: Border.all(color: const Color(0xFFF2E8D9)),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0x17694E30),
              blurRadius: 42,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('♡ HELLO, LITTLE FRIEND!', style: AppTextStyles.outlineStamp),
            const SizedBox(height: 8),
            Text('Meet your forest teddy', style: AppTextStyles.cardHeading),
            const SizedBox(height: 5),
            Text(
              toy.homeCardText,
              style: AppTextStyles.body(size: 12, color: AppColors.muted, height: 1.55),
            ),
            const SizedBox(height: 14),
            ChipsRow(toy.chips),
          ],
        ),
      ),
    );
  }
}
