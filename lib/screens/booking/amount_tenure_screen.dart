import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../utils/finance.dart';
import '../../utils/formatters.dart';
import '../../widgets/common.dart';
import 'booking_args.dart';
import 'kyc_screen.dart';

class AmountTenureScreen extends StatefulWidget {
  const AmountTenureScreen({
    super.key,
    required this.appState,
    required this.args,
  });

  final AppState appState;
  final BookingArgs args;

  @override
  State<AmountTenureScreen> createState() => _AmountTenureScreenState();
}

class _AmountTenureScreenState extends State<AmountTenureScreen> {
  late final _amountController =
      TextEditingController(text: widget.args.defaultAmount.toString());

  double get _amount =>
      double.tryParse(_amountController.text) ??
      widget.args.defaultAmount.toDouble();

  bool get _isValid => _amount >= widget.args.minAmount;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args = widget.args;
    final maturity = computeMaturity(
      principal: _amount,
      ratePercent: args.rate,
      tenureMonths: args.tenureMonths,
    );
    final earnings = maturity - _amount;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Book ${args.kindLabel}'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 140),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.hairline),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  LetterLogo(letter: args.logoLetter, color: args.logoColor),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(args.issuerName,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 2),
                        Text('${args.tenureLabel} tenure',
                            style: TextStyle(
                                fontSize: 13, color: AppColors.grey)),
                      ],
                    ),
                  ),
                  Text('${args.rate.toStringAsFixed(2)}%',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.green)),
                ],
              ),
            ),
            const SizedBox(height: 26),
            Text('Investment amount',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.grey,
                    letterSpacing: 0.6)),
            const SizedBox(height: 10),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (_) => setState(() {}),
              style:
                  const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
              decoration: const InputDecoration(prefixText: '₹  '),
            ),
            if (!_isValid)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Minimum investment is ${formatInr(args.minAmount)}',
                  style: TextStyle(color: AppColors.danger, fontSize: 12),
                ),
              ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              children: [10000, 25000, 50000, 100000].map((v) {
                return OutlinedButton(
                  onPressed: () => setState(
                      () => _amountController.text = v.toString()),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.ink,
                    side: BorderSide(color: AppColors.hairline),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                  child: Text(formatInr(v)),
                );
              }).toList(),
            ),
            const SizedBox(height: 28),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.greenSoft,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Projected maturity value',
                      style: TextStyle(fontSize: 13, color: AppColors.grey)),
                  const SizedBox(height: 6),
                  Text(formatInr(maturity),
                      style: const TextStyle(
                          fontSize: 26, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 6),
                  Text('+${formatInr(earnings)} earnings over ${args.tenureLabel}',
                      style: TextStyle(
                          fontSize: 13,
                          color: AppColors.greenInk,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
          child: BlackPillButton(
            label: 'Continue',
            onPressed: _isValid
                ? () => KycScreen.pushOrSkip(
                      context,
                      appState: widget.appState,
                      args: args,
                      amount: _amount,
                    )
                : null,
          ),
        ),
      ),
    );
  }
}
