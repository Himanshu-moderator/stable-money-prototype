import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// The Stable Money app mark: a purple hairline ring, a white gap, a dark
/// rounded square, and inside it a white two-piece paper-plane pointing to
/// the upper right. Drawn rather than shipped as an asset so the prototype
/// stays a single self-contained Flutter project.
class BrandLogo extends StatelessWidget {
  const BrandLogo({
    super.key,
    this.size = 30,
    this.ring = true,
    this.squareColor,
    this.markColor,
  });

  final double size;

  /// The purple outline that sits around the mark in the app header.
  final bool ring;

  /// Defaults follow the active theme, so the mark stays legible on a dark
  /// page instead of turning into a dark square on a dark background.
  final Color? squareColor;
  final Color? markColor;

  @override
  Widget build(BuildContext context) {
    final square = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: squareColor ?? AppColors.ctaFill,
        borderRadius: BorderRadius.circular(size * 0.29),
      ),
      child: Padding(
        padding: EdgeInsets.all(size * 0.24),
        child: CustomPaint(
            painter: _PlaneMarkPainter(color: markColor ?? AppColors.onCta)),
      ),
    );

    if (!ring) return square;

    return Container(
      padding: EdgeInsets.all(size * 0.09),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.42),
        border: Border.all(color: AppColors.purple, width: size * 0.045),
      ),
      child: square,
    );
  }
}

/// Paper-plane glyph, tip at the upper right, split along its spine into a
/// broad upper wing and a narrower lower tail.
class _PlaneMarkPainter extends CustomPainter {
  const _PlaneMarkPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    double x(double v) => v / 100 * size.width;
    double y(double v) => v / 100 * size.height;

    final upperWing = Path()
      ..moveTo(x(100), y(0))
      ..lineTo(x(4), y(26))
      ..lineTo(x(46), y(50))
      ..close();

    final lowerTail = Path()
      ..moveTo(x(100), y(0))
      ..lineTo(x(52), y(56))
      ..lineTo(x(60), y(100))
      ..lineTo(x(38), y(70))
      ..close();

    canvas.drawPath(upperWing, paint);
    canvas.drawPath(lowerTail, paint);
  }

  @override
  bool shouldRepaint(_PlaneMarkPainter oldDelegate) =>
      oldDelegate.color != color;
}
