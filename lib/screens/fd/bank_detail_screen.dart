import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/mock_data.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../utils/finance.dart';
import '../../utils/formatters.dart';
import '../../widgets/branch_frontage.dart';
import '../../widgets/common.dart';
import '../../widgets/growth_chart.dart';
import '../../widgets/trust_banner.dart';
import '../bonds/bond_detail_screen.dart';
import '../booking/amount_tenure_screen.dart';
import '../booking/booking_args.dart';

/// Bank page. Same skeleton for every bank; only the content, colours and
/// marks change.
///
///   1. Branded header with the bank's identity and regulatory standing.
///   2. Swipeable feature banners — why this bank specifically is worth
///      trusting, plus who else has money in it.
///   3. The deposit itself: tenure picker, growth curve, returns.
///   4. Most bought plans at this bank.
///   5. Everything else, with sort and filter.
class BankDetailScreen extends StatefulWidget {
  const BankDetailScreen({
    super.key,
    required this.appState,
    required this.bank,
  });

  final AppState appState;
  final FdBank bank;

  @override
  State<BankDetailScreen> createState() => _BankDetailScreenState();
}

class _BankDetailScreenState extends State<BankDetailScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 3, vsync: this);
  final _amountController = TextEditingController(text: '100000');

  int _tabIndex = 0;
  int _tenureIndex = 0;
  bool _senior = false;

  _SortBy _sort = _SortBy.rateHighLow;
  bool _insuredOnly = false;

  static const _minAmount = 5000;

  double get _amount => double.tryParse(_amountController.text.trim()) ?? 0;
  bool get _amountValid => _amount >= _minAmount;

  List<TenureRate> get _card => widget.bank.rateCard.isNotEmpty
      ? widget.bank.rateCard
      : [
          TenureRate(
            label: widget.bank.tenureLabel,
            months: widget.bank.tenureMonths,
            rate: widget.bank.rate,
            seniorRate: widget.bank.rate + 0.5,
          ),
        ];

  TenureRate get _selected => _card[_tenureIndex.clamp(0, _card.length - 1)];
  double get _rate => _senior ? _selected.seniorRate : _selected.rate;

  @override
  void initState() {
    super.initState();
    // Open on the bank's best-paying tenure rather than its shortest.
    final best = _card.reduce((a, b) => a.rate >= b.rate ? a : b);
    _tenureIndex = _card.indexOf(best);
  }

  @override
  void dispose() {
    _tabs.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bank = widget.bank;
    final maturity = computeMaturity(
      principal: _amount,
      ratePercent: _rate,
      tenureMonths: _selected.months,
    );

    return Scaffold(
      backgroundColor: AppColors.white,
      body: ListView(
        padding: const EdgeInsets.only(bottom: 28),
        children: [
          _BankHeader(bank: bank),
          const SizedBox(height: 20),
          BankTrustBanner(bank: bank),
          const SizedBox(height: 30),
          _depositSection(bank, maturity),
          const SizedBox(height: 30),
          if (bank.plans.isNotEmpty) ...[
            _mostBought(bank),
            const SizedBox(height: 30),
          ],
          _alternatives(bank),
        ],
      ),
      bottomNavigationBar: _bookingBar(bank, maturity),
    );
  }

  // ------------------------------------------------------------- deposit

  Widget _depositSection(FdBank bank, double maturity) {
    final earnings = maturity - _amount;
    final yieldPct = _amount <= 0
        ? 0.0
        : (earnings / _amount) * 100 * (12 / _selected.months);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('Investment amount'),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (_) => setState(() {}),
                style: const TextStyle(
                    fontSize: 26, fontWeight: FontWeight.w800),
                decoration: const InputDecoration(prefixText: '₹  '),
              ),
              if (!_amountValid)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                      'Minimum investment is ${formatInr(_minAmount)}',
                      style:
                          TextStyle(color: AppColors.danger, fontSize: 12)),
                ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [25000, 50000, 100000, 200000].map((v) {
                  final on = _amount == v;
                  return ChoiceChip(
                    label: Text(formatInr(v)),
                    selected: on,
                    showCheckmark: false,
                    onSelected: (_) => setState(
                        () => _amountController.text = v.toString()),
                    labelStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: on ? AppColors.onCta : AppColors.ink),
                    selectedColor: AppColors.ctaFill,
                    backgroundColor: AppColors.white,
                    side: BorderSide(color: AppColors.hairline),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.hairline),
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tenure sits inside the calculator, unlabelled, the way a
                // rate selector usually does.
                Row(
                  children: [
                    for (var i = 0; i < _card.length; i++) ...[
                      if (i > 0) const SizedBox(width: 8),
                      Expanded(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => setState(() => _tenureIndex = i),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 160),
                            padding:
                                const EdgeInsets.symmetric(vertical: 9),
                            decoration: BoxDecoration(
                              color: i == _tenureIndex
                                  ? AppColors.ctaFill
                                  : AppColors.white,
                              border: Border.all(
                                  color: i == _tenureIndex
                                      ? AppColors.ctaFill
                                      : AppColors.hairline),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                Text(_card[i].label,
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: i == _tenureIndex
                                            ? AppColors.onCta
                                            : AppColors.ink)),
                                const SizedBox(height: 3),
                                Text(
                                    '${(_senior ? _card[i].seniorRate : _card[i].rate).toStringAsFixed(2)}%',
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w800,
                                        color: i == _tenureIndex
                                            ? const Color(0xFF9FE1CB)
                                            : AppColors.green)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Row(
                  children: [
                    Text('Senior citizen rate',
                        style:
                            TextStyle(fontSize: 13, color: AppColors.grey)),
                    const Spacer(),
                    Switch(
                      value: _senior,
                      activeColor: AppColors.purple,
                      onChanged: (v) => setState(() => _senior = v),
                    ),
                  ],
                ),
                if (_amountValid) ...[
                  const SizedBox(height: 6),
                  Text('HOW IT GROWS',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                          color: AppColors.grey)),
                  const SizedBox(height: 10),
                  GrowthChart(
                    principal: _amount,
                    ratePercent: _rate,
                    tenureMonths: _selected.months,
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.greenSoft,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                            child: _Figure(
                                label: 'You invest',
                                value: formatInr(_amount))),
                        Expanded(
                            child: _Figure(
                                label: 'You earn',
                                value: '+${formatInr(earnings)}',
                                accent: true)),
                        Expanded(
                            child: _Figure(
                                label: 'You get',
                                value: formatInr(maturity))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  _RatioRow(
                    label: 'Effective annual yield',
                    value: '${yieldPct.toStringAsFixed(2)}%',
                    note: 'Higher than the headline rate, because interest '
                        'compounds quarterly',
                  ),
                  _RatioRow(
                    label: 'Versus a savings account at 3%',
                    value:
                        '+${formatInr(maturity - computeMaturity(principal: _amount, ratePercent: 3, tenureMonths: _selected.months))}',
                    note: 'Extra earned over the same period',
                  ),
                  _RatioRow(
                    label: 'Cover on this deposit',
                    value: bank.insured
                        ? (_amount <= 500000 ? 'Fully insured' : 'Up to ₹5L')
                        : 'Not insured',
                    note: bank.insured
                        ? 'DICGC covers up to ₹5 lakh per depositor, per bank'
                        : 'NBFC deposits fall outside DICGC cover',
                    danger: !bank.insured,
                    last: true,
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  // --------------------------------------------------------- most bought

  Widget _mostBought(FdBank bank) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle('Most bought at ${bank.name}'),
        const SizedBox(height: 12),
        ...bank.plans.map((p) => Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.hairline),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.purpleSoft,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(p.tag,
                              style: TextStyle(
                                  fontSize: 9,
                                  letterSpacing: 0.6,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.purpleDeep)),
                        ),
                        const Spacer(),
                        Text('${p.rate.toStringAsFixed(2)}%',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: AppColors.green)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(p.name,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(p.why,
                        style: TextStyle(
                            fontSize: 12,
                            color: AppColors.grey,
                            height: 1.4)),
                    const Divider(height: 24),
                    Row(
                      children: [
                        _MiniStat(
                            label: 'Tenure', value: p.tenureLabel),
                        const SizedBox(width: 24),
                        _MiniStat(
                            label: 'Minimum',
                            value: formatInr(p.minAmount)),
                        const Spacer(),
                        TextButton(
                          onPressed: () => setState(() {
                            final i = _card
                                .indexWhere((t) => t.months == p.months);
                            if (i >= 0) _tenureIndex = i;
                          }),
                          child: Text('Select',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.purple)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )),
      ],
    );
  }

  // -------------------------------------------------------- alternatives

  Widget _alternatives(FdBank bank) {
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
              _HeaderAction(
                icon: Icons.swap_vert,
                label: 'Sort',
                active: _sort != _SortBy.rateHighLow,
                onTap: _pickSort,
              ),
              const SizedBox(width: 8),
              if (_tabIndex != 1)
                _HeaderAction(
                  icon: Icons.tune,
                  label: 'Filter',
                  active: _insuredOnly,
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
          tabs: const [
            Tab(text: 'Other FDs'),
            Tab(text: 'Bonds'),
            Tab(text: 'RD'),
          ],
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: switch (_tabIndex) {
            0 => _otherFds(bank),
            1 => _bonds(),
            _ => _rds(bank),
          },
        ),
      ],
    );
  }

  Future<void> _pickFilter() async {
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
                value: _insuredOnly,
                activeColor: AppColors.purple,
                title: const Text('DICGC insured only'),
                subtitle: const Text('Hides NBFC deposits, which are not '
                    'covered by deposit insurance'),
                onChanged: (v) {
                  setSheet(() {});
                  setState(() => _insuredOnly = v);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickSort() async {
    final picked = await showModalBottomSheet<_SortBy>(
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
                    style: TextStyle(
                        fontSize: 17, fontWeight: FontWeight.w800)),
              ),
            ),
            for (final option in _SortBy.values)
              RadioListTile<_SortBy>(
                value: option,
                groupValue: _sort,
                activeColor: AppColors.purple,
                title: Text(switch (option) {
                  _SortBy.rateHighLow => 'Rate: high to low',
                  _SortBy.rateLowHigh => 'Rate: low to high',
                  _SortBy.tenureShort => 'Tenure: shortest first',
                }),
                onChanged: (v) => Navigator.of(context).pop(v),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (picked != null) setState(() => _sort = picked);
  }

  List<FdBank> _sortedBanks(FdBank exclude) {
    var list = MockData.banks.where((b) => b.name != exclude.name).toList();
    if (_insuredOnly) list = list.where((b) => b.insured).toList();
    list.sort(switch (_sort) {
      _SortBy.rateHighLow => (a, b) => b.rate.compareTo(a.rate),
      _SortBy.rateLowHigh => (a, b) => a.rate.compareTo(b.rate),
      _SortBy.tenureShort => (a, b) =>
          a.tenureMonths.compareTo(b.tenureMonths),
    });
    return list;
  }

  Widget _otherFds(FdBank current) {
    final list = _sortedBanks(current);
    if (list.isEmpty) return const _EmptyNote('No banks match that filter.');
    return Column(
      children: [
        for (final b in list)
          _RowTile(
            letter: b.logoLetter,
            color: b.logoColor,
            title: b.name,
            subtitle:
                '${b.type.label}${b.insured ? ' • DICGC insured' : ' • Not insured'}',
            trailingTop: b.tenureLabel,
            trailingBottom: '${b.rate.toStringAsFixed(2)}%',
            onTap: () => Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) =>
                    BankDetailScreen(appState: widget.appState, bank: b),
              ),
            ),
          ),
      ],
    );
  }

  Widget _bonds() {
    final list = [...MockData.bonds];
    list.sort(switch (_sort) {
      _SortBy.rateHighLow => (a, b) => b.ytm.compareTo(a.ytm),
      _SortBy.rateLowHigh => (a, b) => a.ytm.compareTo(b.ytm),
      _SortBy.tenureShort => (a, b) =>
          a.tenureLabel.length.compareTo(b.tenureLabel.length),
    });
    return Column(
      children: [
        for (final bond in list)
          _RowTile(
            letter: bond.logoLetter,
            color: bond.logoColor,
            title: bond.issuer,
            subtitle:
                'Min ${formatInr(bond.minInvestment)} • ${bond.percentSold}% sold',
            trailingTop: bond.tenureLabel,
            trailingBottom: '${bond.ytm.toStringAsFixed(2)}%',
            badge: bond.newlyAdded ? 'NEW' : null,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => BondDetailScreen(
                    appState: widget.appState, bond: bond),
              ),
            ),
          ),
      ],
    );
  }

  Widget _rds(FdBank current) {
    final list = [current, ..._sortedBanks(current)];
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.purpleSoft,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Icon(Icons.autorenew, size: 18, color: AppColors.purple),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Put in a fixed amount every month instead of a lump sum. '
                  'Starts at ₹1,000 a month.',
                  style: TextStyle(fontSize: 12, color: AppColors.inkSoft),
                ),
              ),
            ],
          ),
        ),
        for (final b in list)
          _RowTile(
            letter: b.logoLetter,
            color: b.logoColor,
            title: b.name,
            subtitle: '₹1,000 a month • 12 months',
            trailingTop: 'RD',
            trailingBottom: '${b.rate.toStringAsFixed(2)}%',
            onTap: () => showPrototypeNotice(context, 'RD booking'),
          ),
      ],
    );
  }

  // -------------------------------------------------------------- footer

  Widget _bookingBar(FdBank bank, double maturity) {
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.hairline)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
        child: Row(
          children: [
            if (_amountValid) ...[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('${_selected.label} at ${_rate.toStringAsFixed(2)}%',
                      style: TextStyle(
                          fontSize: 11, color: AppColors.grey)),
                  Text(formatInr(maturity),
                      style: const TextStyle(
                          fontSize: 17, fontWeight: FontWeight.w800)),
                ],
              ),
              const SizedBox(width: 16),
            ],
            Expanded(
              child: BlackPillButton(
                label: 'Book this FD',
                onPressed: _amountValid
                    ? () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => AmountTenureScreen(
                              appState: widget.appState,
                              args: BookingArgs(
                                kind: InvestmentKind.fd,
                                issuerName: bank.name,
                                logoLetter: bank.logoLetter,
                                logoColor: bank.logoColor,
                                rate: _rate,
                                tenureMonths: _selected.months,
                                tenureLabel: _selected.label,
                                defaultAmount: _amount.round(),
                                minAmount: _minAmount,
                                institutionLabel: bank.type.label,
                                insured: bank.insured,
                                prematurePenaltyPercent:
                                    bank.prematurePenaltyPercent,
                                lockInMonths: bank.lockInMonths,
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

enum _SortBy { rateHighLow, rateLowHigh, tenureShort }

/// Branded header: a colour-washed band carrying the bank's own identity,
/// with the logo tile breaking the boundary into the white sheet below.
class _BankHeader extends StatelessWidget {
  const _BankHeader({required this.bank});

  final FdBank bank;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        BranchFrontage(
          name: bank.name,
          letter: bank.logoLetter,
          brand: bank.logoColor,
          overlay: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _RoundAction(
                    icon: Icons.chevron_left,
                    onTap: () => Navigator.of(context).maybePop(),
                  ),
                  const Spacer(),
                  _RoundAction(
                    icon: Icons.ios_share,
                    onTap: () => showPrototypeNotice(context, 'Share'),
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
                          Text(bank.name,
                              style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800)),
                          const SizedBox(height: 6),
                          Text(
                            [
                              'RBI-REGULATED',
                              if (bank.publiclyListed) 'PUBLICLY LISTED',
                            ].join('  •  '),
                            style: TextStyle(
                                fontSize: 11,
                                letterSpacing: 0.8,
                                fontWeight: FontWeight.w600,
                                color: AppColors.grey),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    InkWell(
                      onTap: () =>
                          showPrototypeNotice(context, 'Branch locator'),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.hairline),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.place, size: 15, color: Colors.red),
                            SizedBox(width: 5),
                            Text('Branches\nnear you',
                                style: TextStyle(
                                    fontSize: 10, height: 1.2)),
                            Icon(Icons.chevron_right,
                                size: 14, color: AppColors.greyLight),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 18,
                  runSpacing: 10,
                  children: [
                    if (bank.aum != null)
                      _MiniStat(label: 'AUM', value: bank.aum!),
                    if (bank.customers != null)
                      _MiniStat(label: 'Customers', value: bank.customers!),
                    if (bank.branches != null)
                      _MiniStat(label: 'Network', value: bank.branches!),
                    if (bank.establishedYear != null)
                      _MiniStat(
                          label: 'Since', value: '${bank.establishedYear}'),
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
              border: Border.all(color: bank.logoColor, width: 2),
            ),
            padding: const EdgeInsets.all(4),
            child: Container(
              decoration: BoxDecoration(
                color: bank.logoColor,
                borderRadius: BorderRadius.circular(13),
              ),
              alignment: Alignment.center,
              child: Text(bank.logoLetter,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800)),
            ),
          ),
        ),
      ],
    );
  }
}

class _RoundAction extends StatelessWidget {
  const _RoundAction({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 36,
        height: 36,
        decoration: const BoxDecoration(
            color: Colors.white, shape: BoxShape.circle),
        child: Icon(icon, size: 20, color: AppColors.onLightSurface),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
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

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label,
            style: TextStyle(fontSize: 10, color: AppColors.grey)),
        const SizedBox(height: 2),
        Text(value,
            style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _Figure extends StatelessWidget {
  const _Figure(
      {required this.label, required this.value, this.accent = false});
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
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: accent ? AppColors.green : AppColors.ink)),
      ],
    );
  }
}

class _RatioRow extends StatelessWidget {
  const _RatioRow({
    required this.label,
    required this.value,
    required this.note,
    this.danger = false,
    this.last = false,
  });

  final String label;
  final String value;
  final String note;
  final bool danger;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 11),
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
          const SizedBox(height: 2),
          Text(note,
              style: TextStyle(fontSize: 11, color: AppColors.grey)),
        ],
      ),
    );
  }
}

class _RowTile extends StatelessWidget {
  const _RowTile({
    required this.letter,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.trailingTop,
    required this.trailingBottom,
    required this.onTap,
    this.badge,
  });

  final String letter;
  final Color color;
  final String title;
  final String subtitle;
  final String trailingTop;
  final String trailingBottom;
  final String? badge;
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
                  Row(
                    children: [
                      Flexible(
                        child: Text(title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600)),
                      ),
                      if (badge != null) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.purpleSoft,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(badge!,
                              style: TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.purpleDeep)),
                        ),
                      ],
                    ],
                  ),
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
                Text(trailingTop,
                    style: TextStyle(
                        fontSize: 11, color: AppColors.grey)),
                Row(
                  children: [
                    Text(trailingBottom,
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

/// Compact sort/filter control that sits on the section heading row.
class _HeaderAction extends StatelessWidget {
  const _HeaderAction({
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
  });

  final String label;
  final IconData icon;
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
          border: Border.all(
              color: active ? AppColors.ctaFill : AppColors.hairline),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 15,
                color: active ? AppColors.onCta : AppColors.ink),
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

class _EmptyNote extends StatelessWidget {
  const _EmptyNote(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Center(
        child: Text(text,
            style: TextStyle(fontSize: 13, color: AppColors.grey)),
      ),
    );
  }
}
