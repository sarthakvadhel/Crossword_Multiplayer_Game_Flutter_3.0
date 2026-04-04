import '../data/models/tile_model.dart';
import '../data/models/word_model.dart';
import '../data/models/puzzle_model.dart';

class BoardEngine {
  /// Initialize empty board from puzzle dimensions.
  static List<List<TileModel>> createBoard(PuzzleModel puzzle) {
    final board = List.generate(
      puzzle.rows,
      (r) => List.generate(
        puzzle.cols,
        (c) => TileModel(
          row: r,
          col: c,
          isBlocked: puzzle.blockedCells[r][c],
        ),
      ),
    );

    // Mark clue cells based on word start positions.
    for (final word in puzzle.words) {
      if (word.positions.isNotEmpty) {
        final startPos = word.positions.first;
        final r = startPos[0];
        final c = startPos[1];
        board[r][c].isClueCell = true;
        board[r][c].clueNumber = word.id;
      }
    }

    return board;
  }

  /// Place a letter on the board. Returns true if successful.
  static bool placeLetter(
    List<List<TileModel>> board,
    int row,
    int col,
    String letter,
  ) {
    if (row < 0 || row >= board.length) return false;
    if (col < 0 || col >= board[0].length) return false;
    if (board[row][col].isBlocked) return false;
    if (board[row][col].isLocked) return false;

    board[row][col].letter = letter;
    return true;
  }

  /// Remove a letter (only if not locked).
  static bool removeLetter(List<List<TileModel>> board, int row, int col) {
    if (row < 0 || row >= board.length) return false;
    if (col < 0 || col >= board[0].length) return false;
    if (board[row][col].isLocked) return false;

    board[row][col].letter = null;
    return true;
  }

  /// Lock all currently placed (non-locked) letters.
  static void lockPlacedLetters(List<List<TileModel>> board) {
    for (final row in board) {
      for (final tile in row) {
        if (tile.letter != null && tile.letter!.isNotEmpty && !tile.isLocked) {
          tile.isLocked = true;
        }
      }
    }
  }

  /// Check if all words in puzzle are complete.
  static bool isPuzzleComplete(
    List<List<TileModel>> board,
    List<WordModel> words,
  ) {
    for (final word in words) {
      for (final pos in word.positions) {
        final tile = board[pos[0]][pos[1]];
        if (tile.letter == null || tile.letter!.isEmpty) {
          return false;
        }
      }
    }
    return true;
  }

  /// Get all empty positions that are part of a word.
  static List<List<int>> getValidPositions(
    List<List<TileModel>> board,
    List<WordModel> words,
  ) {
    final positionSet = <String>{};
    final result = <List<int>>[];

    for (final word in words) {
      for (final pos in word.positions) {
        final tile = board[pos[0]][pos[1]];
        final key = '${pos[0]},${pos[1]}';
        if ((tile.letter == null || tile.letter!.isEmpty) &&
            !tile.isBlocked &&
            !positionSet.contains(key)) {
          positionSet.add(key);
          result.add([pos[0], pos[1]]);
        }
      }
    }

    return result;
  }

  /// Clear all highlights on the board.
  static void clearHighlights(List<List<TileModel>> board) {
    for (final row in board) {
      for (final tile in row) {
        tile.isHighlighted = false;
      }
    }
  }

  /// Highlight specific positions.
  static void highlightPositions(
    List<List<TileModel>> board,
    List<List<int>> positions,
  ) {
    for (final pos in positions) {
      if (pos[0] >= 0 &&
          pos[0] < board.length &&
          pos[1] >= 0 &&
          pos[1] < board[0].length) {
        board[pos[0]][pos[1]].isHighlighted = true;
      }
    }
  }
}
