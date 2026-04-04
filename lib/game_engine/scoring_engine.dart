import '../data/models/word_model.dart';
import '../core/constants/game_constants.dart';

class ScoreResult {
  final int points;
  final bool wordCompleted;
  final bool emptyHand;
  final bool isLongestWord;
  final int streak;
  final String? completedWord;

  ScoreResult({
    required this.points,
    required this.wordCompleted,
    required this.emptyHand,
    required this.isLongestWord,
    required this.streak,
    this.completedWord,
  });
}

class ScoringEngine {
  /// Calculate score for letters placed this turn.
  static ScoreResult calculateTurnScore({
    required int lettersPlaced,
    required List<WordModel> completedWords,
    required bool handEmpty,
    required int currentStreak,
    required String? currentLongestWord,
    required String? newLongestWord,
  }) {
    int points = lettersPlaced * GameConstants.correctLetterPoints;
    bool isLongest = false;

    for (final word in completedWords) {
      points += word.answer.length;
    }

    if (handEmpty) points += GameConstants.emptyHandBonus;

    if (newLongestWord != null &&
        (currentLongestWord == null ||
            newLongestWord.length > currentLongestWord.length)) {
      points += GameConstants.longestWordBonus;
      isLongest = true;
    }

    final int newStreak = completedWords.isNotEmpty ? currentStreak + 1 : 0;

    return ScoreResult(
      points: points,
      wordCompleted: completedWords.isNotEmpty,
      emptyHand: handEmpty,
      isLongestWord: isLongest,
      streak: newStreak,
      completedWord:
          completedWords.isNotEmpty ? completedWords.first.answer : null,
    );
  }
}
