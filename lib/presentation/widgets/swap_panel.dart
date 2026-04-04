import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/game_provider.dart';
import '../../core/theme/app_theme.dart';
import 'hand_letters.dart';

class SwapPanel extends StatelessWidget {
  final VoidCallback onClose;
  const SwapPanel({Key? key, required this.onClose}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
              color: Colors.black26, blurRadius: 10, offset: Offset(0, -2))
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Select letters to swap',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          SizedBox(height: 12),
          HandLetters(swapMode: true),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(onPressed: onClose, child: Text('Cancel')),
              Consumer<GameProvider>(
                builder: (context, gp, _) => ElevatedButton(
                  onPressed: gp.selectedForSwap.isEmpty
                      ? null
                      : () {
                          gp.swapLetters();
                          onClose();
                        },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentColor),
                  child: Text('Swap & Pass'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
