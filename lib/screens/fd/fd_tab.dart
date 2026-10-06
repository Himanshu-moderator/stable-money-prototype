import 'package:flutter/material.dart';

import '../../data/mock_data.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../utils/finance.dart';
import '../../utils/formatters.dart';
import '../../widgets/bank_tile.dart';
import '../../widgets/common.dart';
import '../../widgets/hero_carousel.dart';
import '../fd_card/fd_card_tab.dart';
import 'all_banks_screen.dart';
import 'bank_detail_screen.dart';
import '../../widgets/brand_logo.dart';
import '../../widgets/promo_slide.dart';

class FdTab extends StatefulWidget {
  const FdTab({super.key, required this.appState});
  final AppState appState;

  @override
  State<FdTab> createState() => _FdTabState();
}

class _FdTabState extends State<FdTab> {
  final _amountController = TextEditingController(text: '100000');
  String _tenureFilter = '2to3';

  double get _amount => double.tryParse(_amountController.text) ?? 100000;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  List<FdBank> get _filteredTop3 {
    Iterable<FdBank> list = MockData.banks;
    switch (_tenureFilter) {
      case 'below2':
        list = list.where((b) => b.tenureMonths < 24);
        break;
      case '2to3':
        list = list.where((b) => b.tenureMonths >= 24 && b.tenureMonths <= 36);
        break;
      case 'above3':
        list = list.where((b) => b.tenureMonths > 36);
        break;
    }
    final sorted = list.toList()..sort((a, b) => b.rate.compareTo(a.rate));
    return sorted.take(3).toList();
  }

  @override
  Widget build(BuildContext context) {
    // "Most booked" is a curated popularity order, not a rate ranking, so
    // the list is rendered in the order MockData stores it.
    final mostBooked = MockData.banks;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        titleSpacing: 20,
        title: Row(
          children: [
            const BrandLogo(size: 30),
            const SizedBox(width: 10),
            const Text('stable money',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 10),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFBEFD8),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text('TRIAL\nFD',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFB4791E),
                    height: 1.1)),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              backgroundColor: AppColors.cream,
              child: IconButton(
                icon: Icon(Icons.call_outlined,
                    size: 18, color: AppColors.ink),
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
            const QuickFilterItem(
              title: 'RD (monthly)',
              subtitle: 'Start with ₹1000, Save monthly.',
              icon: Icons.autorenew,
              span: 2,
            ),
            const QuickFilterItem(title: 'High returns', icon: Icons.trending_up),
            QuickFilterItem(
              title: 'FD-backed card',
              icon: Icons.credit_card,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => FdCardTab(appState: widget.appState),
                ),
              ),
            ),
            const QuickFilterItem(
                title: 'No penalty withdrawal', icon: Icons.verified_outlined),
            const QuickFilterItem(title: 'Monthly payouts', icon: Icons.payments_outlined),
            const QuickFilterItem(title: 'Withdraw instantly', icon: Icons.bolt),
            QuickFilterItem(
              title: 'View all FDs',
              icon: Icons.grid_view_rounded,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => AllBanksScreen(appState: widget.appState),
                ),
              ),
            ),
          ]),
          const SizedBox(height: 22),
          _kbcBanner(),
          const SizedBox(height: 28),
          _calculatorSection(),
          const SizedBox(height: 12),
          ..._filteredTop3.map((b) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: BankTile(
                  bank: b,
                  onTap: () => _openBank(context, b),
                ),
              )),
          const SizedBox(height: 8),
          Center(
            child: TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => AllBanksScreen(appState: widget.appState),
                ),
              ),
              child: Text('View more FDs',
                  style: TextStyle(
                      color: AppColors.ink,
                      decoration: TextDecoration.underline,
                      fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Most booked banks and NBFCs',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.verified, size: 16, color: AppColors.green),
                    const SizedBox(width: 6),
                    Text('Preferred by Stable Money investors',
                        style:
                            TextStyle(fontSize: 12, color: AppColors.grey)),
                  ],
                ),
                const SizedBox(height: 8),
                ...mostBooked.map((b) => BankTile(
                      bank: b,
                      onTap: () => _openBank(context, b),
                    )),
                const SizedBox(height: 12),
                BlackPillButton(
                  label: 'View all FDs',
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => AllBanksScreen(appState: widget.appState),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          _protectionSection(),
          const SizedBox(height: 28),
          const ExpertConnectCard(),
          const SizedBox(height: 28),
          const TrustStatsFooter(),
        ],
      ),
    );
  }

  void _openBank(BuildContext context, FdBank bank) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BankDetailScreen(appState: widget.appState, bank: bank),
      ),
    );
  }

  /// Eight banners, matching the dot count on the FD home screen. The first
  /// two are transcribed from the screenshots; the rest are built from
  /// features the app demonstrably has (senior rates, RD, the FD-backed
  /// card, penalty-free withdrawal, monthly payouts, referrals) since the
  /// carousel could not be captured slide by slide.
  List<Widget> _heroSlides(BuildContext context) {
    void openAllFds() => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => AllBanksScreen(appState: widget.appState),
          ),
        );

    return [
      PromoSlide(
        gradient: const LinearGradient(
          colors: [Color(0xFFF7F4EC), Color(0xFFFDFCF8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        eyebrow: 'PAYDAY IS HERE',
        eyebrowColor: const Color(0xFF7A7A33),
        titleSpans: const [
          TextSpan(text: 'Salary just came in?\nMake it work harder'),
        ],
        subtitle: 'Move your savings to an FD',
        rate: '8.25%',
        rateSuffix: 'P.A.',
        ctaLabel: 'Invest now',
        onCta: openAllFds,
        art: const FacadeArt(label: 'FIXED DEPOSIT', tint: Color(0xFFB8901F)),
      ),
      _rateHeroSlide(context),
      _voucherHeroSlide(context),
      PromoSlide(
        gradient: const LinearGradient(
          colors: [Color(0xFFEFF6EE), Color(0xFFFDFCF8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        eyebrow: 'SENIOR CITIZEN',
        eyebrowColor: AppColors.green,
        titleSpans: const [TextSpan(text: 'Extra 0.50%\nfor seniors')],
        subtitle: 'Senior citizens earn a higher rate on the same tenure.',
        rate: '8.75%',
        rateSuffix: 'p.a.',
        ctaLabel: 'Check rates',
        onCta: openAllFds,
      ),
      PromoSlide(
        color: AppColors.purpleSoft,
        eyebrow: 'RECURRING DEPOSIT',
        titleSpans: const [TextSpan(text: 'Save monthly,\nstart with ₹1000')],
        subtitle: 'Build the habit without locking a lump sum.',
        ctaLabel: 'Start an RD',
      ),
      PromoSlide(
        gradient: const LinearGradient(
          colors: [Color(0xFF241B3C), Color(0xFF4B2FB0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        eyebrow: 'FD-BACKED CARD',
        eyebrowColor: Colors.white,
        titleSpans: const [
          TextSpan(
            text: 'A credit card\nagainst your FD',
            style: TextStyle(color: Colors.white),
          ),
        ],
        subtitle: 'No income proof. Your deposit keeps earning.',
        ctaLabel: 'Know more',
      ),
      PromoSlide(
        color: AppColors.blueSoft,
        eyebrow: 'ZERO PENALTY',
        eyebrowColor: const Color(0xFF1F5FA8),
        titleSpans: const [TextSpan(text: 'Withdraw early,\nkeep your interest')],
        subtitle: 'Selected banks charge no premature-withdrawal penalty.',
        ctaLabel: 'See these FDs',
        onCta: openAllFds,
      ),
      PromoSlide(
        color: AppColors.tanSoft,
        eyebrow: 'MONTHLY PAYOUT',
        eyebrowColor: const Color(0xFF8A5A2B),
        titleSpans: const [TextSpan(text: 'Interest credited\nevery month')],
        subtitle: 'Turn a deposit into a monthly income stream.',
        ctaLabel: 'Explore payouts',
        onCta: openAllFds,
      ),
      PromoSlide(
        color: AppColors.pinkSoft,
        eyebrow: 'REFER & EARN',
        eyebrowColor: const Color(0xFFB23A4A),
        titleSpans: const [TextSpan(text: 'Invite friends,\nearn rewards')],
        subtitle: 'Both of you get rewarded on their first booking.',
        ctaLabel: 'Invite now',
      ),
    ];
  }

  Widget _rateHeroSlide(BuildContext context) {
    final top4 = ([...MockData.banks]..sort((a, b) => a.rate.compareTo(b.rate)))
        .skip(MockData.banks.length - 4);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF6F0FB), Color(0xFFFDFBF7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              style: TextStyle(
                  fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.ink),
              children: [
                const TextSpan(text: "India's highest\n"),
                TextSpan(
                    text: 'FD',
                    style: TextStyle(color: AppColors.purple)),
                const TextSpan(text: ' rates'),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text('Choose your FD and start earning up to ${top4.last.rate}% p.a.',
              style: TextStyle(color: AppColors.grey, fontSize: 13)),
          const SizedBox(height: 14),
          BlackPillButton(
            label: 'Invest now',
            icon: Icons.arrow_forward,
            expand: false,
            dense: true,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => AllBanksScreen(appState: widget.appState),
              ),
            ),
          ),
          const Spacer(),
          Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              height: 90,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: top4
                    .map((b) => Padding(
                          padding: const EdgeInsets.only(left: 6),
                          child: Container(
                            width: 26,
                            height: 30 + (b.rate - 7) * 14,
                            decoration: BoxDecoration(
                              color: b.logoColor,
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _voucherHeroSlide(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.pinkSoft,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text('LIMITED TIME OFFER',
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFB23A4A))),
          ),
          const SizedBox(height: 10),
          const Text('Book an FD today\nand claim ₹100',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text('Only applicable on first FD',
              style: TextStyle(fontSize: 12, color: AppColors.grey)),
          const Spacer(),
          BlackPillButton(
            label: 'Claim now',
            icon: Icons.arrow_forward,
            expand: false,
            dense: true,
            onPressed: () => showPrototypeNotice(context, '₹100 voucher'),
          ),
        ],
      ),
    );
  }

  Widget _kbcBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2E0F3A),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 22,
            backgroundColor: Color(0xFF4A1F5C),
            child: Icon(Icons.emoji_events, color: Color(0xFFE8C468)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: const TextSpan(
                style: TextStyle(color: Colors.white, fontSize: 13),
                children: [
                  TextSpan(text: 'Get a chance to be\n'),
                  TextSpan(
                      text: 'ON KBC HOTSEAT ',
                      style: TextStyle(
                          color: Color(0xFFE8C468), fontWeight: FontWeight.w800)),
                  TextSpan(text: 'with Amitabh Bachchan'),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () => showPrototypeNotice(context, 'KBC promo'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE8C468),
              foregroundColor: AppColors.onLightSurface,
              minimumSize: const Size(0, 40),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
            ),
            child: const Text('Participate now',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _calculatorSection() {
    final tenureMonthsForFilter = switch (_tenureFilter) {
      'below2' => 18,
      '2to3' => 30,
      'above3' => 42,
      _ => 30,
    };
    final maturity = computeMaturity(
      principal: _amount,
      ratePercent: _filteredTop3.isEmpty ? 8 : _filteredTop3.first.rate,
      tenureMonths: tenureMonthsForFilter,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Calculate FD returns',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              Row(
                children: [
                  Text('Senior rate', style: TextStyle(fontSize: 12, color: AppColors.grey)),
                  Switch(
                    value: false,
                    onChanged: (_) => showPrototypeNotice(context, 'Senior rate'),
                    activeColor: AppColors.purple,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              labelText: 'Investment amount',
              prefixText: '₹ ',
            ),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _tenureChip('Any tenure', 'any'),
              const SizedBox(width: 8),
              _tenureChip('Below 2 years', 'below2'),
              const SizedBox(width: 8),
              _tenureChip('2 to 3 years', '2to3', popular: true),
              const SizedBox(width: 8),
              _tenureChip('Above 3 years', 'above3'),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Top 3 FDs',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              Text('Tenure: low to high',
                  style: TextStyle(fontSize: 12, color: AppColors.grey)),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Estimated maturity at top rate: ${formatInr(maturity)}',
            style: TextStyle(fontSize: 12, color: AppColors.grey),
          ),
        ],
      ),
    );
  }

  Widget _tenureChip(String label, String value, {bool popular = false}) {
    final selected = _tenureFilter == value;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _tenureFilter = value),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.ctaFill : AppColors.white,
            border: Border.all(
                color: selected ? AppColors.ctaFill : AppColors.hairline),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              if (popular)
                Text('POPULAR',
                    style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                        // On the selected chip this sits on ctaFill, which
                        // inverts, so the green has to invert with it.
                        color: selected
                            ? (AppColors.isDark
                                ? const Color(0xFF1B6B39)
                                : const Color(0xFF6FE0AC))
                            : AppColors.greenInk)),
              Text(label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: selected ? AppColors.onCta : AppColors.ink)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _protectionSection() {
    final cards = [
      ('Your FDs are insured up to ₹5 lakh', "Your bank fixed deposits are insured by RBI's DICGC", Icons.shield_outlined),
      ('Small finance banks are RBI regulated', 'RBI-approved banks with same safety as big nationalised banks', Icons.account_balance_outlined),
      ('Money goes direct to bank', "Stable Money doesn't keep your money", Icons.savings_outlined),
      ('Earn up to 1.5% higher returns', 'Higher returns, with similar safety as large nationalised banks', Icons.trending_up),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text('How is your FD protected?', style: AppTheme.serifHeading),
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
        const RegulatoryStrip(),
      ],
    );
  }
}
