import 'package:flutter/material.dart';

import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/brand_logo.dart';
import '../bonds/bonds_tab.dart';
import '../fd/fd_tab.dart';
import '../home/home_tab.dart';
import '../passbook/passbook_tab.dart';

/// Persistent bottom-nav shell: Home | FD | Bonds | Passbook, matching the
/// updated app. The FD Card tab was dropped from the nav in that release —
/// the card is still a product, reached from the Home grid and the
/// "FD-backed card" tile on the FD tab. Only the active tab is built, so
/// switching tabs resets scroll position (fine for a prototype).
class MainShell extends StatefulWidget {
  const MainShell({super.key, required this.appState, this.initialIndex = 0});

  final AppState appState;
  final int initialIndex;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _index = widget.initialIndex;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.appState,
      builder: (context, _) => _buildScaffold(),
    );
  }

  Widget _buildScaffold() {
    final Widget page = switch (_index) {
      0 => HomeTab(appState: widget.appState),
      1 => FdTab(appState: widget.appState),
      2 => BondsTab(appState: widget.appState),
      _ => PassbookTab(appState: widget.appState),
    };

    return Scaffold(
      body: page,
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: AppColors.hairline)),
          ),
          child: Row(
            children: [
              _NavItem(
                key: const ValueKey('nav-home'),
                label: 'Home',
                selected: _index == 0,
                markIcon: true,
                onTap: () => setState(() => _index = 0),
              ),
              _NavItem(
                key: const ValueKey('nav-fd'),
                label: 'FD',
                selected: _index == 1,
                icon: Icons.account_balance,
                onTap: () => setState(() => _index = 1),
              ),
              _NavItem(
                key: const ValueKey('nav-bonds'),
                label: 'Bonds',
                selected: _index == 2,
                badgeText: '12%',
                onTap: () => setState(() => _index = 2),
              ),
              _NavItem(
                key: const ValueKey('nav-passbook'),
                label: 'Passbook',
                selected: _index == 3,
                icon: Icons.menu_book_outlined,
                onTap: () => setState(() => _index = 3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
    this.badgeText,
    this.markIcon = false,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;
  final String? badgeText;

  /// Home uses the Stable Money paper-plane mark instead of a Material icon.
  final bool markIcon;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.ink : AppColors.greyLight;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (markIcon)
                BrandLogo(
                  size: 24,
                  ring: false,
                  squareColor: Colors.transparent,
                  markColor: color,
                )
              else if (icon != null)
                Icon(icon, color: color, size: 24)
              else
                Text(badgeText ?? '',
                    style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w800,
                        fontSize: 18)),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
