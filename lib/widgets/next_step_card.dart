import 'package:flutter/material.dart';

import '../logic/next_step.dart';
import '../models/models.dart';
import '../screens/bonds/bond_detail_screen.dart';
import '../screens/fd/bank_detail_screen.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import 'common.dart';

/// The recommendation block, used on the confirmation screen, the Home tab
/// and the Passbook so the same next step follows the user around instead of
/// living on one screen they may never revisit.
class NextStepCard extends StatelessWidget {
  const NextStepCard({
    super.key,
    required this.appState,
    required this.step,
    this.compact = false,
  });

  final AppState appState;
  final NextStep step;

  /// Compact drops the explanatory line, for rails where space is tight.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.purpleSoft,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.purple.withValues(alpha: 0.32)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.purple,
                  borderRadius: BorderRadius.circular(5),
                ),
                // The chip is always the purple accent, so white type sits
                // on it in every appearance.
                child: Text('STEP ${step.step}',
                    style: const TextStyle(
                        fontSize: 9,
                        letterSpacing: 0.7,
                        fontWeight: FontWeight.w800,
                        color: Colors.white)),
              ),
              const SizedBox(width: 8),
              Text('OF YOUR PLAN',
                  style: TextStyle(
                      fontSize: 9,
                      letterSpacing: 0.7,
                      fontWeight: FontWeight.w800,
                      color: AppColors.purpleDeep)),
              const Spacer(),
              Text(step.amountLine,
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.purpleDeep)),
            ],
          ),
          const SizedBox(height: 10),
          Text(step.title,
              style: TextStyle(
                  fontSize: 16,
                  height: 1.25,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink)),
          if (!compact) ...[
            const SizedBox(height: 6),
            Text(step.detail,
                style: TextStyle(
                    fontSize: 12.5, height: 1.45, color: AppColors.inkSoft)),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: BlackPillButton(
                  label: step.cta,
                  dense: true,
                  onPressed: () => act(context, appState, step),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Routes the recommendation to wherever it can actually be acted on.
  static void act(BuildContext context, AppState appState, NextStep step) {
    switch (step.kind) {
      case NextKind.startRd:
      case NextKind.topUpRd:
        showRecurringSheet(context, appState, step);
      case NextKind.addBond:
        if (step.bond == null) return;
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) =>
              BondDetailScreen(appState: appState, bond: step.bond!),
        ));
      case NextKind.shortFd:
      case NextKind.anotherBank:
        if (step.bank == null) return;
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) =>
              BankDetailScreen(appState: appState, bank: step.bank!),
        ));
    }
  }
}

/// Starting or raising a monthly deposit. Kept to a sheet on purpose: the
/// whole argument is that this is a small decision, and sending the user
/// through the full booking flow would contradict that.
Future<void> showRecurringSheet(
    BuildContext context, AppState appState, NextStep step) async {
  var monthly = step.monthly ?? 2000;
  final options = <int>{1000, 2000, 5000, monthly}.toList()..sort();
  final bank = step.bank;

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
    ),
    builder: (sheetContext) => StatefulBuilder(
      builder: (sheetContext, setSheet) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.hairline,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Monthly deposit',
                  style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink)),
              const SizedBox(height: 6),
              Text(
                'Debited on the day your salary usually lands. You can stop '
                'or change it any month.',
                style: TextStyle(
                    fontSize: 12.5, height: 1.45, color: AppColors.grey),
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: options.map((v) {
                  final on = v == monthly;
                  return InkWell(
                    borderRadius: BorderRadius.circular(22),
                    onTap: () => setSheet(() => monthly = v),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 11),
                      decoration: BoxDecoration(
                        color: on ? AppColors.ctaFill : AppColors.white,
                        border: Border.all(
                            color: on ? AppColors.ctaFill : AppColors.hairline),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Text(formatInr(v),
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: on ? AppColors.onCta : AppColors.ink)),
                    ),
                  );
                }).toList(),
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
                      child: _Fig(
                          label: 'In 12 months',
                          value: formatInr(monthly * 12)),
                    ),
                    Expanded(
                      child: _Fig(
                        label: 'Roughly worth',
                        value: formatInr(_rdValue(monthly, 12,
                            bank?.rate ?? 7.5)),
                        accent: true,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                bank == null
                    ? 'Indicative, at prevailing rates.'
                    : 'Indicative, at ${bank.name} current rates.',
                style: TextStyle(fontSize: 11, color: AppColors.greyLight),
              ),
              const SizedBox(height: 16),
              BlackPillButton(
                label: 'Start ${formatInr(monthly)} a month',
                onPressed: () {
                  appState.addInvestment(BookedInvestment(
                    kind: InvestmentKind.rd,
                    issuerName: bank?.name ?? 'Monthly deposit',
                    logoColor: bank?.logoColor ?? AppColors.purpleTile,
                    logoLetter: bank?.logoLetter ?? 'RD',
                    principal: monthly.toDouble(),
                    rate: bank?.rate ?? 7.5,
                    tenureMonths: 12,
                    bookedOn: DateTime.now(),
                  ));
                  Navigator.of(sheetContext).pop();
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(
                        'Monthly deposit of ${formatInr(monthly)} started'),
                  ));
                },
              ),
              const SizedBox(height: 8),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.of(sheetContext).pop(),
                  child: Text('Not now',
                      style: TextStyle(color: AppColors.grey)),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

/// Rough future value of a monthly deposit, compounded quarterly. Close
/// enough for an indicative figure on a prototype.
double _rdValue(int monthly, int months, double rate) {
  final r = (rate / 100) / 12;
  var total = 0.0;
  for (var m = 0; m < months; m++) {
    total += monthly * (1 + r * (months - m));
  }
  return total;
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
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: accent ? AppColors.greenInk : AppColors.ink)),
      ],
    );
  }
}
