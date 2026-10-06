import 'package:flutter/material.dart';

import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import 'booking_args.dart';
import 'terms_screen.dart';

/// Gap-filled screen: no nominee-details screenshot exists, but every FD
/// provider requires one, so this is styled to match the onboarding forms.
class NomineeScreen extends StatefulWidget {
  const NomineeScreen({
    super.key,
    required this.appState,
    required this.args,
    required this.amount,
  });

  final AppState appState;
  final BookingArgs args;
  final double amount;

  @override
  State<NomineeScreen> createState() => _NomineeScreenState();
}

class _NomineeScreenState extends State<NomineeScreen> {
  final _nameController = TextEditingController();
  String? _relation;

  static const _relations = ['Spouse', 'Parent', 'Child', 'Sibling', 'Other'];

  bool get _isValid =>
      _nameController.text.trim().isNotEmpty && _relation != null;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
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
        title: const Text('Nominee details'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 140),
          children: [
            Text(
              "Add a nominee so your investment reaches the right person, always.",
              style: TextStyle(color: AppColors.grey, fontSize: 14),
            ),
            const SizedBox(height: 22),
            TextField(
              controller: _nameController,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                labelText: 'Nominee full name',
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 20),
            Text('RELATIONSHIP',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.grey,
                    letterSpacing: 0.6)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _relations.map((r) {
                final selected = _relation == r;
                return InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: () => setState(() => _relation = r),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 12),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.ctaFill : AppColors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                          color:
                              selected ? AppColors.ctaFill : AppColors.hairline),
                    ),
                    child: Text(r,
                        style: TextStyle(
                            color: selected ? AppColors.onCta : AppColors.ink,
                            fontWeight: FontWeight.w600)),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
          child: BlackPillButton(
            label: 'Review terms',
            onPressed: _isValid
                ? () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => TermsScreen(
                          appState: widget.appState,
                          args: widget.args,
                          amount: widget.amount,
                        ),
                      ),
                    )
                : null,
          ),
        ),
      ),
    );
  }
}
