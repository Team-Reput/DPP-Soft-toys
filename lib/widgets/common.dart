import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/dpp_models.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Shared pieces reused across screens: section title, detail list, chips,
/// storybox, section card, footer note, disclaimer, eyebrow + heading combo.
/// Mirrors the matching CSS classes in the source HTML (`.section-title`,
/// `.detail-list`, `.chip`, `.storybox`, `.section-card`, `.footer-note`,
/// `.disclaimer`, `.eyebrow`, `.heading`).

class SectionTitle extends StatelessWidget {
  final String text;
  const SectionTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 25, bottom: 12),
      child: Text(text, style: AppTextStyles.sectionTitle),
    );
  }
}

class EyebrowHeading extends StatelessWidget {
  final String eyebrow;
  final String heading; // use \n for <br>
  final String intro;

  const EyebrowHeading({
    super.key,
    required this.eyebrow,
    required this.heading,
    required this.intro,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(eyebrow, style: AppTextStyles.eyebrow),
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 12),
          child: Text(heading, style: AppTextStyles.heading),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Text(intro, style: AppTextStyles.intro),
        ),
      ],
    );
  }
}

class DetailList extends StatelessWidget {
  final List<DetailRow> rows;
  const DetailList(this.rows, {super.key});

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
        children: List.generate(rows.length, (i) {
          final row = rows[i];
          final isLast = i == rows.length - 1;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
            decoration: BoxDecoration(
              border: isLast
                  ? null
                  : const Border(
                      bottom: BorderSide(
                        color: AppColors.border,
                        width: 1,
                        style: BorderStyle.solid,
                      ),
                    ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(row.label, style: AppTextStyles.detailLabel),
                ),
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
          );
        }),
      ),
    );
  }
}

class ChipsRow extends StatelessWidget {
  final List<ChipItem> chips;
  const ChipsRow(this.chips, {super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 7,
      runSpacing: 7,
      children: chips
          .map(
            (c) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.chipBg,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text('${c.emoji} ${c.label}', style: AppTextStyles.chip),
            ),
          )
          .toList(),
    );
  }
}

class StoryBox extends StatelessWidget {
  final String emoji;
  final String title;
  final String text;

  const StoryBox({
    super.key,
    required this.emoji,
    required this.title,
    required this.text,
  });

  factory StoryBox.fromContent(StoryBoxContent content, {Key? key}) {
    return StoryBox(
      key: key,
      emoji: content.emoji,
      title: content.title,
      text: content.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
      decoration: BoxDecoration(
        color: AppColors.storyboxBg,
        borderRadius: BorderRadius.circular(23),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 29)),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.storyboxTitle),
                const SizedBox(height: 5),
                Text(text, style: AppTextStyles.storyboxText),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SectionCard extends StatelessWidget {
  final String? title;
  final Widget child;
  final EdgeInsets margin;

  const SectionCard({
    super.key,
    this.title,
    required this.child,
    this.margin = const EdgeInsets.only(top: 14),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: AppColors.sectionCardBg,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(title!, style: AppTextStyles.sectionCardTitle),
            const SizedBox(height: 9),
          ],
          child,
        ],
      ),
    );
  }
}

class FooterNote extends StatelessWidget {
  final String text;
  const FooterNote(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(7, 25, 7, 8),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: AppTextStyles.footerNote,
      ),
    );
  }
}

class DisclaimerText extends StatelessWidget {
  final String text;
  const DisclaimerText(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 15),
      child: Text(text, style: AppTextStyles.disclaimer),
    );
  }
}

/// Small two-column rows used inside an expandable panel.
/// Mirrors `.tiny-row` in the source HTML.
class TinyRowsList extends StatelessWidget {
  final List<TinyRow> rows;
  const TinyRowsList(this.rows, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(rows.length, (i) {
        final row = rows[i];
        final isLast = i == rows.length - 1;
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            border: isLast
                ? null
                : const Border(
                    bottom: BorderSide(color: AppColors.tinyRowBorder, width: 1),
                  ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(child: Text(row.label, style: AppTextStyles.tinyRowLabel)),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  row.value,
                  style: AppTextStyles.tinyRowValue,
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

/// A detail/tiny row whose value is a tappable external link.
/// Mirrors the `<a>` inside a `.tiny-row`/`.detail` value in the source HTML.
class LinkDetailRow extends StatelessWidget {
  final LinkRow row;
  final bool tiny;

  const LinkDetailRow(this.row, {super.key, this.tiny = true});

  @override
  Widget build(BuildContext context) {
    final labelStyle = tiny ? AppTextStyles.tinyRowLabel : AppTextStyles.detailLabel;
    final linkStyle = (tiny ? AppTextStyles.tinyRowValue : AppTextStyles.detailValue)
        .copyWith(
      color: AppColors.forest,
      decoration: TextDecoration.underline,
      decorationColor: AppColors.forest,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(child: Text(row.label, style: labelStyle)),
          const SizedBox(width: 10),
          InkWell(
            onTap: () => launchUrl(
              Uri.parse(row.url),
              mode: LaunchMode.externalApplication,
            ),
            child: Text(row.linkText, style: linkStyle),
          ),
        ],
      ),
    );
  }
}

/// Collapsible "+/−" panel. Mirrors `.toggle` + `.expand` in the source
/// HTML — a section-card header row that expands to reveal `child`.
class ExpandableSection extends StatefulWidget {
  final String label;
  final Widget child;

  const ExpandableSection({
    super.key,
    required this.label,
    required this.child,
  });

  @override
  State<ExpandableSection> createState() => _ExpandableSectionState();
}

class _ExpandableSectionState extends State<ExpandableSection> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => setState(() => _open = !_open),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.label,
                    style: AppTextStyles.body(size: 12, weight: FontWeight.w800),
                  ),
                ),
                Text(
                  _open ? '−' : '+',
                  style: AppTextStyles.body(size: 19, weight: FontWeight.w800),
                ),
              ],
            ),
          ),
        ),
        if (_open) Padding(
          padding: const EdgeInsets.only(top: 4),
          child: widget.child,
        ),
      ],
    );
  }
}

class NoteBox extends StatelessWidget {
  final String label;
  final String text;

  const NoteBox({super.key, required this.label, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.noteBg,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: AppColors.noteBorder,
          style: BorderStyle.solid,
        ),
      ),
      child: RichText(
        text: TextSpan(
          style: AppTextStyles.noteText,
          children: [
            TextSpan(
              text: '$label ',
              style: AppTextStyles.noteText.copyWith(fontWeight: FontWeight.w700),
            ),
            TextSpan(text: text),
          ],
        ),
      ),
    );
  }
}
