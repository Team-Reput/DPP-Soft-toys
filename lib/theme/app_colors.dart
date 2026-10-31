import 'package:flutter/material.dart';

/// Colors lifted from the Forest Friends DPP CSS custom properties.
class AppColors {
  AppColors._();

  // White base (previously a warm beige/cream) — the page background,
  // header, tab bars and card surfaces are now all plain white, with
  // borders/shadows (not color) doing the work of separating them.
  static const Color cream = Color(0xFFFFFFFF);
  static const Color paper = Color(0xFFFFFFFF);
  static const Color ink = Color(0xFF221F1C);
  static const Color muted = Color(0xFF6B7280);
  static const Color orange = Color(0xFFD88A55);
  static const Color brown = Color(0xFF805638);
  static const Color forest = Color(0xFF2E6F64);
  static const Color mint = Color(0xFFE4EDDA);
  static const Color pink = Color(0xFFF8E2DC);
  static const Color border = Color(0xFFE9ECEF);

  // Page background radial-gradient base tones.
  static const Color bgPeach = Color(0xFFF9E4D7);
  static const Color bgSage = Color(0xFFE0EACB);
  static const Color bgBase = Color(0xFFFFFFFF);

  // Hero section.
  static const Color heroBg = Color(0xFFE6EBD6);
  static const Color heroHeading = Color(0xFF4D614D);
  static const Color heroAccent = Color(0xFFB87952);
  static const Color heroDashedRing = Color(0xFFBBCBAB);
  static const Color heroStampBg = Color(0xFFFFF8ED);
  static const Color heroStampBorder = Color(0xFFCFA98F);
  static const Color heroStampText = Color(0xFFA66C4B);

  // Chips / badges — pale teal, matching the Journey screen's accent
  // family, in place of the old tan/beige.
  static const Color chipBg = Color(0xFFE7F3F1);
  static const Color chipText = Color(0xFF1F5A50);
  static const Color passportBorder = Color(0xFFBFE1DA);
  static const Color passportText = Color(0xFF1F5A50);

  // Storybox.
  static const Color storyboxBg = Color(0xFFE7F3F1);
  static const Color storyboxText = Color(0xFF5F6B67);

  // Eyebrow / headings.
  static const Color eyebrow = Color(0xFFAD774E);

  // Metric cards (Impact screen) — white/pale-teal/pale-gray instead of
  // the old warm pastel set, so they read as the same white-base family
  // as every other card in the app.
  static const Color metric1Bg = Color(0xFFFFFFFF);
  static const Color metric2Bg = Color(0xFFEFF8F6);
  static const Color metric3Bg = Color(0xFFF6F6F5);
  static const Color metric4Bg = Color(0xFFEFF6F3);
  static const Color metricWhat = Color(0xFF6B7572);

  // Note / disclaimer boxes.
  static const Color noteText = Color(0xFF5F6B67);
  static const Color noteBg = Color(0xFFF4F7F6);
  static const Color noteBorder = Color(0xFFDCE6E3);
  static const Color disclaimer = Color(0xFF8B9490);

  // Progress bar — teal fill, matching the Journey accent.
  static const Color progressTrack = Color(0xFFE7EFEC);
  static const Color progressFill = Color(0xFF2E6F64);
  static const Color progressLabel = Color(0xFF5F6B67);

  // Section card.
  static const Color sectionCardBg = Color(0xFFFFFFFF);
  static const Color sectionCardText = Color(0xFF6B7572);

  // Journey screen — redesigned around a teal accent on white cards.
  static const Color journeyLine = Color(0xFFC3CDA9);
  static const Color bubbleEvenBg = Color(0xFFE3EDDA);
  static const Color bubbleEvenBorder = Color(0xFFD3E2C7);
  static const Color bubbleOddBg = Color(0xFFF8E4D7);
  static const Color bubbleOddBorder = Color(0xFFEFDBCC);
  static const Color stopText = Color(0xFF83766A);
  static const Color placeText = Color(0xFFA07152);
  static const Color journeyCardBg = Color(0xFFFFFFFF);
  static const Color journeyCardBorder = Color(0xFFECEEF1);
  static const Color journeyBadgeBg = Color(0xFF2E6F64);
  static const Color journeyBadgeText = Color(0xFFFFFFFF);
  static const Color journeySubtitle = Color(0xFF2B2B2B);
  static const Color journeyLocationText = Color(0xFF6B7280);
  static const Color journeyPin = Color(0xFFE2584B);
  static const Color journeyChipBg = Color(0xFFE7F3F1);
  static const Color journeyChipBorder = Color(0xFFBFE1DA);
  static const Color journeyChipText = Color(0xFF1F5A50);

  // Care screen — same white/pale-teal/pale-gray family as the metric
  // cards, instead of the old warm pastel set.
  static const Color care1Bg = Color(0xFFFFFFFF);
  static const Color care2Bg = Color(0xFFEFF8F6);
  static const Color care3Bg = Color(0xFFF6F6F5);
  static const Color care4Bg = Color(0xFFEFF6F3);
  static const Color careText = Color(0xFF6B7572);
  static const Color careBannerBg = Color(0xFFE7F3F1);
  static const Color careBannerText = Color(0xFF1F5A50);

  // About / verified box.
  static const Color verifiedBg = Color(0xFFF4F7F6);
  static const Color verifiedBorder = Color(0xFFDCE6E3);
  static const Color verifiedText = Color(0xFF5F6B67);
  static const Color tinyRowBorder = Color(0xFFE7ECEA);
  static const Color pillLinkBg = Color(0xFF2E6F64);

  // Tab bar — pale teal active state, matching the Journey accent.
  static const Color tabBarBg = Color(0xFFFFFFFF);
  static const Color tabBarBorder = Color(0xFFE7ECEA);
  static const Color tabInactive = Color(0xFF7C8884);
  static const Color tabActiveBg = Color(0xFFE7F3F1);
  static const Color tabActiveText = Color(0xFF1F5A50);

  static const Color footerNote = Color(0xFF86908C);
}
