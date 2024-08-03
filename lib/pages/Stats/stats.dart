import 'package:banner_carousel/banner_carousel.dart';
import 'package:booness/pages/Stats/your_lives.dart';
import 'package:flutter/material.dart';

import 'streaks.dart';

class Stats extends StatefulWidget {
  const Stats({super.key});

  @override
  State<Stats> createState() => _StatsState();
}

class _StatsState extends State<Stats> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          top: MediaQuery.of(context).size.shortestSide * 0.03,
          bottom: MediaQuery.of(context).size.shortestSide * 0.03),
      child: const BannerCarousel(
        animation: true,
        showIndicator: true,
        customizedBanners: [
          // MySliderScreen(),
          Streaks(),
          YourLives(),
        ],
      ),
    );
  }
}
