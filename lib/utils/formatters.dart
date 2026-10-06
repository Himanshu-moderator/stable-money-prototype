/// Formats a number using Indian digit grouping (e.g. 1234567 -> "12,34,567"),
/// matching the ₹1,22,212-style figures seen throughout the app.
String formatInr(num value, {bool withSymbol = true, int decimals = 0}) {
  final isNegative = value < 0;
  final fixed = value.abs().toStringAsFixed(decimals);
  final parts = fixed.split('.');
  final wholeDigits = parts[0];

  String grouped;
  if (wholeDigits.length <= 3) {
    grouped = wholeDigits;
  } else {
    final last3 = wholeDigits.substring(wholeDigits.length - 3);
    final rest = wholeDigits.substring(0, wholeDigits.length - 3);
    final buffer = StringBuffer();
    for (var i = 0; i < rest.length; i++) {
      final posFromEnd = rest.length - i;
      buffer.write(rest[i]);
      if (posFromEnd > 1 && posFromEnd % 2 == 1) {
        buffer.write(',');
      }
    }
    grouped = '${buffer.toString()},$last3';
  }

  final decimalPart = parts.length > 1 ? '.${parts[1]}' : '';
  final sign = isNegative ? '-' : '';
  final symbol = withSymbol ? '₹' : '';
  return '$sign$symbol$grouped$decimalPart';
}

/// e.g. 24 -> "2Y", 30 -> "2Y 6M", 5 -> "5M".
String formatTenureMonths(int months) {
  final years = months ~/ 12;
  final rem = months % 12;
  if (years == 0) return '${rem}M';
  if (rem == 0) return '${years}Y';
  return '${years}Y ${rem}M';
}
