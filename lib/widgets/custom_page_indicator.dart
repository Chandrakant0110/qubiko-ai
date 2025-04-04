import 'package:flutter/material.dart';

class CustomPageIndicator extends StatelessWidget {
  final int itemCount;
  final int currentPage;
  final Color activeColor;
  final Color inactiveColor;
  final double activeDotWidth;
  final double dotHeight;
  final double dotWidth;
  final double spacing;
  final Duration animationDuration;

  const CustomPageIndicator({
    super.key,
    required this.itemCount,
    required this.currentPage,
    this.activeColor = Colors.blue,
    this.inactiveColor = const Color(0xFFE0E0E0),
    this.activeDotWidth = 24.0,
    this.dotHeight = 8.0,
    this.dotWidth = 8.0,
    this.spacing = 3.0,
    this.animationDuration = const Duration(milliseconds: 300),
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        itemCount,
        (index) => AnimatedContainer(
          duration: animationDuration,
          margin: EdgeInsets.symmetric(horizontal: spacing),
          height: dotHeight,
          width: currentPage == index ? activeDotWidth : dotWidth,
          decoration: BoxDecoration(
            color: currentPage == index ? activeColor : inactiveColor,
            borderRadius: BorderRadius.circular(dotHeight / 2),
          ),
        ),
      ),
    );
  }
}
