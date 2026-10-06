import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'common.dart';

/// One card in a hero banner carousel. Covers every banner shape seen in the
/// screenshots: a headline with an optional coloured word, an optional
/// eyebrow pill, an optional big rate (with strike-through), a black pill
/// CTA, an optional bottom ribbon, and an optional piece of art on the right.
class PromoSlide extends StatelessWidget {
  const PromoSlide({
    super.key,
    required this.titleSpans,
    required this.ctaLabel,
    this.onCta,
    this.eyebrow,
    this.eyebrowColor,
    this.subtitle,
    this.rate,
    this.rateSuffix,
    this.strikeRate,
    this.ribbon,
    this.art,
    this.gradient,
    this.color,
    this.centered = false,
  });

  /// Headline, split into runs so one word can carry the accent colour.
  final List<TextSpan> titleSpans;
  final String ctaLabel;
  final VoidCallback? onCta;

  /// Small uppercase pill above the headline, e.g. "LIMITED TIME OFFER".
  final String? eyebrow;
  final Color? eyebrowColor;
  final String? subtitle;

  /// Large rate figure, e.g. "8.50" rendered with [rateSuffix] "YTM".
  final String? rate;
  final String? rateSuffix;
  final String? strikeRate;

  /// Full-width strip pinned to the bottom, e.g. "Best returns in it's category".
  final String? ribbon;
  final Widget? art;

  final Gradient? gradient;
  final Color? color;

  /// Centre-stacked layout used by the "EXCLUSIVE OFFER" style slide.
  final bool centered;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: color,
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: centered ? _centeredBody(context) : _splitBody(context),
            ),
          ),
          if (ribbon != null)
            Container(
              width: double.infinity,
              color: AppColors.purpleDeep,
              padding: const EdgeInsets.symmetric(vertical: 7),
              child: Text(
                ribbon!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600),
              ),
            ),
        ],
      ),
    );
  }

  Widget _splitBody(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (eyebrow != null) ...[_eyebrowPill(), const SizedBox(height: 10)],
              _title(),
              if (subtitle != null) ...[
                const SizedBox(height: 8),
                Text(subtitle!,
                    style:
                        TextStyle(color: AppColors.grey, fontSize: 13)),
              ],
              if (rate != null) ...[
                const SizedBox(height: 12),
                _rateRow(),
              ],
              const Spacer(),
              BlackPillButton(
                label: ctaLabel,
                icon: Icons.arrow_forward,
                expand: false,
                dense: true,
                onPressed:
                    onCta ?? () => showPrototypeNotice(context, ctaLabel),
              ),
            ],
          ),
        ),
        if (art != null) ...[
          const SizedBox(width: 12),
          Expanded(flex: 2, child: Center(child: art!)),
        ],
      ],
    );
  }

  Widget _centeredBody(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (eyebrow != null) ...[_eyebrowPill(), const SizedBox(height: 14)],
        if (rate != null) _rateRow(big: true),
        const SizedBox(height: 6),
        DefaultTextStyle(
          style: const TextStyle(fontSize: 15),
          textAlign: TextAlign.center,
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.purpleDeep),
              children: titleSpans,
            ),
          ),
        ),
        const SizedBox(height: 16),
        BlackPillButton(
          label: ctaLabel,
          icon: Icons.arrow_forward,
          expand: false,
          dense: true,
          onPressed: onCta ?? () => showPrototypeNotice(context, ctaLabel),
        ),
      ],
    );
  }

  Widget _eyebrowPill() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: (eyebrowColor ?? AppColors.purpleDeep).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        eyebrow!,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.6,
          color: eyebrowColor ?? AppColors.purpleDeep,
        ),
      ),
    );
  }

  Widget _title() {
    return RichText(
      text: TextSpan(
        style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
            height: 1.25),
        children: titleSpans,
      ),
    );
  }

  Widget _rateRow({bool big = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          rate!,
          style: TextStyle(
            fontSize: big ? 46 : 26,
            fontWeight: FontWeight.w800,
            fontStyle: FontStyle.italic,
            color: big ? AppColors.purpleDeep : AppColors.ink,
            height: 1,
          ),
        ),
        if (strikeRate != null) ...[
          const SizedBox(width: 6),
          Padding(
            padding: const EdgeInsets.only(bottom: 3),
            child: Text(
              strikeRate!,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFFD0453F),
                decoration: TextDecoration.lineThrough,
                decorationColor: Color(0xFFD0453F),
              ),
            ),
          ),
        ],
        if (rateSuffix != null) ...[
          const SizedBox(width: 5),
          Padding(
            padding: EdgeInsets.only(bottom: big ? 6 : 3),
            child: Text(
              rateSuffix!,
              style: TextStyle(
                fontSize: big ? 13 : 12,
                fontWeight: FontWeight.w600,
                color: AppColors.grey,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Flat stand-in for the building / product photography used in the real
/// banners — a simple facade block tinted to the slide's accent colour.
class FacadeArt extends StatelessWidget {
  const FacadeArt({super.key, required this.label, required this.tint});

  final String label;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.14),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
        border: Border.all(color: tint.withValues(alpha: 0.30)),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w800, color: tint),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: GridView.count(
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 4,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
              children: List.generate(
                12,
                (_) => DecoratedBox(
                  decoration: BoxDecoration(
                    color: tint.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
