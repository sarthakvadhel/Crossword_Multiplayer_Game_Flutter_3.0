/// Pure-Dart unit tests for the game engine layer.
///
/// Run with:  dart run test/game_engine_test.dart
///
/// These tests use only [assert] so they can execute without flutter_test
/// or package:test.  Each logical group prints progress to stdout.

import '../lib/data/models/tile_model.dart';
import '../lib/data/models/word_model.dart';
import '../lib/data/models/puzzle_model.dart';
import '../lib/data/models/player_model.dart';
import '../lib/data/models/game_state_model.dart';
import '../lib/data/repositories/puzzle_repo.dart';
import '../lib/game_engine/board_engine.dart';
import '../lib/game_engine/move_validator.dart';
import '../lib/game_engine/scoring_engine.dart';
import '../lib/game_engine/letter_generator.dart';
import '../lib/game_engine/turn_manager.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

PuzzleModel _testPuzzle() => PuzzleRepo.getPuzzle1();

List<List<TileModel>> _freshBoard() => BoardEngine.createBoard(_testPuzzle());

// ---------------------------------------------------------------------------
// BoardEngine tests
// ---------------------------------------------------------------------------

void testBoardEngine() {
  print('--- BoardEngine ---');

  final puzzle = _testPuzzle();
  final board = BoardEngine.createBoard(puzzle);

  // Correct dimensions
  print('  createBoard: correct row count');
  assert(board.length == puzzle.rows, 'Expected ${puzzle.rows} rows');

  print('  createBoard: correct col count');
  assert(board[0].length == puzzle.cols, 'Expected ${puzzle.cols} cols');

  // Blocked cells match puzzle
  print('  createBoard: blocked cells match puzzle data');
  for (int r = 0; r < puzzle.rows; r++) {
    for (int c = 0; c < puzzle.cols; c++) {
      assert(
        board[r][c].isBlocked == puzzle.blockedCells[r][c],
        'Blocked mismatch at ($r,$c)',
      );
    }
  }

  // Non-blocked cells start empty
  print('  createBoard: non-blocked cells start with no letter');
  for (final row in board) {
    for (final tile in row) {
      if (!tile.isBlocked) {
        assert(tile.letter == null, 'Tile (${tile.row},${tile.col}) should be null');
      }
    }
  }

  // Clue cells are marked at word start positions
  print('  createBoard: clue cells marked at word starts');
  for (final word in puzzle.words) {
    final startR = word.positions.first[0];
    final startC = word.positions.first[1];
    assert(
      board[startR][startC].isClueCell == true,
      'Expected clue cell at ($startR,$startC) for word ${word.id}',
    );
    assert(
      board[startR][startC].clueNumber == word.id,
      'Expected clueNumber ${word.id} at ($startR,$startC)',
    );
  }

  // --- placeLetter ---
  print('  placeLetter: place on valid empty cell');
  final b2 = _freshBoard();
  // (1,1) is the first letter of FLAME/FLORA – not blocked
  assert(BoardEngine.placeLetter(b2, 1, 1, 'F') == true, 'Should succeed');
  assert(b2[1][1].letter == 'F', 'Letter should be F');

  print('  placeLetter: reject blocked cell');
  assert(BoardEngine.placeLetter(b2, 0, 0, 'X') == false, '(0,0) is blocked');

  print('  placeLetter: reject out-of-bounds');
  assert(BoardEngine.placeLetter(b2, -1, 0, 'A') == false, 'row -1 OOB');
  assert(BoardEngine.placeLetter(b2, 0, 99, 'A') == false, 'col 99 OOB');

  print('  placeLetter: reject locked cell');
  b2[1][1].isLocked = true;
  assert(BoardEngine.placeLetter(b2, 1, 1, 'Z') == false, 'locked cell');

  // --- removeLetter ---
  print('  removeLetter: remove from unlocked cell');
  final b3 = _freshBoard();
  BoardEngine.placeLetter(b3, 1, 2, 'L');
  assert(BoardEngine.removeLetter(b3, 1, 2) == true, 'remove should succeed');
  assert(b3[1][2].letter == null, 'letter should be cleared');

  print('  removeLetter: reject locked cell');
  b3[1][3].isLocked = true;
  assert(BoardEngine.removeLetter(b3, 1, 3) == false, 'locked remove fails');

  // --- lockPlacedLetters ---
  print('  lockPlacedLetters: locks non-empty tiles');
  final b4 = _freshBoard();
  BoardEngine.placeLetter(b4, 1, 1, 'F');
  BoardEngine.placeLetter(b4, 1, 2, 'L');
  BoardEngine.lockPlacedLetters(b4);
  assert(b4[1][1].isLocked == true, '(1,1) should be locked');
  assert(b4[1][2].isLocked == true, '(1,2) should be locked');
  // Empty tile should NOT be locked
  assert(b4[1][3].isLocked == false, '(1,3) empty tile not locked');

  // --- isPuzzleComplete ---
  print('  isPuzzleComplete: false when board is empty');
  assert(
    BoardEngine.isPuzzleComplete(_freshBoard(), puzzle.words) == false,
    'Empty board is not complete',
  );

  print('  isPuzzleComplete: true when all words filled');
  final bFull = _freshBoard();
  for (final word in puzzle.words) {
    for (int i = 0; i < word.positions.length; i++) {
      final r = word.positions[i][0];
      final c = word.positions[i][1];
      if (bFull[r][c].letter == null) {
        bFull[r][c].letter = word.answer[i];
      }
    }
  }
  assert(
    BoardEngine.isPuzzleComplete(bFull, puzzle.words) == true,
    'Fully filled board should be complete',
  );

  // --- getValidPositions ---
  print('  getValidPositions: returns only empty word cells');
  final bPartial = _freshBoard();
  BoardEngine.placeLetter(bPartial, 1, 1, 'F');
  final valid = BoardEngine.getValidPositions(bPartial, puzzle.words);
  // (1,1) is filled so should NOT be in valid positions
  assert(
    valid.every((p) => !(p[0] == 1 && p[1] == 1)),
    '(1,1) should not be valid – already filled',
  );
  assert(valid.isNotEmpty, 'There should be valid positions');

  // --- highlightPositions / clearHighlights ---
  print('  highlightPositions & clearHighlights');
  final bH = _freshBoard();
  BoardEngine.highlightPositions(bH, [
    [1, 1],
    [1, 2],
  ]);
  assert(bH[1][1].isHighlighted == true, '(1,1) highlighted');
  assert(bH[1][2].isHighlighted == true, '(1,2) highlighted');
  BoardEngine.clearHighlights(bH);
  assert(bH[1][1].isHighlighted == false, '(1,1) cleared');
  assert(bH[1][2].isHighlighted == false, '(1,2) cleared');

  print('  BoardEngine ✓');
}

// ---------------------------------------------------------------------------
// MoveValidator tests
// ---------------------------------------------------------------------------

void testMoveValidator() {
  print('--- MoveValidator ---');

  final puzzle = _testPuzzle();
  final board = _freshBoard();

  // isValidPlacement
  print('  isValidPlacement: blocked cell returns false');
  assert(MoveValidator.isValidPlacement(board, 0, 0) == false, '(0,0) blocked');

  print('  isValidPlacement: out-of-bounds returns false');
  assert(MoveValidator.isValidPlacement(board, -1, 0) == false, 'row -1');
  assert(MoveValidator.isValidPlacement(board, 0, 10) == false, 'col 10');
  assert(MoveValidator.isValidPlacement(board, 10, 0) == false, 'row 10');

  print('  isValidPlacement: valid empty cell returns true');
  assert(MoveValidator.isValidPlacement(board, 1, 1) == true, '(1,1) valid');

  print('  isValidPlacement: locked cell returns false');
  board[1][1].isLocked = true;
  assert(MoveValidator.isValidPlacement(board, 1, 1) == false, 'locked');
  board[1][1].isLocked = false; // reset

  // isCorrectLetter
  // FLAME at row 1, positions 1-5 → F L A M E
  print('  isCorrectLetter: correct letter returns true');
  assert(
    MoveValidator.isCorrectLetter(board, puzzle.words, 1, 1, 'F') == true,
    'F at (1,1) is correct for FLAME',
  );
  assert(
    MoveValidator.isCorrectLetter(board, puzzle.words, 1, 3, 'M') == true,
    'M at (1,3) is correct for FLAME',
  );

  print('  isCorrectLetter: wrong letter returns false');
  assert(
    MoveValidator.isCorrectLetter(board, puzzle.words, 1, 1, 'Z') == false,
    'Z at (1,1) should be false',
  );

  print('  isCorrectLetter: case-insensitive match');
  assert(
    MoveValidator.isCorrectLetter(board, puzzle.words, 1, 1, 'f') == true,
    'lowercase f should match F',
  );

  // checkCompletedWords
  print('  checkCompletedWords: no words complete on fresh board');
  final bEmpty = _freshBoard();
  final comp1 = MoveValidator.checkCompletedWords(bEmpty, puzzle.words);
  assert(comp1.isEmpty, 'No completed words on fresh board');

  print('  checkCompletedWords: detects completed word');
  final bW = _freshBoard();
  // Fill FLAME at row 1
  for (int i = 0; i < puzzle.words[0].positions.length; i++) {
    final r = puzzle.words[0].positions[i][0];
    final c = puzzle.words[0].positions[i][1];
    bW[r][c].letter = puzzle.words[0].answer[i];
  }
  final comp2 = MoveValidator.checkCompletedWords(bW, puzzle.words);
  assert(comp2.any((w) => w.answer == 'FLAME'), 'FLAME should be completed');

  print('  checkCompletedWords: skips already-completed words');
  puzzle.words[0].isCompleted = true;
  final comp3 = MoveValidator.checkCompletedWords(bW, puzzle.words);
  assert(
    comp3.every((w) => w.answer != 'FLAME'),
    'FLAME already completed – should be skipped',
  );
  puzzle.words[0].isCompleted = false; // reset

  print('  MoveValidator ✓');
}

// ---------------------------------------------------------------------------
// ScoringEngine tests
// ---------------------------------------------------------------------------

void testScoringEngine() {
  print('--- ScoringEngine ---');

  // Basic letter scoring
  print('  calculateTurnScore: correct letters give +1 each');
  final r1 = ScoringEngine.calculateTurnScore(
    lettersPlaced: 3,
    completedWords: [],
    handEmpty: false,
    currentStreak: 0,
    currentLongestWord: null,
    newLongestWord: null,
  );
  assert(r1.points == 3, 'Expected 3, got ${r1.points}');

  // Empty hand bonus
  print('  calculateTurnScore: empty hand gives +5 bonus');
  final r2 = ScoringEngine.calculateTurnScore(
    lettersPlaced: 2,
    completedWords: [],
    handEmpty: true,
    currentStreak: 0,
    currentLongestWord: null,
    newLongestWord: null,
  );
  assert(r2.points == 7, 'Expected 7 (2 + 5), got ${r2.points}');
  assert(r2.emptyHand == true, 'emptyHand flag');

  // Longest word bonus
  print('  calculateTurnScore: longest word gives +6 bonus');
  final r3 = ScoringEngine.calculateTurnScore(
    lettersPlaced: 1,
    completedWords: [],
    handEmpty: false,
    currentStreak: 0,
    currentLongestWord: 'CAT',
    newLongestWord: 'FLAME',
  );
  assert(r3.points == 7, 'Expected 7 (1 + 6), got ${r3.points}');
  assert(r3.isLongestWord == true, 'isLongestWord flag');

  // Longest word NOT awarded when not longer
  print('  calculateTurnScore: no bonus if new word is not longer');
  final r3b = ScoringEngine.calculateTurnScore(
    lettersPlaced: 1,
    completedWords: [],
    handEmpty: false,
    currentStreak: 0,
    currentLongestWord: 'FLAME',
    newLongestWord: 'CAT',
  );
  assert(r3b.points == 1, 'Expected 1, got ${r3b.points}');
  assert(r3b.isLongestWord == false, 'should not be longest');

  // Word completion bonus
  print('  calculateTurnScore: word completion adds word length');
  final completedWord = WordModel(
    id: 1,
    clue: 'test',
    answer: 'FLAME',
    positions: [
      [1, 1], [1, 2], [1, 3], [1, 4], [1, 5],
    ],
    direction: WordDirection.across,
  );
  final r4 = ScoringEngine.calculateTurnScore(
    lettersPlaced: 2,
    completedWords: [completedWord],
    handEmpty: false,
    currentStreak: 0,
    currentLongestWord: null,
    newLongestWord: null,
  );
  // 2 letters + 5 (FLAME length) = 7
  assert(r4.points == 7, 'Expected 7, got ${r4.points}');
  assert(r4.wordCompleted == true, 'wordCompleted flag');
  assert(r4.completedWord == 'FLAME', 'completedWord name');

  // Streak incremented on word completion
  print('  calculateTurnScore: streak increments on word completion');
  assert(r4.streak == 1, 'Expected streak 1, got ${r4.streak}');

  // Streak resets when no word completed
  print('  calculateTurnScore: streak resets to 0 with no completion');
  assert(r1.streak == 0, 'Expected streak 0, got ${r1.streak}');

  // Combined bonuses
  print('  calculateTurnScore: combined bonuses stack');
  final r5 = ScoringEngine.calculateTurnScore(
    lettersPlaced: 5,
    completedWords: [completedWord],
    handEmpty: true,
    currentStreak: 2,
    currentLongestWord: null,
    newLongestWord: 'FLAME',
  );
  // 5 letters + 5 (FLAME) + 5 (empty hand) + 6 (longest word) = 21
  assert(r5.points == 21, 'Expected 21, got ${r5.points}');

  print('  ScoringEngine ✓');
}

// ---------------------------------------------------------------------------
// LetterGenerator tests
// ---------------------------------------------------------------------------

void testLetterGenerator() {
  print('--- LetterGenerator ---');

  print('  generateHand: returns 5 letters');
  final hand = LetterGenerator.generateHand();
  assert(hand.length == 5, 'Expected 5, got ${hand.length}');

  print('  generateHand: all letters are uppercase A-Z');
  for (final letter in hand) {
    assert(
      letter.length == 1 && letter.codeUnitAt(0) >= 65 && letter.codeUnitAt(0) <= 90,
      'Invalid letter: $letter',
    );
  }

  print('  refillHand: fills up to 5 from partial hand');
  final partial = ['A', 'B'];
  final refilled = LetterGenerator.refillHand(List<String>.from(partial));
  assert(refilled.length == 5, 'Expected 5, got ${refilled.length}');
  assert(refilled[0] == 'A', 'First letter preserved');
  assert(refilled[1] == 'B', 'Second letter preserved');

  print('  refillHand: no change when hand is full');
  final full = ['A', 'B', 'C', 'D', 'E'];
  final refilled2 = LetterGenerator.refillHand(List<String>.from(full));
  assert(refilled2.length == 5, 'Still 5');

  print('  swapLetters: replaces at correct indices');
  final toSwap = ['A', 'B', 'C', 'D', 'E'];
  final swapped = LetterGenerator.swapLetters(List<String>.from(toSwap), [1, 3]);
  assert(swapped.length == 5, 'Length unchanged');
  assert(swapped[0] == 'A', 'Index 0 unchanged');
  assert(swapped[2] == 'C', 'Index 2 unchanged');
  assert(swapped[4] == 'E', 'Index 4 unchanged');
  // Indices 1 and 3 may or may not have changed (random), but they're valid letters
  assert(
    swapped[1].length == 1 && swapped[1].codeUnitAt(0) >= 65 && swapped[1].codeUnitAt(0) <= 90,
    'Swapped index 1 is valid letter',
  );
  assert(
    swapped[3].length == 1 && swapped[3].codeUnitAt(0) >= 65 && swapped[3].codeUnitAt(0) <= 90,
    'Swapped index 3 is valid letter',
  );

  print('  swapLetters: ignores out-of-bounds indices');
  final safe = ['X', 'Y'];
  final swapped2 = LetterGenerator.swapLetters(List<String>.from(safe), [5, -1]);
  assert(swapped2.length == 2, 'Length unchanged');
  assert(swapped2[0] == 'X', 'Index 0 unchanged');
  assert(swapped2[1] == 'Y', 'Index 1 unchanged');

  print('  LetterGenerator ✓');
}

// ---------------------------------------------------------------------------
// TurnManager tests
// ---------------------------------------------------------------------------

void testTurnManager() {
  print('--- TurnManager ---');

  // nextTurn
  print('  nextTurn: playerTurn → aiTurn');
  assert(
    TurnManager.nextTurn(GamePhase.playerTurn) == GamePhase.aiTurn,
    'Should switch to aiTurn',
  );

  print('  nextTurn: aiTurn → playerTurn');
  assert(
    TurnManager.nextTurn(GamePhase.aiTurn) == GamePhase.playerTurn,
    'Should switch to playerTurn',
  );

  print('  nextTurn: other phases return themselves');
  assert(
    TurnManager.nextTurn(GamePhase.notStarted) == GamePhase.notStarted,
    'notStarted stays',
  );
  assert(
    TurnManager.nextTurn(GamePhase.gameOver) == GamePhase.gameOver,
    'gameOver stays',
  );

  // shouldEndGame
  print('  shouldEndGame: false when puzzle incomplete');
  final stateInProgress = GameStateModel(
    board: _freshBoard(),
    player: PlayerModel(name: 'Alice', type: PlayerType.human, score: 10),
    computer: PlayerModel(name: 'Bot', type: PlayerType.computer, score: 5),
    isPuzzleComplete: false,
  );
  assert(TurnManager.shouldEndGame(stateInProgress) == false, 'not done');

  print('  shouldEndGame: true when puzzle complete');
  stateInProgress.isPuzzleComplete = true;
  assert(TurnManager.shouldEndGame(stateInProgress) == true, 'done');

  // getWinner
  print('  getWinner: player with higher score wins');
  final stateP = GameStateModel(
    board: _freshBoard(),
    player: PlayerModel(name: 'Alice', type: PlayerType.human, score: 15),
    computer: PlayerModel(name: 'Bot', type: PlayerType.computer, score: 10),
  );
  assert(TurnManager.getWinner(stateP) == 'Alice', 'Alice should win');

  print('  getWinner: computer with higher score wins');
  final stateC = GameStateModel(
    board: _freshBoard(),
    player: PlayerModel(name: 'Alice', type: PlayerType.human, score: 5),
    computer: PlayerModel(name: 'Bot', type: PlayerType.computer, score: 20),
  );
  assert(TurnManager.getWinner(stateC) == 'Bot', 'Bot should win');

  print('  getWinner: tie');
  final stateT = GameStateModel(
    board: _freshBoard(),
    player: PlayerModel(name: 'Alice', type: PlayerType.human, score: 10),
    computer: PlayerModel(name: 'Bot', type: PlayerType.computer, score: 10),
  );
  assert(TurnManager.getWinner(stateT) == 'Tie', 'Should be Tie');

  print('  TurnManager ✓');
}

// ---------------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------------

void main() {
  testBoardEngine();
  testMoveValidator();
  testScoringEngine();
  testLetterGenerator();
  testTurnManager();
  print('\n✅ All game engine tests passed!');
}
