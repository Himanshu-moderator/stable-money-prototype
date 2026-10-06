import '../data/mock_data.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../utils/formatters.dart';

/// What the recommendation is asking the user to do next.
enum NextKind { startRd, addBond, shortFd, anotherBank, topUpRd }

/// One recommended next investment, derived entirely from what the user
/// already holds.
class NextStep {
  const NextStep({
    required this.kind,
    required this.step,
    required this.title,
    required this.detail,
    required this.cta,
    required this.amountLine,
    this.bank,
    this.bond,
    this.monthly,
  });

  final NextKind kind;

  /// Position in the plan, so the card can read step 2, step 3 and onward.
  final int step;

  final String title;
  final String detail;
  final String cta;

  /// The headline figure, e.g. a monthly amount or a minimum ticket.
  final String amountLine;

  final FdBank? bank;
  final BondOffer? bond;
  final int? monthly;
}

/// Decides what to suggest next.
///
/// The ladder matters more than any single suggestion. A first deposit is a
/// large lump sum, and most first-time investors have just spent the savings
/// they built over months, so asking for another lump sum inside ninety days
/// asks for money that does not exist yet. The first rung is therefore a
/// small recurring amount, and only once that habit exists does the ladder
/// move on to larger or longer commitments. It never runs out: past the
/// fourth booking it alternates between growing the monthly amount and
/// spreading across another institution.
class Recommender {
  Recommender._();

  static NextStep? next(AppState state) {
    final held = state.portfolio;
    if (held.isEmpty) return null;

    final fds = held.where((i) => i.kind == InvestmentKind.fd).toList();
    final bonds = held.where((i) => i.kind == InvestmentKind.bond).toList();
    final rds = held.where((i) => i.kind == InvestmentKind.rd).toList();
    final step = held.length + 1;

    // Rung one: make the second investment small and repeating.
    if (rds.isEmpty) {
      final monthly = _suggestMonthly(held);
      return NextStep(
        kind: NextKind.startRd,
        step: step,
        title: 'Start a ${formatInr(monthly)} monthly deposit',
        detail: 'Your next investment does not have to be another lump sum. '
            'A small amount on salary day builds the same way, without '
            'waiting to save up again.',
        cta: 'Start monthly deposit',
        amountLine: '${formatInr(monthly)} a month',
        monthly: monthly,
        bank: _bestShortBank(),
      );
    }

    // Rung two: the cheapest way to add a genuinely different asset.
    if (bonds.isEmpty) {
      final cheapest = _cheapestBond();
      return NextStep(
        kind: NextKind.addBond,
        step: step,
        title: 'Try a bond from ${formatInr(cheapest.minInvestment)}',
        detail: 'Bonds pay more than a deposit and start small, so you can '
            'see how they behave without moving a large amount.',
        cta: 'See this bond',
        amountLine: '${cheapest.ytm.toStringAsFixed(2)}% · '
            '${cheapest.tenureLabel}',
        bond: cheapest,
      );
    }

    // Rung three: a short deposit, so something matures sooner than the
    // first one does.
    if (fds.length < 2) {
      final bank = _bestShortBank();
      final first = fds.isEmpty ? held.first : fds.first;
      return NextStep(
        kind: NextKind.shortFd,
        step: step,
        title: 'Add a shorter deposit at '
            '${bank.rateCard.isEmpty ? bank.rate.toStringAsFixed(2) : _shortRate(bank).toStringAsFixed(2)}%',
        detail: 'Your ${first.issuerName} deposit is locked until '
            '${_monthName(first.maturesOn)}. A shorter one alongside it means '
            'money frees up sooner without breaking anything.',
        cta: 'See short deposits',
        amountLine: '6 months · ${bank.name}',
        bank: bank,
      );
    }

    // From here on it alternates, so the plan never runs out of a next step.
    if (held.length.isEven) {
      final monthly = rds.first.principal.round();
      final raised = _round500((monthly * 1.5).round());
      return NextStep(
        kind: NextKind.topUpRd,
        step: step,
        title: 'Raise your monthly deposit to ${formatInr(raised)}',
        detail: 'You have kept ${formatInr(monthly)} a month going. Moving up '
            'in small steps is how a monthly habit turns into a real '
            'holding.',
        cta: 'Raise monthly amount',
        amountLine: 'from ${formatInr(monthly)} to ${formatInr(raised)}',
        monthly: raised,
      );
    }

    final fresh = _bankNotHeld(held);
    return NextStep(
      kind: NextKind.anotherBank,
      step: step,
      title: 'Spread the next one across ${fresh.name}',
      detail: 'Deposit insurance is counted per bank, so splitting across '
          'institutions keeps more of your money inside the covered limit.',
      cta: 'See ${fresh.name}',
      amountLine: '${fresh.rate.toStringAsFixed(2)}% · ${fresh.tenureLabel}',
      bank: fresh,
    );
  }

  // ------------------------------------------------------------- helpers

  /// Two percent of what they have already committed, rounded to a friendly
  /// number and kept inside a range a salaried investor will not flinch at.
  static int _suggestMonthly(List<BookedInvestment> held) {
    final total = held.fold<double>(0, (s, i) => s + i.principal);
    return _round500((total * 0.02).round()).clamp(1000, 10000);
  }

  static int _round500(int v) => ((v / 500).round() * 500).clamp(500, 1000000);

  static double _shortRate(FdBank b) {
    if (b.rateCard.isEmpty) return b.rate;
    final short = b.rateCard.where((r) => r.months <= 12).toList();
    if (short.isEmpty) return b.rate;
    return short.map((r) => r.rate).reduce((a, c) => a > c ? a : c);
  }

  /// Best rate available on a tenure of a year or less.
  static FdBank _bestShortBank() {
    final ranked = [...MockData.banks]
      ..sort((a, b) => _shortRate(b).compareTo(_shortRate(a)));
    return ranked.first;
  }

  static BondOffer _cheapestBond() {
    final ranked = [...MockData.bonds]
      ..sort((a, b) => a.minInvestment.compareTo(b.minInvestment));
    return ranked.first;
  }

  static FdBank _bankNotHeld(List<BookedInvestment> held) {
    final names = held.map((i) => i.issuerName).toSet();
    final fresh =
        MockData.banks.where((b) => !names.contains(b.name)).toList();
    final pool = fresh.isEmpty ? [...MockData.banks] : fresh;
    pool.sort((a, b) => b.rate.compareTo(a.rate));
    return pool.first;
  }

  static const _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  static String _monthName(DateTime d) =>
      '${_months[(d.month - 1) % 12]} ${d.year}';
}
