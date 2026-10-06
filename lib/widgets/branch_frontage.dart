import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// The header band on a bank or issuer page: an illustrated branch frontage
/// with the institution's signboard over it, in place of a flat colour wash.
///
/// The real app puts a photograph of the branch here, which is the first
/// thing a hesitant depositor sees. There is no photography in this project
/// and inventing a specific bank's premises would be worse than an obvious
/// illustration, so the frontage is drawn as vectors and tinted with the
/// institution's own colour. Every bank gets the same architecture and a
/// different palette and sign, the way a real high street looks.
class BranchFrontage extends StatelessWidget {
  const BranchFrontage({
    super.key,
    required this.name,
    required this.letter,
    required this.brand,
    this.height = 210,
    this.overlay,
  });

  final String name;
  final String letter;
  final Color brand;
  final double height;

  /// The app bar row, drawn over the artwork.
  final Widget? overlay;

  static const double signTop = 60;
  static const double signHeight = 40;

  @override
  Widget build(BuildContext context) {
    var hsl = HSLColor.fromColor(brand);

    // On a dark page a near-black brand would print a black band on a black
    // background and the frontage would disappear. Lift the floor, and give
    // the darkest marks a little saturation to hold on to.
    if (AppColors.isDark) {
      hsl = hsl
          .withLightness(hsl.lightness.clamp(0.26, 0.62))
          .withSaturation(hsl.saturation < 0.12 ? 0.12 : hsl.saturation);
    }

    final base = hsl.toColor();
    final deep = hsl
        .withLightness((hsl.lightness - (AppColors.isDark ? 0.14 : 0.30))
            .clamp(0.06, 1.0))
        .toColor();
    final board = hsl
        .withLightness((hsl.lightness - 0.16).clamp(0.06, 1.0))
        .toColor();

    return SizedBox(
      height: height,
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [base, deep],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: CustomPaint(painter: _FrontagePainter(board: board)),
          ),

          // Signboard lettering, laid over the board the painter drew.
          Positioned(
            left: 26,
            right: 26,
            top: signTop,
            height: signHeight,
            child: Row(
              children: [
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(7),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    letter,
                    style: TextStyle(
                      color: base,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      name.toUpperCase(),
                      maxLines: 1,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        letterSpacing: 1.6,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (overlay != null) Positioned.fill(child: overlay!),
        ],
      ),
    );
  }
}

class _FrontagePainter extends CustomPainter {
  const _FrontagePainter({required this.board});

  /// Fill for the signboard, a shade down from the brand colour.
  final Color board;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // The white sheet of the page starts around here, so nothing below the
    // pavement is ever seen.
    final ground = h * 0.78;
    const signTop = BranchFrontage.signTop;
    const signH = BranchFrontage.signHeight;
    final glassTop = signTop + signH + 8;
    final glassBottom = ground - 14;

    Paint fill(double a) => Paint()..color = Colors.white.withValues(alpha: a);

    // Building block behind everything, so the frontage reads as a structure
    // rather than shapes floating on a gradient.
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTRB(8, signTop - 14, w - 8, ground),
        topLeft: const Radius.circular(10),
        topRight: const Radius.circular(10),
      ),
      fill(0.06),
    );

    // Cornice above the sign.
    canvas.drawRect(Rect.fromLTWH(2, signTop - 14, w - 4, 7), fill(0.13));

    // Signboard.
    final signRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(14, signTop, w - 28, signH),
      const Radius.circular(6),
    );
    canvas.drawRRect(signRect, Paint()..color = board);
    canvas.drawRRect(
      signRect,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.28)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
    // Light strip along the top edge, the way an illuminated fascia catches.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(18, signTop + 3, w - 36, 2.5),
        const Radius.circular(2),
      ),
      fill(0.30),
    );

    // Shopfront glazing: five bays, the middle one the entrance.
    const margin = 22.0;
    const gap = 5.0;
    final bayW = (w - margin * 2 - gap * 4) / 5;
    for (var i = 0; i < 5; i++) {
      final x = margin + i * (bayW + gap);
      final entrance = i == 2;
      final rect = Rect.fromLTRB(
        x,
        entrance ? glassTop - 4 : glassTop,
        x + bayW,
        glassBottom,
      );
      canvas.drawRRect(
        RRect.fromRectAndCorners(
          rect,
          topLeft: Radius.circular(entrance ? 10 : 3),
          topRight: Radius.circular(entrance ? 10 : 3),
        ),
        fill(entrance ? 0.30 : 0.14),
      );
      // Mullion shadow down the right edge of each bay.
      canvas.drawRect(
        Rect.fromLTWH(x + bayW - 1, rect.top, 1, rect.height),
        fill(0.20),
      );
    }

    // Two diagonal reflections sweeping across the glazing.
    canvas.save();
    canvas.clipRect(Rect.fromLTRB(margin, glassTop - 6, w - margin, glassBottom));
    for (final start in [w * 0.16, w * 0.52]) {
      final streak = Path()
        ..moveTo(start, glassBottom)
        ..lineTo(start + 34, glassTop - 8)
        ..lineTo(start + 60, glassTop - 8)
        ..lineTo(start + 26, glassBottom)
        ..close();
      canvas.drawPath(streak, fill(0.10));
    }
    canvas.restore();

    // Door handle.
    final doorX = margin + 2 * (bayW + gap) + bayW * 0.72;
    canvas.drawLine(
      Offset(doorX, glassTop + 26),
      Offset(doorX, glassTop + 44),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.70)
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round,
    );

    // A small plate on the left bay, the kind every branch carries.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(margin + 7, glassTop + 12, 30, 11),
        const Radius.circular(2),
      ),
      fill(0.26),
    );

    // Planters either side of the entrance.
    for (final side in [-1.0, 1.0]) {
      final px = w / 2 + side * (bayW + gap + 6);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(px - 9, glassBottom - 16, 18, 16),
          const Radius.circular(3),
        ),
        fill(0.22),
      );
      canvas.drawCircle(Offset(px, glassBottom - 22), 9, fill(0.16));
      canvas.drawCircle(Offset(px - 6, glassBottom - 18), 6, fill(0.14));
      canvas.drawCircle(Offset(px + 6, glassBottom - 18), 6, fill(0.14));
    }

    // Step and pavement.
    canvas.drawRect(
      Rect.fromLTWH(margin + 2 * (bayW + gap) - 8, glassBottom, bayW + 16, 5),
      fill(0.24),
    );
    canvas.drawRect(Rect.fromLTWH(0, glassBottom + 5, w, h - glassBottom), fill(0.09));
    canvas.drawRect(Rect.fromLTWH(0, glassBottom + 5, w, 1.5), fill(0.18));
  }

  @override
  bool shouldRepaint(_FrontagePainter old) => old.board != board;
}
