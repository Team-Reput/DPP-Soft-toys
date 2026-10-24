import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../data/dpp_models.dart';
import '../providers/dpp_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/common.dart';

/// "Toy" tab — desktop layout. Two-column grid: a tall hero on the left
/// (pinned, non-scrolling) and the home-card + passport details scrolling
/// on the right. Mirrors `#home.active` in the source Desktop HTML
/// (`grid-template-columns:.94fr 1.06fr`). Content comes from
/// [DppProvider.toy].
class HomeScreenDesktop extends StatelessWidget {
  const HomeScreenDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    final toy = context.watch<DppProvider>().toy ?? ToyModel.fromJson(const {});

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 94, child: _HeroDesktop()),
        SizedBox(width: 38.w),
        Expanded(
          flex: 106,
          child: SingleChildScrollView(
            padding: EdgeInsets.only(bottom: 45.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HomeCardDesktop(toy: toy),
                SizedBox(height: 18.h),
                SectionTitle('What am I made of? 🧵', desktop: true),
                DetailList(toy.madeOf, desktop: true),
                SectionTitle('My little passport 📖', desktop: true),
                DetailList(toy.passportFacts, desktop: true),
                SectionCard(
                  desktop: true,
                  margin: EdgeInsets.only(top: 14.h),
                  child: ExpandableSection(
                    label: toy.petParentToggleLabel,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TinyRowsList(toy.petParentRows),
                        LinkDetailRow(toy.petParentWebsite),
                        DisclaimerText(toy.petParentDisclaimer, desktop: true),
                      ],
                    ),
                  ),
                ),
                SectionTitle('A little note from the forest', desktop: true),
                StoryBox.fromContent(toy.story, desktop: true),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _HeroDesktop extends StatelessWidget {
  const _HeroDesktop();

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: 630.h),
      decoration: BoxDecoration(
        color: const Color(0xFFE6EEDC),
        borderRadius: BorderRadius.circular(34.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0x1A5A6042),
            blurRadius: 45,
            offset: Offset(0, 18.h),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(37.w, 45.h, 37.w, 25.h),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '✳ THE FOREST FRIENDS COLLECTION',
                style: AppTextStyles.body(
                  size: 12,
                  weight: FontWeight.w800,
                  color: AppColors.forest,
                ).copyWith(letterSpacing: 1.9),
              ),
              SizedBox(height: 9.h),
              RichText(
                text: TextSpan(
                  style: AppTextStyles.display(
                    size: 50,
                    height: 1.04,
                    color: AppColors.heroHeading,
                    letterSpacing: -1.6,
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
                height: 360.h,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Transform.rotate(
                      angle: -0.087,
                      child: SizedBox(
                        width: 330.w,
                        height: 350.h,
                        child: SvgPicture.asset('assets/teddy_bear.svg'),
                      ),
                    ),
                    Positioned(
                      right: 20.w,
                      bottom: 35.h,
                      child: Transform.rotate(
                        angle: 0.227,
                        child: Container(
                          height: 90.h,
                          width: 90.w,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.heroStampBg,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.heroStampBorder,
                              width: 2,
                            ),
                          ),
                          child: Text(
                            '10-INCH\nPLUSH\n♡',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.display(
                              size: 14,
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
    );
  }
}

class _HomeCardDesktop extends StatelessWidget {
  final ToyModel toy;
  const _HomeCardDesktop({required this.toy});

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
          Text('♡ HELLO, LITTLE FRIEND!', style: AppTextStyles.outlineStamp),
          SizedBox(height: 8.h),
          Text(
            'Meet your forest teddy',
            style: AppTextStyles.display(size: 30, weight: FontWeight.w600),
          ),
          SizedBox(height: 5.h),
          Text(
            toy.homeCardText,
            style: AppTextStyles.body(size: 13, color: AppColors.muted, height: 1.55),
          ),
          SizedBox(height: 14.h),
          ChipsRow(toy.chips),
        ],
      ),
    );
  }
}
