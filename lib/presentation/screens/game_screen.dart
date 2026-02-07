import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/game_provider.dart';
import '../../data/models/game_state_model.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/crossword_board.dart';
import '../widgets/hand_letters.dart';
import '../widgets/score_display.dart';
import '../widgets/swap_panel.dart';
import '../widgets/turn_indicator.dart';
import 'banner_overlay.dart';
import 'hint_popup.dart';
import 'word_popup.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  bool _showSwapPanel = false;
  bool _gameOverDialogShown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkGameOver();
    });
  }

  void _checkGameOver() {
    if (_gameOverDialogShown) return;
    final gp = context.read<GameProvider>();
    if (gp.phase == GamePhase.gameOver) {
      _gameOverDialogShown = true;
      _showGameOverDialog();
    }
  }

  void _showGameOverDialog() {
    final gp = context.read<GameProvider>();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.emoji_events, color: AppTheme.bannerColor, size: 28),
            SizedBox(width: 8),
            Text('Game Over'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${gp.getWinner()} wins!',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _scoreColumn('You', gp.player.score, AppTheme.primaryColor),
                _scoreColumn('CPU', gp.computer.score, AppTheme.scoreColor),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // dismiss dialog
              Navigator.pop(context); // back to home
            },
            child: const Text('Home'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _gameOverDialogShown = false;
              gp.startNewGame();
            },
            child: const Text('New Game'),
          ),
        ],
      ),
    );
  }

  Widget _scoreColumn(String label, int score, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
        const SizedBox(height: 4),
        Text('$score',
            style: TextStyle(
                fontSize: 28, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Puzzle 1'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<GameProvider>(
        builder: (context, gameProvider, _) {
          // Listen for game-over transition
          if (gameProvider.phase == GamePhase.gameOver &&
              !_gameOverDialogShown) {
            _gameOverDialogShown = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _showGameOverDialog();
            });
          }

          return Stack(
            children: [
              Column(
                children: [
                  const SizedBox(height: 8),
                  // Score display
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: ScoreDisplay(),
                  ),
                  const SizedBox(height: 8),
                  // Turn indicator
                  const Center(child: TurnIndicator()),
                  const SizedBox(height: 8),
                  // Crossword board
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: SingleChildScrollView(
                        child: const CrosswordBoard(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Hand letters
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: HandLetters(),
                  ),
                  const SizedBox(height: 8),
                  // Action buttons
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _actionButton(
                          icon: Icons.lightbulb_outline,
                          label: 'Hint',
                          onTap: () {
                            gameProvider.showHint();
                            HintPopup.show(context);
                          },
                        ),
                        _actionButton(
                          icon: Icons.check_circle_outline,
                          label: 'Confirm',
                          onTap: gameProvider.phase == GamePhase.playerTurn
                              ? () => gameProvider.confirmTurn()
                              : null,
                        ),
                        _actionButton(
                          icon: Icons.undo_rounded,
                          label: 'Undo',
                          onTap: () => gameProvider.undoLastPlacement(),
                        ),
                        _actionButton(
                          icon: Icons.swap_horiz,
                          label: 'Swap',
                          onTap: gameProvider.phase == GamePhase.playerTurn
                              ? () => setState(() => _showSwapPanel = true)
                              : null,
                        ),
                        _actionButton(
                          icon: Icons.list_alt,
                          label: 'Words',
                          onTap: () => WordPopup.show(context),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
              // Banner overlay
              if (gameProvider.currentBanner != null)
                BannerOverlay(
                  message: gameProvider.currentBanner!,
                  onDismiss: () => gameProvider.clearBanner(),
                ),
              // Swap panel bottom sheet
              if (_showSwapPanel)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: SwapPanel(
                    onClose: () => setState(() => _showSwapPanel = false),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    VoidCallback? onTap,
  }) {
    final enabled = onTap != null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 24,
                color: enabled ? AppTheme.primaryColor : Colors.grey),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: enabled ? AppTheme.primaryColor : Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
