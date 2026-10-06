import 'package:flutter/material.dart';

import '../../models/models.dart';

/// Carries the fixed terms (issuer, rate, tenure) through the booking
/// flow; only the amount is editable by the user.
class BookingArgs {
  const BookingArgs({
    required this.kind,
    required this.issuerName,
    required this.logoLetter,
    required this.logoColor,
    required this.rate,
    required this.tenureMonths,
    required this.tenureLabel,
    required this.defaultAmount,
    required this.minAmount,
    this.institutionLabel = '',
    this.insured = true,
    this.prematurePenaltyPercent = 1.0,
    this.lockInMonths = 3,
    this.rating = '',
    this.secured = true,
  });

  final InvestmentKind kind;
  final String issuerName;
  final String logoLetter;
  final Color logoColor;
  final double rate;
  final int tenureMonths;
  final String tenureLabel;
  final int defaultAmount;
  final int minAmount;

  // Carried through so the terms step can state the actual deal rather than
  // generic boilerplate: this bank's penalty, this issue's rating, whether
  // deposit insurance applies at all.

  /// e.g. "Small Finance Bank", "NBFC", "MSME lending".
  final String institutionLabel;

  /// DICGC cover applies. False for NBFC deposits and for every bond.
  final bool insured;

  final double prematurePenaltyPercent;
  final int lockInMonths;

  /// Bond only.
  final String rating;
  final bool secured;

  String get kindLabel => kind == InvestmentKind.fd ? 'FD' : 'Bond';
}
