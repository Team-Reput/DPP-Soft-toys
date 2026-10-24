import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../data/dpp_models.dart';
import '../providers/dpp_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/common.dart';

/// "Toy" tab — mobile layout. Hero illustration + product intro, single
/// scrolling column. Mirrors `#home` in the source Mobile HTML. Content
/// comes from [DppProvider.toy].
class HomeScreenMobile extends StatelessWidget {
  const HomeScreenMobile({super.key});

  @override
  Widget build(BuildContext context) {
    final toy = context.watch<DppProvider>().toy ?? ToyModel.fromJson(const {});

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _HeroMobile(),
          _HomeCard(toy: toy),
          Padding(
            padding: EdgeInsets.fromLTRB(22.w, 1.h, 22.w, 36.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionTitle('What am I made of? 🧵'),
                DetailList(toy.madeOf),
                const SectionTitle('My little passport 📖'),
                DetailList(toy.passportFacts),
                SectionCard(
                  margin: EdgeInsets.only(top: 14.h),
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

class _HeroMobile extends StatelessWidget {
  const _HeroMobile();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.vertical(bottom: Radius.circular(36.r)),
      child: Container(
        constraints: BoxConstraints(minHeight: 390.h),
        color: AppColors.heroBg,
        padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 0),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Dashed ring behind the bear (decorative; simplified as a
            // plain translucent circle to avoid a custom dash painter).
            Positioned(
              top: 70.h,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 340.w,
                  height: 340.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.heroDashedRing, width: 1),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 21.w,
              top: 157.h,
              child: Transform.rotate(
                angle: -0.28,
                child: Text(
                  '✿',
                  style: TextStyle(fontSize: 40.sp, color: const Color(0xFFF1B887)),
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
                SizedBox(height: 9.h),
                RichText(
                  text: TextSpan(
                    style: AppTextStyles.display(
                      size: 40,
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
                  height: 239.h,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Transform.rotate(
                        angle: -0.087, // ~-5deg
                        child: SizedBox(
                          width: 265.w,
                          height: 280.h,
                          child: SvgPicture.asset('assets/teddy_bear.svg'),
                        ),
                      ),
                      Positioned(
                        right: 20.w,
                        bottom: 20.h,
                        child: Transform.rotate(
                          angle: 0.227, // ~13deg
                          child: Container(
                            height: 76.h,
                            width: 76.w,
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
                              '10-INCH\nPLUSH\n♡',
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
      offset: Offset(0, -17.h),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w),
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
            Text('♡ HELLO, LITTLE FRIEND!', style: AppTextStyles.outlineStamp),
            SizedBox(height: 8.h),
            Text('Meet your forest teddy', style: AppTextStyles.cardHeading),
            SizedBox(height: 5.h),
            Text(
              toy.homeCardText,
              style: AppTextStyles.body(size: 12, color: AppColors.muted, height: 1.55),
            ),
            SizedBox(height: 14.h),
            ChipsRow(toy.chips),
          ],
        ),
      ),
    );
  }
}
