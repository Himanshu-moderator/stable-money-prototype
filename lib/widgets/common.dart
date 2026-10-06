import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'brand_logo.dart';

/// The black pill CTA used everywhere in the app ("Invest now", "Book",
/// "Apply now", "Claim now"...).
class BlackPillButton extends StatelessWidget {
  const BlackPillButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.expand = true,
    this.dense = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool expand;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        minimumSize: Size(expand ? double.infinity : 0, dense ? 44 : 56),
        padding: dense
            ? const EdgeInsets.symmetric(horizontal: 20)
            : const EdgeInsets.symmetric(horizontal: 24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label),
          if (icon != null) ...[
            const SizedBox(width: 8),
            Icon(icon, size: 18),
          ],
        ],
      ),
    );
  }
}

/// Small rounded avatar bearing initials/letter — used for bank/bond issuer
/// logos throughout, standing in for real brand marks.
class LetterLogo extends StatelessWidget {
  const LetterLogo({
    super.key,
    required this.letter,
    required this.color,
    this.size = 40,
  });

  final String letter;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(size * 0.28),
        border: Border.all(color: AppColors.hairline),
      ),
      alignment: Alignment.center,
      child: Text(
        letter,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: size * 0.34,
        ),
      ),
    );
  }
}

/// The regulatory / trust footer repeated across FD, Bonds and Bond-detail
/// screens: DICGC + "subsidiary of" + RBI seal.
class RegulatoryStrip extends StatelessWidget {
  const RegulatoryStrip({super.key, this.rbiOnly = false});

  final bool rbiOnly;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      color: AppColors.greenSoft,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (!rbiOnly)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('DICGC',
                    style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: AppColors.greenInk,
                        fontSize: 15)),
                Text('Deposit Insurance and Credit\nGuarantee Corporation',
                    style: TextStyle(fontSize: 9, color: AppColors.grey)),
              ],
            ),
          Text('A WHOLLY OWNED\nSUBSIDIARY OF',
              style: TextStyle(fontSize: 9, color: AppColors.grey),
              textAlign: TextAlign.center),
          const Icon(Icons.account_balance, color: Color(0xFF8A6D1F)),
          const Text('RESERVE BANK OF INDIA',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

/// "Trusted by 60+ lakh Indians" stat block, tan background, serif italic
/// tagline — appears at the bottom of both FD and Bonds tabs.
class TrustStatsFooter extends StatelessWidget {
  const TrustStatsFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.tanSoft,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      child: Column(
        children: [
          Text('Trusted by',
              style: TextStyle(color: AppColors.grey, fontSize: 14)),
          const SizedBox(height: 4),
          Text('60+ lakh Indians',
              style: AppTheme.serifItalic.copyWith(fontSize: 26)),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _StatColumn(value: '3,500+', label: 'Across cities'),
              ),
              SizedBox(
                height: 40,
                child: VerticalDivider(color: AppColors.hairline),
              ),
              Expanded(
                child: _StatColumn(value: '₹11,000+ cr', label: 'Invested'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text('Secure, Stable, Indian', style: AppTheme.serifItalic),
          const SizedBox(height: 6),
          Text('All banks on Stable Money are RBI-licensed',
              style: TextStyle(color: AppColors.grey, fontSize: 12)),
        ],
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 20,
                color: Color(0xFF8A5A2B))),
        const SizedBox(height: 2),
        Text(label,
            style: TextStyle(fontSize: 12, color: AppColors.grey)),
      ],
    );
  }
}

/// "Connect with expert" card with the call-centre-agent photo placeholder.
class ExpertConnectCard extends StatelessWidget {
  const ExpertConnectCard({
    super.key,
    this.title = 'Need help choosing\nyour first FD?',
    this.buttonLabel = 'Call now',
    this.icon = Icons.call,
  });

  final String title;
  final String buttonLabel;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Connect with expert',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.hairline),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.purpleSoft,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text('EXPERTS AVAILABLE',
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppColors.purple)),
                      ),
                      const SizedBox(height: 10),
                      Text(title,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 14),
                      BlackPillButton(
                        label: buttonLabel,
                        icon: icon,
                        expand: false,
                        dense: true,
                        onPressed: () => _showComingSoon(context),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                CircleAvatar(
                  radius: 34,
                  backgroundColor: AppColors.purpleSoft,
                  child: Icon(Icons.support_agent,
                      color: AppColors.purple, size: 34),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

void _showComingSoon(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('This is a prototype — no live call center yet.')),
  );
}

/// Shows a lightweight "not wired up in this prototype" toast, for any
/// tappable element that isn't part of the core demo flow.
void showPrototypeNotice(BuildContext context, [String? what]) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(what == null
          ? 'Not wired up in this prototype.'
          : '$what — not wired up in this prototype.'),
      duration: const Duration(seconds: 2),
    ),
  );
}

/// The 2x4 "What's on your mind?" quick-filter grid, reused verbatim
/// (per the screenshots) across the FD and Bonds tabs with different
/// icon sets.
class QuickFilterGrid extends StatelessWidget {
  const QuickFilterGrid({super.key, required this.items});

  final List<QuickFilterItem> items;

  /// Packs items into rows of 4 column-units, honouring each item's [span].
  /// On the FD tab this reproduces the screenshot layout: a double-width
  /// "RD (monthly)" tile plus two singles on row one, four singles on row two.
  List<List<QuickFilterItem>> get _rows {
    final rows = <List<QuickFilterItem>>[];
    var current = <QuickFilterItem>[];
    var used = 0;
    for (final item in items) {
      if (used + item.span > 4 && current.isNotEmpty) {
        rows.add(current);
        current = <QuickFilterItem>[];
        used = 0;
      }
      current.add(item);
      used += item.span;
    }
    if (current.isNotEmpty) rows.add(current);
    return rows;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("What's on your mind?",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 14),
          for (final row in _rows)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: SizedBox(
                height: 96,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var i = 0; i < row.length; i++) ...[
                      if (i > 0) const SizedBox(width: 8),
                      Expanded(
                        flex: row[i].span,
                        child: _QuickFilterTile(item: row[i]),
                      ),
                    ],
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class QuickFilterItem {
  const QuickFilterItem({
    required this.title,
    this.subtitle,
    required this.icon,
    this.onTap,
    this.span = 1,
  });

  final String title;
  final String? subtitle;
  final IconData icon;
  final VoidCallback? onTap;

  /// How many of the grid's 4 column-units this tile occupies.
  final int span;
}

class _QuickFilterTile extends StatelessWidget {
  const _QuickFilterTile({required this.item});
  final QuickFilterItem item;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: item.onTap ?? () => showPrototypeNotice(context, item.title),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.hairline),
          borderRadius: BorderRadius.circular(14),
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.title,
                maxLines: 2,
                style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    height: 1.15)),
            if (item.subtitle != null) ...[
              const SizedBox(height: 2),
              Text(item.subtitle!,
                  maxLines: 2,
                  style: TextStyle(fontSize: 9, color: AppColors.grey)),
            ],
            const Spacer(),
            Align(
              alignment: Alignment.bottomRight,
              child: Icon(item.icon, color: AppColors.purpleTile, size: 22),
            ),
          ],
        ),
      ),
    );
  }
}

/// Small dot pagination indicator for the hero carousels.
class CarouselDots extends StatelessWidget {
  const CarouselDots({super.key, required this.count, required this.index});
  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = i == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: active ? 18 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: active ? AppColors.ctaFill : AppColors.hairline,
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }
}

/// Top app header repeated on every tab: logo + wordmark, trailing actions.
class BrandHeader extends StatelessWidget implements PreferredSizeWidget {
  const BrandHeader({
    super.key,
    this.wordmark = 'stable money',
    this.trailing,
  });

  final String wordmark;
  final List<Widget>? trailing;

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      titleSpacing: 20,
      title: Row(
        children: [
          const BrandLogo(size: 30),
          const SizedBox(width: 10),
          Text(wordmark,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        ],
      ),
      actions: trailing,
    );
  }
}

/// Green "RATE INCREASED" chip used against banks whose rates recently rose.
class RateIncreasedChip extends StatelessWidget {
  const RateIncreasedChip({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.greenSoft,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.arrow_upward, size: 10, color: AppColors.greenInk),
          const SizedBox(width: 2),
          Text('RATE INCREASED',
              style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: AppColors.greenInk)),
        ],
      ),
    );
  }
}
