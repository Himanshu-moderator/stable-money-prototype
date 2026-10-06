import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Appearance picker. Each row carries a small swatch built from the palette
/// it is offering, so the choice is made by looking rather than by reading.
Future<void> showAppearanceSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) => AnimatedBuilder(
      animation: themeController,
      builder: (context, _) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Appearance',
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink)),
              ),
            ),
            for (final mode in AppThemeMode.values)
              _AppearanceRow(
                mode: mode,
                selected: themeController.mode == mode,
                onTap: () => themeController.select(mode),
              ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    ),
  );
}

class _AppearanceRow extends StatelessWidget {
  const _AppearanceRow({
    required this.mode,
    required this.selected,
    required this.onTap,
  });

  final AppThemeMode mode;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            _Swatch(mode: mode),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(mode.label,
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink)),
                  const SizedBox(height: 2),
                  Text(mode.blurb,
                      style:
                          TextStyle(fontSize: 12, color: AppColors.grey)),
                ],
              ),
            ),
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              size: 20,
              color: selected ? AppColors.purple : AppColors.greyLight,
            ),
          ],
        ),
      ),
    );
  }
}

/// A miniature of the page each appearance produces: background, a card, a
/// line of type and the accent.
class _Swatch extends StatelessWidget {
  const _Swatch({required this.mode});

  final AppThemeMode mode;

  @override
  Widget build(BuildContext context) {
    final (bg, card, text, accent) = switch (mode) {
      AppThemeMode.light => (
          const Color(0xFFFFFFFF),
          const Color(0xFFFBF8F2),
          const Color(0xFF1A1A1A),
          const Color(0xFF6C4FD9),
        ),
      AppThemeMode.dark => (
          const Color(0xFF1B1D23),
          const Color(0xFF2C2F38),
          const Color(0xFFEDEBE7),
          const Color(0xFFAE95FF),
        ),
      AppThemeMode.gradient => (
          const Color(0xFF1B1443),
          const Color(0xFF2E2260),
          const Color(0xFFF1EEF8),
          const Color(0xFFBBA4FF),
        ),
    };

    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: mode == AppThemeMode.gradient ? null : bg,
        gradient: mode == AppThemeMode.gradient
            ? const LinearGradient(
                colors: [Color(0xFF150F30), Color(0xFF2E2060)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: AppColors.hairline),
      ),
      padding: const EdgeInsets.all(7),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            height: 12,
            decoration: BoxDecoration(
              color: card,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          Container(height: 3, width: 20, color: text),
          Row(
            children: [
              Container(
                height: 6,
                width: 6,
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 3),
              Container(height: 3, width: 12, color: text.withValues(alpha: 0.5)),
            ],
          ),
        ],
      ),
    );
  }
}
