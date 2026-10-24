import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Text styles mapped from the HTML's DM Sans (body) / Fredoka (display)
/// pairing. Every `size` passed in is a design-reference px value (from the
/// source HTML's CSS) and is run through ScreenUtil's `.sp` so it scales
/// with the device, matching the `.sp`/`.w`/`.h` convention used across the
/// desktop and mobile screen layouts.
class AppTextStyles {
  AppTextStyles._();

  static TextStyle body({
    double size = 13,
    FontWeight weight = FontWeight.w400,
    Color color = AppColors.ink,
    double height = 1.5,
  }) => GoogleFonts.dmSans(
    fontSize: size.sp,
    fontWeight: weight,
    color: color,
    height: height,
  );

  static TextStyle display({
    double size = 32,
    FontWeight weight = FontWeight.w600,
    Color color = AppColors.ink,
    double height = 1.08,
    double letterSpacing = -0.6,
  }) => GoogleFonts.fredoka(
    fontSize: size.sp,
    fontWeight: weight,
    color: color,
    height: height,
    letterSpacing: letterSpacing,
  );

  // Common reusable named styles.
  static TextStyle get brand =>
      display(size: 19, weight: FontWeight.w600, height: 1.0);

  static TextStyle get passportBadge => body(
    size: 10,
    weight: FontWeight.w800,
    color: AppColors.passportText,
  ).copyWith(letterSpacing: 0.8);

  static TextStyle get eyebrow => body(
    size: 11,
    weight: FontWeight.w800,
    color: AppColors.eyebrow,
  ).copyWith(letterSpacing: 1.8);

  static TextStyle get heading => display(size: 33, height: 1.08);

  static TextStyle get intro =>
      body(size: 13, color: AppColors.muted, height: 1.65);

  static TextStyle get sectionTitle =>
      display(size: 20, weight: FontWeight.w600);

  static TextStyle get cardHeading =>
      display(size: 24, weight: FontWeight.w600);

  static TextStyle get detailLabel => body(size: 12, color: AppColors.muted);

  static TextStyle get detailValue =>
      body(size: 12, weight: FontWeight.w700, color: AppColors.ink);

  static TextStyle get chip =>
      body(size: 11, weight: FontWeight.w700, color: AppColors.chipText);

  static TextStyle get metricValue =>
      display(size: 27, weight: FontWeight.w600, letterSpacing: -0.8);

  static TextStyle get metricUnit =>
      body(size: 11, weight: FontWeight.w700, color: AppColors.ink);

  static TextStyle get metricWhat =>
      body(size: 11, color: AppColors.metricWhat, height: 1.35);

  static TextStyle get noteText =>
      body(size: 11, color: AppColors.noteText, height: 1.6);

  static TextStyle get tabLabel =>
      body(size: 10, weight: FontWeight.w800, color: AppColors.tabInactive);

  static TextStyle get tabLabelActive =>
      body(size: 10, weight: FontWeight.w800, color: AppColors.tabActiveText);

  static TextStyle get footerNote =>
      body(size: 10, color: AppColors.footerNote, height: 1.6);

  static TextStyle get disclaimer =>
      body(size: 10, color: AppColors.disclaimer, height: 1.65);

  static TextStyle get storyboxTitle =>
      display(size: 17, weight: FontWeight.w600);

  static TextStyle get storyboxText =>
      body(size: 12, color: AppColors.storyboxText, height: 1.6);

  static TextStyle get sectionCardTitle =>
      display(size: 18, weight: FontWeight.w600);

  static TextStyle get sectionCardText =>
      body(size: 12, color: AppColors.sectionCardText, height: 1.65);

  static TextStyle get stopTitle => display(size: 17, weight: FontWeight.w600);

  static TextStyle get stopText =>
      body(size: 12, color: AppColors.stopText, height: 1.5);

  static TextStyle get placeText =>
      body(size: 11, weight: FontWeight.w700, color: AppColors.placeText);

  static TextStyle get careTitle => display(size: 16, weight: FontWeight.w600);

  static TextStyle get careText =>
      body(size: 11, color: AppColors.careText, height: 1.45);

  static TextStyle get careBannerTitle =>
      display(size: 18, weight: FontWeight.w600);

  static TextStyle get careBannerText =>
      body(size: 12, color: AppColors.careBannerText, height: 1.5);

  static TextStyle get verifiedTitle => body(size: 13, weight: FontWeight.w700);

  static TextStyle get verifiedText =>
      body(size: 11, color: AppColors.verifiedText, height: 1.6);

  static TextStyle get tinyRowLabel => body(size: 11, color: AppColors.muted);

  static TextStyle get tinyRowValue =>
      body(size: 11, weight: FontWeight.w700, color: AppColors.ink);

  static TextStyle get outlineStamp => body(
    size: 11,
    weight: FontWeight.w800,
    color: AppColors.orange,
    height: 1.4,
  ).copyWith(letterSpacing: 1.0);
}
