import 'package:flutter/material.dart';

import '../../data/mock_data.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../utils/formatters.dart';
import '../../widgets/common.dart';
import '../../widgets/hero_carousel.dart';
import 'bond_detail_screen.dart';
import '../../widgets/brand_logo.dart';
import '../../widgets/promo_slide.dart';

class BondsTab extends StatefulWidget {
  const BondsTab({super.key, required this.appState});
  final AppState appState;

  @override
  State<BondsTab> createState() => _BondsTabState();
}

class _BondsTabState extends State<BondsTab> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        titleSpacing: 20,
        title: Row(
          children: [
            const BrandLogo(size: 30),
            const SizedBox(width: 10),
            const Text('stable bonds',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 10),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.ctaFill,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text('NEW TO\nBONDS?',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.1,
                    fontStyle: FontStyle.italic)),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              backgroundColor: AppColors.cream,
              child: IconButton(
                icon: Icon(Icons.call_outlined, size: 18, color: AppColors.ink),
                onPressed: () => showPrototypeNotice(context, 'Call support'),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          HeroCarousel(height: 300, slides: _heroSlides(context)),
          const SizedBox(height: 22),
          QuickFilterGrid(items: [
            const QuickFilterItem(title: 'Short term', icon: Icons.bolt),
            const QuickFilterItem(title: 'High returns', icon: Icons.trending_up),
            const QuickFilterItem(title: 'Monthly payouts', icon: Icons.payments_outlined),
            const QuickFilterItem(title: 'Few units in stock', icon: Icons.timer_outlined),
            const QuickFilterItem(title: 'Under ₹10,000', icon: Icons.paid_outlined),
            const QuickFilterItem(title: 'Public listed', icon: Icons.fact_check_outlined),
            const QuickFilterItem(title: 'Top rated bonds', icon: Icons.workspace_premium_outlined),
            QuickFilterItem(
              title: 'View all bonds',
              icon: Icons.grid_view_rounded,
              onTap: () => showPrototypeNotice(context, 'Bonds catalogue'),
            ),
          ]),
          const SizedBox(height: 22),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.hairline),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Icon(Icons.search, color: AppColors.grey),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text('Search all bonds',
                        style: TextStyle(color: AppColors.grey)),
                  ),
                  ...MockData.bonds.take(4).map((b) => Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: CircleAvatar(
                            radius: 12,
                            backgroundColor: b.logoColor,
                            child: Text(b.logoLetter,
                                style: const TextStyle(
                                    fontSize: 9, color: Colors.white))),
                      )),
                  const SizedBox(width: 4),
                  Icon(Icons.chevron_right, size: 18, color: AppColors.greyLight),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Popular Bonds for you',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.verified, size: 16, color: AppColors.green),
                    const SizedBox(width: 6),
                    Text('No lock-in, zero exit fees',
                        style: TextStyle(fontSize: 12, color: AppColors.grey)),
                  ],
                ),
                const SizedBox(height: 14),
                ...MockData.bonds.map((b) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _BondCard(
                        bond: b,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => BondDetailScreen(
                                appState: widget.appState, bond: b),
                          ),
                        ),
                      ),
                    )),
                BlackPillButton(
                  label: 'View all',
                  onPressed: () => showPrototypeNotice(context, 'Bonds catalogue'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Bond rates at a glance',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.hairline),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Container(
                        color: AppColors.cream,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        child: Row(
                          children: [
                            Expanded(
                                flex: 3,
                                child: Text('TENURE',
                                    style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.grey))),
                            Expanded(
                                flex: 2,
                                child: Text('YTM',
                                    style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.grey))),
                            Expanded(
                                flex: 3,
                                child: Text('BONDS',
                                    style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.grey))),
                          ],
                        ),
                      ),
                      for (final row in MockData.bondRateGlance)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                          child: Row(
                            children: [
                              Expanded(
                                  flex: 3,
                                  child: Text(row['tenure']!,
                                      style: const TextStyle(fontSize: 13))),
                              Expanded(
                                  flex: 2,
                                  child: Text(row['ytm']!,
                                      style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w800))),
                              Expanded(
                                  flex: 3,
                                  child: Text(row['name']!,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 13))),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          _whyInvestSection(),
          const SizedBox(height: 24),
          _videoPlaceholder(context),
          const SizedBox(height: 28),
          const ExpertConnectCard(
            title: 'Speak to our expert\nfor any help required',
            buttonLabel: 'Get started',
            icon: Icons.arrow_forward,
          ),
          const SizedBox(height: 28),
          _qaSection(),
          const SizedBox(height: 24),
          _footer(),
        ],
      ),
    );
  }

  /// Seven banners, matching the dot count on the Bonds home screen. The
  /// payday-offer and exclusive-offer slides are transcribed from the
  /// updated screenshots; the rest are built from filters the tab actually
  /// exposes (under ₹10,000, monthly payouts, top-rated) plus the bonds
  /// webinar the app promotes. Issuers are read off the live shelf rather
  /// than named literally, so a change to MockData.bonds can't strand a
  /// slide on a delisted issue.
  List<Widget> _heroSlides(BuildContext context) {
    final headline = MockData.bonds.first;

    return [
      PromoSlide(
        color: AppColors.white,
        centered: true,
        eyebrow: 'PAYDAY OFFER',
        eyebrowColor: AppColors.green,
        rate: '0.25%',
        rateSuffix: 'UPTO',
        titleSpans: [
          TextSpan(text: '+ Additional YTM p.a. +\n'),
          TextSpan(
            text: 'Additional returns via brokerage waiver',
            style: TextStyle(fontSize: 11, color: AppColors.grey),
          ),
        ],
        ctaLabel: 'Invest now',
        ribbon: 'Valid till tomorrow',
      ),
      _offerSlide(context),
      _adaniSlide(context),
      PromoSlide(
        color: AppColors.pinkSoft,
        titleSpans: const [
          TextSpan(text: 'Backed by '),
          TextSpan(
              text: 'gold loans,\n',
              style: TextStyle(fontWeight: FontWeight.w800)),
          TextSpan(text: 'Start with ₹10K'),
        ],
        subtitle: 'Withdraw anytime. Zero exit fees.',
        rate: '${headline.ytm.toStringAsFixed(2)}%',
        strikeRate: headline.strikethroughYtm == null
            ? null
            : '${headline.strikethroughYtm!.toStringAsFixed(2)}%',
        rateSuffix: 'YTM',
        ctaLabel: 'Invest now',
        art: FacadeArt(label: headline.issuer, tint: headline.logoColor),
      ),
      PromoSlide(
        color: AppColors.purpleSoft,
        eyebrow: 'LOW TICKET',
        titleSpans: [TextSpan(text: 'Start investing\nunder ₹10,000')],
        subtitle: 'Fixed-income exposure without a large commitment.',
        ctaLabel: 'Browse bonds',
      ),
      PromoSlide(
        color: AppColors.tanSoft,
        eyebrow: 'MONTHLY PAYOUT',
        eyebrowColor: Color(0xFF8A5A2B),
        titleSpans: [TextSpan(text: 'Interest in your\naccount monthly')],
        subtitle: 'Pick bonds that pay out every month, not at maturity.',
        ctaLabel: 'See payout bonds',
      ),
      PromoSlide(
        color: AppColors.greenSoft,
        eyebrow: 'TOP RATED',
        eyebrowColor: AppColors.green,
        titleSpans: [TextSpan(text: 'AAA and AA\nrated bonds')],
        subtitle: 'Higher-rated issuers, lower credit risk.',
        ctaLabel: 'View top rated',
      ),
      PromoSlide(
        color: Color(0xFFF6F7DC),
        eyebrow: 'WEBINAR • SATURDAY 11 AM',
        eyebrowColor: Color(0xFF5F6B12),
        titleSpans: [
          TextSpan(text: 'Invest in '),
          TextSpan(text: 'Bonds\n', style: TextStyle(color: AppColors.green)),
          TextSpan(text: 'with confidence'),
        ],
        subtitle: '30 minutes live session and detailed Q&A.',
        ctaLabel: 'Register now',
      ),
    ];
  }

  Widget _offerSlide(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFBF1E1), Color(0xFFFFFFFF)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.purpleSoft,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text('EXCLUSIVE OFFER',
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: AppColors.purple)),
          ),
          const SizedBox(height: 14),
          RichText(
            text: TextSpan(
              style: TextStyle(
                  color: AppColors.purple,
                  fontWeight: FontWeight.w800,
                  fontSize: 44),
              children: [
                TextSpan(text: '12.00'),
                TextSpan(text: '%', style: TextStyle(fontSize: 22)),
              ],
            ),
          ),
          Text('YTM', style: TextStyle(color: AppColors.grey)),
          const SizedBox(height: 6),
          Text('✦  A- Rated  ✦',
              style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.purple)),
          const SizedBox(height: 14),
          BlackPillButton(
            label: 'Invest now',
            icon: Icons.arrow_forward,
            expand: false,
            dense: true,
            onPressed: () => showPrototypeNotice(context, 'Bonds catalogue'),
          ),
        ],
      ),
    );
  }

  Widget _adaniSlide(BuildContext context) {
    // Shortest-tenure issue currently on the shelf.
    final adani = MockData.bonds.reduce(
        (a, b) => a.tenureLabel.length <= b.tenureLabel.length ? a : b);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.blueSoft,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('3 months tenure,\nPublic listed',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text('Withdraw anytime. Zero exit fees.',
              style: TextStyle(fontSize: 12, color: AppColors.grey)),
          const SizedBox(height: 10),
          Text('${adani.ytm}% YTM',
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  fontStyle: FontStyle.italic)),
          const Spacer(),
          BlackPillButton(
            label: 'Invest now',
            icon: Icons.arrow_forward,
            expand: false,
            dense: true,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => BondDetailScreen(appState: widget.appState, bond: adani),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _whyInvestSection() {
    final cards = [
      ('Stable Bonds is SEBI registered', 'Transparency in every bond transaction', Icons.verified_user_outlined),
      ('Sell anytime, no lock-in', 'Withdraw before maturity, subject to liquidity', Icons.swap_horiz),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text('Why invest with Stable Bonds?',
              style: AppTheme.serifItalic.copyWith(
                  color: const Color(0xFF8A5A2B), fontSize: 22)),
        ),
        const SizedBox(height: 12),
        HeroCarousel(
          height: 190,
          viewportFraction: 0.82,
          slides: cards
              .map((c) => Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      border: Border.all(color: AppColors.hairline),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(c.$1,
                            style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 6),
                        Text(c.$2,
                            style: TextStyle(
                                fontSize: 12, color: AppColors.grey)),
                        const Spacer(),
                        Icon(c.$3, color: AppColors.purple),
                      ],
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              _StatChip(value: '1L+ bonds', label: 'booked'),
              _StatChip(value: '₹2,500 Cr+', label: 'invested'),
              _StatChip(value: '₹160 Cr+', label: 'paid to users'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _videoPlaceholder(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('What are bonds?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => showPrototypeNotice(context, 'Video playback'),
            child: AspectRatio(
              aspectRatio: 1,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF23303A),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Center(
                  child: Icon(Icons.play_circle_fill,
                      color: Colors.white70, size: 56),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _qaSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Questions and Answers',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.hairline),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                for (var i = 0; i < MockData.bondFaqs.length; i++) ...[
                  if (i > 0) const Divider(height: 1),
                  Theme(
                    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      initiallyExpanded: i == 0,
                      title: Text(MockData.bondFaqs[i]['q']!,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 15)),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text('${MockData.bondFaqs[i]['name']} asks:',
                            style: TextStyle(
                                fontSize: 12, color: AppColors.grey)),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: Text(MockData.bondFaqs[i]['a']!,
                              style: TextStyle(
                                  color: AppColors.grey, height: 1.4)),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: TextButton(
              onPressed: () => showPrototypeNotice(context, 'All Q&A'),
              child: Text('View all questions >',
                  style: TextStyle(
                      color: AppColors.ink,
                      decoration: TextDecoration.underline)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _footer() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            BrandLogo(
                size: 26, ring: false, squareColor: AppColors.greyLight),
            const SizedBox(width: 8),
            Text('stable bonds',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.greyLight)),
          ],
        ),
        const SizedBox(height: 12),
        Text('Stable Broking Private Limited',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.grey, fontSize: 12)),
        const SizedBox(height: 6),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            'SEBI registration number - INZ000314637 | NSE member code - 90363 | BSE member code - 6829 (Inactive) | DP number INDP7912025',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.greyLight, fontSize: 10),
          ),
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, size: 12, color: AppColors.gold),
            const SizedBox(width: 4),
            Text(value,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
          ],
        ),
        Text(label, style: TextStyle(fontSize: 11, color: AppColors.grey)),
      ],
    );
  }
}

class _BondCard extends StatelessWidget {
  const _BondCard({required this.bond, required this.onTap});
  final BondOffer bond;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.hairline),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                LetterLogo(letter: bond.logoLetter, color: bond.logoColor, size: 32),
                const SizedBox(width: 10),
                if (bond.rateDropping)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.pinkSoft,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text('RATE DROPPING TONIGHT',
                        style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFB23A4A))),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('${bond.ytm.toStringAsFixed(2)}%',
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.w800)),
                const SizedBox(width: 6),
                if (bond.strikethroughYtm != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: Text(
                      '${bond.strikethroughYtm!.toStringAsFixed(2)}%',
                      style: TextStyle(
                          color: AppColors.greyLight,
                          decoration: TextDecoration.lineThrough,
                          fontSize: 13),
                    ),
                  ),
                const SizedBox(width: 4),
                Padding(
                  padding: EdgeInsets.only(bottom: 5),
                  child: Text('YTM',
                      style: TextStyle(color: AppColors.grey, fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text('${bond.tenureLabel} • ${bond.title}',
                style: TextStyle(color: AppColors.grey, fontSize: 13)),
            const Divider(height: 24),
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Min', style: TextStyle(fontSize: 11, color: AppColors.grey)),
                    Text(formatInr(bond.minInvestment),
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: bond.percentSold / 100,
                          minHeight: 4,
                          backgroundColor: AppColors.hairline,
                          color: const Color(0xFFE0442C),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text('${bond.percentSold}% sold',
                          style: TextStyle(
                              fontSize: 11, color: AppColors.grey)),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                BlackPillButton(
                  label: 'Know more',
                  expand: false,
                  dense: true,
                  onPressed: onTap,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
