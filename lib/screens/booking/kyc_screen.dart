import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import 'booking_args.dart';
import 'nominee_screen.dart';

/// KYC step inside the booking flow. Confirmed by the user: login is only
/// mobile plus OTP, and identity verification is asked for at the point of
/// booking, not at sign-in. Support & FAQs corroborates this by listing
/// "KYC - eKYC - Video KYC" as its own help topic.
///
/// The exact screen was not captured, so the layout follows the mobile
/// number screen's form styling. Once completed, [AppState.kycComplete]
/// stays true, so a second booking skips straight past this step.
class KycScreen extends StatefulWidget {
  const KycScreen({
    super.key,
    required this.appState,
    required this.args,
    required this.amount,
  });

  final AppState appState;
  final BookingArgs args;
  final double amount;

  /// Pushes KYC only when it hasn't been completed yet, otherwise goes
  /// straight to the nominee step.
  static void pushOrSkip(
    BuildContext context, {
    required AppState appState,
    required BookingArgs args,
    required double amount,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => appState.kycComplete
            ? NomineeScreen(appState: appState, args: args, amount: amount)
            : KycScreen(appState: appState, args: args, amount: amount),
      ),
    );
  }

  @override
  State<KycScreen> createState() => _KycScreenState();
}

class _KycScreenState extends State<KycScreen> {
  final _panController = TextEditingController();
  final _panRegex = RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]$');
  bool _verifying = false;

  bool get _isValid => _panRegex.hasMatch(_panController.text.trim());

  @override
  void dispose() {
    _panController.dispose();
    super.dispose();
  }

  Future<void> _proceed() async {
    if (!_isValid || _verifying) return;
    setState(() => _verifying = true);
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    widget.appState.completeKyc(_panController.text.trim());
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => NomineeScreen(
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
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Complete KYC'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              const Text('Verify your identity',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text(
                'Your PAN is required before ${widget.args.issuerName} can open '
                'the deposit. You only need to do this once.',
                style: TextStyle(color: AppColors.grey, fontSize: 14),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _panController,
                textCapitalization: TextCapitalization.characters,
                maxLength: 10,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
                  UpperCaseTextFormatter(),
                ],
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  labelText: 'PAN number',
                  hintText: 'ABCDE1234F',
                  counterText: '',
                  prefixIcon: Icon(Icons.badge_outlined),
                ),
                style: const TextStyle(fontSize: 16, letterSpacing: 1.2),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.cream,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.videocam_outlined,
                        size: 18, color: AppColors.grey),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Some banks additionally ask for a short video KYC. '
                        'If yours does, it opens right after payment.',
                        style:
                            TextStyle(fontSize: 12, color: AppColors.grey),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.lock_outline, size: 14, color: AppColors.grey),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Bank-grade encryption. Shared only with the RBI-regulated '
                      'bank or NBFC holding your deposit.',
                      style: TextStyle(fontSize: 12, color: AppColors.grey),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: BlackPillButton(
                  label: _verifying ? 'Verifying...' : 'Verify and continue',
                  onPressed: _isValid && !_verifying ? _proceed : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}
