import 'package:flutter/material.dart';

import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../utils/formatters.dart';
import '../../widgets/common.dart';
import 'booking_args.dart';
import 'success_screen.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({
    super.key,
    required this.appState,
    required this.args,
    required this.amount,
  });

  final AppState appState;
  final BookingArgs args;
  final double amount;

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _method = 'upi';
  bool _paying = false;

  Future<void> _pay() async {
    setState(() => _paying = true);
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => SuccessScreen(
          appState: widget.appState,
          args: widget.args,
          amount: widget.amount,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: _paying ? null : () => Navigator.of(context).pop(),
        ),
        title: const Text('Make payment'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 140),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.hairline),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Amount to pay',
                      style: TextStyle(color: AppColors.grey)),
                  Text(formatInr(widget.amount),
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w800)),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Icon(Icons.lock_outline, size: 14, color: AppColors.grey),
                  SizedBox(width: 6),
                  Text('ZERO convenience fee',
                      style: TextStyle(fontSize: 12, color: AppColors.grey)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text('PAYMENT METHOD',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.grey,
                    letterSpacing: 0.6)),
            const SizedBox(height: 10),
            _methodTile('upi', Icons.qr_code_2, 'UPI',
                'Pay instantly using any UPI app'),
            const SizedBox(height: 10),
            _methodTile('netbanking', Icons.account_balance_outlined,
                'Net Banking', 'Pay via ${widget.appState.profile.linkedBank ?? 'your bank'}'),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
          child: BlackPillButton(
            label: _paying ? 'Processing…' : 'Pay ${formatInr(widget.amount)}',
            onPressed: _paying ? null : _pay,
          ),
        ),
      ),
    );
  }

  Widget _methodTile(
      String value, IconData icon, String title, String subtitle) {
    final selected = _method == value;
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => setState(() => _method = value),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          border: Border.all(
              color: selected ? AppColors.purple : AppColors.hairline,
              width: selected ? 1.4 : 1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.ink),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700)),
                  Text(subtitle,
                      style: TextStyle(
                          fontSize: 12, color: AppColors.grey)),
                ],
              ),
            ),
            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_off,
              color: selected ? AppColors.purple : AppColors.greyLight,
            ),
          ],
        ),
      ),
    );
  }
}
