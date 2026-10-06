import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/mock_data.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../utils/formatters.dart';
import '../../widgets/branch_frontage.dart';
import '../../widgets/common.dart';
import '../../widgets/trust_banner.dart';
import '../booking/amount_tenure_screen.dart';
import '../booking/booking_args.dart';
import '../fd/bank_detail_screen.dart';

/// Bond page. Deliberately the bank page's sibling rather than its twin:
/// same rhythm of header, banners, the investment itself, then alternatives,
/// but the middle is built around units, payout schedule and sell-through
/// rather than a tenure ladder, because that is what differs about a bond.
class BondDetailScreen extends StatefulWidget {
  const BondDetailScreen({
    super.key,
    required this.appState,
    required this.bond,
  });

  final AppState appState;
  final BondOffer bond;

  @override
  State<BondDetailScreen> createState() => _BondDetailScreenState();
}

class _BondDetailScreenState extends State<BondDetailScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 2, vsync: this);
  late final _amountController =
      TextEditingController(text: widget.bond.minInvestment.toString());

  int _tabIndex = 0;
  bool _yieldHighLow = true;
  bool _securedOnly = false;

  double get _amount => double.tryParse(_amountController.text.trim()) ?? 0;
  bool get _valid => _amount >= widget.bond.minInvestment;

  int get _units =>
      widget.bond.faceValue <= 0 ? 0 : (_amount / widget.bond.faceValue).floor();

  /// Rough months implied by labels like "1Y 8M 12D", "28D", "3M 1D".
  int get _months {
    final l = widget.bond.tenureLabel;
    final y = RegExp(r'(\d+)Y').firstMatch(l);
    final m = RegExp(r'(\d+)M').firstMatch(l);
    final d = RegExp(r'(\d+)D').firstMatch(l);
    var total = 0;
    if (y != null) total += int.parse(y.group(1)!) * 12;
    if (m != null) total += int.parse(m.group(1)!);
    if (y == null && m == null && d != null) {
      total = (int.parse(d.group(1)!) / 30).ceil();
    }
    return total == 0 ? 1 : total;
  }

  double get _payoutTotal =>
      _amount * (1 + (widget.bond.ytm / 100) * (_months / 12));

  @override
  void dispose() {
    _tabs.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bond = widget.bond;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: ListView(
        padding: const EdgeInsets.only(bottom: 28),
        children: [
          _IssuerHeader(bond: bond),
          const SizedBox(height: 20),
          BondTrustBanner(bond: bond),
          const SizedBox(height: 30),
          _investment(bond),
          const SizedBox(height: 30),
          _terms(bond),
          const SizedBox(height: 30),
          _alternatives(),
        ],
      ),
      bottomNavigationBar: _bar(bond),
    );
  }

  Widget _investment(BondOffer bond) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _Title('How much to put in'),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.hairline),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('INVESTMENT AMOUNT',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                        color: AppColors.grey)),
                const SizedBox(height: 6),
                TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (_) => setState(() {}),
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.w800),
                  decoration: const InputDecoration(prefixText: '₹  '),
                ),
                if (!_valid)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                        'Minimum is ${formatInr(bond.minInvestment)}',
                        style: TextStyle(
                            color: AppColors.danger, fontSize: 12)),
                  ),
                if (_valid) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.greenSoft,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _Fig(
                              label: 'Units',
                              value: '$_units'),
                        ),
                        Expanded(
                          child: _Fig(
                              label: bond.payout == 'Monthly'
                                  ? 'Every month'
                                  : 'You receive',
                              value: bond.payout == 'Monthly'
                                  ? formatInr(
                                      _amount * (bond.ytm / 100) / 12)
                                  : formatInr(_payoutTotal),
                              accent: true),
                        ),
                        Expanded(
                          child: _Fig(
                              label: 'Total back',
                              value: formatInr(_payoutTotal)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  _PayoutTimeline(
                    monthly: bond.payout == 'Monthly',
                    months: _months,
                    label: bond.tenureLabel,
                  ),
                ],
                const SizedBox(height: 16),
                _SellThrough(percent: bond.percentSold),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _terms(BondOffer bond) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _Title('The terms, plainly'),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            decoration: BoxDecoration(
              color: AppColors.cream,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.hairline),
            ),
            child: Column(
              children: [
                _Term(label: 'Yield to maturity',
                    value: '${bond.ytm.toStringAsFixed(2)}%'),
                _Term(label: 'Matures on', value: bond.maturityOn),
                _Term(label: 'Interest paid', value: bond.payout),
                _Term(label: 'Credit rating', value: bond.rating),
                _Term(
                    label: 'Security',
                    value: bond.secured ? 'Secured' : 'Unsecured',
                    note: bond.secured
                        ? 'Ranks ahead of unsecured creditors'
                        : 'No collateral behind this issue'),
                _Term(label: 'Face value per unit',
                    value: formatInr(bond.faceValue)),
                const _Term(
                  label: 'Deposit insurance',
                  value: 'Not applicable',
                  note: 'Bonds are not covered by DICGC. Repayment depends '
                      'on the issuer',
                  danger: true,
                  last: true,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _alternatives() {
    final sign = _yieldHighLow ? -1 : 1;
    final bonds = MockData.bonds
        .where((b) => b.issuer != widget.bond.issuer)
        .where((b) => !_securedOnly || b.secured)
        .toList()
      ..sort((a, b) => sign * a.ytm.compareTo(b.ytm));
    final banks = MockData.banks
        .where((b) => !_securedOnly || b.insured)
        .toList()
      ..sort((a, b) => sign * a.rate.compareTo(b.rate));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              const Text('All other options',
                  style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const Spacer(),
              _HeadAction(
                icon: Icons.swap_vert,
                label: 'Sort',
                active: !_yieldHighLow,
                onTap: _pickSort,
              ),
              const SizedBox(width: 8),
              _HeadAction(
                icon: Icons.tune,
                label: 'Filter',
                active: _securedOnly,
                onTap: _pickFilter,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        TabBar(
          controller: _tabs,
          labelColor: AppColors.purple,
          unselectedLabelColor: AppColors.grey,
          indicatorColor: AppColors.purple,
          indicatorWeight: 3,
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: AppColors.hairline,
          labelStyle:
              const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          unselectedLabelStyle:
              const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          onTap: (i) => setState(() => _tabIndex = i),
          tabs: const [Tab(text: 'Other bonds'), Tab(text: 'FDs')],
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _tabIndex == 0
              ? Column(
                  children: [
                    for (final b in bonds)
                      _Row(
                        letter: b.logoLetter,
                        color: b.logoColor,
                        title: b.issuer,
                        subtitle:
                            '${b.rating} • ${b.secured ? 'Secured' : 'Unsecured'} • ${b.payout}',
                        top: b.tenureLabel,
                        bottom: '${b.ytm.toStringAsFixed(2)}%',
                        onTap: () => Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => BondDetailScreen(
                                appState: widget.appState, bond: b),
                          ),
                        ),
                      ),
                  ],
                )
              : Column(
                  children: [
                    for (final b in banks.take(5))
                      _Row(
                        letter: b.logoLetter,
                        color: b.logoColor,
                        title: b.name,
                        subtitle: b.insured
                            ? 'DICGC insured up to ₹5 lakh'
                            : '${b.type.label} • not insured',
                        top: b.tenureLabel,
                        bottom: '${b.rate.toStringAsFixed(2)}%',
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => BankDetailScreen(
                                appState: widget.appState, bank: b),
                          ),
                        ),
                      ),
                  ],
                ),
        ),
      ],
    );
  }

  Future<void> _pickSort() async {
    final picked = await showModalBottomSheet<bool>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 18, 20, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Sort by',
                    style:
                        TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
              ),
            ),
            RadioListTile<bool>(
              value: true,
              groupValue: _yieldHighLow,
              activeColor: AppColors.purple,
              title: const Text('Return: high to low'),
              onChanged: (v) => Navigator.of(context).pop(v),
            ),
            RadioListTile<bool>(
              value: false,
              groupValue: _yieldHighLow,
              activeColor: AppColors.purple,
              title: const Text('Return: low to high'),
              onChanged: (v) => Navigator.of(context).pop(v),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (picked != null) setState(() => _yieldHighLow = picked);
  }

  Future<void> _pickFilter() async {
    final onBonds = _tabIndex == 0;
    await showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheet) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 18, 20, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Filter',
                      style: TextStyle(
                          fontSize: 17, fontWeight: FontWeight.w800)),
                ),
              ),
              SwitchListTile(
                value: _securedOnly,
                activeColor: AppColors.purple,
                title: Text(onBonds
                    ? 'Secured issues only'
                    : 'DICGC insured only'),
                subtitle: Text(onBonds
                    ? 'Backed by collateral, ranking ahead of unsecured '
                        'lenders'
                    : 'Hides NBFC deposits, which are not covered by '
                        'deposit insurance'),
                onChanged: (v) {
                  setSheet(() {});
                  setState(() => _securedOnly = v);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bar(BondOffer bond) {
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.hairline)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
        child: Row(
          children: [
            if (_valid) ...[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('$_units units at ${bond.ytm.toStringAsFixed(2)}%',
                      style: TextStyle(
                          fontSize: 11, color: AppColors.grey)),
                  Text(formatInr(_payoutTotal),
                      style: const TextStyle(
                          fontSize: 17, fontWeight: FontWeight.w800)),
                ],
              ),
              const SizedBox(width: 16),
            ],
            Expanded(
              child: BlackPillButton(
                label: 'Invest now',
                onPressed: _valid
                    ? () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => AmountTenureScreen(
                              appState: widget.appState,
                              args: BookingArgs(
                                kind: InvestmentKind.bond,
                                issuerName: bond.issuer,
                                logoLetter: bond.logoLetter,
                                logoColor: bond.logoColor,
                                rate: bond.ytm,
                                tenureMonths: _months,
                                tenureLabel: bond.tenureLabel,
                                defaultAmount: _amount.round(),
                                minAmount: bond.minInvestment,
                                institutionLabel: bond.sector,
                                insured: false,
                                rating: bond.rating,
                                secured: bond.secured,
                              ),
                            ),
                          ),
                        )
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Issuer header, structurally the bank header's twin so the two detail
/// pages feel like one app, but carrying bond-specific chips.
class _IssuerHeader extends StatelessWidget {
  const _IssuerHeader({required this.bond});

  final BondOffer bond;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        BranchFrontage(
          name: bond.issuer,
          letter: bond.logoLetter,
          brand: bond.logoColor,
          overlay: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () => Navigator.of(context).maybePop(),
                    customBorder: const CircleBorder(),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                          color: Colors.white, shape: BoxShape.circle),
                      child: Icon(Icons.chevron_left,
                          size: 20, color: AppColors.onLightSurface),
                    ),
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: () => showPrototypeNotice(context, 'Share'),
                    customBorder: const CircleBorder(),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                          color: Colors.white, shape: BoxShape.circle),
                      child: Icon(Icons.ios_share,
                          size: 18, color: AppColors.onLightSurface),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 160),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.fromLTRB(20, 44, 20, 0),
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
                          Text(bond.issuer,
                              style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800)),
                          const SizedBox(height: 4),
                          Text(bond.title,
                              style: TextStyle(
                                  fontSize: 12, color: AppColors.grey)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('${bond.ytm.toStringAsFixed(2)}%',
                                style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.green)),
                          ],
                        ),
                        Text('YTM',
                            style: TextStyle(
                                fontSize: 10, color: AppColors.grey)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _Pill(text: bond.rating, color: AppColors.purple),
                    _Pill(
                        text: bond.secured ? 'SECURED' : 'UNSECURED',
                        color: bond.secured
                            ? AppColors.green
                            : const Color(0xFFB4791E)),
                    _Pill(
                        text: bond.payout.toUpperCase(),
                        color: AppColors.inkSoft),
                    if (bond.sector.isNotEmpty)
                      _Pill(
                          text: bond.sector.toUpperCase(),
                          color: AppColors.inkSoft),
                  ],
                ),
              ],
            ),
          ),
        ),
        Positioned(
          left: 20,
          top: 134,
          child: Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: bond.logoColor, width: 2),
            ),
            padding: const EdgeInsets.all(4),
            child: Container(
              decoration: BoxDecoration(
                color: bond.logoColor,
                borderRadius: BorderRadius.circular(13),
              ),
              alignment: Alignment.center,
              child: Text(bond.logoLetter,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w800)),
            ),
          ),
        ),
      ],
    );
  }
}

/// Where a bank page shows a growth curve, a bond shows when money actually
/// arrives — monthly coupons or a single repayment at maturity.
class _PayoutTimeline extends StatelessWidget {
  const _PayoutTimeline({
    required this.monthly,
    required this.months,
    required this.label,
  });

  final bool monthly;
  final int months;
  final String label;

  @override
  Widget build(BuildContext context) {
    final ticks = monthly ? (months < 3 ? 3 : (months > 10 ? 10 : months)) : 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(monthly ? 'You get paid every month' : 'You get paid once',
            style: const TextStyle(
                fontSize: 12, fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        SizedBox(
          height: 34,
          child: Row(
            children: [
              Expanded(
                child: Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    Container(height: 3, color: AppColors.hairline),
                    Row(
                      mainAxisAlignment: monthly
                          ? MainAxisAlignment.spaceBetween
                          : MainAxisAlignment.end,
                      children: [
                        for (var i = 0; i < ticks; i++)
                          Container(
                            width: 11,
                            height: 11,
                            decoration: BoxDecoration(
                              color: AppColors.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.greenSoft,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(label,
                    style: const TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SellThrough extends StatelessWidget {
  const _SellThrough({required this.percent});
  final int percent;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('$percent% of this issue sold',
                style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w700)),
            const Spacer(),
            Text('${100 - percent}% left',
                style:
                    TextStyle(fontSize: 11, color: AppColors.grey)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percent / 100,
            minHeight: 7,
            backgroundColor: AppColors.hairline,
            valueColor: AlwaysStoppedAnimation<Color>(
              percent >= 80 ? const Color(0xFFD0453F) : AppColors.green,
            ),
          ),
        ),
      ],
    );
  }
}

class _Title extends StatelessWidget {
  const _Title(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Text(text,
            style:
                const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
      );
}

/// Compact sort/filter control that sits on the section heading row.
class _HeadAction extends StatelessWidget {
  const _HeadAction({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
        decoration: BoxDecoration(
          color: active ? AppColors.ctaFill : AppColors.white,
          border:
              Border.all(color: active ? AppColors.ctaFill : AppColors.hairline),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: active ? AppColors.onCta : AppColors.ink),
            const SizedBox(width: 5),
            Text(label,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: active ? AppColors.onCta : AppColors.ink)),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.text, required this.color});
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(text,
          style: TextStyle(
              fontSize: 9.5,
              letterSpacing: 0.5,
              fontWeight: FontWeight.w800,
              color: color)),
    );
  }
}

class _Fig extends StatelessWidget {
  const _Fig({required this.label, required this.value, this.accent = false});
  final String label;
  final String value;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(fontSize: 11, color: AppColors.grey)),
        const SizedBox(height: 3),
        Text(value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: accent ? AppColors.green : AppColors.ink)),
      ],
    );
  }
}

class _Term extends StatelessWidget {
  const _Term({
    required this.label,
    required this.value,
    this.note,
    this.danger = false,
    this.last = false,
  });

  final String label;
  final String value;
  final String? note;
  final bool danger;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: last
          ? null
          : BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.hairline))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(label,
                    style: TextStyle(
                        fontSize: 13, color: AppColors.inkSoft)),
              ),
              const SizedBox(width: 10),
              Text(value,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: danger
                          ? const Color(0xFFB4791E)
                          : AppColors.ink)),
            ],
          ),
          if (note != null) ...[
            const SizedBox(height: 2),
            Text(note!,
                style:
                    TextStyle(fontSize: 11, color: AppColors.grey)),
          ],
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.letter,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.top,
    required this.bottom,
    required this.onTap,
  });

  final String letter;
  final Color color;
  final String title;
  final String subtitle;
  final String top;
  final String bottom;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            LetterLogo(letter: letter, color: color),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 11.5, color: AppColors.grey)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(top,
                    style: TextStyle(
                        fontSize: 11, color: AppColors.grey)),
                Row(
                  children: [
                    Text(bottom,
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.green)),
                    Icon(Icons.chevron_right,
                        size: 18, color: AppColors.greyLight),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
