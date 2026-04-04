import 'dart:math';

import '../data/models/tile_model.dart';
import '../data/models/word_model.dart';

class AiMove {
  final List<MapEntry<List<int>, String>> placements;
  final bool isSwap;

  AiMove({required this.placements, this.isSwap = false});
}

class AiEngine {
  static final Random _random = Random();

  /// AI decides what to do: place correct letters or swap.
  static AiMove decideMove({
    required List<List<TileModel>> board,
    required List<WordModel> words,
    required List<String> hand,
  }) {
    if (hand.isEmpty) {
      return AiMove(placements: [], isSwap: true);
    }

    // 15% chance to just swap
    if (_random.nextDouble() < 0.15) {
      return AiMove(placements: [], isSwap: true);
    }

    // Build a set of available letters (mutable copy)
    final availableLetters = List<String>.from(hand);
    final placements = <MapEntry<List<int>, String>>[];

    // 30% chance: try to complete a near-complete word
    if (_random.nextDouble() < 0.30) {
      final nearComplete = _findNearCompleteWord(board, words, availableLetters);
      if (nearComplete != null) {
        placements.addAll(nearComplete);
        for (final entry in nearComplete) {
          availableLetters.remove(entry.value);
        }
        return AiMove(placements: placements);
      }
    }

    // Otherwise place 1-3 random correct letters
    final maxPlacements = _random.nextInt(3) + 1;

    for (int i = 0; i < maxPlacements && availableLetters.isNotEmpty; i++) {
      MapEntry<List<int>, String>? placement;

      // Shuffle to add randomness
      final shuffledLetters = List<String>.from(availableLetters)..shuffle(_random);

      for (final letter in shuffledLetters) {
        final positions = findPositionsForLetter(board, words, letter);
        if (positions.isNotEmpty) {
          final pos = positions[_random.nextInt(positions.length)];
          placement = MapEntry(pos, letter);
          break;
        }
      }

      if (placement != null) {
        placements.add(placement);
        availableLetters.remove(placement.value);
      } else {
        break;
      }
    }

    // If no valid placements found, swap
    if (placements.isEmpty) {
      return AiMove(placements: [], isSwap: true);
    }

    return AiMove(placements: placements);
  }

  /// Find positions where a specific letter is needed (empty and matches answer).
  static List<List<int>> findPositionsForLetter(
    List<List<TileModel>> board,
    List<WordModel> words,
    String letter,
  ) {
    final result = <List<int>>[];
    final seen = <String>{};

    for (final word in words) {
      if (word.isCompleted) continue;

      for (int i = 0; i < word.positions.length; i++) {
        final pos = word.positions[i];
        final key = '${pos[0]},${pos[1]}';
        final tile = board[pos[0]][pos[1]];

        if ((tile.letter == null || tile.letter!.isEmpty) &&
            !tile.isBlocked &&
            !tile.isLocked &&
            word.answer[i].toUpperCase() == letter.toUpperCase() &&
            !seen.contains(key)) {
          seen.add(key);
          result.add([pos[0], pos[1]]);
        }
      }
    }

    return result;
  }

  /// Find a near-complete word (needs 1-2 letters) that AI can finish.
  static List<MapEntry<List<int>, String>>? _findNearCompleteWord(
    List<List<TileModel>> board,
    List<WordModel> words,
    List<String> availableLetters,
  ) {
    final candidates = <WordModel>[];

    for (final word in words) {
      if (word.isCompleted) continue;
      final filled = word.getFilledCount(board);
      final remaining = word.answer.length - filled;
      if (remaining >= 1 && remaining <= 2) {
        candidates.add(word);
      }
    }

    candidates.shuffle(_random);

    for (final word in candidates) {
      final needed = <MapEntry<List<int>, String>>[];
      final tempAvailable = List<String>.from(availableLetters);
      bool canComplete = true;

      for (int i = 0; i < word.positions.length; i++) {
        final pos = word.positions[i];
        final tile = board[pos[0]][pos[1]];

        if (tile.letter == null || tile.letter!.isEmpty) {
          final neededLetter = word.answer[i].toUpperCase();
          final idx = tempAvailable.indexWhere(
            (l) => l.toUpperCase() == neededLetter,
          );
          if (idx == -1) {
            canComplete = false;
            break;
          }
          tempAvailable.removeAt(idx);
          needed.add(MapEntry([pos[0], pos[1]], neededLetter));
        }
      }

      if (canComplete && needed.isNotEmpty) {
        return needed;
      }
    }

    return null;
  }
}
