import 'package:flutter/material.dart';

import '../../logic/next_step.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../utils/formatters.dart';
import '../../widgets/common.dart';
import '../../widgets/next_step_card.dart';
import '../shell/main_shell.dart';
import 'booking_args.dart';

/// Confirmation, in two beats.
///
/// First a full-bleed success animation, the pattern every payment app has
/// trained people to expect, which does the emotional work of saying it went
/// through. About two seconds later it resolves into the receipt, and the
/// lower third carries the next investment.
///
/// That lower third is the point. This is the single moment in the whole
/// product where the user has just acted and feels good about it, which
/// makes it the cheapest attention the platform will ever get.
class SuccessScreen extends StatefulWidget {
  const SuccessScreen({
    super.key,
    required this.appState,
    required this.args,
    required this.amount,
  });

  final AppState appState;
  final BookingArgs args;
  final double amount;

  @override
  State<SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen>
    with TickerProviderStateMixin {
  late final BookedInvestment _investment;
  bool _added = false;
  bool _revealed = false;

  late final AnimationController _burst = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );
  late final AnimationController _sheet = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  );

  @override
  void initState() {
    super.initState();
    _investment = BookedInvestment(
      kind: widget.args.kind,
      issuerName: widget.args.issuerName,
      logoColor: widget.args.logoColor,
      logoLetter: widget.args.logoLetter,
      principal: widget.amount,
      rate: widget.args.rate,
      tenureMonths: widget.args.tenureMonths,
      bookedOn: DateTime.now(),
    );

    _burst.forward();
    Future.delayed(const Duration(milliseconds: 1900), () {
      if (!mounted) return;
      setState(() => _revealed = true);
      _sheet.forward();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_added) {
      _added = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.appState.addInvestment(_investment);
      });
    }
  }

  @override
  void dispose() {
    _burst.dispose();
    _sheet.dispose();
    super.dispose();
  }

  void _goTo(int tabIndex) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) =>
            MainShell(appState: widget.appState, initialIndex: tabIndex),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _revealed ? AppColors.white : AppColors.greenInk,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 340),
        child: _revealed ? _receipt() : _celebration(),
      ),
    );
  }

  // ----------------------------------------------------------- beat one

  Widget _celebration() {
    return SizedBox.expand(
      key: const ValueKey('burst'),
      child: Container(
        color: AppColors.greenInk,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _burst,
              builder: (context, _) {
                final t = Curves.easeOutBack.transform(
                    _burst.value.clamp(0.0, 1.0));
                final ring = Curves.easeOut.transform(_burst.value);
                return SizedBox(
                  width: 200,
                  height: 200,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Ring pushing outward behind the mark.
                      Opacity(
                        opacity: (1 - ring).clamp(0.0, 1.0) * 0.45,
                        child: Container(
                          width: 90 + ring * 110,
                          height: 90 + ring * 110,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: Colors.white, width: 2.5),
                          ),
                        ),
                      ),
                      Transform.scale(
                        scale: t.clamp(0.0, 1.4),
                        child: Container(
                          width: 96,
                          height: 96,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: CustomPaint(
                            painter: _TickPainter(
                              progress: Curves.easeOut.transform(
                                  ((_burst.value - 0.35) / 0.5)
                                      .clamp(0.0, 1.0)),
                              colour: AppColors.greenInk,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 30),
            FadeTransition(
              opacity: CurvedAnimation(
                parent: _burst,
                curve: const Interval(0.55, 1, curve: Curves.easeOut),
              ),
              child: Column(
                children: [
                  Text(formatInr(widget.amount),
                      style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          color: Colors.white)),
                  const SizedBox(height: 6),
                  Text('Paid to ${widget.args.issuerName}',
                      style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.85))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ----------------------------------------------------------- beat two

  Widget _receipt() {
    final next = Recommender.next(widget.appState);

    return SafeArea(
      key: const ValueKey('receipt'),
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.greenSoft,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.check_rounded,
                          color: AppColors.greenInk, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${widget.args.kindLabel} booked',
                              style: TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.ink)),
                          Text(_stamp(),
                              style: TextStyle(
                                  fontSize: 11.5, color: AppColors.grey)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.cream,
                    border: Border.all(color: AppColors.hairline),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      _row('Paid to', widget.args.issuerName),
                      _row('Amount', formatInr(widget.amount)),
                      _row('Rate',
                          '${widget.args.rate.toStringAsFixed(2)}% per annum'),
                      _row('Tenure', widget.args.tenureLabel),
                      _row('Matures on', _dateLabel(_investment.maturesOn)),
                      if (widget.args.kind == InvestmentKind.fd)
                        _row('Withdraw after',
                            _dateLabel(DateTime(
                                _investment.bookedOn.year,
                                _investment.bookedOn.month +
                                    widget.args.lockInMonths,
                                _investment.bookedOn.day))),
                      _row('Maturity value',
                          formatInr(_investment.maturityValue),
                          strong: true, last: true),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.trending_up_rounded,
                        size: 16, color: AppColors.greenInk),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'This will have earned about '
                        '${formatInr(_investment.earnedByDay30)} a month from '
                        'now. You can watch it build in the Passbook.',
                        style: TextStyle(
                            fontSize: 12, height: 1.4, color: AppColors.inkSoft),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // The lower third: what to do next.
          if (next != null)
            SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.35),
                end: Offset.zero,
              ).animate(
                  CurvedAnimation(parent: _sheet, curve: Curves.easeOutCubic)),
              child: FadeTransition(
                opacity: _sheet,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    border:
                        Border(top: BorderSide(color: AppColors.hairline)),
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Want to plan your next investment?',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppColors.ink)),
                      const SizedBox(height: 10),
                      NextStepCard(appState: widget.appState, step: next),
                    ],
                  ),
                ),
              ),
            ),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 6, 20, 12),
            child: Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => _goTo(3),
                    child: Text('View in Passbook',
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.ink)),
                  ),
                ),
                Expanded(
                  child: TextButton(
                    onPressed: () => _goTo(0),
                    child: Text('Not now',
                        style: TextStyle(color: AppColors.grey)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _stamp() {
    final d = _investment.bookedOn;
    final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final m = d.minute.toString().padLeft(2, '0');
    return '${_dateLabel(d)} at $h:$m ${d.hour < 12 ? 'am' : 'pm'}';
  }

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  String _dateLabel(DateTime d) =>
      '${d.day} ${_months[(d.month - 1) % 12]} ${d.year}';

  Widget _row(String label, String value,
      {bool strong = false, bool last = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 9),
      decoration: last
          ? null
          : BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.hairline))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(label,
                style: TextStyle(fontSize: 12.5, color: AppColors.grey)),
          ),
          const SizedBox(width: 12),
          Text(value,
              style: TextStyle(
                  fontSize: strong ? 15 : 12.5,
                  fontWeight: strong ? FontWeight.w800 : FontWeight.w600,
                  color: strong ? AppColors.greenInk : AppColors.ink)),
        ],
      ),
    );
  }
}

/// The tick, drawn rather than faded in, so it strokes on the way it does in
/// a payment app.
class _TickPainter extends CustomPainter {
  const _TickPainter({required this.progress, required this.colour});

  final double progress;
  final Color colour;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;
    final w = size.width, h = size.height;
    final a = Offset(w * 0.27, h * 0.52);
    final b = Offset(w * 0.44, h * 0.68);
    final c = Offset(w * 0.74, h * 0.35);

    final paint = Paint()
      ..color = colour
      ..strokeWidth = 7
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final leg1 = (b - a).distance;
    final leg2 = (c - b).distance;
    final total = leg1 + leg2;
    final drawn = total * progress;

    final path = Path()..moveTo(a.dx, a.dy);
    if (drawn <= leg1) {
      final t = drawn / leg1;
      path.lineTo(a.dx + (b.dx - a.dx) * t, a.dy + (b.dy - a.dy) * t);
    } else {
      path.lineTo(b.dx, b.dy);
      final t = ((drawn - leg1) / leg2).clamp(0.0, 1.0);
      path.lineTo(b.dx + (c.dx - b.dx) * t, b.dy + (c.dy - b.dy) * t);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_TickPainter old) =>
      old.progress != progress || old.colour != colour;
}
