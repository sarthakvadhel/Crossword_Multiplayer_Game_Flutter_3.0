/// Pure-Dart unit tests for the data model layer.
///
/// Run with:  dart run test/models_test.dart
///
/// Uses only [assert] – no flutter_test or package:test dependency.

import '../lib/data/models/tile_model.dart';
import '../lib/data/models/word_model.dart';
import '../lib/data/models/player_model.dart';
import '../lib/data/models/puzzle_model.dart';
import '../lib/data/models/game_state_model.dart';
import '../lib/data/repositories/puzzle_repo.dart';

// ---------------------------------------------------------------------------
// TileModel tests
// ---------------------------------------------------------------------------

void testTileModel() {
  print('--- TileModel ---');

  // Constructor defaults
  print('  constructor: default values');
  final tile = TileModel(row: 2, col: 3);
  assert(tile.row == 2, 'row');
  assert(tile.col == 3, 'col');
  assert(tile.letter == null, 'letter default null');
  assert(tile.isLocked == false, 'isLocked default false');
  assert(tile.isHighlighted == false, 'isHighlighted default false');
  assert(tile.isClueCell == false, 'isClueCell default false');
  assert(tile.clueNumber == null, 'clueNumber default null');
  assert(tile.isBlocked == false, 'isBlocked default false');

  // Constructor with all values
  print('  constructor: explicit values');
  final tile2 = TileModel(
    row: 0,
    col: 1,
    letter: 'A',
    isLocked: true,
    isHighlighted: true,
    isClueCell: true,
    clueNumber: 5,
    isBlocked: true,
  );
  assert(tile2.letter == 'A', 'letter');
  assert(tile2.isLocked == true, 'isLocked');
  assert(tile2.isHighlighted == true, 'isHighlighted');
  assert(tile2.isClueCell == true, 'isClueCell');
  assert(tile2.clueNumber == 5, 'clueNumber');
  assert(tile2.isBlocked == true, 'isBlocked');

  // copyWith
  print('  copyWith: overrides selected fields');
  final copy = tile.copyWith(letter: 'B', isLocked: true);
  assert(copy.letter == 'B', 'copied letter');
  assert(copy.isLocked == true, 'copied isLocked');
  assert(copy.row == 2, 'row preserved');
  assert(copy.col == 3, 'col preserved');

  print('  copyWith: set letter to null explicitly');
  final copy2 = tile2.copyWith(letter: null);
  assert(copy2.letter == null, 'letter set to null');

  print('  copyWith: set clueNumber to null explicitly');
  final copy3 = tile2.copyWith(clueNumber: null);
  assert(copy3.clueNumber == null, 'clueNumber set to null');

  // toJson / fromJson roundtrip
  print('  toJson/fromJson roundtrip');
  final json = tile2.toJson();
  assert(json['letter'] == 'A', 'json letter');
  assert(json['row'] == 0, 'json row');
  assert(json['col'] == 1, 'json col');
  assert(json['isLocked'] == true, 'json isLocked');
  assert(json['isClueCell'] == true, 'json isClueCell');
  assert(json['clueNumber'] == 5, 'json clueNumber');
  assert(json['isBlocked'] == true, 'json isBlocked');

  final restored = TileModel.fromJson(json);
  assert(restored.letter == tile2.letter, 'restored letter');
  assert(restored.row == tile2.row, 'restored row');
  assert(restored.col == tile2.col, 'restored col');
  assert(restored.isLocked == tile2.isLocked, 'restored isLocked');
  assert(restored.isClueCell == tile2.isClueCell, 'restored isClueCell');
  assert(restored.clueNumber == tile2.clueNumber, 'restored clueNumber');
  assert(restored.isBlocked == tile2.isBlocked, 'restored isBlocked');

  // fromJson with missing optional fields
  print('  fromJson: handles missing optional fields');
  final minimal = TileModel.fromJson({'row': 4, 'col': 5});
  assert(minimal.letter == null, 'letter null');
  assert(minimal.isLocked == false, 'isLocked false');
  assert(minimal.isHighlighted == false, 'isHighlighted false');
  assert(minimal.isClueCell == false, 'isClueCell false');
  assert(minimal.clueNumber == null, 'clueNumber null');
  assert(minimal.isBlocked == false, 'isBlocked false');

  print('  TileModel ✓');
}

// ---------------------------------------------------------------------------
// WordModel tests
// ---------------------------------------------------------------------------

void testWordModel() {
  print('--- WordModel ---');

  final word = WordModel(
    id: 1,
    clue: 'A hot light',
    answer: 'FLAME',
    positions: [
      [1, 1], [1, 2], [1, 3], [1, 4], [1, 5],
    ],
    direction: WordDirection.across,
  );

  // Constructor defaults
  print('  constructor: default isCompleted = false');
  assert(word.isCompleted == false, 'isCompleted default');
  assert(word.imageAsset == null, 'imageAsset default null');

  // Fields
  print('  constructor: fields set correctly');
  assert(word.id == 1, 'id');
  assert(word.clue == 'A hot light', 'clue');
  assert(word.answer == 'FLAME', 'answer');
  assert(word.positions.length == 5, 'positions length');
  assert(word.direction == WordDirection.across, 'direction');

  // getFilledCount
  print('  getFilledCount: counts filled tiles');
  final board = List.generate(
    10,
    (r) => List.generate(10, (c) => TileModel(row: r, col: c)),
  );
  assert(word.getFilledCount(board) == 0, 'empty board → 0');
  board[1][1].letter = 'F';
  board[1][2].letter = 'L';
  assert(word.getFilledCount(board) == 2, 'two filled → 2');

  // getPattern
  print('  getPattern: shows filled and blank positions');
  final pattern = word.getPattern(board);
  assert(pattern == 'F L _ _ _', 'Expected "F L _ _ _", got "$pattern"');

  // toJson / fromJson roundtrip
  print('  toJson/fromJson roundtrip');
  final json = word.toJson();
  assert(json['id'] == 1, 'json id');
  assert(json['answer'] == 'FLAME', 'json answer');
  assert(json['direction'] == 'across', 'json direction');
  assert(json['isCompleted'] == false, 'json isCompleted');

  final restored = WordModel.fromJson(json);
  assert(restored.id == word.id, 'restored id');
  assert(restored.clue == word.clue, 'restored clue');
  assert(restored.answer == word.answer, 'restored answer');
  assert(restored.direction == word.direction, 'restored direction');
  assert(restored.isCompleted == word.isCompleted, 'restored isCompleted');
  assert(restored.positions.length == word.positions.length, 'restored positions');
  for (int i = 0; i < word.positions.length; i++) {
    assert(
      restored.positions[i][0] == word.positions[i][0] &&
          restored.positions[i][1] == word.positions[i][1],
      'restored position $i',
    );
  }

  // Direction enum round-trip
  print('  WordDirection: down round-trips');
  final downWord = WordModel(
    id: 2,
    clue: 'test',
    answer: 'FLORA',
    positions: [[1, 1], [2, 1], [3, 1], [4, 1], [5, 1]],
    direction: WordDirection.down,
  );
  final dJson = downWord.toJson();
  assert(dJson['direction'] == 'down', 'json direction down');
  final dRestored = WordModel.fromJson(dJson);
  assert(dRestored.direction == WordDirection.down, 'restored down');

  print('  WordModel ✓');
}

// ---------------------------------------------------------------------------
// PlayerModel tests
// ---------------------------------------------------------------------------

void testPlayerModel() {
  print('--- PlayerModel ---');

  // Constructor defaults
  print('  constructor: default values');
  final player = PlayerModel(name: 'Alice', type: PlayerType.human);
  assert(player.name == 'Alice', 'name');
  assert(player.type == PlayerType.human, 'type');
  assert(player.score == 0, 'score default 0');
  assert(player.hand.isEmpty, 'hand default empty');
  assert(player.streak == 0, 'streak default 0');
  assert(player.longestWord == null, 'longestWord default null');
  assert(player.totalWordsCompleted == 0, 'totalWordsCompleted default 0');
  assert(player.profileImageUrl == null, 'profileImageUrl default null');

  // Constructor with all values
  print('  constructor: explicit values');
  final player2 = PlayerModel(
    name: 'Bot',
    type: PlayerType.computer,
    score: 42,
    hand: ['A', 'B', 'C'],
    streak: 3,
    longestWord: 'FLAME',
    totalWordsCompleted: 7,
    profileImageUrl: 'https://example.com/bot.png',
  );
  assert(player2.score == 42, 'score');
  assert(player2.hand.length == 3, 'hand length');
  assert(player2.streak == 3, 'streak');
  assert(player2.longestWord == 'FLAME', 'longestWord');
  assert(player2.totalWordsCompleted == 7, 'totalWordsCompleted');
  assert(player2.profileImageUrl == 'https://example.com/bot.png', 'profileImageUrl');

  // Mutable hand
  print('  hand: is mutable');
  player.hand.add('X');
  assert(player.hand.length == 1, 'hand modified');
  player.hand.clear();

  // toJson / fromJson roundtrip
  print('  toJson/fromJson roundtrip');
  final json = player2.toJson();
  assert(json['name'] == 'Bot', 'json name');
  assert(json['type'] == 'computer', 'json type');
  assert(json['score'] == 42, 'json score');
  assert((json['hand'] as List).length == 3, 'json hand');
  assert(json['streak'] == 3, 'json streak');
  assert(json['longestWord'] == 'FLAME', 'json longestWord');

  final restored = PlayerModel.fromJson(json);
  assert(restored.name == player2.name, 'restored name');
  assert(restored.type == player2.type, 'restored type');
  assert(restored.score == player2.score, 'restored score');
  assert(restored.hand.length == player2.hand.length, 'restored hand');
  assert(restored.streak == player2.streak, 'restored streak');
  assert(restored.longestWord == player2.longestWord, 'restored longestWord');
  assert(restored.totalWordsCompleted == player2.totalWordsCompleted, 'restored totalWordsCompleted');
  assert(restored.profileImageUrl == player2.profileImageUrl, 'restored profileImageUrl');

  // fromJson with missing optional fields
  print('  fromJson: handles missing optional fields');
  final minimal = PlayerModel.fromJson({
    'name': 'Min',
    'type': 'human',
  });
  assert(minimal.score == 0, 'score 0');
  assert(minimal.hand.isEmpty, 'hand empty');
  assert(minimal.streak == 0, 'streak 0');
  assert(minimal.longestWord == null, 'longestWord null');
  assert(minimal.totalWordsCompleted == 0, 'totalWordsCompleted 0');

  // PlayerType enum
  print('  PlayerType: human and computer');
  assert(PlayerType.human.name == 'human', 'human name');
  assert(PlayerType.computer.name == 'computer', 'computer name');

  print('  PlayerModel ✓');
}

// ---------------------------------------------------------------------------
// PuzzleModel tests
// ---------------------------------------------------------------------------

void testPuzzleModel() {
  print('--- PuzzleModel ---');

  // getPuzzle1 returns valid puzzle
  print('  getPuzzle1: returns valid puzzle');
  final puzzle = PuzzleRepo.getPuzzle1();
  assert(puzzle.id == 1, 'id');
  assert(puzzle.name == 'Puzzle 1', 'name');
  assert(puzzle.rows == 10, 'rows');
  assert(puzzle.cols == 10, 'cols');
  assert(puzzle.words.length == 5, 'words count');
  assert(puzzle.blockedCells.length == 10, 'blockedCells rows');
  assert(puzzle.blockedCells[0].length == 10, 'blockedCells cols');

  // Verify word answers
  print('  getPuzzle1: correct word answers');
  final answers = puzzle.words.map((w) => w.answer).toSet();
  assert(answers.contains('FLAME'), 'has FLAME');
  assert(answers.contains('TORCH'), 'has TORCH');
  assert(answers.contains('BREAD'), 'has BREAD');
  assert(answers.contains('SHINE'), 'has SHINE');
  assert(answers.contains('FLORA'), 'has FLORA');

  // Every word position cell is NOT blocked
  print('  getPuzzle1: word cells are not blocked');
  for (final word in puzzle.words) {
    for (final pos in word.positions) {
      assert(
        puzzle.blockedCells[pos[0]][pos[1]] == false,
        'Word ${word.answer} pos (${pos[0]},${pos[1]}) should not be blocked',
      );
    }
  }

  // Word positions match answer length
  print('  getPuzzle1: word positions match answer length');
  for (final word in puzzle.words) {
    assert(
      word.positions.length == word.answer.length,
      '${word.answer}: positions.length ${word.positions.length} != answer.length ${word.answer.length}',
    );
  }

  // toJson / fromJson roundtrip
  print('  toJson/fromJson roundtrip');
  final json = puzzle.toJson();
  assert(json['id'] == 1, 'json id');
  assert(json['rows'] == 10, 'json rows');
  assert((json['words'] as List).length == 5, 'json words count');

  final restored = PuzzleModel.fromJson(json);
  assert(restored.id == puzzle.id, 'restored id');
  assert(restored.name == puzzle.name, 'restored name');
  assert(restored.rows == puzzle.rows, 'restored rows');
  assert(restored.cols == puzzle.cols, 'restored cols');
  assert(restored.words.length == puzzle.words.length, 'restored words count');

  // Verify restored words match original
  for (int i = 0; i < puzzle.words.length; i++) {
    assert(
      restored.words[i].answer == puzzle.words[i].answer,
      'restored word $i answer',
    );
    assert(
      restored.words[i].direction == puzzle.words[i].direction,
      'restored word $i direction',
    );
  }

  // Verify restored blocked cells
  for (int r = 0; r < puzzle.rows; r++) {
    for (int c = 0; c < puzzle.cols; c++) {
      assert(
        restored.blockedCells[r][c] == puzzle.blockedCells[r][c],
        'restored blocked ($r,$c)',
      );
    }
  }

  print('  PuzzleModel ✓');
}

// ---------------------------------------------------------------------------
// GameStateModel tests
// ---------------------------------------------------------------------------

void testGameStateModel() {
  print('--- GameStateModel ---');

  final board = List.generate(
    2,
    (r) => List.generate(2, (c) => TileModel(row: r, col: c)),
  );
  final player = PlayerModel(name: 'Alice', type: PlayerType.human, score: 10);
  final computer = PlayerModel(name: 'Bot', type: PlayerType.computer, score: 5);

  // Constructor defaults
  print('  constructor: default values');
  final state = GameStateModel(
    board: board,
    player: player,
    computer: computer,
  );
  assert(state.phase == GamePhase.notStarted, 'phase default');
  assert(state.currentTurn == 0, 'currentTurn default');
  assert(state.lastBanner == null, 'lastBanner default');
  assert(state.moveHistory.isEmpty, 'moveHistory default empty');
  assert(state.isPuzzleComplete == false, 'isPuzzleComplete default');
  assert(state.lastSaved == null, 'lastSaved default');

  // Constructor with explicit values
  print('  constructor: explicit values');
  final now = DateTime.now();
  final state2 = GameStateModel(
    board: board,
    player: player,
    computer: computer,
    phase: GamePhase.playerTurn,
    currentTurn: 3,
    lastBanner: 'Amazing!',
    moveHistory: ['move1', 'move2'],
    isPuzzleComplete: true,
    lastSaved: now,
  );
  assert(state2.phase == GamePhase.playerTurn, 'phase');
  assert(state2.currentTurn == 3, 'currentTurn');
  assert(state2.lastBanner == 'Amazing!', 'lastBanner');
  assert(state2.moveHistory.length == 2, 'moveHistory');
  assert(state2.isPuzzleComplete == true, 'isPuzzleComplete');
  assert(state2.lastSaved == now, 'lastSaved');

  // toJson / fromJson roundtrip
  print('  toJson/fromJson roundtrip');
  final json = state2.toJson();
  assert(json['phase'] == 'playerTurn', 'json phase');
  assert(json['currentTurn'] == 3, 'json currentTurn');
  assert(json['lastBanner'] == 'Amazing!', 'json lastBanner');
  assert((json['moveHistory'] as List).length == 2, 'json moveHistory');
  assert(json['isPuzzleComplete'] == true, 'json isPuzzleComplete');
  assert(json['lastSaved'] != null, 'json lastSaved');

  final restored = GameStateModel.fromJson(json);
  assert(restored.phase == state2.phase, 'restored phase');
  assert(restored.currentTurn == state2.currentTurn, 'restored currentTurn');
  assert(restored.lastBanner == state2.lastBanner, 'restored lastBanner');
  assert(restored.moveHistory.length == state2.moveHistory.length, 'restored moveHistory');
  assert(restored.isPuzzleComplete == state2.isPuzzleComplete, 'restored isPuzzleComplete');
  assert(restored.lastSaved != null, 'restored lastSaved not null');

  // Board roundtrip
  print('  toJson/fromJson: board preserves tiles');
  assert(restored.board.length == 2, 'restored board rows');
  assert(restored.board[0].length == 2, 'restored board cols');
  assert(restored.board[0][0].row == 0, 'restored tile row');
  assert(restored.board[0][0].col == 0, 'restored tile col');

  // Player roundtrip
  print('  toJson/fromJson: player data preserved');
  assert(restored.player.name == 'Alice', 'restored player name');
  assert(restored.player.score == 10, 'restored player score');
  assert(restored.computer.name == 'Bot', 'restored computer name');
  assert(restored.computer.score == 5, 'restored computer score');

  // fromJson with missing optional fields
  print('  fromJson: handles missing optional fields');
  final minimalJson = {
    'board': [
      [TileModel(row: 0, col: 0).toJson()],
    ],
    'player': PlayerModel(name: 'P', type: PlayerType.human).toJson(),
    'computer': PlayerModel(name: 'C', type: PlayerType.computer).toJson(),
    'phase': 'notStarted',
  };
  final minState = GameStateModel.fromJson(minimalJson);
  assert(minState.currentTurn == 0, 'default currentTurn');
  assert(minState.moveHistory.isEmpty, 'default moveHistory');
  assert(minState.isPuzzleComplete == false, 'default isPuzzleComplete');
  assert(minState.lastSaved == null, 'default lastSaved');

  // GamePhase enum
  print('  GamePhase: all values exist');
  assert(GamePhase.values.length == 4, '4 phases');
  assert(GamePhase.notStarted.name == 'notStarted', 'notStarted');
  assert(GamePhase.playerTurn.name == 'playerTurn', 'playerTurn');
  assert(GamePhase.aiTurn.name == 'aiTurn', 'aiTurn');
  assert(GamePhase.gameOver.name == 'gameOver', 'gameOver');

  print('  GameStateModel ✓');
}

// ---------------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------------

void main() {
  testTileModel();
  testWordModel();
  testPlayerModel();
  testPuzzleModel();
  testGameStateModel();
  print('\n✅ All model tests passed!');
}
