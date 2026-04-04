import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/game_provider.dart';
import '../../data/models/game_state_model.dart';
import '../../data/models/word_model.dart';
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
        title: const Row(
          children: [
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
        Text(label,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
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
        actions: [
          IconButton(
            icon: const Icon(Icons.list_alt),
            tooltip: 'View clues',
            onPressed: () => WordPopup.show(context),
          ),
        ],
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
                  const SizedBox(height: 6),
                  // Turn indicator
                  const Center(child: TurnIndicator()),
                  const SizedBox(height: 6),
                  // Crossword board – fills remaining space
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: const CrosswordBoard(),
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Horizontal scrollable clue bar
                  _ClueBar(),
                  const SizedBox(height: 6),
                  // Hand letters
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: HandLetters(),
                  ),
                  const SizedBox(height: 6),
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
  // Fix the icon to match the "Words" label
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

/// A compact horizontally-scrolling list of incomplete word clues.
class _ClueBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gp, _) {
        final board = gp.board;
        final allWords = gp.words;
        if (board.isEmpty) return const SizedBox.shrink();

        final incomplete = allWords.where((w) => !w.isCompleted).toList();
        if (incomplete.isEmpty) return const SizedBox.shrink();

        return SizedBox(
          height: 54,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: incomplete.length,
            itemBuilder: (context, i) {
              final word = incomplete[i];
              final dir = word.direction == WordDirection.across ? '→' : '↓';
              final pattern = word.getPattern(board);
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: AppTheme.primaryColor.withOpacity(0.3)),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 3),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${word.id}$dir ${word.clue}',
                      style: TextStyle(
                          fontSize: 10, color: Colors.grey.shade700),
                    ),
                    Text(
                      pattern,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 3,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
