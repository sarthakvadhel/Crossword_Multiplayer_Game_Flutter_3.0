import '../data/models/tile_model.dart';
import '../data/models/word_model.dart';

class MoveValidator {
  /// Check if a letter can be placed at position.
  static bool isValidPlacement(
    List<List<TileModel>> board,
    int row,
    int col,
  ) {
    if (row < 0 || row >= board.length) return false;
    if (col < 0 || col >= board[0].length) return false;
    if (board[row][col].isBlocked) return false;
    if (board[row][col].isLocked) return false;
    return true;
  }

  /// Check which words were newly completed by recent placements.
  static List<WordModel> checkCompletedWords(
    List<List<TileModel>> board,
    List<WordModel> words,
  ) {
    final completed = <WordModel>[];

    for (final word in words) {
      if (word.isCompleted) continue;

      bool allFilled = true;
      for (final pos in word.positions) {
        final tile = board[pos[0]][pos[1]];
        if (tile.letter == null || tile.letter!.isEmpty) {
          allFilled = false;
          break;
        }
      }

      if (allFilled) {
        completed.add(word);
      }
    }

    return completed;
  }

  /// Validate that the placed letter matches the expected word letter.
  static bool isCorrectLetter(
    List<List<TileModel>> board,
    List<WordModel> words,
    int row,
    int col,
    String letter,
  ) {
    for (final word in words) {
      for (int i = 0; i < word.positions.length; i++) {
        final pos = word.positions[i];
        if (pos[0] == row && pos[1] == col) {
          if (word.answer[i].toUpperCase() == letter.toUpperCase()) {
            return true;
          }
        }
      }
    }
    return false;
  }
}
