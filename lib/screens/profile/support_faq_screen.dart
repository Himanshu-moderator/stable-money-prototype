import 'package:flutter/material.dart';

import '../../data/mock_data.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';

class SupportFaqScreen extends StatelessWidget {
  const SupportFaqScreen({super.key, required this.appState});
  final AppState appState;

  static const _icons = [
    Icons.info_outline,
    Icons.people_alt_outlined,
    Icons.card_giftcard_outlined,
    Icons.description_outlined,
    Icons.verified_user_outlined,
    Icons.credit_card_outlined,
    Icons.account_balance_outlined,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFAF3),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFCFAF3),
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Support & FAQs'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            Text('Hi ${appState.profile.initials},',
                style:
                    const TextStyle(fontSize: 26, fontWeight: FontWeight.w700)),
            const Text('how can we help you today?',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700)),
            const SizedBox(height: 24),
            Text('YOUR TICKETS',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.grey,
                    letterSpacing: 0.6)),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: AppColors.hairline),
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.purpleSoft,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.receipt_long_outlined,
                        color: AppColors.purple),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Track your requests',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w600)),
                        Text('Stay updated on your tickets',
                            style: TextStyle(
                                fontSize: 12, color: AppColors.grey)),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => showPrototypeNotice(context),
                    child: Text('View status >',
                        style: TextStyle(
                            color: AppColors.purple,
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text('FREQUENTLY ASKED QUESTIONS',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.grey,
                    letterSpacing: 0.6)),
            for (var i = 0; i < MockData.supportFaqs.length; i++)
              Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: AppColors.hairline),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(_icons[i % _icons.length], size: 20),
                    ),
                    title: Text(MockData.supportFaqs[i]['title']!,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700)),
                    subtitle: MockData.supportFaqs[i]['subtitle']!.isEmpty
                        ? null
                        : Text(MockData.supportFaqs[i]['subtitle']!),
                    onTap: () => showPrototypeNotice(context),
                  ),
                  const Divider(height: 1),
                ],
              ),
            const SizedBox(height: 24),
            Text('SUPPORT AND ACCOUNT',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.grey,
                    letterSpacing: 0.6)),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: AppColors.hairline),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.chat_bubble_outline, size: 20),
              ),
              title: const Text('Chat with us',
                  style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              subtitle: const Text('We typically respond within 15 mins'),
              onTap: () => showPrototypeNotice(context),
            ),
            const Divider(height: 1),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: AppColors.hairline),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.logout, size: 20),
              ),
              title: const Text('Logout',
                  style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              onTap: () => Navigator.of(context)
                  .popUntil((route) => route.isFirst),
            ),
          ],
        ),
      ),
    );
  }
}
