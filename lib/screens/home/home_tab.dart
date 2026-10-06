import 'package:flutter/material.dart';

import '../../data/mock_data.dart';
import '../../logic/next_step.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../utils/formatters.dart';
import '../../widgets/brand_logo.dart';
import '../../widgets/common.dart';
import '../../widgets/next_step_card.dart';
import '../bonds/bonds_tab.dart';
import '../fd/all_banks_screen.dart';
import '../fd_card/fd_card_tab.dart';
import '../profile/profile_home_screen.dart';

/// The Home tab introduced in the updated app. A cross-product landing:
/// a goals grid covering FD, Bonds, RD and the FD card, the KBC promo, the
/// "Why invest with Stable Money" reasons rail, the investor rail, and the
/// trust footer.
class HomeTab extends StatelessWidget {
  const HomeTab({super.key, required this.appState});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        titleSpacing: 20,
        title: Row(
          children: const [
            BrandLogo(size: 30),
            SizedBox(width: 10),
            Text('stable money',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          ],
        ),
        actions: [
          CircleAvatar(
            backgroundColor: AppColors.cream,
            child: IconButton(
              icon: Icon(Icons.call_outlined,
                  size: 18, color: AppColors.ink),
              onPressed: () => showPrototypeNotice(context, 'Call support'),
            ),
          ),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ProfileHomeScreen(appState: appState),
                ),
              ),
              child: CircleAvatar(
                backgroundColor: AppColors.purpleSoft,
                child: Text(appState.profile.initials,
                    style: TextStyle(
                        color: AppColors.purple, fontWeight: FontWeight.w800)),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const SizedBox(height: 4),
          // Once there is a portfolio the shelf is no longer the first
          // thing a returning user needs. What they are missing is a next
          // step, so it takes the top slot and changes as they build.
          ..._whatsNext(context),
          const _SectionTitle('Explore what fits your goals'),
          const SizedBox(height: 12),
          _goalsGrid(context),
          const SizedBox(height: 28),
          const _SectionTitle('Stable Money presents'),
          const SizedBox(height: 12),
          _kbcCard(context),
          const SizedBox(height: 28),
          const _SectionTitle('Why invest with Stable Money'),
          const SizedBox(height: 12),
          const _ReasonsRail(),
          const SizedBox(height: 28),
          const _SectionTitle('Backed by the best'),
          const SizedBox(height: 12),
          const _BackersRail(),
          const SizedBox(height: 28),
          const TrustStatsFooter(),
        ],
      ),
    );
  }


  /// The recommendation, shown only once the user actually holds something.
  List<Widget> _whatsNext(BuildContext context) {
    final next = Recommender.next(appState);
    if (next == null) return const [];
    final earned = appState.portfolio
        .fold<double>(0, (sum, i) => sum + i.earnedSoFar);
    return [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            Text('What\'s next for you',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink)),
            const Spacer(),
            Text(
              earned > 0
                  ? '${formatInr(earned)} earned so far'
                  : '${appState.portfolio.length} active',
              style: TextStyle(fontSize: 11.5, color: AppColors.grey),
            ),
          ],
        ),
      ),
      const SizedBox(height: 10),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: NextStepCard(appState: appState, step: next),
      ),
      const SizedBox(height: 28),
    ];
  }

  Widget _goalsGrid(BuildContext context) {
    final topRates = [...MockData.banks]
      ..sort((a, b) => b.rate.compareTo(a.rate));
    final topFd = topRates.first;
    final topBond = [...MockData.bonds]
      ..sort((a, b) => b.ytm.compareTo(a.ytm));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _GoalCard(
            title: 'FD',
            pill: "Insured by RBI's DICGC",
            subtitle: 'RBI-regulated',
            rate: '${topFd.rate.toStringAsFixed(2)}%',
            rateSuffix: 'P.A.',
            tall: true,
            trailing: _bankChips(topRates.take(5).toList()),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => AllBanksScreen(appState: appState),
              ),
            ),
          ),
          const SizedBox(height: 10),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 5,
                  child: _GoalCard(
                    title: 'Bonds',
                    pill: 'Senior secured',
                    subtitle: 'SEBI-registered',
                    rate: '${topBond.first.ytm.toStringAsFixed(2)}%',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => BondsTab(appState: appState),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 3,
                  child: _GoalCard(
                    title: 'RD',
                    subtitle: 'RBI-regulated',
                    onTap: () => showPrototypeNotice(context, 'Recurring deposits'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 3,
                  child: _GoalCard(
                    title: 'FD card',
                    subtitle: '0.5% cashback',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => FdCardTab(appState: appState),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bankChips(List banks) {
    return SizedBox(
      height: 26,
      child: Stack(
        children: [
          for (var i = 0; i < banks.length; i++)
            Positioned(
              left: i * 18.0,
              child: Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: banks[i].logoColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.white, width: 2),
                ),
                alignment: Alignment.center,
                child: Text(
                  banks[i].logoLetter.substring(0, 1),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _kbcCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.hairline),
        ),
        child: Column(
          children: [
            // Stand-in for the campaign artwork.
            Container(
              height: 150,
              width: double.infinity,
              color: const Color(0xFFEDE6DA),
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('ISS\nBAAR',
                        style: TextStyle(
                            fontSize: 22,
                            height: 1.1,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFE0651F))),
                    const Text('SOCHNA\nPADEGA',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                            fontSize: 22,
                            height: 1.1,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFE0651F))),
                  ],
                ),
              ),
            ),
            Container(
              color: const Color(0xFF5A1B3D),
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2ECC71),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text('LIVE',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w800)),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Expanded(
                        child: Text.rich(
                          TextSpan(
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                height: 1.35),
                            children: [
                              TextSpan(text: 'Chance to be '),
                              TextSpan(
                                  text: 'on KBC Hotseat\n',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w800)),
                              TextSpan(text: 'with '),
                              TextSpan(
                                  text: 'Amitabh Bachchan',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w800)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () =>
                            showPrototypeNotice(context, 'KBC promo'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF3D67F),
                          foregroundColor: AppColors.onLightSurface,
                          minimumSize: const Size(0, 40),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Participate now',
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(text,
          style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700)),
    );
  }
}

class _GoalCard extends StatelessWidget {
  const _GoalCard({
    required this.title,
    required this.subtitle,
    this.pill,
    this.rate,
    this.rateSuffix,
    this.tall = false,
    this.trailing,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final String? pill;
  final String? rate;
  final String? rateSuffix;
  final bool tall;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap ?? () => showPrototypeNotice(context, title),
      child: Container(
        padding: const EdgeInsets.all(14),
        constraints: BoxConstraints(minHeight: tall ? 128 : 104),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.hairline),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700)),
                if (pill != null) ...[
                  const SizedBox(width: 8),
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.purpleSoft,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(pill!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppColors.purpleDeep)),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 3),
            Text(subtitle,
                style: TextStyle(fontSize: 12, color: AppColors.grey)),
            const Spacer(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (rate != null)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(rate!,
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: AppColors.green)),
                      if (rateSuffix != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 3, left: 3),
                          child: Text(rateSuffix!,
                              style: TextStyle(
                                  fontSize: 10, color: AppColors.grey)),
                        ),
                    ],
                  ),
                if (trailing != null) ...[
                  const SizedBox(width: 12),
                  Expanded(child: trailing!),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// "Why invest with Stable Money" — a horizontally scrolling rail of
/// numbered reason cards, each with a large faded ordinal behind it.
class _ReasonsRail extends StatelessWidget {
  const _ReasonsRail();

  static const _reasons = [
    (
      'Your money stays with regulated institutions',
      'Invest directly with RBI-regulated banks, NBFCs and trusted financial institutions.',
    ),
    (
      'All your savings in one place',
      'Invest in FDs, Bonds, Recurring Deposits and more, and track them together.',
    ),
    (
      'Rates you would not find alone',
      'Compare 200+ banks and NBFCs in one place and book the best available rate.',
    ),
    (
      'No hidden fees. Complete transparency',
      'No annual charges or hidden platform fees, just transparent investing.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 168,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _reasons.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final r = _reasons[i];
          return SizedBox(
            width: 268,
            child: Stack(
              children: [
                Positioned(
                  left: -6,
                  bottom: -26,
                  child: Text(
                    '${i + 1}',
                    style: TextStyle(
                      fontSize: 92,
                      fontWeight: FontWeight.w800,
                      color: AppColors.hairline.withValues(alpha: 0.8),
                      height: 1,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.hairline),
                    borderRadius: BorderRadius.circular(16),
                    color: AppColors.white.withValues(alpha: 0.92),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(r.$1,
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              height: 1.25)),
                      const SizedBox(height: 8),
                      Expanded(
                        child: Text(r.$2,
                            style: TextStyle(
                                fontSize: 12,
                                color: AppColors.grey,
                                height: 1.45)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// "Backed by the best" — the investor and advisor rail.
class _BackersRail extends StatelessWidget {
  const _BackersRail();

  static const _backers = [
    ('Nandan Nilekani', 'Non-ex chairman', 'Infosys'),
    ('Kunal Bahl', 'Former CEO', 'Snapdeal'),
    ('Fundamentum', 'Led', 'Series B'),
    ('Lightspeed', 'Investor', 'Seed to B'),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 190,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _backers.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final b = _backers[i];
          return Container(
            width: 210,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.hairline),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(b.$1,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Text(b.$2,
                        style: TextStyle(
                            fontSize: 12, color: AppColors.grey)),
                    const SizedBox(width: 5),
                    Text(b.$3,
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.inkSoft)),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.cream,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.bottomCenter,
                    child: Icon(Icons.person,
                        size: 62, color: AppColors.greyLight),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
