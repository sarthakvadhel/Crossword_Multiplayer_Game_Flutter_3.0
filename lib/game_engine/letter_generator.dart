import '../core/utils/helpers.dart';
import '../core/constants/game_constants.dart';

class LetterGenerator {
  /// Generate initial hand.
  static List<String> generateHand() {
    return Helpers.generateHand(GameConstants.handSize);
  }

  /// Refill hand to full size.
  static List<String> refillHand(List<String> currentHand) {
    while (currentHand.length < GameConstants.handSize) {
      currentHand.add(Helpers.randomLetter());
    }
    return currentHand;
  }

  /// Swap specific letters by index.
  static List<String> swapLetters(List<String> hand, List<int> indices) {
    for (final i in indices) {
      if (i >= 0 && i < hand.length) {
        hand[i] = Helpers.randomLetter();
      }
    }
    return hand;
  }
}
