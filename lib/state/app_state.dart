import 'package:flutter/material.dart';

import '../models/models.dart';

/// Single global store for the prototype. Everything here is in-memory
/// only (lost on app restart) — there is no backend, matching the "low
/// backend, mock data" brief.
class AppState extends ChangeNotifier {
  final UserProfile profile = UserProfile();
  final List<BookedInvestment> portfolio = [];

  String? pendingMobile;

  /// KYC is collected at the point of booking, not at login. Once done it
  /// stays done, so a repeat booking skips the step entirely.
  bool kycComplete = false;

  void completeKyc(String pan) {
    profile.pan = pan;
    kycComplete = true;
    notifyListeners();
  }

  void setPendingMobile(String mobile) {
    pendingMobile = mobile;
    notifyListeners();
  }

  void confirmMobileVerified() {
    profile.mobile = pendingMobile ?? profile.mobile;
    notifyListeners();
  }

  void updateProfile({
    String? fullName,
    String? email,
    String? pan,
    int? day,
    int? month,
    int? year,
    String? gender,
    String? city,
    String? occupation,
    String? income,
    Set<String>? investmentInterests,
    String? linkedBank,
  }) {
    if (fullName != null) profile.fullName = fullName;
    if (email != null) profile.email = email;
    if (pan != null) profile.pan = pan;
    if (day != null) profile.day = day;
    if (month != null) profile.month = month;
    if (year != null) profile.year = year;
    if (gender != null) profile.gender = gender;
    if (city != null) profile.city = city;
    if (occupation != null) profile.occupation = occupation;
    if (income != null) profile.income = income;
    if (investmentInterests != null) {
      profile.investmentInterests = investmentInterests;
    }
    if (linkedBank != null) profile.linkedBank = linkedBank;
    notifyListeners();
  }

  double get netWorth =>
      portfolio.fold<double>(0, (sum, item) => sum + item.principal);

  double get fdTotal => portfolio
      .where((i) => i.kind == InvestmentKind.fd)
      .fold<double>(0, (sum, item) => sum + item.principal);

  double get bondTotal => portfolio
      .where((i) => i.kind == InvestmentKind.bond)
      .fold<double>(0, (sum, item) => sum + item.principal);

  /// Recurring deposits are held as their monthly amount, so the total is
  /// what is committed per month rather than a lump sum.
  double get rdMonthly => portfolio
      .where((i) => i.kind == InvestmentKind.rd)
      .fold<double>(0, (sum, item) => sum + item.principal);

  int get rdCount =>
      portfolio.where((i) => i.kind == InvestmentKind.rd).length;

  void addInvestment(BookedInvestment investment) {
    portfolio.add(investment);
    notifyListeners();
  }
}
