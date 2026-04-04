import 'tile_model.dart';
import 'player_model.dart';

enum GamePhase { notStarted, playerTurn, aiTurn, gameOver }

class GameStateModel {
  List<List<TileModel>> board;
  PlayerModel player;
  PlayerModel computer;
  GamePhase phase;
  int currentTurn;
  String? lastBanner;
  List<String> moveHistory;
  bool isPuzzleComplete;
  DateTime? lastSaved;

  GameStateModel({
    required this.board,
    required this.player,
    required this.computer,
    this.phase = GamePhase.notStarted,
    this.currentTurn = 0,
    this.lastBanner,
    List<String>? moveHistory,
    this.isPuzzleComplete = false,
    this.lastSaved,
  }) : moveHistory = moveHistory ?? [];

  Map<String, dynamic> toJson() {
    return {
      'board': board
          .map((row) => row.map((tile) => tile.toJson()).toList())
          .toList(),
      'player': player.toJson(),
      'computer': computer.toJson(),
      'phase': phase.name,
      'currentTurn': currentTurn,
      'lastBanner': lastBanner,
      'moveHistory': moveHistory,
      'isPuzzleComplete': isPuzzleComplete,
      'lastSaved': lastSaved?.toIso8601String(),
    };
  }

  factory GameStateModel.fromJson(Map<String, dynamic> json) {
    return GameStateModel(
      board: (json['board'] as List)
          .map((row) => (row as List)
              .map((tile) => TileModel.fromJson(tile as Map<String, dynamic>))
              .toList())
          .toList(),
      player: PlayerModel.fromJson(json['player'] as Map<String, dynamic>),
      computer: PlayerModel.fromJson(json['computer'] as Map<String, dynamic>),
      phase: GamePhase.values.byName(json['phase'] as String),
      currentTurn: json['currentTurn'] as int? ?? 0,
      lastBanner: json['lastBanner'] as String?,
      moveHistory: (json['moveHistory'] as List?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      isPuzzleComplete: json['isPuzzleComplete'] as bool? ?? false,
      lastSaved: json['lastSaved'] != null
          ? DateTime.parse(json['lastSaved'] as String)
          : null,
    );
  }
}
