import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import 'otp_screen.dart';

class MobileNumberScreen extends StatefulWidget {
  const MobileNumberScreen({super.key, required this.appState});
  final AppState appState;

  @override
  State<MobileNumberScreen> createState() => _MobileNumberScreenState();
}

class _MobileNumberScreenState extends State<MobileNumberScreen> {
  final _controller = TextEditingController();

  bool get _isValid => _controller.text.trim().length == 10;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _proceed() {
    if (!_isValid) return;
    widget.appState.setPendingMobile(_controller.text.trim());
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => OtpScreen(appState: widget.appState),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              const Text("What's your mobile number?",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.hairline),
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Text('+91',
                        style: TextStyle(fontSize: 16, color: AppColors.ink)),
                    const SizedBox(width: 10),
                    Container(width: 1, height: 24, color: AppColors.hairline),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        keyboardType: TextInputType.phone,
                        maxLength: 10,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onChanged: (_) => setState(() {}),
                        onSubmitted: (_) => _proceed(),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          counterText: '',
                          hintText: 'Enter Aadhaar-linked number',
                          hintStyle: TextStyle(color: AppColors.greyLight),
                        ),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              RichText(
                text: TextSpan(
                  style: TextStyle(color: AppColors.ink, fontSize: 13),
                  children: [
                    TextSpan(text: 'By proceeding, I agree to '),
                    TextSpan(
                      text: 'T&C',
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          decoration: TextDecoration.underline),
                    ),
                    TextSpan(text: ' and '),
                    TextSpan(
                      text: 'Privacy policy',
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          decoration: TextDecoration.underline),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: BlackPillButton(
                  label: 'Verify mobile number',
                  onPressed: _isValid ? _proceed : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
