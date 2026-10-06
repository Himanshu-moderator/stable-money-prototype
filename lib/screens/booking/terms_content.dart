import '../../models/models.dart';
import '../../utils/formatters.dart';
import 'booking_args.dart';

/// One of the handful of facts that actually change what the investor gets
/// back, written three ways: a heading, a line, and the long version behind
/// an expander.
class KeyPoint {
  const KeyPoint({
    required this.heading,
    required this.brief,
    required this.detail,
  });

  final String heading;
  final String brief;
  final String detail;
}

/// Numbered clauses for the scrollable agreement. Deliberately the dry
/// version: the readable summary is the second step.
List<(String, String)> agreementFor(BookingArgs a) {
  final isFd = a.kind == InvestmentKind.fd;
  final rate = a.rate.toStringAsFixed(2);

  if (isFd) {
    return [
      (
        'Application and acceptance',
        'This application is made by the depositor to ${a.issuerName} through '
            'Stable Money, which acts as a distributor and not as a party to '
            'the deposit. The deposit is created only once ${a.issuerName} '
            'receives and accepts the funds, and the deposit relationship '
            'exists between the depositor and ${a.issuerName} alone.',
      ),
      (
        'Rate and tenure',
        'The rate of $rate% per annum applies for the selected tenure of '
            '${a.tenureLabel} and is fixed on the date the deposit is booked. '
            'Rates displayed before booking are indicative and are subject to '
            'the rate card in force at the time the deposit is created. '
            'Interest is compounded quarterly unless the selected plan states '
            'a different frequency.',
      ),
      (
        'Maturity and renewal',
        'On the maturity date the principal together with interest is credited '
            'to the bank account linked to this application. Automatic renewal '
            'is not applied unless the depositor elects it. Where instructions '
            'are absent on the maturity date, ${a.issuerName} may hold the '
            'proceeds in accordance with its own policy and applicable Reserve '
            'Bank of India directions.',
      ),
      (
        'Premature withdrawal',
        'A withdrawal request may be made after the lock-in period of '
            '${a.lockInMonths} months. Where premature withdrawal is permitted, '
            'interest is payable at the rate applicable to the period for which '
            'the deposit actually ran, reduced by a penalty of '
            '${a.prematurePenaltyPercent.toStringAsFixed(2)}%. The contracted '
            'rate of $rate% does not apply to a deposit broken before maturity.',
      ),
      (
        'Deposit insurance',
        a.insured
            ? 'Deposits with ${a.issuerName} are insured by the Deposit '
                'Insurance and Credit Guarantee Corporation, a wholly owned '
                'subsidiary of the Reserve Bank of India, up to a limit of '
                'five lakh rupees per depositor per bank, covering principal '
                'and interest together and aggregated across all accounts held '
                'in the same right and capacity at that bank.'
            : '${a.issuerName} is a non-banking financial company. Deposit '
                'insurance under the Deposit Insurance and Credit Guarantee '
                'Corporation applies to banks only and does not extend to this '
                'deposit. Repayment depends on the financial position of '
                '${a.issuerName}.',
      ),
      (
        'Taxation',
        'Interest is taxable as income in the hands of the depositor. Tax is '
            'deducted at source at ten per cent where interest from the same '
            'institution exceeds fifty thousand rupees in a financial year, or '
            'one lakh rupees where the depositor is sixty years of age or '
            'above. Where a valid permanent account number is not on record, '
            'tax is deducted at twenty per cent. A depositor whose total income '
            'is below the taxable limit may file the prescribed declaration '
            'with the institution.',
      ),
      (
        'Nomination',
        'The nominee recorded on this application is registered with '
            '${a.issuerName}. Only one nominee may be recorded against the '
            'deposit and the nomination may be varied at any time before '
            'maturity.',
      ),
      (
        'Grievances',
        'Complaints regarding the deposit are addressed to ${a.issuerName} in '
            'the first instance. Where a complaint is not resolved within '
            'thirty days, the depositor may approach the Reserve Bank of India '
            'Ombudsman. Complaints regarding the distribution platform are '
            'addressed to Stable Money.',
      ),
    ];
  }

  return [
    (
      'Application and allotment',
      'This is an application to subscribe to debentures issued by '
          '${a.issuerName}. Stable Money acts as a distributor and is not the '
          'issuer, guarantor or obligor. Units are allotted subject to '
          'availability and the issuer may accept the application in part or '
          'reject it in full.',
    ),
    (
      'Yield and maturity',
      'The indicated yield to maturity of $rate% per annum assumes that every '
          'scheduled payment is made in full and on time and that the '
          'investment is held to maturity on the stated date. The yield is not '
          'a guarantee and is not assured by any person.',
    ),
    (
      'Credit risk',
      'Repayment of principal and interest depends on the financial position '
          'of ${a.issuerName}. ${a.rating.isEmpty ? '' : 'The issue carries a '
              'published rating of ${a.rating}, which reflects an opinion of '
              'the rating agency, may be revised or withdrawn at any time, and '
              'is not a recommendation to invest. '}'
          '${a.secured ? 'The issue is secured, so holders rank ahead of '
              'unsecured creditors on the charged assets.' : 'The issue is '
              'unsecured and carries no collateral.'}',
    ),
    (
      'No deposit insurance',
      'A debenture is not a bank deposit. Deposit insurance under the Deposit '
          'Insurance and Credit Guarantee Corporation does not apply to this '
          'investment in any circumstance.',
    ),
    (
      'Liquidity before maturity',
      'Units may be offered for sale on the secondary market before maturity. '
          'A buyer is not assured, and the price obtainable depends on '
          'prevailing interest rates and on the credit standing of the issuer '
          'at that time. It may be below the amount invested.',
    ),
    (
      'Taxation',
      'Interest is taxable as income in the hands of the holder at the '
          'applicable slab rate. Gains realised on a sale before maturity are '
          'taxed as capital gains. Tax is deducted at source where the '
          'applicable threshold is exceeded, and at a higher rate where a '
          'valid permanent account number is not on record.',
    ),
    (
      'Holding and transfer',
      'Units are held in dematerialised form in the demat account recorded on '
          'this application. Transfer, pledge and transmission follow the '
          'procedures of the depository and of the issuer.',
    ),
    (
      'Grievances',
      'Complaints regarding the issue are addressed to ${a.issuerName} and to '
          'the debenture trustee. Where a complaint is not resolved within '
          'thirty days, the holder may approach the Securities and Exchange '
          'Board of India through its complaints redress system.',
    ),
  ];
}

/// The short list the investor is actually expected to read and tick.
List<KeyPoint> keyPointsFor(BookingArgs a) {
  final rate = a.rate.toStringAsFixed(2);

  if (a.kind == InvestmentKind.fd) {
    return [
      KeyPoint(
        heading: 'Your money is committed for ${a.tenureLabel}',
        brief: 'You can ask for it back after ${a.lockInMonths} months, but '
            'not before.',
        detail: 'The deposit runs for ${a.tenureLabel} from the day it is '
            'created. A withdrawal request cannot be made at all during the '
            'first ${a.lockInMonths} months. After that a request is possible '
            'but is not instant: the institution processes it and credits the '
            'linked bank account, which usually takes one to three working '
            'days. Plan around money you will not need in that window.',
      ),
      KeyPoint(
        heading: 'Breaking it early costs you the headline rate',
        brief: 'You get the rate for how long it actually ran, minus '
            '${a.prematurePenaltyPercent.toStringAsFixed(2)}%.',
        detail: 'The $rate% applies only if the deposit runs the full '
            '${a.tenureLabel}. Break it early and interest is recalculated at '
            'the rate the institution offers for the period it actually ran, '
            'and a penalty of '
            '${a.prematurePenaltyPercent.toStringAsFixed(2)}% is then taken off '
            'that. On a short holding the effective return can fall close to a '
            'savings account, and in some cases below what you put in after '
            'the penalty is applied to accrued interest.',
      ),
      KeyPoint(
        heading: a.insured
            ? 'Insured up to five lakh, not beyond'
            : 'This deposit is not insured',
        brief: a.insured
            ? 'DICGC covers ${formatInr(500000)} per depositor at this bank, '
                'principal and interest together.'
            : '${a.issuerName} is an ${a.institutionLabel.isEmpty ? 'NBFC' : a.institutionLabel}, '
                'so deposit insurance does not apply.',
        detail: a.insured
            ? 'Deposit insurance is provided by the DICGC, a wholly owned '
                'subsidiary of the RBI. The limit is five lakh rupees per '
                'depositor per bank, and it counts principal and interest '
                'together, not separately. It is also aggregated: every '
                'account you hold at this bank in the same right and capacity '
                'shares the one limit. If you already hold deposits here, the '
                'insured portion of this one is whatever is left under that '
                'ceiling.'
            : 'DICGC insurance covers bank deposits only. It does not extend '
                'to deposits with a non-banking financial company, whatever '
                'the credit rating. Repayment rests entirely on the financial '
                'strength of ${a.issuerName}. That is the reason the rate is '
                'higher than a comparable bank deposit, and it is the risk you '
                'are being paid to take.',
      ),
      KeyPoint(
        heading: 'Interest is taxable, and tax may be cut at source',
        brief: 'Above ${formatInr(50000)} of interest a year here, 10% is '
            'deducted before you are paid.',
        detail: 'Interest counts as income and is taxed at your slab rate '
            'whether or not tax is deducted at source. TDS starts once '
            'interest from this one institution passes ${formatInr(50000)} in '
            'a financial year, or ${formatInr(100000)} if you are sixty or '
            'above. The rate is 10% with a valid PAN on record and 20% '
            'without one. The threshold is counted per institution rather than '
            'across all your deposits. If your total income is below the '
            'taxable limit you can file the prescribed declaration with the '
            'institution so nothing is deducted.',
      ),
      KeyPoint(
        heading: 'The rate is locked now, and it does not renew itself',
        brief: '$rate% is fixed at booking; at maturity the money returns to '
            'your linked account.',
        detail: 'Once booked, the $rate% holds for the full ${a.tenureLabel} '
            'whatever happens to rates in the meantime. That protects you if '
            'rates fall and costs you if they rise. Nothing rolls over '
            'automatically: on the maturity date principal and interest are '
            'credited to the bank account linked to this application, and if '
            'you want to reinvest you book again at whatever rate is on offer '
            'that day.',
      ),
    ];
  }

  return [
    KeyPoint(
      heading: 'This is a bond, not a deposit',
      brief: 'No deposit insurance applies here, in any circumstance.',
      detail: 'DICGC insurance covers bank deposits. A debenture is a loan you '
          'make to a company, so it sits entirely outside that cover. There is '
          'no floor under it and no government guarantee behind it. Everything '
          'you get back depends on ${a.issuerName} being able to pay.',
    ),
    KeyPoint(
      heading: 'The $rate% depends on the issuer paying',
      brief: 'It is an expected yield, not an assured one.',
      detail: 'The yield to maturity assumes every scheduled payment arrives '
          'in full and on time and that you hold to maturity. '
          '${a.rating.isEmpty ? '' : 'The published rating of ${a.rating} is an '
              'agency opinion of how likely that is. It can be revised or '
              'withdrawn, and it is not a recommendation. '}'
          '${a.secured ? 'Because the issue is secured, holders rank ahead of '
              'unsecured creditors against the charged assets if things go '
              'wrong, which improves recovery but does not guarantee it.' : 'The '
              'issue is unsecured, so there is no collateral to fall back on.'}',
    ),
    KeyPoint(
      heading: 'Selling before maturity is not guaranteed',
      brief: 'A buyer has to exist, and the price may be below what you paid.',
      detail: 'These units can be offered on the secondary market, but that is '
          'not the same as a withdrawal. You need a willing buyer, and the '
          'price they will pay moves with interest rates and with the credit '
          'standing of ${a.issuerName}. If rates have risen since you bought, '
          'or the issuer has been downgraded, the price will be lower than '
          'what you paid. Treat the money as committed until '
          '${a.tenureLabel} has run.',
    ),
    KeyPoint(
      heading: 'Interest is taxed as income, gains as capital gains',
      brief: 'Interest at your slab rate; a sale before maturity is taxed '
          'separately.',
      detail: 'Interest received is added to your income and taxed at your '
          'slab rate, with tax deducted at source once the applicable '
          'threshold is crossed, and at a higher rate if a valid PAN is not on '
          'record. If you sell before maturity, the difference between what '
          'you paid and what you receive is treated as a capital gain or loss '
          'rather than as interest, and is taxed under those rules.',
    ),
    KeyPoint(
      heading: 'Terms are fixed at allotment',
      brief: 'The rate and the maturity date do not change once units are '
          'allotted.',
      detail: 'The yield and the maturity date are set when the units are '
          'allotted to you and do not move afterwards. Allotment itself is '
          'subject to availability, so the issuer may allot fewer units than '
          'you applied for, or none, in which case the money is returned. '
          'Units are held in dematerialised form in the demat account recorded '
          'on this application.',
    ),
  ];
}
