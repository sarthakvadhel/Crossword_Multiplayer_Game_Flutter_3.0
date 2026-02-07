import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/game_provider.dart';
import 'letter_tile.dart';

class HandLetters extends StatelessWidget {
  final bool swapMode;
  const HandLetters({Key? key, this.swapMode = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        final hand = gameProvider.player.hand;
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(hand.length, (index) {
            return LetterTile(
              letter: hand[index],
              isSelected:
                  !swapMode && gameProvider.selectedLetterIndex == index,
              isSwapSelected:
                  swapMode && gameProvider.selectedForSwap.contains(index),
              onTap: () {
                if (swapMode) {
                  gameProvider.toggleSwapSelection(index);
                } else {
                  gameProvider.selectLetter(index);
                }
              },
            );
          }),
        );
      },
    );
  }
}
