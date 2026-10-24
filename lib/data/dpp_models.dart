/// Typed model classes for the soft-toy Digital Product Passport response.
///
/// Mirrors the architecture of the reference "bags" DPP app (coercion
/// helpers, an `o_status`/`details` envelope, `fromJson` factories per
/// section) but with fields shaped for this product's 5 tabs — Toy, Planet,
/// Journey, Care, Brand — instead of the bags app's own sections. Values are
/// the single source of truth the screens render from [DppProvider]; there
/// is no more static per-screen content.
library dpp_models;

// ════════════════════════════════════════════════════════════════════════
// JSON COERCION HELPERS — tolerant of String/num/bool-as-string payloads,
// since not every backend field is guaranteed to arrive as the "right" type.
// ════════════════════════════════════════════════════════════════════════

String _s(Map<String, dynamic> j, List<String> keys, [String fb = '']) {
  for (final k in keys) {
    final v = j[k];
    if (v != null && v.toString().trim().isNotEmpty) return v.toString().trim();
  }
  return fb;
}

double _d(Map<String, dynamic> j, List<String> keys, [double fb = 0.0]) {
  for (final k in keys) {
    final v = j[k];
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? fb;
  }
  return fb;
}

/// Parses either a real `List` or a JSON-encoded `"[…]"` string.
List<Map<String, dynamic>> _mapList(Map<String, dynamic> j, List<String> keys) {
  for (final k in keys) {
    final v = j[k];
    if (v is List) return v.whereType<Map<String, dynamic>>().toList();
  }
  return [];
}

/// Returns a nested Map for [keys], or `{}` if absent / wrong type.
Map<String, dynamic> _map(Map<String, dynamic> j, List<String> keys) {
  for (final k in keys) {
    final v = j[k];
    if (v is Map<String, dynamic>) return v;
  }
  return {};
}

// ════════════════════════════════════════════════════════════════════════
// JSON NAVIGATION — same envelope shape as the reference app:
//   { "issuccessful": true,
//     "data": [ { "o_status": true, "o_message": "", "details": { … } } ] }
// ════════════════════════════════════════════════════════════════════════

/// Thrown when the API returns `o_status: false` for a brand/batch pair
/// (i.e. the scanned QR code doesn't resolve to a known product/batch).
class DppNotFoundException implements Exception {
  final String message;
  const DppNotFoundException(this.message);
  @override
  String toString() => message;
}

Map<String, dynamic> _extractDetails(Map<String, dynamic> json) {
  final dataList = json['data'];
  if (dataList is! List || dataList.isEmpty) return {};

  final first = dataList[0];
  if (first is! Map<String, dynamic>) return {};

  final oStatus = first['o_status'];
  if (oStatus == false) {
    final msg = first['o_message']?.toString() ?? 'Product not found';
    throw DppNotFoundException(msg);
  }

  final details = first['details'];
  if (details is! Map<String, dynamic>) return {};
  return details;
}

// ════════════════════════════════════════════════════════════════════════
// SHARED VALUE TYPES — rendered directly by the widgets in widgets/common.dart.
// ════════════════════════════════════════════════════════════════════════

/// A two-column "label: value" row. Mirrors `.detail-list .detail` /
/// `.tiny-row` in the original design.
class DetailRow {
  final String label;
  final String value;
  const DetailRow(this.label, this.value);

  factory DetailRow.fromJson(Map<String, dynamic> j) =>
      DetailRow(_s(j, ['label']), _s(j, ['value']));
}

/// A detail/tiny row whose value is a tappable external link.
class LinkRow {
  final String label;
  final String linkText;
  final String url;
  const LinkRow(this.label, this.linkText, this.url);

  factory LinkRow.fromJson(Map<String, dynamic> j) => LinkRow(
        _s(j, ['label']),
        _s(j, ['link_text', 'text']),
        _s(j, ['url']),
      );

  static const empty = LinkRow('', '', '');
}

class ChipItem {
  final String emoji;
  final String label;
  const ChipItem(this.emoji, this.label);

  factory ChipItem.fromJson(Map<String, dynamic> j) =>
      ChipItem(_s(j, ['emoji']), _s(j, ['label']));
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

  factory MetricItem.fromJson(Map<String, dynamic> j) => MetricItem(
        icon: _s(j, ['icon']),
        value: _s(j, ['value']),
        unit: _s(j, ['unit']),
        what: _s(j, ['what']),
      );
}

class JourneyStop {
  final String emoji;
  final String title;
  final String description;
  final String place;
  const JourneyStop({
    required this.emoji,
    required this.title,
    required this.description,
    required this.place,
  });

  factory JourneyStop.fromJson(Map<String, dynamic> j) => JourneyStop(
        emoji: _s(j, ['emoji']),
        title: _s(j, ['title']),
        description: _s(j, ['description']),
        place: _s(j, ['place']),
      );
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

  factory CareItem.fromJson(Map<String, dynamic> j) => CareItem(
        emoji: _s(j, ['emoji']),
        title: _s(j, ['title']),
        description: _s(j, ['description']),
      );
}

class TinyRow {
  final String label;
  final String value;
  const TinyRow(this.label, this.value);

  factory TinyRow.fromJson(Map<String, dynamic> j) =>
      TinyRow(_s(j, ['label']), _s(j, ['value']));
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

  factory StoryBoxContent.fromJson(Map<String, dynamic> j) => StoryBoxContent(
        emoji: _s(j, ['emoji']),
        title: _s(j, ['title']),
        text: _s(j, ['text']),
      );

  static const empty = StoryBoxContent(emoji: '', title: '', text: '');
}

// ════════════════════════════════════════════════════════════════════════
// SECTION MODELS — one per tab. `details.<key>` in the API payload.
// ════════════════════════════════════════════════════════════════════════

/// "Toy" tab (home screen) — `details.toy`.
class ToyModel {
  final List<ChipItem> chips;
  final String homeCardText;
  final List<DetailRow> madeOf;
  final List<DetailRow> passportFacts;
  final String petParentToggleLabel;
  final List<TinyRow> petParentRows;
  final LinkRow petParentWebsite;
  final String petParentDisclaimer;
  final StoryBoxContent story;

  const ToyModel({
    required this.chips,
    required this.homeCardText,
    required this.madeOf,
    required this.passportFacts,
    required this.petParentToggleLabel,
    required this.petParentRows,
    required this.petParentWebsite,
    required this.petParentDisclaimer,
    required this.story,
  });

  factory ToyModel.fromJson(Map<String, dynamic> j) => ToyModel(
        chips: _mapList(j, ['chips']).map(ChipItem.fromJson).toList(),
        homeCardText: _s(j, ['home_card_text']),
        madeOf: _mapList(j, ['made_of']).map(DetailRow.fromJson).toList(),
        passportFacts:
            _mapList(j, ['passport_facts']).map(DetailRow.fromJson).toList(),
        petParentToggleLabel: _s(j, ['pet_parent_toggle_label'],
            'For pet parents · more product info'),
        petParentRows: _mapList(j, ['pet_parent_rows'])
            .map(TinyRow.fromJson)
            .toList(),
        petParentWebsite: _map(j, ['pet_parent_website']).isEmpty
            ? LinkRow.empty
            : LinkRow.fromJson(_map(j, ['pet_parent_website'])),
        petParentDisclaimer: _s(j, ['pet_parent_disclaimer']),
        story: _map(j, ['story']).isEmpty
            ? StoryBoxContent.empty
            : StoryBoxContent.fromJson(_map(j, ['story'])),
      );
}

/// "Planet" tab (impact/environmental footprint) — `details.impact`.
class ImpactModel {
  final List<MetricItem> metrics;
  final double renewableSharePercent;
  final double nonRenewableSharePercent;
  final String disclaimer;

  const ImpactModel({
    required this.metrics,
    required this.renewableSharePercent,
    required this.nonRenewableSharePercent,
    required this.disclaimer,
  });

  factory ImpactModel.fromJson(Map<String, dynamic> j) => ImpactModel(
        metrics: _mapList(j, ['metrics']).map(MetricItem.fromJson).toList(),
        renewableSharePercent: _d(j, ['renewable_share_percent']),
        nonRenewableSharePercent: _d(j, ['non_renewable_share_percent']),
        disclaimer: _s(j, ['disclaimer']),
      );
}

/// "Journey" tab (manufacturing timeline) — `details.journey`.
class JourneyModel {
  final String intro;
  final List<JourneyStop> stops;

  const JourneyModel({required this.intro, required this.stops});

  factory JourneyModel.fromJson(Map<String, dynamic> j) => JourneyModel(
        intro: _s(j, ['intro']),
        stops: _mapList(j, ['stops']).map(JourneyStop.fromJson).toList(),
      );
}

/// "Care" tab — `details.care`.
class CareModel {
  final String intro;
  final List<CareItem> items;
  final String retireText;

  const CareModel({
    required this.intro,
    required this.items,
    required this.retireText,
  });

  factory CareModel.fromJson(Map<String, dynamic> j) => CareModel(
        intro: _s(j, ['intro']),
        items: _mapList(j, ['items']).map(CareItem.fromJson).toList(),
        retireText: _s(j, ['retire_text']),
      );
}

/// "Brand" tab — `details.brand`.
class BrandModel {
  final StoryBoxContent story;
  final List<DetailRow> behindTheBrand;
  final LinkRow websiteRow;
  final String certsIntro;
  final List<ChipItem> certChips;
  final String supportingDocsText;
  final String takeBackHeadline;
  final String takeBackText;
  final String takeBackEndOfLifeText;
  final String disclaimer;

  const BrandModel({
    required this.story,
    required this.behindTheBrand,
    required this.websiteRow,
    required this.certsIntro,
    required this.certChips,
    required this.supportingDocsText,
    required this.takeBackHeadline,
    required this.takeBackText,
    required this.takeBackEndOfLifeText,
    required this.disclaimer,
  });

  factory BrandModel.fromJson(Map<String, dynamic> j) => BrandModel(
        story: _map(j, ['story']).isEmpty
            ? StoryBoxContent.empty
            : StoryBoxContent.fromJson(_map(j, ['story'])),
        behindTheBrand: _mapList(j, ['behind_the_brand'])
            .map(DetailRow.fromJson)
            .toList(),
        websiteRow: _map(j, ['website']).isEmpty
            ? LinkRow.empty
            : LinkRow.fromJson(_map(j, ['website'])),
        certsIntro: _s(j, ['certs_intro']),
        certChips: _mapList(j, ['cert_chips']).map(ChipItem.fromJson).toList(),
        supportingDocsText: _s(j, ['supporting_docs_text']),
        takeBackHeadline: _s(j, ['take_back_headline']),
        takeBackText: _s(j, ['take_back_text']),
        takeBackEndOfLifeText: _s(j, ['take_back_end_of_life_text']),
        disclaimer: _s(j, ['disclaimer']),
      );
}

// ════════════════════════════════════════════════════════════════════════
// TOP-LEVEL RESPONSE
// ════════════════════════════════════════════════════════════════════════

class DppResponseModel {
  final ToyModel toy;
  final ImpactModel impact;
  final JourneyModel journey;
  final CareModel care;
  final BrandModel brand;

  const DppResponseModel({
    required this.toy,
    required this.impact,
    required this.journey,
    required this.care,
    required this.brand,
  });

  /// [json] is the full decrypted map:
  ///   { "issuccessful": true,
  ///     "data": [ { "o_status": true, "details": { toy, impact, journey,
  ///                 care, brand } } ] }
  factory DppResponseModel.fromJson(Map<String, dynamic> json) {
    final details = _extractDetails(json);
    return DppResponseModel(
      toy: ToyModel.fromJson(_map(details, ['toy'])),
      impact: ImpactModel.fromJson(_map(details, ['impact'])),
      journey: JourneyModel.fromJson(_map(details, ['journey'])),
      care: CareModel.fromJson(_map(details, ['care'])),
      brand: BrandModel.fromJson(_map(details, ['brand'])),
    );
  }
}
