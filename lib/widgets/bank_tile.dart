import 'package:flutter/material.dart';

import '../models/models.dart';
import '../theme/app_theme.dart';
import 'common.dart';

/// A single row in the "Most booked banks and NBFCs" / "All FDs" lists.
class BankTile extends StatelessWidget {
  const BankTile({super.key, required this.bank, required this.onTap});

  final FdBank bank;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            LetterLogo(letter: bank.logoLetter, color: bank.logoColor),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(bank.name,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600)),
                  if (bank.rateIncreased) ...[
                    const SizedBox(height: 4),
                    const RateIncreasedChip(),
                  ],
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(bank.tenureLabel,
                    style: TextStyle(
                        fontSize: 12, color: AppColors.grey)),
                Row(
                  children: [
                    Text('${bank.rate.toStringAsFixed(2)}%',
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
