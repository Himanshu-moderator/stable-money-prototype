import 'package:flutter/material.dart';

import 'common.dart';

/// Generic auto-nothing (user-swiped only) PageView + dots, used for the
/// hero banner at the top of FD/Bonds tabs and for the horizontal trust
/// carousels ("How is your FD protected?", "Why invest with Stable Bonds").
class HeroCarousel extends StatefulWidget {
  const HeroCarousel({
    super.key,
    required this.slides,
    this.height = 300,
    this.viewportFraction = 1.0,
  });

  final List<Widget> slides;
  final double height;
  final double viewportFraction;

  @override
  State<HeroCarousel> createState() => _HeroCarouselState();
}

class _HeroCarouselState extends State<HeroCarousel> {
  late final PageController _controller =
      PageController(viewportFraction: widget.viewportFraction);
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: widget.height,
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.slides.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (context, i) => Padding(
              padding: EdgeInsets.symmetric(
                horizontal: widget.viewportFraction < 1 ? 6 : 0,
              ),
              child: widget.slides[i],
            ),
          ),
        ),
        const SizedBox(height: 10),
        CarouselDots(count: widget.slides.length, index: _index),
      ],
    );
  }
}
