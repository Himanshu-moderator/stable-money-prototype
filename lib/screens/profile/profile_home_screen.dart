import 'package:flutter/material.dart';

import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/appearance_sheet.dart';
import '../../widgets/common.dart';
import 'profile_details_screen.dart';
import 'support_faq_screen.dart';
import '../../widgets/brand_logo.dart';

/// Matches the profile screenshots: purple-tinted photo backdrop, avatar
/// with a profile-completion badge, name, masked mobile, "Edit profile"
/// pill, then the five-row menu (Profile details, Invite friends & family,
/// Chat with us, Support and FAQs, Rate us on Play Store) and the legal
/// footer carrying the app version and the sub-agent disclaimer.
class ProfileHomeScreen extends StatelessWidget {
  const ProfileHomeScreen({super.key, required this.appState});
  final AppState appState;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Stack(
              children: [
                Container(
                  height: 220,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF6C4FD9), Color(0xFFB9A6F2)],
                    ),
                  ),
                  child: const Center(
                    child: Icon(Icons.account_balance,
                        size: 90, color: Colors.white24),
                  ),
                ),
                Positioned(
                  top: 4,
                  left: 4,
                  child: IconButton(
                    icon: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(Icons.chevron_left, color: AppColors.onLightSurface),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ],
            ),
            Transform.translate(
              offset: const Offset(0, -46),
              child: Column(
                children: [
                  SizedBox(
                    height: 100,
                    child: Stack(
                      alignment: Alignment.topCenter,
                      children: [
                        CircleAvatar(
                          radius: 46,
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            radius: 42,
                            backgroundColor: AppColors.purpleSoft,
                            child: Text(
                              appState.profile.initials,
                              style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.purple),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.purple,
                              borderRadius: BorderRadius.circular(12),
                              border:
                                  Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Text('100%',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    appState.profile.initials,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                  if (appState.profile.maskedMobile.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      appState.profile.maskedMobile,
                      style: TextStyle(
                          fontSize: 14, color: AppColors.grey),
                    ),
                  ],
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            ProfileDetailsScreen(appState: appState),
                      ),
                    ),
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    label: const Text('Edit profile'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.ink,
                      side: BorderSide(color: AppColors.hairline),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  const Divider(height: 1, indent: 24, endIndent: 24),
                  ListTile(
                    leading: const Icon(Icons.badge_outlined),
                    title: const Text('Profile details'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            ProfileDetailsScreen(appState: appState),
                      ),
                    ),
                  ),
                  const Divider(height: 1, indent: 24, endIndent: 24),
                  ListTile(
                    leading: const Icon(Icons.palette_outlined),
                    title: const Text('Appearance'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(themeController.mode.label,
                            style: TextStyle(
                                fontSize: 13, color: AppColors.grey)),
                        const SizedBox(width: 6),
                        const Icon(Icons.chevron_right),
                      ],
                    ),
                    onTap: () => showAppearanceSheet(context),
                  ),
                  const Divider(height: 1, indent: 24, endIndent: 24),
                  ListTile(
                    leading: const Icon(Icons.card_giftcard_outlined),
                    title: const Text('Invite friends & family'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.greenSoft,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text('INVITE',
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.greenInk)),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.chevron_right),
                      ],
                    ),
                    onTap: () => showPrototypeNotice(context, 'Invite'),
                  ),
                  const Divider(height: 1, indent: 24, endIndent: 24),
                  ListTile(
                    leading: const Icon(Icons.chat_bubble_outline),
                    title: const Text('Chat with us'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => showPrototypeNotice(context, 'Chat'),
                  ),
                  const Divider(height: 1, indent: 24, endIndent: 24),
                  ListTile(
                    leading: const Icon(Icons.help_outline),
                    title: const Text('Support and FAQs'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => SupportFaqScreen(appState: appState),
                      ),
                    ),
                  ),
                  const Divider(height: 1, indent: 24, endIndent: 24),
                  ListTile(
                    leading: const Icon(Icons.star_border),
                    title: const Text('Rate us on Play Store'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => showPrototypeNotice(context, 'Play Store'),
                  ),
                  const Divider(height: 1, indent: 24, endIndent: 24),
                  const SizedBox(height: 32),
                  const _LegalFooter(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Wordmark, app version and the sub-agent/referral-partner disclaimer that
/// closes the profile screen.
class _LegalFooter extends StatelessWidget {
  const _LegalFooter();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              BrandLogo(
                  size: 26, ring: false, squareColor: AppColors.greyLight),
              const SizedBox(width: 8),
              Text('stable money',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.greyLight)),
              const Spacer(),
              Text('App version 2.9.15',
                  style: TextStyle(fontSize: 12, color: AppColors.greyLight)),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Disclaimer: Fixed Deposits are offered by Banks and NBFCs and are '
            'regulated by the Reserve Bank of India. Stable Finserv Private '
            'Limited using the brand name Stable Money is acting in the capacity '
            'of Sub Agent/Referral Partner for distribution of Fixed Deposits(FD) '
            'of Banks and NBFCs.',
            style: TextStyle(
                fontSize: 11, color: AppColors.greyLight, height: 1.45),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              GestureDetector(
                onTap: () => showPrototypeNotice(context, 'TnC'),
                child: Text('TnC',
                    style: TextStyle(
                        fontSize: 12,
                        color: AppColors.grey,
                        decoration: TextDecoration.underline)),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text('|',
                    style: TextStyle(fontSize: 12, color: AppColors.greyLight)),
              ),
              GestureDetector(
                onTap: () => showPrototypeNotice(context, 'Privacy Policy'),
                child: Text('Privacy Policy',
                    style: TextStyle(
                        fontSize: 12,
                        color: AppColors.grey,
                        decoration: TextDecoration.underline)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
