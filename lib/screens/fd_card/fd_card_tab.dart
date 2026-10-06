import 'package:flutter/material.dart';

import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import '../../widgets/brand_logo.dart';

class FdCardTab extends StatelessWidget {
  const FdCardTab({super.key, required this.appState});
  final AppState appState;

  static const _benefits = [
    ('Lounge Access', false, true),
    ('Lifetime free & 0.5% cashback', true, true),
    ('Fuel Surcharge Waiver', true, true),
    ('RuPay brand offers', true, true),
    ('Insurance & concierge', true, true),
    ('Gym membership', false, true),
    ('Cabs discount', false, true),
    ('Golf sessions', false, true),
    ('Health check-ups', false, true),
    ('Spa & Salon coupons', false, true),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        titleSpacing: 20,
        title: Row(
          children: [
            const BrandLogo(size: 30),
            const SizedBox(width: 10),
            const Text('stable money',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              backgroundColor: AppColors.cream,
              child: IconButton(
                icon: Icon(Icons.help_outline, size: 18, color: AppColors.ink),
                onPressed: () => showPrototypeNotice(context, 'Card help'),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFEDE6FB), Color(0xFFFFFFFF)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              children: [
                Text('FD-BACKED CREDIT CARD',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.purple,
                        letterSpacing: 1)),
                const SizedBox(height: 6),
                Text('LIFETIME FREE',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: AppColors.purple)),
                const Text('SECURED CREDIT CARD',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
                const SizedBox(height: 6),
                Text('No income proof needed, 100% approval rate',
                    style: TextStyle(color: AppColors.grey, fontSize: 12)),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.hairline),
                  ),
                  child: Row(
                    children: const [
                      Expanded(child: _Step(step: 'STEP 1', label: 'Book an FD\nwith us')),
                      _StepDivider(),
                      Expanded(child: _Step(step: 'STEP 2', label: 'Request card\nfor your FD')),
                      _StepDivider(),
                      Expanded(child: _Step(step: 'STEP 3', label: 'Get 90%\nlimit of FD')),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                _cardMockup(),
                const SizedBox(height: 10),
                Text('Stable Money Suryoday Bank Credit Card',
                    style: TextStyle(fontSize: 12, color: AppColors.grey)),
                const SizedBox(height: 18),
                BlackPillButton(
                  label: 'Apply now',
                  icon: Icons.bolt,
                  onPressed: () => showPrototypeNotice(context, 'Card application'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Compare benefits',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.hairline),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(color: AppColors.hairline)),
                        ),
                        child: Row(
                          children: [
                            const Expanded(flex: 3, child: SizedBox()),
                            const Expanded(
                                child: Text('Basic',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700))),
                            Expanded(
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.purpleSoft,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text('RuPay Select',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.purple)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      for (final b in _benefits)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            border: Border(
                                bottom:
                                    BorderSide(color: AppColors.hairline)),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                  flex: 3,
                                  child: Text(b.$1,
                                      style: const TextStyle(fontSize: 13))),
                              Expanded(
                                child: Center(
                                  child: b.$2
                                      ? Icon(Icons.check,
                                          color: AppColors.purple, size: 18)
                                      : Text('—',
                                          style: TextStyle(
                                              color: AppColors.greyLight)),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  color: AppColors.purpleSoft.withValues(alpha: 0.5),
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  child: Center(
                                    child: Icon(Icons.check,
                                        color: AppColors.purple, size: 18),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "RuPay Select is available for FD amount above ₹1,15,000. The max age limit to get a credit card is 80 years.",
                  style: TextStyle(fontSize: 12, color: AppColors.grey),
                ),
                const SizedBox(height: 6),
                const Text('Read full details of card offers & benefits here.',
                    style: TextStyle(
                        fontSize: 12,
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 18),
                BlackPillButton(
                  label: 'Apply now',
                  icon: Icons.bolt,
                  onPressed: () => showPrototypeNotice(context, 'Card application'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          Container(
            height: 200,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: const Color(0xFF2C2420),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Center(
              child: Icon(Icons.airline_seat_recline_extra,
                  color: Colors.white24, size: 64),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              "Lounge access is available only with physical cards and is applicable for users who have an FD of over ₹40,000 with Suryoday Bank. Read complete details here.",
              style: TextStyle(fontSize: 12, color: AppColors.grey),
            ),
          ),
          const SizedBox(height: 20),
          const Center(
            child: Text('Know your card',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Discover the benefits that match your lifestyle and spending habits',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.grey),
            ),
          ),
          const SizedBox(height: 18),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: BlackPillButton(
              label: 'Apply now',
              icon: Icons.bolt,
              onPressed: () => showPrototypeNotice(context, 'Card application'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cardMockup() {
    return SizedBox(
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.rotate(
            angle: -0.12,
            child: Container(
              width: 190,
              height: 110,
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          Transform.rotate(
            angle: 0.02,
            child: Container(
              width: 190,
              height: 110,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF7B5CFF), Color(0xFF5A3FD1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      BrandLogo(
                          size: 22,
                          ring: false,
                          squareColor: Colors.transparent),
                      Icon(Icons.wifi, color: Colors.white70, size: 16),
                    ],
                  ),
                  Spacer(),
                  Text('stable money',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({required this.step, required this.label});
  final String step;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(step,
            style: TextStyle(
                fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.grey)),
        const SizedBox(height: 4),
        Text(label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _StepDivider extends StatelessWidget {
  const _StepDivider();
  @override
  Widget build(BuildContext context) =>
      SizedBox(height: 36, child: VerticalDivider(color: AppColors.hairline));
}
