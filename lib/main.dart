import 'package:flutter/material.dart';

import 'screens/onboarding/mobile_number_screen.dart';
import 'state/app_state.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(StableMoneyCloneApp(appState: AppState()));
}

/// Root of the prototype. A single [AppState] instance is created here and
/// threaded through every screen — there is no backend, so this is the
/// entire "database" for the demo.
class StableMoneyCloneApp extends StatelessWidget {
  const StableMoneyCloneApp({super.key, required this.appState});
  final AppState appState;

  @override
  Widget build(BuildContext context) {
    // Rebuilt whenever the appearance changes, so a palette swap repaints
    // every screen at once.
    return AnimatedBuilder(
      animation: themeController,
      builder: (context, _) => MaterialApp(
        title: 'Stable Money (Prototype)',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.data,
        home: MobileNumberScreen(appState: appState),
        builder: (context, child) => PhonePreviewFrame(
          child: AppBackdrop(child: child!),
        ),
      ),
    );
  }
}

/// Paints the gradient appearance behind the whole app. Surfaces are left
/// translucent on that theme, so the gradient carries through the page
/// instead of stopping at the first card.
class AppBackdrop extends StatelessWidget {
  const AppBackdrop({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final gradient = AppColors.pageGradient;
    if (gradient == null) return child;
    return DecoratedBox(
      decoration: BoxDecoration(gradient: gradient),
      child: child,
    );
  }
}

/// On a phone the app runs edge to edge. On anything wider — a laptop
/// browser, a projector, a shared link opened on a desktop — it is centred
/// inside a phone-sized frame so the prototype reads as a mobile app rather
/// than a stretched web page.
class PhonePreviewFrame extends StatelessWidget {
  const PhonePreviewFrame({super.key, required this.child});

  final Widget child;

  /// Below this width we assume a real phone and skip the frame entirely.
  static const _breakpoint = 620.0;
  static const _deviceWidth = 390.0;
  static const _deviceHeight = 844.0;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    if (size.width < _breakpoint) return child;

    final frameHeight =
        _deviceHeight.clamp(0.0, (size.height - 48).clamp(320.0, _deviceHeight));

    // The surround follows the appearance too, so a dark phone is not
    // floating on a bright desk.
    return ColoredBox(
      color: switch (AppColors.mode) {
        AppThemeMode.light => const Color(0xFFEDEAE3),
        AppThemeMode.dark => const Color(0xFF0E0F13),
        AppThemeMode.gradient => const Color(0xFF0C0920),
      },
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: _deviceWidth,
              height: frameHeight,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(38),
                border: Border.all(color: const Color(0xFF1A1A1A), width: 8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.18),
                    blurRadius: 40,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: MediaQuery(
                // Re-scope the media query so screens lay out against the
                // frame, not the browser window.
                data: MediaQuery.of(context).copyWith(
                  size: Size(_deviceWidth, frameHeight),
                  padding: EdgeInsets.zero,
                  viewPadding: EdgeInsets.zero,
                  viewInsets: EdgeInsets.zero,
                ),
                child: child,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Stable Money — interactive prototype',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
