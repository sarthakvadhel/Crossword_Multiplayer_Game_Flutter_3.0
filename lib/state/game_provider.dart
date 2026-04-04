import 'package:flutter/foundation.dart';
import '../data/models/tile_model.dart';
import '../data/models/word_model.dart';
import '../data/models/player_model.dart';
import '../data/models/game_state_model.dart';
import '../data/repositories/puzzle_repo.dart';
import '../game_engine/board_engine.dart';
import '../game_engine/scoring_engine.dart';
import '../game_engine/ai_engine.dart';
import '../game_engine/move_validator.dart';
import '../game_engine/letter_generator.dart';
import '../game_engine/turn_manager.dart';
import '../core/services/storage_service.dart';
import '../core/services/banner_service.dart';
import '../core/constants/game_constants.dart';
import '../core/utils/helpers.dart';

class GameProvider extends ChangeNotifier {
  GameStateModel? _gameState;
  final StorageService _storageService;

  // Track letters placed during current turn (before confirming)
  List<MapEntry<List<int>, String>> _currentTurnPlacements = [];

  // Selected letter index from hand (-1 if none)
  int _selectedLetterIndex = -1;

  // Selected letters for swap
  List<int> _selectedForSwap = [];

  // Banner message to show
  String? _currentBanner;

  // Is AI thinking
  bool _isAiThinking = false;

  // Hint positions
  List<List<int>> _hintPositions = [];

  GameProvider(this._storageService);

  // Getters
  GameStateModel? get gameState => _gameState;
  List<List<TileModel>> get board => _gameState?.board ?? [];
  PlayerModel get player =>
      _gameState?.player ??
      PlayerModel(name: 'Player', type: PlayerType.human);
  PlayerModel get computer =>
      _gameState?.computer ??
      PlayerModel(name: 'Computer', type: PlayerType.computer);
  GamePhase get phase => _gameState?.phase ?? GamePhase.notStarted;
  int get selectedLetterIndex => _selectedLetterIndex;
  List<int> get selectedForSwap => _selectedForSwap;
  String? get currentBanner => _currentBanner;
  bool get isAiThinking => _isAiThinking;
  List<List<int>> get hintPositions => _hintPositions;
  bool get hasActiveGame =>
      _gameState != null && !(_gameState!.isPuzzleComplete);
  List<WordModel> get words => PuzzleRepo.getPuzzle1().words;

  // Initialize new game
  void startNewGame() {
    final puzzle = PuzzleRepo.getPuzzle1();
    final board = BoardEngine.createBoard(puzzle);
    _gameState = GameStateModel(
      board: board,
      player: PlayerModel(
        name: 'Player',
        type: PlayerType.human,
        hand: LetterGenerator.generateHand(),
      ),
      computer: PlayerModel(
        name: 'Computer',
        type: PlayerType.computer,
        hand: LetterGenerator.generateHand(),
      ),
      phase: GamePhase.playerTurn,
      currentTurn: 1,
    );
    _currentTurnPlacements = [];
    _selectedLetterIndex = -1;
    _selectedForSwap = [];
    _currentBanner = null;
    _hintPositions = [];
    _isAiThinking = false;
    notifyListeners();
    _saveGame();
  }

  // Try to load saved game, returns true if found
  bool loadGame() {
    final saved = _storageService.loadGameState();
    if (saved != null) {
      _gameState = saved;
      _currentTurnPlacements = [];
      _selectedLetterIndex = -1;
      notifyListeners();
      return true;
    }
    return false;
  }

  // Select a letter from hand
  void selectLetter(int index) {
    if (_gameState?.phase != GamePhase.playerTurn) return;
    _selectedLetterIndex = index == _selectedLetterIndex ? -1 : index;
    notifyListeners();
  }

  // Place selected letter on board
  void placeLetter(int row, int col) {
    if (_gameState == null || _gameState!.phase != GamePhase.playerTurn) return;
    if (_selectedLetterIndex < 0 ||
        _selectedLetterIndex >= _gameState!.player.hand.length) return;
    if (!MoveValidator.isValidPlacement(_gameState!.board, row, col)) return;
    if (_gameState!.board[row][col].letter != null) return;

    final letter = _gameState!.player.hand[_selectedLetterIndex];

    final puzzle = PuzzleRepo.getPuzzle1();
    if (!MoveValidator.isCorrectLetter(
        _gameState!.board, puzzle.words, row, col, letter)) return;

    BoardEngine.placeLetter(_gameState!.board, row, col, letter);
    _currentTurnPlacements.add(MapEntry([row, col], letter));

    _gameState!.player.hand.removeAt(_selectedLetterIndex);
    _selectedLetterIndex = -1;
    _hintPositions = [];

    notifyListeners();
  }

  // Confirm turn (end player's turn)
  void confirmTurn() {
    if (_gameState == null || _currentTurnPlacements.isEmpty) return;

    BoardEngine.lockPlacedLetters(_gameState!.board);

    final puzzle = PuzzleRepo.getPuzzle1();
    final completedWords =
        MoveValidator.checkCompletedWords(_gameState!.board, puzzle.words);
    final newlyCompleted =
        completedWords.where((w) => !w.isCompleted).toList();
    for (var w in newlyCompleted) {
      w.isCompleted = true;
    }

    String? longestCompleted;
    if (newlyCompleted.isNotEmpty) {
      longestCompleted = newlyCompleted
          .map((w) => w.answer)
          .reduce((a, b) => a.length >= b.length ? a : b);
    }

    final scoreResult = ScoringEngine.calculateTurnScore(
      lettersPlaced: _currentTurnPlacements.length,
      completedWords: newlyCompleted,
      handEmpty: _gameState!.player.hand.isEmpty,
      currentStreak: _gameState!.player.streak,
      currentLongestWord: _gameState!.player.longestWord,
      newLongestWord: longestCompleted,
    );

    _gameState!.player.score += scoreResult.points;
    _gameState!.player.streak = scoreResult.streak;
    if (scoreResult.isLongestWord && longestCompleted != null) {
      _gameState!.player.longestWord = longestCompleted;
    }
    _gameState!.player.totalWordsCompleted += newlyCompleted.length;

    _gameState!.moveHistory.add(
        'Player placed ${_currentTurnPlacements.length} letters (+${scoreResult.points})');

    _currentBanner = BannerService.getBanner(
      wordCompleted: scoreResult.wordCompleted,
      emptyHand: scoreResult.emptyHand,
      longestWord: scoreResult.isLongestWord,
      streak: scoreResult.streak,
      score: scoreResult.points,
    );

    _gameState!.player.hand =
        LetterGenerator.refillHand(_gameState!.player.hand);

    _gameState!.isPuzzleComplete =
        BoardEngine.isPuzzleComplete(_gameState!.board, puzzle.words);
    if (_gameState!.isPuzzleComplete) {
      _gameState!.phase = GamePhase.gameOver;
    } else {
      _gameState!.phase = GamePhase.aiTurn;
    }

    _currentTurnPlacements = [];
    _selectedLetterIndex = -1;
    _gameState!.currentTurn++;

    notifyListeners();
    _saveGame();

    if (_gameState!.phase == GamePhase.aiTurn) {
      _playAiTurn();
    }
  }

  // AI turn logic
  Future<void> _playAiTurn() async {
    if (_gameState == null) return;
    _isAiThinking = true;
    notifyListeners();

    await Future.delayed(Duration(
        milliseconds:
            Helpers.randomInt(GameConstants.aiMinDelay, GameConstants.aiMaxDelay)));

    final puzzle = PuzzleRepo.getPuzzle1();
    final move = AiEngine.decideMove(
      board: _gameState!.board,
      words: puzzle.words,
      hand: _gameState!.computer.hand,
    );

    if (move.isSwap) {
      _gameState!.computer.hand = LetterGenerator.generateHand();
      _gameState!.moveHistory.add('Computer swapped letters');
      _gameState!.computer.streak = 0;
    } else {
      for (var placement in move.placements) {
        final pos = placement.key;
        BoardEngine.placeLetter(
            _gameState!.board, pos[0], pos[1], placement.value);
        _gameState!.computer.hand.remove(placement.value);
      }

      BoardEngine.lockPlacedLetters(_gameState!.board);

      final completedWords =
          MoveValidator.checkCompletedWords(_gameState!.board, puzzle.words);
      final newlyCompleted =
          completedWords.where((w) => !w.isCompleted).toList();
      for (var w in newlyCompleted) {
        w.isCompleted = true;
      }

      String? longestCompleted;
      if (newlyCompleted.isNotEmpty) {
        longestCompleted = newlyCompleted
            .map((w) => w.answer)
            .reduce((a, b) => a.length >= b.length ? a : b);
      }

      final scoreResult = ScoringEngine.calculateTurnScore(
        lettersPlaced: move.placements.length,
        completedWords: newlyCompleted,
        handEmpty: _gameState!.computer.hand.isEmpty,
        currentStreak: _gameState!.computer.streak,
        currentLongestWord: _gameState!.computer.longestWord,
        newLongestWord: longestCompleted,
      );

      _gameState!.computer.score += scoreResult.points;
      _gameState!.computer.streak = scoreResult.streak;
      if (scoreResult.isLongestWord && longestCompleted != null) {
        _gameState!.computer.longestWord = longestCompleted;
      }
      _gameState!.computer.totalWordsCompleted += newlyCompleted.length;

      _gameState!.moveHistory.add(
          'Computer placed ${move.placements.length} letters (+${scoreResult.points})');

      _gameState!.computer.hand =
          LetterGenerator.refillHand(_gameState!.computer.hand);
    }

    _gameState!.isPuzzleComplete =
        BoardEngine.isPuzzleComplete(_gameState!.board, puzzle.words);
    if (_gameState!.isPuzzleComplete) {
      _gameState!.phase = GamePhase.gameOver;
    } else {
      _gameState!.phase = GamePhase.playerTurn;
    }

    _gameState!.currentTurn++;
    _isAiThinking = false;
    _currentBanner = null;
    notifyListeners();
    _saveGame();
  }

  // Swap selected letters
  void swapLetters() {
    if (_gameState == null || _selectedForSwap.isEmpty) return;
    if (_gameState!.phase != GamePhase.playerTurn) return;

    _gameState!.player.hand =
        LetterGenerator.swapLetters(_gameState!.player.hand, _selectedForSwap);
    _gameState!.player.streak = 0;
    _gameState!.moveHistory
        .add('Player swapped ${_selectedForSwap.length} letters');

    _selectedForSwap = [];
    _gameState!.phase = GamePhase.aiTurn;
    _gameState!.currentTurn++;

    notifyListeners();
    _saveGame();
    _playAiTurn();
  }

  // Toggle letter selection for swap
  void toggleSwapSelection(int index) {
    if (_selectedForSwap.contains(index)) {
      _selectedForSwap.remove(index);
    } else {
      _selectedForSwap.add(index);
    }
    notifyListeners();
  }

  // Show hints
  void showHint() {
    if (_gameState == null) return;
    final puzzle = PuzzleRepo.getPuzzle1();
    _hintPositions =
        BoardEngine.getValidPositions(_gameState!.board, puzzle.words);
    BoardEngine.clearHighlights(_gameState!.board);
    BoardEngine.highlightPositions(_gameState!.board, _hintPositions);
    notifyListeners();
  }

  // Clear banner
  void clearBanner() {
    _currentBanner = null;
    notifyListeners();
  }

  // Undo last placement (during current turn only)
  void undoLastPlacement() {
    if (_currentTurnPlacements.isEmpty || _gameState == null) return;
    final last = _currentTurnPlacements.removeLast();
    BoardEngine.removeLetter(_gameState!.board, last.key[0], last.key[1]);
    _gameState!.player.hand.add(last.value);
    notifyListeners();
  }

  // Get winner name
  String getWinner() => TurnManager.getWinner(_gameState!);

  // Save game
  Future<void> _saveGame() async {
    if (_gameState != null) {
      _gameState!.lastSaved = DateTime.now();
      await _storageService.saveGameState(_gameState!);
    }
  }

  // Reset game
  Future<void> resetGame() async {
    await _storageService.clearGameState();
    _gameState = null;
    _currentTurnPlacements = [];
    _selectedLetterIndex = -1;
    _selectedForSwap = [];
    _currentBanner = null;
    _hintPositions = [];
    notifyListeners();
  }
}
