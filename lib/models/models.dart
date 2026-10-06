import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../utils/finance.dart';

/// What kind of institution is holding the deposit. This matters more than
/// it looks: DICGC insurance covers bank deposits only, so an NBFC fixed
/// deposit is NOT insured, and the app must not imply otherwise.
enum InstitutionType { smallFinanceBank, privateBank, publicBank, nbfc }

extension InstitutionTypeInfo on InstitutionType {
  String get label => switch (this) {
        InstitutionType.smallFinanceBank => 'Small Finance Bank',
        InstitutionType.privateBank => 'Private Sector Bank',
        InstitutionType.publicBank => 'Public Sector Bank',
        InstitutionType.nbfc => 'NBFC',
      };

  /// Only bank deposits fall under DICGC cover.
  bool get dicgcEligible => this != InstitutionType.nbfc;

  String get regulatorNote => switch (this) {
        InstitutionType.nbfc => 'Registered with and regulated by the RBI',
        _ => 'Licensed and regulated by the RBI',
      };
}

/// One rung of a bank's published rate card.
class TenureRate {
  const TenureRate({
    required this.label,
    required this.months,
    required this.rate,
    required this.seniorRate,
  });

  final String label;
  final int months;
  final double rate;
  final double seniorRate;
}

/// A standout fact about the institution, rendered as a swipeable banner.
/// [motif] picks the artwork; [accent] and [deep] set the gradient.
class BankFeature {
  const BankFeature({
    required this.motif,
    required this.eyebrow,
    required this.bigValue,
    required this.headline,
    required this.detail,
    required this.stamp,
  });

  final String motif;
  final String eyebrow;
  final String bigValue;
  final String headline;
  final String detail;
  final String stamp;
}

/// An institutional investor behind the bank. Trust by association: who has
/// already done the diligence a retail depositor cannot.
class Backer {
  const Backer({
    required this.name,
    required this.kind,
    required this.mark,
    required this.color,
  });

  final String name;

  /// e.g. "Sovereign fund", "World Bank arm", "UK development finance".
  final String kind;

  /// Short monogram used in place of a logo asset.
  final String mark;
  final Color color;
}

/// A pre-packaged deposit the bank sells most of.
class BankPlan {
  const BankPlan({
    required this.name,
    required this.tenureLabel,
    required this.months,
    required this.rate,
    required this.minAmount,
    required this.tag,
    required this.why,
  });

  final String name;
  final String tenureLabel;
  final int months;
  final double rate;
  final int minAmount;
  final String tag;
  final String why;
}

/// A bank/NBFC offering fixed deposits, as listed in the "Most booked
/// banks and NBFCs" section.
class FdBank {
  const FdBank({
    required this.name,
    required this.logoLetter,
    required this.logoColor,
    required this.tenureLabel,
    required this.tenureMonths,
    required this.rate,
    this.rateIncreased = false,
    this.type = InstitutionType.smallFinanceBank,
    this.establishedYear,
    this.creditRating,
    this.investorsOnPlatform,
    this.prematurePenaltyPercent = 1.0,
    this.lockInMonths = 3,
    this.payoutNote = 'Interest compounded quarterly, paid at maturity',
    this.publiclyListed = false,
    this.rateCard = const [],
    this.features = const [],
    this.backers = const [],
    this.plans = const [],
    this.aum,
    this.customers,
    this.branches,
    this.headquarters,
  });

  final String name;
  final String logoLetter;
  final Color logoColor;
  final String tenureLabel;
  final int tenureMonths;
  final double rate;
  final bool rateIncreased;

  final InstitutionType type;

  /// Year the institution began operating in its current form.
  final int? establishedYear;

  /// Long-term credit rating, where one is publicly published.
  final String? creditRating;

  /// How many Stable Money users have booked with this institution.
  /// Platform-internal figure, illustrative in this prototype.
  final int? investorsOnPlatform;

  /// Rate reduction applied if the deposit is broken early.
  final double prematurePenaltyPercent;

  /// Minimum period before any premature withdrawal is permitted.
  final int lockInMonths;

  final String payoutNote;

  /// Shown in the header caption alongside the regulator line.
  final bool publiclyListed;

  /// Published rates by tenure, driving the tenure picker and growth chart.
  final List<TenureRate> rateCard;

  /// Bank-specific banner content.
  final List<BankFeature> features;

  /// Institutional investors behind the bank.
  final List<Backer> backers;

  /// The deposits this bank sells most of.
  final List<BankPlan> plans;

  final String? aum;
  final String? customers;
  final String? branches;
  final String? headquarters;

  bool get insured => type.dicgcEligible;

  /// Best available rate across the published card, falling back to the
  /// headline rate when no card is defined.
  double get bestRate => rateCard.isEmpty
      ? rate
      : rateCard.map((r) => r.rate).reduce((a, b) => a > b ? a : b);
}

/// A listed/private bond offering, as shown on the Bonds tab.
class BondOffer {
  const BondOffer({
    required this.issuer,
    required this.logoLetter,
    required this.logoColor,
    required this.title,
    required this.tenureLabel,
    required this.ytm,
    required this.minInvestment,
    required this.percentSold,
    this.strikethroughYtm,
    this.rateDropping = false,
    this.newlyAdded = false,
    this.rating = '',
    this.secured = true,
    this.payout = 'At maturity',
    this.maturityOn = '',
    this.faceValue = 1000,
    this.sector = '',
    this.features = const [],
  });

  final String issuer;
  final String logoLetter;
  final Color logoColor;
  final String title;
  final String tenureLabel;
  final double ytm;
  final double? strikethroughYtm;
  final int minInvestment;
  final int percentSold;
  final bool rateDropping;

  /// Purple "NEWLY ADDED" chip shown on recently listed issues.
  final bool newlyAdded;

  /// Published credit rating for the issue, e.g. "ICRA A-".
  final String rating;

  /// Secured issues are backed by collateral and rank ahead of unsecured
  /// creditors if the issuer runs into trouble. Worth saying plainly.
  final bool secured;

  /// "Monthly" or "At maturity".
  final String payout;
  final String maturityOn;
  final int faceValue;

  /// What the issuer actually lends against, e.g. "Gold loans".
  final String sector;

  /// Swipeable banners, same shape as a bank's.
  final List<BankFeature> features;

  String get grade => rating.isEmpty ? '' : rating.split(' ').last;
}

/// Recurring deposit is a first-class kind because the whole point of the
/// third solution is that the second investment is small and repeating.
enum InvestmentKind { fd, bond, rd }

extension InvestmentKindInfo on InvestmentKind {
  String get label => switch (this) {
        InvestmentKind.fd => 'FD',
        InvestmentKind.bond => 'Bond',
        InvestmentKind.rd => 'RD',
      };
}

/// A booked investment sitting in the user's local (mock) passbook.
class BookedInvestment {
  BookedInvestment({
    required this.kind,
    required this.issuerName,
    required this.logoColor,
    required this.logoLetter,
    required this.principal,
    required this.rate,
    required this.tenureMonths,
    required this.bookedOn,
  });

  final InvestmentKind kind;
  final String issuerName;
  final Color logoColor;
  final String logoLetter;
  final double principal;
  final double rate;
  final int tenureMonths;
  final DateTime bookedOn;

  /// Quarterly-compounded FD/bond growth, matching the "Top 3 FDs"
  /// calculator earnings shown in the app (e.g. ₹1L @ 8.10% for 2Y6M
  /// ≈ ₹1,22,212).
  double get maturityValue => computeMaturity(
        principal: principal,
        ratePercent: rate,
        tenureMonths: tenureMonths,
      );

  double get earnings => maturityValue - principal;

  /// Whole days the money has actually been invested.
  int get daysHeld {
    final d = DateTime.now().difference(bookedOn).inDays;
    return d < 0 ? 0 : d;
  }

  /// Interest accrued to date. A fixed deposit pays nothing until maturity,
  /// so without this the investor has no evidence their money is working.
  double get earnedSoFar => _growth(daysHeld);

  double _growth(int days) {
    if (days <= 0) return 0;
    return principal * (math.pow(1 + (rate / 100) / 4, 4 * days / 365) - 1);
  }

  /// What it will have earned thirty days from booking. Used on a deposit
  /// made today, where the accrued figure would otherwise read zero.
  double get earnedByDay30 => _growth(30);

  DateTime get maturesOn =>
      DateTime(bookedOn.year, bookedOn.month + tenureMonths, bookedOn.day);
}

/// The user's profile, filled progressively during onboarding.
class UserProfile {
  UserProfile({
    this.fullName = '',
    this.email = '',
    this.mobile = '',
    this.pan = '',
    this.day,
    this.month,
    this.year,
    this.gender,
    this.city = '',
    this.occupation,
    this.income,
    this.investmentInterests = const {},
    this.linkedBank,
  });

  String fullName;
  String email;
  String mobile;
  String pan;
  int? day;
  int? month;
  int? year;
  String? gender;
  String city;
  String? occupation;
  String? income;
  Set<String> investmentInterests;
  String? linkedBank;

  /// Phone rendered the way the app shows it on the profile screen:
  /// country code, masked middle, last three digits.
  String get maskedMobile {
    final digits = mobile.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 4) return '';
    return '+91*******${digits.substring(digits.length - 3)}';
  }

  String get initials {
    if (fullName.trim().isEmpty) return 'HC';
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }
}
