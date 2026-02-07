import '../data/models/game_state_model.dart';

class TurnManager {
  /// Switch to next player's turn.
  static GamePhase nextTurn(GamePhase currentPhase) {
    if (currentPhase == GamePhase.playerTurn) return GamePhase.aiTurn;
    if (currentPhase == GamePhase.aiTurn) return GamePhase.playerTurn;
    return currentPhase;
  }

  /// Check if game should end.
  static bool shouldEndGame(GameStateModel state) {
    return state.isPuzzleComplete;
  }

  /// Get winner name or 'Tie'.
  static String getWinner(GameStateModel state) {
    if (state.player.score > state.computer.score) return state.player.name;
    if (state.computer.score > state.player.score) return state.computer.name;
    return 'Tie';
  }
}
