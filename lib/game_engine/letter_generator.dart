import 'dart:math';

import '../core/utils/helpers.dart';
import '../core/constants/game_constants.dart';
import '../data/models/word_model.dart';
import '../data/models/tile_model.dart';

class LetterGenerator {
  static final _random = Random();

  /// Generate initial hand (no puzzle context).
  static List<String> generateHand() {
    return Helpers.generateHand(GameConstants.handSize);
  }

  /// Generate a hand biased towards letters still needed in the puzzle.
  /// At least 3 of the [handSize] letters will be letters required by
  /// unfilled puzzle cells, making the game immediately interactive.
  static List<String> generatePuzzleAwareHand(
    List<WordModel> words,
    List<List<TileModel>> board,
  ) {
    final needed = _getNeededLetters(words, board);
    return _buildHand(needed, GameConstants.handSize);
  }

  /// Refill [currentHand] to [handSize] letters.
  /// New letters are 60 % puzzle-needed, 40 % random, keeping the game
  /// solvable even after many turns.
  // 60 % of new letters come from the puzzle to keep the game solvable
  // while still providing variety. The remaining 40 % are random, which
  // prevents the game from becoming trivially easy.
  static List<String> refillHandPuzzleAware(
    List<String> currentHand,
    List<WordModel> words,
    List<List<TileModel>> board,
  ) {
    final needed = _getNeededLetters(words, board);
    final hand = List<String>.from(currentHand);
    while (hand.length < GameConstants.handSize) {
      if (needed.isNotEmpty && _random.nextDouble() < 0.60) {
        hand.add(needed[_random.nextInt(needed.length)]);
      } else {
        hand.add(Helpers.randomLetter());
      }
    }
    return hand;
  }

  /// Refill hand to full size (legacy, no puzzle context).
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

  // ── Private helpers ──────────────────────────────────────────────────────

  /// Collect all letters still needed for empty positions in the puzzle.
  static List<String> _getNeededLetters(
    List<WordModel> words,
    List<List<TileModel>> board,
  ) {
    if (board.isEmpty) return [];
    final needed = <String>[];
    final seen = <String>{};

    for (final word in words) {
      if (word.isCompleted) continue;
      for (int i = 0; i < word.positions.length; i++) {
        final pos = word.positions[i];
        final key = '${pos[0]},${pos[1]}';
        if (seen.contains(key)) continue;
        final tile = board[pos[0]][pos[1]];
        if (tile.letter == null || tile.letter!.isEmpty) {
          needed.add(word.answer[i].toUpperCase());
          seen.add(key);
        }
      }
    }

    needed.shuffle(_random);
    return needed;
  }

  /// Build a hand with up to 3 puzzle-needed letters and the rest random.
  static List<String> _buildHand(List<String> needed, int count) {
    final hand = <String>[];
    final puzzleCount = min(3, min(count, needed.length));
    hand.addAll(needed.take(puzzleCount));
    while (hand.length < count) {
      hand.add(Helpers.randomLetter());
    }
    hand.shuffle(_random);
    return hand;
  }
}
