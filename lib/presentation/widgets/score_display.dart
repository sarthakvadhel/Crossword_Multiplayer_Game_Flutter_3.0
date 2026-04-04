import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/game_provider.dart';
import '../../core/theme/app_theme.dart';

class ScoreDisplay extends StatelessWidget {
  const ScoreDisplay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _scoreColumn(
                  'You', gameProvider.player.score, AppTheme.primaryColor),
              Container(
                  width: 1, height: 40, color: Colors.grey.shade300),
              _scoreColumn(
                  'CPU', gameProvider.computer.score, AppTheme.scoreColor),
            ],
          ),
        );
      },
    );
  }

  Widget _scoreColumn(String label, int score, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500)),
        SizedBox(height: 2),
        Text('$score',
            style: TextStyle(
                fontSize: 24, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }
}
