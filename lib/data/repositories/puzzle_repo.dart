import '../models/puzzle_model.dart';
import '../models/word_model.dart';

/// Repository providing predefined crossword puzzle data.
class PuzzleRepo {
  /// Returns Puzzle 1: a 10×10 crossword with 5 interlocking words.
  ///
  /// Grid layout ('x' = blocked):
  /// ```
  ///      0  1  2  3  4  5  6  7  8  9
  ///  0:  x  x  x  x  x  x  x  x  x  x
  ///  1:  x  F  L  A  M  E  x  x  x  x
  ///  2:  x  L  x  x  x  x  x  x  x  x
  ///  3:  T  O  R  C  H  x  x  x  x  x
  ///  4:  x  R  x  x  x  x  x  x  x  x
  ///  5:  x  A  x  x  x  x  x  x  x  x
  ///  6:  x  x  B  R  E  A  D  x  x  x
  ///  7:  x  x  x  x  x  x  x  x  x  x
  ///  8:  x  x  x  S  H  I  N  E  x  x
  ///  9:  x  x  x  x  x  x  x  x  x  x
  /// ```
  ///
  /// Intersections:
  ///  - FLORA(F) × FLAME(F) at (1,1)
  ///  - FLORA(O) × TORCH(O) at (3,1)
  static PuzzleModel getPuzzle1() {
    const int rows = 10;
    const int cols = 10;

    final words = <WordModel>[
      WordModel(
        id: 1,
        clue: "Fire's dancing light",
        answer: 'FLAME',
        positions: [
          [1, 1],
          [1, 2],
          [1, 3],
          [1, 4],
          [1, 5],
        ],
        direction: WordDirection.across,
      ),
      WordModel(
        id: 2,
        clue: 'Portable light source',
        answer: 'TORCH',
        positions: [
          [3, 0],
          [3, 1],
          [3, 2],
          [3, 3],
          [3, 4],
        ],
        direction: WordDirection.across,
      ),
      WordModel(
        id: 3,
        clue: 'Baked food staple',
        answer: 'BREAD',
        positions: [
          [6, 2],
          [6, 3],
          [6, 4],
          [6, 5],
          [6, 6],
        ],
        direction: WordDirection.across,
      ),
      WordModel(
        id: 4,
        clue: 'To glow brightly',
        answer: 'SHINE',
        positions: [
          [8, 3],
          [8, 4],
          [8, 5],
          [8, 6],
          [8, 7],
        ],
        direction: WordDirection.across,
      ),
      WordModel(
        id: 5,
        clue: 'Plant life',
        answer: 'FLORA',
        positions: [
          [1, 1],
          [2, 1],
          [3, 1],
          [4, 1],
          [5, 1],
        ],
        direction: WordDirection.down,
      ),
    ];

    final blockedCells = List.generate(
      rows,
      (r) => List.generate(cols, (c) => true),
    );
    for (final word in words) {
      for (final pos in word.positions) {
        blockedCells[pos[0]][pos[1]] = false;
      }
    }

    return PuzzleModel(
      id: 1,
      name: 'Puzzle 1',
      rows: rows,
      cols: cols,
      words: words,
      blockedCells: blockedCells,
    );
  }
}
