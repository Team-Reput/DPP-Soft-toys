import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/dpp_models.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Shared pieces reused across both the mobile and desktop screen variants:
/// section title, detail list, chips, storybox, section card, footer note,
/// disclaimer, eyebrow + heading combo. Mirrors the matching CSS classes in
/// the source HTML (`.section-title`, `.detail-list`, `.chip`, `.storybox`,
/// `.section-card`, `.footer-note`, `.disclaimer`, `.eyebrow`, `.heading`).
///
/// Every size here is run through ScreenUtil (`.w`/`.h`/`.r`, and `.sp` via
/// [AppTextStyles]) so it scales with the device. Where the desktop CSS
/// (`@media(min-width:700px)` in the source "Desktop" HTML) uses visibly
/// different sizes than the mobile CSS, these widgets take a [desktop] flag
/// to switch between the two; where the desktop rules don't touch a class
/// at all, there's just one scaled size shared by both screen variants.

class SectionTitle extends StatelessWidget {
  final String text;
  final bool desktop;
  const SectionTitle(this.text, {super.key, this.desktop = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: (desktop ? 28 : 25).h,
        bottom: (desktop ? 14 : 12).h,
      ),
      child: Text(
        text,
        style: AppTextStyles.display(
          size: desktop ? 25 : 20,
          weight: FontWeight.w600,
        ),
      ),
    );
  }
}

class DetailList extends StatelessWidget {
  final List<DetailRow> rows;
  final bool desktop;
  const DetailList(this.rows, {super.key, this.desktop = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.paper,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular((desktop ? 22 : 19).r),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: List.generate(rows.length, (i) {
          final row = rows[i];
          final isLast = i == rows.length - 1;
          return Container(
            padding: EdgeInsets.symmetric(
              horizontal: (desktop ? 19 : 15).w,
              vertical: (desktop ? 17 : 13).h,
            ),
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
                  child: Text(
                    row.label,
                    style: AppTextStyles.body(
                      size: desktop ? 14 : 12,
                      color: AppColors.muted,
                    ),
                  ),
                ),
                SizedBox(width: 18.w),
                Flexible(
                  child: Text(
                    row.value,
                    style: AppTextStyles.body(
                      size: desktop ? 14 : 12,
                      weight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
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
      spacing: 7.w,
      runSpacing: 7.h,
      children: chips
          .map(
            (c) => Container(
              padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: AppColors.chipBg,
                borderRadius: BorderRadius.circular(100.r),
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
  final bool desktop;

  const StoryBox({
    super.key,
    required this.emoji,
    required this.title,
    required this.text,
    this.desktop = false,
  });

  factory StoryBox.fromContent(
    StoryBoxContent content, {
    Key? key,
    bool desktop = false,
  }) {
    return StoryBox(
      key: key,
      emoji: content.emoji,
      title: content.title,
      text: content.text,
      desktop: desktop,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: desktop ? BoxConstraints(maxWidth: 850.w) : null,
      padding: EdgeInsets.fromLTRB(
        (desktop ? 24 : 18).w,
        (desktop ? 24 : 18).h,
        (desktop ? 24 : 18).w,
        (desktop ? 24 : 20).h,
      ),
      decoration: BoxDecoration(
        color: AppColors.storyboxBg,
        borderRadius: BorderRadius.circular(23.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: TextStyle(fontSize: 29.sp)),
          SizedBox(width: 13.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.display(
                    size: desktop ? 20 : 17,
                    weight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 5.h),
                Text(
                  text,
                  style: AppTextStyles.body(
                    size: desktop ? 14 : 12,
                    color: AppColors.storyboxText,
                    height: 1.6,
                  ),
                ),
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
  final EdgeInsets? margin;
  final bool desktop;
  final double? maxWidth;

  const SectionCard({
    super.key,
    this.title,
    required this.child,
    this.margin,
    this.desktop = false,
    this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      margin: margin ?? EdgeInsets.only(top: 14.h),
      padding: EdgeInsets.symmetric(
        horizontal: (desktop ? 26 : 17).w,
        vertical: (desktop ? 23 : 17).h,
      ),
      decoration: BoxDecoration(
        color: AppColors.sectionCardBg,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular((desktop ? 23 : 22).r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title!,
              style: AppTextStyles.display(
                size: desktop ? 22 : 18,
                weight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 9.h),
          ],
          DefaultTextStyle.merge(
            style: AppTextStyles.body(
              size: desktop ? 14 : 12,
              color: AppColors.sectionCardText,
              height: 1.65,
            ),
            child: child,
          ),
        ],
      ),
    );
    if (maxWidth == null) return card;
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth!),
      child: card,
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
          padding: EdgeInsets.symmetric(vertical: 8.h),
          decoration: BoxDecoration(
            border: isLast
                ? null
                : const Border(
                    bottom: BorderSide(
                      color: AppColors.tinyRowBorder,
                      width: 1,
                    ),
                  ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(row.label, style: AppTextStyles.tinyRowLabel),
              ),
              SizedBox(width: 10.w),
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
    final labelStyle = tiny
        ? AppTextStyles.tinyRowLabel
        : AppTextStyles.detailLabel;
    final linkStyle =
        (tiny ? AppTextStyles.tinyRowValue : AppTextStyles.detailValue)
            .copyWith(
              color: AppColors.forest,
              decoration: TextDecoration.underline,
              decorationColor: AppColors.forest,
            );
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(child: Text(row.label, style: labelStyle)),
          SizedBox(width: 10.w),
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
            padding: EdgeInsets.symmetric(vertical: 8.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.label,
                    style: AppTextStyles.body(
                      size: 12,
                      weight: FontWeight.w800,
                    ),
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
        if (_open)
          Padding(
            padding: EdgeInsets.only(top: 4.h),
            child: widget.child,
          ),
      ],
    );
  }
}
