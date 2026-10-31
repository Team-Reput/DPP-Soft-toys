/// Shared UI value types rendered by the widgets in `widgets/common.dart`.
///
/// These are plain display shapes, not a parsed API response — every
/// screen now builds them directly from the REAL `getToyDppProcessDetail`
/// data (`dpp_process_models.dart`) through its own local view-model (e.g.
/// `_HomeContent`, `_ImpactContent` at the bottom of each screen file).
///
/// This file used to also hold the old placeholder-shaped response model
/// (`DppResponseModel`/`ToyModel`/`ImpactModel`/`JourneyModel`/`CareModel`/
/// `BrandModel`, its `fromJson` parsing, and the demo JSON that fed it) —
/// all of that was dummy/placeholder content written before the real
/// backend existed, and has been removed now that every screen reads real
/// data. Only the reusable value types survive.
library dpp_models;

/// A two-column "label: value" row. Mirrors `.detail-list .detail` /
/// `.tiny-row` in the original design.
class DetailRow {
  final String label;
  final String value;
  const DetailRow(this.label, this.value);
}

/// A detail/tiny row whose value is a tappable external link.
class LinkRow {
  final String label;
  final String linkText;
  final String url;
  const LinkRow(this.label, this.linkText, this.url);

  static const empty = LinkRow('', '', '');
}

class ChipItem {
  final String emoji;
  final String label;
  const ChipItem(this.emoji, this.label);
}

class MetricItem {
  final String icon;
  final String value;
  final String unit;
  final String what;
  const MetricItem({
    required this.icon,
    required this.value,
    required this.unit,
    required this.what,
  });
}

class JourneyStop {
  final String emoji;
  final String title;
  final String description;
  final String place;
  // Added for the numbered-card Journey redesign.
  final int index;
  final String subtitle;
  final String location;
  final List<String> chips;
  // Added for the icon-led "route" row (origin → mode/distance →
  // destination), replacing the old one-line sentence.
  final String originLabel;
  final String destinationLabel;
  final String transportMode;
  final String distanceLabel;
  const JourneyStop({
    required this.emoji,
    required this.title,
    required this.description,
    required this.place,
    this.index = 0,
    this.subtitle = '',
    this.location = '',
    this.chips = const [],
    this.originLabel = '',
    this.destinationLabel = '',
    this.transportMode = '',
    this.distanceLabel = '',
  });
}

class CareItem {
  final String emoji;
  final String title;
  final String description;
  const CareItem({
    required this.emoji,
    required this.title,
    required this.description,
  });
}

class TinyRow {
  final String label;
  final String value;
  const TinyRow(this.label, this.value);
}

/// Shared payload for the `.storybox` blocks on the Home and Brand screens.
class StoryBoxContent {
  final String emoji;
  final String title;
  final String text;
  const StoryBoxContent({
    required this.emoji,
    required this.title,
    required this.text,
  });

  static const empty = StoryBoxContent(emoji: '', title: '', text: '');
}
