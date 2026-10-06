import 'dart:math' as math;

/// Quarterly-compounded maturity value — shared by the FD calculator
/// preview and the booked-investment passbook math so both agree.
double computeMaturity({
  required double principal,
  required double ratePercent,
  required int tenureMonths,
}) {
  final years = tenureMonths / 12;
  const n = 4.0;
  return principal * math.pow(1 + (ratePercent / 100) / n, n * years);
}

double computeEarnings({
  required double principal,
  required double ratePercent,
  required int tenureMonths,
}) {
  return computeMaturity(
        principal: principal,
        ratePercent: ratePercent,
        tenureMonths: tenureMonths,
      ) -
      principal;
}
