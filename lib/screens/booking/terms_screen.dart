import 'package:flutter/material.dart';

import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../utils/formatters.dart';
import '../../widgets/common.dart';
import 'booking_args.dart';
import 'payment_screen.dart';
import 'terms_content.dart';

/// The disclosure step, sitting between the nominee and payment.
///
/// Two stages, following the pattern regulated products settle on: the full
/// agreement first, as a document you scroll, then a short statement of the
/// facts that actually change the outcome. The second stage is the one people
/// read, so it carries a checkbox per point rather than a single blanket
/// tick, and each point can be opened for the long version without leaving
/// the page.
class TermsScreen extends StatefulWidget {
  const TermsScreen({
    super.key,
    required this.appState,
    required this.args,
    required this.amount,
  });

  final AppState appState;
  final BookingArgs args;
  final double amount;

  @override
  State<TermsScreen> createState() => _TermsScreenState();
}

class _TermsScreenState extends State<TermsScreen> {
  final _docScroll = ScrollController();

  int _step = 0;

  /// Both document acknowledgements.
  bool _readAgreement = false;
  bool _lawfulFunds = false;

  /// Scrolled far enough that the checkboxes have actually been reached.
  bool _reachedEnd = false;

  late final List<KeyPoint> _points = keyPointsFor(widget.args);
  late final List<bool> _ticked = List<bool>.filled(_points.length, false);
  late final List<bool> _open = List<bool>.filled(_points.length, false);

  bool get _docDone => _readAgreement && _lawfulFunds;
  bool get _pointsDone => !_ticked.contains(false);

  @override
  void initState() {
    super.initState();
    _docScroll.addListener(() {
      if (_reachedEnd) return;
      if (_docScroll.hasClients &&
          _docScroll.offset >= _docScroll.position.maxScrollExtent - 24) {
        setState(() => _reachedEnd = true);
      }
    });
  }

  @override
  void dispose() {
    _docScroll.dispose();
    super.dispose();
  }

  void _next() {
    if (_step == 0) {
      setState(() => _step = 1);
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PaymentScreen(
          appState: widget.appState,
          args: widget.args,
          amount: widget.amount,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isFd = widget.args.kind == InvestmentKind.fd;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () => _step == 1
              ? setState(() => _step = 0)
              : Navigator.of(context).maybePop(),
        ),
        title: Text(_step == 0 ? 'Terms and conditions' : 'Before you confirm'),
      ),
      body: Column(
        children: [
          _StepBar(step: _step),
          Expanded(
            child: _step == 0 ? _document(isFd) : _keyPoints(),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_step == 1 && !_pointsDone)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    '${_ticked.where((t) => t).length} of ${_points.length} acknowledged',
                    style: TextStyle(fontSize: 12, color: AppColors.grey),
                  ),
                ),
              BlackPillButton(
                label: _step == 0 ? 'Next' : 'Agree and continue',
                onPressed: (_step == 0 ? _docDone : _pointsDone) ? _next : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------ step one

  Widget _document(bool isFd) {
    final clauses = agreementFor(widget.args);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Container(
        decoration: BoxDecoration(
          // A sheet of paper: white in every appearance would glare on dark,
          // so it takes the surface and leans on its border and shadow.
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.hairline),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: AppColors.isDark ? 0.4 : 0.06),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Scrollbar(
              controller: _docScroll,
              child: ListView(
                controller: _docScroll,
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
                children: [
                  Text(
                    isFd
                        ? 'FIXED DEPOSIT AGREEMENT'
                        : 'DEBENTURE SUBSCRIPTION TERMS',
                    style: TextStyle(
                      fontSize: 11,
                      letterSpacing: 1.4,
                      fontWeight: FontWeight.w800,
                      color: AppColors.grey,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.args.issuerName,
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${formatInr(widget.amount)} • ${widget.args.tenureLabel} • '
                    '${widget.args.rate.toStringAsFixed(2)}% per annum',
                    style: TextStyle(fontSize: 12.5, color: AppColors.grey),
                  ),
                  const SizedBox(height: 16),
                  Divider(color: AppColors.hairline, height: 1),
                  const SizedBox(height: 16),
                  for (var i = 0; i < clauses.length; i++) ...[
                    _Clause(
                      number: i + 1,
                      heading: clauses[i].$1,
                      body: clauses[i].$2,
                    ),
                    const SizedBox(height: 16),
                  ],
                  Divider(color: AppColors.hairline, height: 1),
                  const SizedBox(height: 18),
                  _TinyCheck(
                    value: _readAgreement,
                    enabled: _reachedEnd,
                    label: 'I have read and accept the terms set out above.',
                    onChanged: (v) => setState(() => _readAgreement = v),
                  ),
                  const SizedBox(height: 10),
                  _TinyCheck(
                    value: _lawfulFunds,
                    enabled: _reachedEnd,
                    label:
                        'The funds are mine and come from a lawful source, and '
                        'the details on the previous steps are correct.',
                    onChanged: (v) => setState(() => _lawfulFunds = v),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
            if (!_reachedEnd)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: IgnorePointer(
                  child: Container(
                    height: 54,
                    alignment: Alignment.bottomCenter,
                    padding: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.white.withValues(alpha: 0),
                          AppColors.white,
                        ],
                      ),
                    ),
                    child: Text('Scroll to the end to continue',
                        style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.grey)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------ step two

  Widget _keyPoints() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.purpleSoft,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.purple.withValues(alpha: 0.35)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline, size: 18, color: AppColors.purpleDeep),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'The ${_points.length} points below are the ones that change '
                  'what you get back. Tick each to confirm you have read it.',
                  style: TextStyle(
                      fontSize: 12.5,
                      height: 1.45,
                      color: AppColors.purpleDeep,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        for (var i = 0; i < _points.length; i++) ...[
          _PointCard(
            index: i + 1,
            point: _points[i],
            ticked: _ticked[i],
            open: _open[i],
            onTick: (v) => setState(() => _ticked[i] = v),
            onToggle: () => setState(() => _open[i] = !_open[i]),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

// ------------------------------------------------------------------ parts

class _StepBar extends StatelessWidget {
  const _StepBar({required this.step});
  final int step;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
      child: Row(
        children: [
          for (var i = 0; i < 2; i++) ...[
            if (i > 0) const SizedBox(width: 6),
            Expanded(
              child: Container(
                height: 3,
                decoration: BoxDecoration(
                  color: i <= step ? AppColors.purple : AppColors.hairline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ],
          const SizedBox(width: 10),
          Text('${step + 1} of 2',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.grey)),
        ],
      ),
    );
  }
}

class _Clause extends StatelessWidget {
  const _Clause({
    required this.number,
    required this.heading,
    required this.body,
  });

  final int number;
  final String heading;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$number.  $heading',
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppColors.ink)),
        const SizedBox(height: 5),
        Text(body,
            style: TextStyle(
                fontSize: 12.5,
                height: 1.55,
                color: AppColors.inkSoft)),
      ],
    );
  }
}

/// The small tick at the foot of the document. Disabled until the reader has
/// actually reached it.
class _TinyCheck extends StatelessWidget {
  const _TinyCheck({
    required this.value,
    required this.enabled,
    required this.label,
    required this.onChanged,
  });

  final bool value;
  final bool enabled;
  final String label;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? () => onChanged(!value) : null,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: Checkbox(
              value: value,
              onChanged: enabled ? (v) => onChanged(v ?? false) : null,
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              activeColor: AppColors.purple,
              side: BorderSide(
                  color: enabled ? AppColors.grey : AppColors.greyLight),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                height: 1.45,
                color: enabled ? AppColors.inkSoft : AppColors.greyLight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// One key point: heading, one-line brief, a tap target that opens the long
/// version, and its own tick.
class _PointCard extends StatelessWidget {
  const _PointCard({
    required this.index,
    required this.point,
    required this.ticked,
    required this.open,
    required this.onTick,
    required this.onToggle,
  });

  final int index;
  final KeyPoint point;
  final bool ticked;
  final bool open;
  final ValueChanged<bool> onTick;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ticked ? AppColors.greenSoft : AppColors.cream,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ticked
              ? AppColors.green.withValues(alpha: 0.45)
              : AppColors.hairline,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 22,
                height: 22,
                margin: const EdgeInsets.only(top: 1),
                decoration: BoxDecoration(
                  color: ticked ? AppColors.green : AppColors.hairline,
                  borderRadius: BorderRadius.circular(7),
                ),
                alignment: Alignment.center,
                child: Text('$index',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        // The dark palettes brighten the green, so white
                        // type on it would wash out.
                        color: ticked
                            ? (AppColors.isDark
                                ? AppColors.onCta
                                : Colors.white)
                            : AppColors.grey)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(point.heading,
                        style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                            height: 1.25,
                            color: AppColors.ink)),
                    const SizedBox(height: 5),
                    Text(point.brief,
                        style: TextStyle(
                            fontSize: 12.5,
                            height: 1.5,
                            color: AppColors.inkSoft)),
                  ],
                ),
              ),
            ],
          ),

          // Long version, closed until asked for.
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 180),
            crossFadeState:
                open ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            firstChild: const SizedBox(width: double.infinity, height: 0),
            secondChild: Padding(
              padding: const EdgeInsets.only(left: 34, top: 10, right: 4),
              child: Container(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.hairline),
                ),
                child: Text(
                  point.detail,
                  style: TextStyle(
                      fontSize: 11.5,
                      height: 1.6,
                      color: AppColors.inkSoft),
                ),
              ),
            ),
          ),

          const SizedBox(height: 6),
          Row(
            children: [
              const SizedBox(width: 30),
              InkWell(
                borderRadius: BorderRadius.circular(6),
                onTap: onToggle,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(open ? 'Hide detail' : 'In detail',
                          style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.purple)),
                      Icon(open ? Icons.expand_less : Icons.expand_more,
                          size: 16, color: AppColors.purple),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: 22,
                height: 22,
                child: Checkbox(
                  value: ticked,
                  onChanged: (v) => onTick(v ?? false),
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  activeColor: AppColors.green,
                  side: BorderSide(color: AppColors.grey),
                ),
              ),
              const SizedBox(width: 4),
            ],
          ),
        ],
      ),
    );
  }
}
