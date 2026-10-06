import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/models.dart';
import '../theme/app_theme.dart';
import 'common.dart';

/// Solution 1 from the capstone: per-bank trust signals, shown on the bank
/// the user is actually hesitating over rather than as a generic statement
/// about Stable Money.
///
/// Built as full-bleed graphical banners rather than text cards — the same
/// composition the app's own campaign banners use: an illustrated top half,
/// a wave divider, and a colour panel carrying the message. Every value and
/// the accent colour come from the bank itself, so two banks never produce
/// the same set of banners.
class BankTrustBanner extends StatelessWidget {
  const BankTrustBanner({super.key, required this.bank});

  final FdBank bank;

  @override
  Widget build(BuildContext context) {
    // Bank-specific highlights come first — what actually makes this
    // institution worth trusting, beyond the fact that it is registered.
    final cards = _fromFeatures(bank.features, bank.logoColor);

    // Deposit safety closes the set rather than opening it: registration is
    // table stakes, the bank's own record is the part worth leading with.
    if (bank.type.dicgcEligible) {
      cards.add(_TrustCardData(
        motif: _Motif.shield,
        top: _fixed(const Color(0xFF0F6E56), const Color(0xFF128266)),
        bottom: _fixed(const Color(0xFF04342C), const Color(0xFF0B4A3B)),
        eyebrow: 'DEPOSIT SAFETY',
        bigValue: '₹5,00,000',
        headline: 'Insured, whatever happens',
        detail:
            'Your deposit with ${bank.name} is covered by DICGC, a wholly '
            'owned subsidiary of the RBI.',
        stamp: 'DICGC',
        flip: cards.length.isOdd,
      ));
    } else {
      cards.add(_TrustCardData(
        motif: _Motif.shield,
        top: _fixed(const Color(0xFFB4791E), const Color(0xFF9D6A1A)),
        bottom: _fixed(const Color(0xFF5C3B06), const Color(0xFF7A5310)),
        eyebrow: 'DEPOSIT SAFETY',
        bigValue: 'Not insured',
        headline: 'No DICGC cover here',
        detail:
            '${bank.name} is an NBFC, so deposit insurance does not apply. '
            'Safety rests on its credit strength.',
        stamp: 'NBFC',
        flip: cards.length.isOdd,
      ));
    }

    return _TrustCarousel(
      title: 'Why people trust ${bank.name}',
      cards: cards,
      backers: bank.backers,
    );
  }
}

/// The same idea applied to a bond issuer. A bond carries genuine credit
/// risk, so the closing card states that plainly instead of implying the
/// cover a deposit would have.
class BondTrustBanner extends StatelessWidget {
  const BondTrustBanner({super.key, required this.bond});

  final BondOffer bond;

  @override
  Widget build(BuildContext context) {
    final cards = _fromFeatures(bond.features, bond.logoColor);

    cards.add(_TrustCardData(
      motif: _Motif.shield,
      top: _fixed(const Color(0xFFB4791E), const Color(0xFF9D6A1A)),
      bottom: _fixed(const Color(0xFF5C3B06), const Color(0xFF7A5310)),
      eyebrow: 'WHAT YOU CARRY',
      bigValue: 'Credit risk',
      headline: 'A bond is not a deposit',
      detail: bond.secured
          ? 'DICGC cover does not apply. This issue is secured, so you rank '
              'ahead of unsecured lenders, but repayment still depends on '
              '${bond.issuer}.'
          : 'DICGC cover does not apply, and this issue carries no '
              'collateral. Repayment depends entirely on ${bond.issuer}.',
      stamp: 'NO DICGC',
      flip: cards.length.isOdd,
    ));

    return _TrustCarousel(
      title: 'What backs this bond',
      cards: cards,
      backers: const [],
    );
  }
}

/// Palettes are derived from the issuer's own brand colour rather than a
/// fixed list, so each issuer's banners read as one campaign and no two
/// issuers produce the same-looking set. Hue rotation keeps the family
/// coherent while the individual cards stay distinct.
List<_TrustCardData> _fromFeatures(List<BankFeature> features, Color brand) {
  final cards = <_TrustCardData>[];
  for (var i = 0; i < features.length; i++) {
    final f = features[i];
    final base = switch (i % 3) {
      0 => brand,
      1 => _rotate(brand, 38),
      _ => _rotate(brand, -32),
    };
    final top = _readable(base, i == 1 ? 0.06 : 0.0);
    cards.add(_TrustCardData(
      motif: _motifFrom(f.motif),
      top: top,
      bottom: _darken(top, 0.30),
      eyebrow: f.eyebrow,
      bigValue: f.bigValue,
      headline: f.headline,
      detail: f.detail,
      stamp: f.stamp,
      flip: i.isOdd,
    ));
  }
  return cards;
}

_Motif _motifFrom(String name) => switch (name) {
      'shield' => _Motif.shield,
      'laurel' => _Motif.laurel,
      'people' => _Motif.people,
      _ => _Motif.rings,
    };

/// Rotates hue so sibling banners stay in the issuer's family without
/// repeating its exact brand colour.
Color _rotate(Color c, double degrees) {
  final hsl = HSLColor.fromColor(c);
  return hsl.withHue((hsl.hue + degrees) % 360).toColor();
}

/// Keeps a colour dark enough for white type to sit on it.
///
/// The window moves with the appearance. On light the cards want to be dark
/// slabs against a white page; on dark they have to sit clearly *above* a
/// near-black page, so the floor rises. Without that, a bank whose brand is
/// almost black would print a banner the same value as the page behind it.
Color _readable(Color c, double extra) {
  final hsl = HSLColor.fromColor(c);
  final lo = AppColors.isDark ? 0.30 : 0.18;
  final hi = AppColors.isDark ? 0.52 : 0.42;
  final l = (hsl.lightness - extra).clamp(lo, hi);
  return hsl
      .withLightness(l)
      .withSaturation(hsl.saturation.clamp(AppColors.isDark ? 0.42 : 0.35, 0.85))
      .toColor();
}

/// The lower panel of a banner. It is shallower on dark so the card keeps a
/// readable floor rather than bottoming out into the page.
Color _darken(Color c, double amount) {
  final hsl = HSLColor.fromColor(c);
  final floor = AppColors.isDark ? 0.18 : 0.06;
  final drop = AppColors.isDark ? amount * 0.72 : amount;
  return hsl.withLightness((hsl.lightness - drop).clamp(floor, 1.0)).toColor();
}

/// Deposit-safety and risk cards use fixed colours rather than the brand's,
/// so they need the same lift on dark appearances.
Color _fixed(Color light, Color dark) => AppColors.isDark ? dark : light;

/// Swipeable banner rail shared by the bank and bond pages.
class _TrustCarousel extends StatefulWidget {
  const _TrustCarousel({
    required this.title,
    required this.cards,
    required this.backers,
  });

  final String title;
  final List<_TrustCardData> cards;
  final List<Backer> backers;

  @override
  State<_TrustCarousel> createState() => _TrustCarouselState();
}

class _TrustCarouselState extends State<_TrustCarousel> {
  final _controller = PageController(viewportFraction: 0.9);
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cards = widget.cards;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(widget.title,
              style: AppTheme.serifHeading.copyWith(fontSize: 19)),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 214,
          child: PageView.builder(
            controller: _controller,
            itemCount: cards.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (context, i) => Padding(
              padding: EdgeInsets.only(
                left: i == 0 ? 20 : 5,
                right: i == cards.length - 1 ? 20 : 5,
              ),
              child: _TrustBannerCard(data: cards[i]),
            ),
          ),
        ),
        const SizedBox(height: 12),
        CarouselDots(count: cards.length, index: _index),
        if (widget.backers.isNotEmpty) ...[
          const SizedBox(height: 18),
          _BackerStrip(backers: widget.backers),
        ],
      ],
    );
  }
}

enum _Motif { shield, rings, laurel, people }

class _TrustCardData {
  const _TrustCardData({
    required this.motif,
    required this.top,
    required this.bottom,
    required this.eyebrow,
    required this.bigValue,
    required this.headline,
    required this.detail,
    required this.stamp,
    this.flip = false,
  });

  final _Motif motif;
  final Color top;
  final Color bottom;
  final String eyebrow;
  final String bigValue;
  final String headline;
  final String detail;
  final String stamp;

  /// Mirrors the artwork and wave so consecutive banners don't look stamped
  /// from one template.
  final bool flip;
}

class _TrustBannerCard extends StatelessWidget {
  const _TrustBannerCard({required this.data});

  final _TrustCardData data;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Illustrated upper half.
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [data.top, _mix(data.top, data.bottom, 0.45)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          CustomPaint(painter: _MotifPainter(motif: data.motif)),

          // Wave-divided colour panel, the same composition as the app's
          // campaign banners.
          Positioned.fill(
            child: CustomPaint(
                painter: _WavePainter(color: data.bottom, flip: data.flip)),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(data.eyebrow,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              letterSpacing: 0.8,
                              fontWeight: FontWeight.w800)),
                    ),
                    const Spacer(),
                    _Stamp(label: data.stamp),
                  ],
                ),
                const SizedBox(height: 10),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    data.bigValue,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      height: 1,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  data.headline,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  data.detail,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.82),
                    fontSize: 11.5,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Color _mix(Color a, Color b, double t) =>
      Color.lerp(a, b, t) ?? a;
}

/// Small circular seal in the banner's top-right, echoing a stamped
/// certification mark.
class _Stamp extends StatelessWidget {
  const _Stamp({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.55)),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 8,
          letterSpacing: 0.4,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

/// The gold-and-white wave that separates artwork from message, mirroring
/// the sweep used on the app's promotional banners.
class _WavePainter extends CustomPainter {
  const _WavePainter({required this.color, this.flip = false});

  final Color color;
  final bool flip;

  @override
  void paint(Canvas canvas, Size size) {
    if (flip) {
      canvas.save();
      canvas.translate(size.width, 0);
      canvas.scale(-1, 1);
    }
    final top = size.height * 0.52;

    final accent = Path()
      ..moveTo(0, top - 8)
      ..quadraticBezierTo(
          size.width * 0.35, top - 34, size.width * 0.62, top - 6)
      ..quadraticBezierTo(
          size.width * 0.84, top + 12, size.width, top - 14)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
        accent, Paint()..color = Colors.white.withValues(alpha: 0.28));

    final panel = Path()
      ..moveTo(0, top)
      ..quadraticBezierTo(size.width * 0.35, top - 26, size.width * 0.62, top + 2)
      ..quadraticBezierTo(size.width * 0.84, top + 20, size.width, top - 6)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(panel, Paint()..color = color);
    if (flip) canvas.restore();
  }

  @override
  bool shouldRepaint(_WavePainter old) =>
      old.color != color || old.flip != flip;
}

/// Decorative artwork behind the headline: a shield, concentric rings, a
/// laurel wreath, or a cluster of figures depending on the card.
class _MotifPainter extends CustomPainter {
  const _MotifPainter({required this.motif});

  final _Motif motif;

  @override
  void paint(Canvas canvas, Size size) {
    final light = Paint()..color = Colors.white.withValues(alpha: 0.16);
    final faint = Paint()..color = Colors.white.withValues(alpha: 0.09);
    final stroke = Paint()
      ..color = Colors.white.withValues(alpha: 0.22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final cx = size.width * 0.80;
    final cy = size.height * 0.30;

    switch (motif) {
      case _Motif.shield:
        final w = 62.0, h = 74.0;
        final path = Path()
          ..moveTo(cx, cy - h / 2)
          ..lineTo(cx + w / 2, cy - h / 2 + 14)
          ..lineTo(cx + w / 2, cy + h / 6)
          ..quadraticBezierTo(cx + w / 2, cy + h / 2, cx, cy + h / 2 + 6)
          ..quadraticBezierTo(cx - w / 2, cy + h / 2, cx - w / 2, cy + h / 6)
          ..lineTo(cx - w / 2, cy - h / 2 + 14)
          ..close();
        canvas.drawPath(path, light);
        canvas.drawPath(path, stroke);
        final tick = Path()
          ..moveTo(cx - 13, cy)
          ..lineTo(cx - 3, cy + 11)
          ..lineTo(cx + 15, cy - 12);
        canvas.drawPath(
          tick,
          Paint()
            ..color = Colors.white.withValues(alpha: 0.75)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 4
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round,
        );
        break;

      case _Motif.rings:
        for (var i = 3; i >= 1; i--) {
          canvas.drawCircle(Offset(cx, cy), 16.0 * i, i.isOdd ? faint : light);
        }
        canvas.drawCircle(Offset(cx, cy), 48, stroke);
        canvas.drawCircle(Offset(cx, cy), 15,
            Paint()..color = Colors.white.withValues(alpha: 0.55));
        break;

      case _Motif.laurel:
        // Two mirrored wreath arms, leaves swept along an arc so the
        // rating sits inside a laurel, the way the app frames its
        // "A- Rated" offer banner.
        const radius = 42.0;
        for (final side in [-1.0, 1.0]) {
          for (var i = 0; i < 7; i++) {
            final t = i / 6;
            final angle = -1.05 + t * 2.1;
            final px = cx + side * (math.cos(angle) * radius * 0.55 + 16);
            final py = cy + math.sin(angle) * radius;
            canvas.save();
            canvas.translate(px, py);
            canvas.rotate(side * angle * 0.8);
            canvas.drawOval(
              Rect.fromCenter(center: Offset.zero, width: 9, height: 20),
              i.isEven ? light : faint,
            );
            canvas.restore();
          }
        }
        canvas.drawCircle(Offset(cx, cy), 30, stroke);
        break;

      case _Motif.people:
        for (var i = 0; i < 4; i++) {
          final px = cx - 34 + (i % 3) * 26.0;
          final py = cy - 12 + (i ~/ 3) * 30.0;
          canvas.drawCircle(Offset(px, py), 10, i.isEven ? light : faint);
          final body = Rect.fromLTWH(px - 13, py + 12, 26, 22);
          canvas.drawRRect(
            RRect.fromRectAndCorners(body,
                topLeft: const Radius.circular(12),
                topRight: const Radius.circular(12)),
            i.isEven ? light : faint,
          );
        }
        break;

    }
  }

  @override
  bool shouldRepaint(_MotifPainter old) => old.motif != motif;
}

/// "Who else backed this bank" — institutional investors shown as a compact
/// strip under the banners. Trust by association: money that did diligence a
/// retail depositor never could.
class _BackerStrip extends StatelessWidget {
  const _BackerStrip({required this.backers});

  final List<Backer> backers;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text('BACKED BY',
              style: TextStyle(
                  fontSize: 11,
                  letterSpacing: 0.8,
                  fontWeight: FontWeight.w800,
                  color: AppColors.grey)),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 74,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: backers.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, i) {
              final b = backers[i];
              return Container(
                width: 186,
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.hairline),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: b.color,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: Text(b.mark,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w800)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(b.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700)),
                          const SizedBox(height: 2),
                          Text(b.kind,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 10.5, color: AppColors.grey)),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
