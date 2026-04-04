import 'package:flutter/material.dart';

class GameAnimations {
  // Tile placement bounce animation
  static Animation<double> tileBounce(AnimationController controller) {
    return Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: controller, curve: Curves.elasticOut),
    );
  }

  // Score popup scale animation
  static Animation<double> scorePopup(AnimationController controller) {
    return Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: controller, curve: Curves.bounceOut),
    );
  }

  // Banner slide-in animation
  static Animation<Offset> bannerSlideIn(AnimationController controller) {
    return Tween<Offset>(begin: Offset(0, -1), end: Offset.zero).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeOutBack),
    );
  }

  // Hint highlight pulse
  static Animation<double> hintPulse(AnimationController controller) {
    return Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeInOut),
    );
  }
}
