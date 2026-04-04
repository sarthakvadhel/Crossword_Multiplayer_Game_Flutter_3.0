/// Configuration parameters for a single AI difficulty level.
class AiDifficulty {
  final double swapChance;
  final double completeWordChance;
  final int maxLettersPerTurn;
  final String name;

  const AiDifficulty({
    required this.swapChance,
    required this.completeWordChance,
    required this.maxLettersPerTurn,
    required this.name,
  });

  static const easy = AiDifficulty(
    swapChance: 0.20,
    completeWordChance: 0.20,
    maxLettersPerTurn: 2,
    name: 'Easy',
  );

  static const medium = AiDifficulty(
    swapChance: 0.15,
    completeWordChance: 0.30,
    maxLettersPerTurn: 3,
    name: 'Medium',
  );

  static const hard = AiDifficulty(
    swapChance: 0.05,
    completeWordChance: 0.50,
    maxLettersPerTurn: 5,
    name: 'Hard',
  );
}

/// Repository for managing AI difficulty configuration.
///
/// Defaults to [AiDifficulty.medium] for a balanced experience.
class AiRepo {
  AiDifficulty currentDifficulty = AiDifficulty.medium;

  void setDifficulty(AiDifficulty difficulty) {
    currentDifficulty = difficulty;
  }
}
