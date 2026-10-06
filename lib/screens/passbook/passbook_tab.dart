import 'package:flutter/material.dart';

import '../../logic/next_step.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../utils/formatters.dart';
import '../../widgets/common.dart';
import '../../widgets/next_step_card.dart';
import '../fd/all_banks_screen.dart';
import '../../widgets/brand_logo.dart';
import '../bonds/bond_detail_screen.dart';
import '../fd/bank_detail_screen.dart';
import '../../data/mock_data.dart';

class PassbookTab extends StatefulWidget {
  const PassbookTab({super.key, required this.appState});
  final AppState appState;

  @override
  State<PassbookTab> createState() => _PassbookTabState();
}

class _PassbookTabState extends State<PassbookTab>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController =
      TabController(length: 3, vsync: this);

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _goToTab(int i) => setState(() => _tabController.index = i);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.appState,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: AppColors.white,
          appBar: AppBar(
            titleSpacing: 20,
            title: Row(
              children: [
                const BrandLogo(size: 30),
                const SizedBox(width: 10),
                const Text('stable money',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              ],
            ),
            actions: [
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (v) => showPrototypeNotice(context, v),
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'Reports', child: Text('Reports')),
                  PopupMenuItem(value: 'Need help?', child: Text('Need help?')),
                ],
              ),
              const SizedBox(width: 8),
            ],
            bottom: TabBar(
              controller: _tabController,
              labelColor: AppColors.ink,
              unselectedLabelColor: AppColors.greyLight,
              indicatorColor: AppColors.ink,
              labelStyle: const TextStyle(fontWeight: FontWeight.w700),
              tabs: const [
                Tab(text: 'Overview'),
                Tab(text: 'FD'),
                Tab(text: 'Bonds'),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _overview(),
              _fdTab(),
              _bondsTab(),
            ],
          ),
        );
      },
    );
  }

  Widget _overview() {
    final netWorth = widget.appState.netWorth;
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFEAF6EE), Color(0xFFFFFFFF)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('STABLE NET WORTH',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.grey,
                      letterSpacing: 0.6)),
              const SizedBox(height: 6),
              Text(formatInr(netWorth),
                  style: const TextStyle(
                      fontSize: 34, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              Text(
                netWorth == 0
                    ? 'You have not invested yet'
                    : '${widget.appState.portfolio.length} active investment${widget.appState.portfolio.length == 1 ? '' : 's'}',
                style: TextStyle(color: AppColors.grey),
              ),
              // A deposit pays nothing until maturity, so without this the
              // investor has no evidence their money is doing anything.
              if (netWorth > 0) ...[
                const SizedBox(height: 12),
                Builder(builder: (context) {
                  final earned = widget.appState.portfolio
                      .fold<double>(0, (sum, i) => sum + i.earnedSoFar);
                  final soon = widget.appState.portfolio
                      .fold<double>(0, (sum, i) => sum + i.earnedByDay30);
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.hairline),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.trending_up_rounded,
                            size: 15, color: AppColors.greenInk),
                        const SizedBox(width: 8),
                        Text(
                          earned >= 1
                              ? '${formatInr(earned)} earned so far'
                              : 'About ${formatInr(soon)} earned by next month',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.ink),
                        ),
                      ],
                    ),
                  );
                }),
              ],
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  children: [
                    ListTile(
                      onTap: () => _goToTab(1),
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.cream,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.account_balance_outlined),
                      ),
                      title: const Text('FD',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                      subtitle: Text(
                          widget.appState.fdTotal == 0
                              ? 'Build a safety net'
                              : '${widget.appState.portfolio.where((i) => i.kind == InvestmentKind.fd).length} FDs booked'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(formatInr(widget.appState.fdTotal),
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700)),
                          Icon(Icons.chevron_right,
                              color: AppColors.greyLight),
                        ],
                      ),
                    ),
                    const Divider(height: 1, indent: 16, endIndent: 16),
                    ListTile(
                      onTap: () => _goToTab(2),
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.cream,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Center(
                          child: Text('12%',
                              style: TextStyle(
                                  fontWeight: FontWeight.w800, fontSize: 11)),
                        ),
                      ),
                      title: const Text('Bonds',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                      subtitle: Text(
                          widget.appState.bondTotal == 0
                              ? 'Get 9-12% fixed returns'
                              : '${widget.appState.portfolio.where((i) => i.kind == InvestmentKind.bond).length} bonds booked'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(formatInr(widget.appState.bondTotal),
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700)),
                          Icon(Icons.chevron_right,
                              color: AppColors.greyLight),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // The same next step the confirmation screen offered, so the
        // suggestion survives being tapped past once.
        ...(() {
          final next = Recommender.next(widget.appState);
          if (next == null) return <Widget>[];
          return <Widget>[
            const SizedBox(height: 28),
            const _SectionLabel('What\'s next'),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: NextStepCard(
                  appState: widget.appState, step: next, compact: true),
            ),
          ];
        })(),
        const SizedBox(height: 28),
        const _SectionLabel('Invest now'),
        const SizedBox(height: 12),
        const _InvestNowRail(),
        const SizedBox(height: 40),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _wordmarkChip('stable money'),
            const SizedBox(width: 8),
            Container(width: 1, height: 20, color: AppColors.hairline),
            const SizedBox(width: 8),
            _wordmarkChip('stable bonds'),
          ],
        ),
        const SizedBox(height: 10),
        Center(
          child: Text('Trusted by 60L+ happy users',
              style: TextStyle(color: AppColors.greyLight, fontSize: 12)),
        ),
      ],
    );
  }

  Widget _wordmarkChip(String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        BrandLogo(
            size: 22, ring: false, squareColor: AppColors.greyLight),
        const SizedBox(width: 6),
        Text(label,
            style: TextStyle(
                color: AppColors.greyLight,
                fontWeight: FontWeight.w700,
                fontSize: 13)),
      ],
    );
  }

  /// FD tab: its own net worth, an FD and an RD row, then a bank promo and
  /// the DICGC reassurance strip.
  Widget _fdTab() {
    final booked = widget.appState.portfolio
        .where((i) => i.kind == InvestmentKind.fd)
        .toList();
    final topFd = ([...MockData.banks]..sort((a, b) => b.rate.compareTo(a.rate)))
        .first;

    return ListView(
      padding: const EdgeInsets.only(bottom: 28),
      children: [
        _summaryHeader(
          label: 'FD NET WORTH',
          amount: widget.appState.fdTotal,
          rows: [
            _SummaryRow(
              icon: Icons.account_balance_outlined,
              title: 'FD',
              subtitle: 'Build a safety net',
              amount: widget.appState.fdTotal,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => AllBanksScreen(appState: widget.appState),
                ),
              ),
            ),
            _SummaryRow(
              icon: Icons.autorenew,
              title: 'RD',
              subtitle: widget.appState.rdCount == 0
                  ? 'Start a monthly deposit'
                  : '${formatInr(widget.appState.rdMonthly)} a month, running',
              amount: widget.appState.rdMonthly,
              onTap: () {
                final next = Recommender.next(widget.appState);
                if (next != null) {
                  showRecurringSheet(context, widget.appState, next);
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 20),
        _ProductPromo(
          eyebrow: 'Safe and fixed returns',
          title: 'Invest in ${topFd.name} FD',
          logoLetter: topFd.logoLetter,
          logoColor: topFd.logoColor,
          primaryValue: '${topFd.rate.toStringAsFixed(2)}%',
          primarySuffix: 'P.A.',
          secondaryValue: '₹1K',
          secondarySuffix: 'MINIMUM',
          ctaLabel: 'Book FD today',
          onCta: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) =>
                  BankDetailScreen(appState: widget.appState, bank: topFd),
            ),
          ),
        ),
        const SizedBox(height: 18),
        const _FootNote('UP TO ₹5 LAKHS INSURED BY DICGC'),
        if (booked.isNotEmpty) ...[
          const SizedBox(height: 24),
          const _SectionLabel('Your FDs'),
          const SizedBox(height: 8),
          ..._bookedCards(booked),
        ],
      ],
    );
  }

  /// Bonds tab: corporate and government split, then the featured issue.
  Widget _bondsTab() {
    final booked = widget.appState.portfolio
        .where((i) => i.kind == InvestmentKind.bond)
        .toList();
    final featured = MockData.bonds.last;

    return ListView(
      padding: const EdgeInsets.only(bottom: 28),
      children: [
        _summaryHeader(
          label: 'STABLE NET WORTH',
          amount: widget.appState.bondTotal,
          rows: [
            _SummaryRow(
              badgeText: '12%',
              title: 'Corporate',
              subtitle: 'Get interest of up to 12%',
              amount: widget.appState.bondTotal,
              onTap: () => showPrototypeNotice(context, 'Corporate bonds'),
            ),
            _SummaryRow(
              icon: Icons.account_balance_outlined,
              title: 'Government',
              subtitle: 'No TDS on payouts',
              amount: 0,
              onTap: () => showPrototypeNotice(context, 'Government bonds'),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _ProductPromo(
          eyebrow: 'Senior & Secured bonds',
          title: featured.issuer,
          logoLetter: featured.logoLetter,
          logoColor: featured.logoColor,
          chip: 'SHORT TENURE',
          primaryValue: '${featured.ytm.toStringAsFixed(2)}%',
          primarySuffix: 'YTM',
          secondaryValue: '~₹1K',
          secondarySuffix: 'MINIMUM',
          ctaLabel: 'Start investing',
          onCta: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => BondDetailScreen(
                  appState: widget.appState, bond: featured),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'By clicking on Start investing you will be redirected to the '
            'online bond platform run by Stable Broking Pvt. Ltd., regulated '
            'by SEBI, registration number INZ000314637. Investments in debt '
            'securities are subject to risks, including delay or default in '
            'payment. Read all offer-related documents carefully.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 9, color: AppColors.greyLight, height: 1.5),
          ),
        ),
        const SizedBox(height: 16),
        const _FootNote('POWERED BY STABLE BROKING PVT LTD'),
        const SizedBox(height: 24),
        const _ReferStrip(),
        if (booked.isNotEmpty) ...[
          const SizedBox(height: 24),
          const _SectionLabel('Your bonds'),
          const SizedBox(height: 8),
          ..._bookedCards(booked),
        ],
      ],
    );
  }

  Widget _summaryHeader({
    required String label,
    required double amount,
    required List<Widget> rows,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFEAF6EE), Color(0xFFFFFFFF)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.grey,
                  letterSpacing: 0.6)),
          const SizedBox(height: 6),
          Text(formatInr(amount),
              style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          if (amount == 0)
            Text('You have not invested yet',
                style: TextStyle(color: AppColors.grey)),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(children: rows),
          ),
        ],
      ),
    );
  }

  List<Widget> _bookedCards(List<BookedInvestment> items) {
    return [
      for (final inv in items)
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.hairline),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                LetterLogo(letter: inv.logoLetter, color: inv.logoColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(inv.issuerName,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 15)),
                      Text(
                          '${formatTenureMonths(inv.tenureMonths)} • ${inv.rate.toStringAsFixed(2)}%',
                          style: TextStyle(
                              fontSize: 12, color: AppColors.grey)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(formatInr(inv.principal),
                        style: const TextStyle(fontWeight: FontWeight.w800)),
                    Text(formatInr(inv.maturityValue),
                        style: TextStyle(
                            fontSize: 12, color: AppColors.green)),
                  ],
                ),
              ],
            ),
          ),
        ),
    ];
  }

}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(text,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
    );
  }
}

/// Row inside a passbook summary card: FD/RD, or Corporate/Government.
class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.onTap,
    this.icon,
    this.badgeText,
  });

  final String title;
  final String subtitle;
  final double amount;
  final VoidCallback onTap;
  final IconData? icon;
  final String? badgeText;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.cream,
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: icon != null
            ? Icon(icon, size: 20, color: AppColors.ink)
            : Text(badgeText ?? '',
                style: const TextStyle(
                    fontWeight: FontWeight.w800, fontSize: 11)),
      ),
      title: Text(title,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
      subtitle: Text(subtitle,
          style: TextStyle(fontSize: 12, color: AppColors.grey)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(formatInr(amount),
              style: const TextStyle(fontWeight: FontWeight.w700)),
          Icon(Icons.chevron_right, color: AppColors.greyLight),
        ],
      ),
    );
  }
}

/// The bordered promo card the FD and Bonds passbook tabs close with.
class _ProductPromo extends StatelessWidget {
  const _ProductPromo({
    required this.eyebrow,
    required this.title,
    required this.logoLetter,
    required this.logoColor,
    required this.primaryValue,
    required this.primarySuffix,
    required this.secondaryValue,
    required this.secondarySuffix,
    required this.ctaLabel,
    required this.onCta,
    this.chip,
  });

  final String eyebrow;
  final String title;
  final String logoLetter;
  final Color logoColor;
  final String? chip;
  final String primaryValue;
  final String primarySuffix;
  final String secondaryValue;
  final String secondarySuffix;
  final String ctaLabel;
  final VoidCallback onCta;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.hairline),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(eyebrow,
                          style: TextStyle(
                              fontSize: 13, color: AppColors.grey)),
                      const SizedBox(height: 4),
                      Text(title,
                          style: const TextStyle(
                              fontSize: 19, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                LetterLogo(letter: logoLetter, color: logoColor, size: 44),
              ],
            ),
            if (chip != null) ...[
              const SizedBox(height: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.purpleSoft,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(chip!,
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                        color: AppColors.purpleDeep)),
              ),
            ],
            const Divider(height: 26),
            Row(
              children: [
                Expanded(
                  child: _Metric(
                      value: primaryValue, suffix: primarySuffix),
                ),
                Container(width: 1, height: 28, color: AppColors.hairline),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: _Metric(
                        value: secondaryValue, suffix: secondarySuffix),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            BlackPillButton(
              label: ctaLabel,
              icon: Icons.arrow_forward,
              onPressed: onCta,
            ),
          ],
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.value, required this.suffix});
  final String value;
  final String suffix;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Flexible(
          child: Text(value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  fontStyle: FontStyle.italic)),
        ),
        const SizedBox(width: 5),
        Padding(
          padding: const EdgeInsets.only(bottom: 3),
          child: Text(suffix,
              style: TextStyle(
                  fontSize: 10,
                  letterSpacing: 0.6,
                  color: AppColors.grey,
                  fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}

/// Centred, letterspaced caption bracketed by dots, e.g.
/// "• UP TO ₹5 LAKHS INSURED BY DICGC •".
class _FootNote extends StatelessWidget {
  const _FootNote(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('• $text •',
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 11,
              letterSpacing: 0.8,
              fontWeight: FontWeight.w600,
              color: AppColors.grey)),
    );
  }
}

class _ReferStrip extends StatelessWidget {
  const _ReferStrip();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('Your bonds are earning up to 12% returns',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        Text('Refer your loved ones and get 2% extra returns',
            style: TextStyle(fontSize: 12, color: AppColors.grey)),
        const SizedBox(height: 10),
        TextButton(
          onPressed: () => showPrototypeNotice(context, 'Referral'),
          child: Text('Get 2% extra  >',
              style: TextStyle(
                  color: AppColors.purple, fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }
}

/// Horizontal rail of product prompts on the Overview tab.
class _InvestNowRail extends StatelessWidget {
  const _InvestNowRail();

  @override
  Widget build(BuildContext context) {
    final topFd =
        ([...MockData.banks]..sort((a, b) => b.rate.compareTo(a.rate))).first;
    final topBond =
        ([...MockData.bonds]..sort((a, b) => b.ytm.compareTo(a.ytm))).last;

    final cards = [
      (
        topFd.name.toUpperCase(),
        topFd.logoColor,
        "Start with India's\ntop FD",
        '${topFd.rate.toStringAsFixed(2)}',
        'P.A.',
        'Booked by 1.5L+ investors',
      ),
      (
        topBond.issuer.toUpperCase(),
        topBond.logoColor,
        'Public listed,\nA+ rated',
        '${topBond.ytm.toStringAsFixed(2)}',
        'YTM',
        '',
      ),
    ];

    return SizedBox(
      height: 128,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: cards.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final c = cards[i];
          return Container(
            width: 300,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFDF7EE),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 14,
                      height: 14,
                      decoration:
                          BoxDecoration(color: c.$2, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 7),
                    Flexible(
                      child: Text(c.$1,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(c.$3,
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              height: 1.25)),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(c.$4,
                                style: const TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFFE08A1E))),
                            const Text('%',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFFE08A1E))),
                          ],
                        ),
                        Text(c.$5,
                            style: TextStyle(
                                fontSize: 9, color: AppColors.grey)),
                      ],
                    ),
                  ],
                ),
                const Spacer(),
                if (c.$6.isNotEmpty)
                  Text(c.$6,
                      style: TextStyle(
                          fontSize: 10, color: AppColors.grey)),
              ],
            ),
          );
        },
      ),
    );
  }
}
