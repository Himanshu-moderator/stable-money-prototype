import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../shell/main_shell.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key, required this.appState});
  final AppState appState;

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _nodes = List.generate(6, (_) => FocusNode());
  Timer? _timer;
  int _secondsLeft = 27;
  bool _verifying = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _secondsLeft = 27;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft <= 1) {
        t.cancel();
        setState(() => _secondsLeft = 0);
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  String get _code => _controllers.map((c) => c.text).join();

  void _onDigitChanged(int index, String value) {
    if (value.isNotEmpty && index < 5) {
      _nodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _nodes[index - 1].requestFocus();
    }
    if (_code.length == 6) {
      _verify();
    }
    setState(() {});
  }

  Future<void> _verify() async {
    if (_verifying) return;
    setState(() => _verifying = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    widget.appState.confirmMobileVerified();
    // The real app has no PAN or profile-setup step at login: an
    // Aadhaar-linked mobile plus OTP drops you straight onto the FD home.
    // KYC is collected later, at the point of booking.
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => MainShell(appState: widget.appState),
      ),
      (route) => false,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final n in _nodes) {
      n.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mobile = widget.appState.pendingMobile ?? '';
    final maskedEmail = widget.appState.profile.email.isNotEmpty
        ? '${widget.appState.profile.email.substring(0, 2)}******@gmail.com'
        : 'kk******@gmail.com';

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.white,
                    child: IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text('OTP please?',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700)),
              const SizedBox(height: 14),
              Text(
                "We've sent it to +91 $mobile and\n$maskedEmail",
                style: TextStyle(color: AppColors.grey, fontSize: 14),
              ),
              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (i) => _otpBox(i)),
              ),
              const SizedBox(height: 18),
              Text(
                _secondsLeft > 0
                    ? 'Resend in ${_secondsLeft}s'
                    : 'Resend OTP',
                style: TextStyle(
                  color: _secondsLeft > 0 ? AppColors.grey : AppColors.purple,
                  fontWeight:
                      _secondsLeft > 0 ? FontWeight.w400 : FontWeight.w700,
                ),
              ),
              const Spacer(),
              if (_verifying)
                Padding(
                  padding: EdgeInsets.only(bottom: 24),
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.ink),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _otpBox(int i) {
    return SizedBox(
      width: 46,
      height: 56,
      child: TextField(
        controller: _controllers[i],
        focusNode: _nodes[i],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        obscureText: true,
        obscuringCharacter: '●',
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: const TextStyle(fontSize: 18),
        decoration: InputDecoration(
          counterText: '',
          contentPadding: EdgeInsets.zero,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.hairline),
          ),
        ),
        onChanged: (v) => _onDigitChanged(i, v),
      ),
    );
  }
}
