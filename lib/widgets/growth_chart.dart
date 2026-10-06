import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../utils/finance.dart';
import '../utils/formatters.dart';

/// Compact area chart showing how a deposit compounds across its tenure.
/// Hand-drawn rather than pulled from a charting package, since the project
/// deliberately ships with no chart dependency.
class GrowthChart extends StatelessWidget {
  const GrowthChart({
    super.key,
    required this.principal,
    required this.ratePercent,
    required this.tenureMonths,
    this.height = 150,
  });

  final double principal;
  final double ratePercent;
  final int tenureMonths;
  final double height;

  @override
  Widget build(BuildContext context) {
    final maturity = computeMaturity(
      principal: principal,
      ratePercent: ratePercent,
      tenureMonths: tenureMonths,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: height,
          width: double.infinity,
          child: CustomPaint(
            painter: _GrowthPainter(
              principal: principal,
              ratePercent: ratePercent,
              tenureMonths: tenureMonths,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _Axis(label: 'Today', value: formatInr(principal)),
            _Axis(
              label: formatTenureMonths(tenureMonths),
              value: formatInr(maturity),
              alignEnd: true,
            ),
          ],
        ),
      ],
    );
  }
}

class _Axis extends StatelessWidget {
  const _Axis({
    required this.label,
    required this.value,
    this.alignEnd = false,
  });

  final String label;
  final String value;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(fontSize: 11, color: AppColors.grey)),
        const SizedBox(height: 2),
        Text(value,
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _GrowthPainter extends CustomPainter {
  const _GrowthPainter({
    required this.principal,
    required this.ratePercent,
    required this.tenureMonths,
  });

  final double principal;
  final double ratePercent;
  final int tenureMonths;

  @override
  void paint(Canvas canvas, Size size) {
    if (tenureMonths <= 0 || principal <= 0) return;

    const steps = 48;
    final maturity = computeMaturity(
      principal: principal,
      ratePercent: ratePercent,
      tenureMonths: tenureMonths,
    );
    final span = (maturity - principal).abs() < 1 ? 1.0 : maturity - principal;

    Offset pointAt(int i) {
      final months = tenureMonths * i / steps;
      final value = computeMaturity(
        principal: principal,
        ratePercent: ratePercent,
        tenureMonths: months.round(),
      );
      final x = size.width * i / steps;
      // Leave headroom so the curve never touches the top edge.
      final t = (value - principal) / span;
      final y = size.height - (t * (size.height - 18)) - 10;
      return Offset(x, y);
    }

    // Baseline showing the principal, so the shaded area reads as earnings.
    final baseline = Paint()
      ..color = AppColors.hairline
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(0, size.height - 10),
      Offset(size.width, size.height - 10),
      baseline,
    );

    final curve = Path()..moveTo(0, pointAt(0).dy);
    for (var i = 1; i <= steps; i++) {
      final p = pointAt(i);
      curve.lineTo(p.dx, p.dy);
    }

    final fill = Path.from(curve)
      ..lineTo(size.width, size.height - 10)
      ..lineTo(0, size.height - 10)
      ..close();

    canvas.drawPath(
      fill,
      Paint()..color = AppColors.green.withValues(alpha: 0.13),
    );
    canvas.drawPath(
      curve,
      Paint()
        ..color = AppColors.green
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeJoin = StrokeJoin.round
        ..isAntiAlias = true,
    );

    final end = pointAt(steps);
    canvas.drawCircle(end, 5, Paint()..color = Colors.white);
    canvas.drawCircle(
      end,
      5,
      Paint()
        ..color = AppColors.green
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
  }

  @override
  bool shouldRepaint(_GrowthPainter old) =>
      old.principal != principal ||
      old.ratePercent != ratePercent ||
      old.tenureMonths != tenureMonths;
}
