import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/game_provider.dart';
import '../../data/models/game_state_model.dart';
import '../../core/theme/app_theme.dart';

class TurnIndicator extends StatelessWidget {
  const TurnIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        String text;
        Color color;
        IconData icon;

        switch (gameProvider.phase) {
          case GamePhase.playerTurn:
            text = 'Your Turn';
            color = AppTheme.primaryColor;
            icon = Icons.person;
            break;
          case GamePhase.aiTurn:
            text = gameProvider.isAiThinking
                ? 'Computer thinking...'
                : 'Computer\'s Turn';
            color = AppTheme.scoreColor;
            icon = Icons.computer;
            break;
          case GamePhase.gameOver:
            text = 'Game Over!';
            color = AppTheme.bannerColor;
            icon = Icons.emoji_events;
            break;
          default:
            text = 'Ready';
            color = Colors.grey;
            icon = Icons.play_arrow;
        }

        return AnimatedContainer(
          duration: Duration(milliseconds: 300),
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color, width: 1.5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 18),
              SizedBox(width: 6),
              Text(text,
                  style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w600,
                      fontSize: 14)),
              if (gameProvider.isAiThinking) ...[
                SizedBox(width: 8),
                SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(color))),
              ],
            ],
          ),
        );
      },
    );
  }
}
