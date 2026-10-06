import 'package:flutter/material.dart';

import '../../data/mock_data.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/bank_tile.dart';
import 'bank_detail_screen.dart';

class AllBanksScreen extends StatelessWidget {
  const AllBanksScreen({super.key, required this.appState});
  final AppState appState;

  @override
  Widget build(BuildContext context) {
    final banks = [...MockData.banks]..sort((a, b) => b.rate.compareTo(a.rate));
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('All FDs'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          itemCount: banks.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, i) => BankTile(
            bank: banks[i],
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) =>
                    BankDetailScreen(appState: appState, bank: banks[i]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
