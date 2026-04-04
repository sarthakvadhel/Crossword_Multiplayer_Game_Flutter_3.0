import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/game_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/tile_model.dart';

class CrosswordBoard extends StatelessWidget {
  const CrosswordBoard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        final board = gameProvider.board;
        if (board.isEmpty) return const SizedBox.shrink();

        return LayoutBuilder(
          builder: (context, constraints) {
            final cols = board[0].length;
            final rows = board.length;

            final maxH = constraints.maxHeight.isFinite
                ? constraints.maxHeight
                : MediaQuery.of(context).size.height * 0.55;

            final cellSize = min(
              constraints.maxWidth / cols,
              maxH / rows,
            );

            final boardW = cellSize * cols;
            final boardH = cellSize * rows;

            return Center(
              child: SizedBox(
                width: boardW,
                height: boardH,
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: cols,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: rows * cols,
                  itemBuilder: (context, index) {
                    final row = index ~/ cols;
                    final col = index % cols;
                    final tile = board[row][col];
                    return _buildTile(context, tile, gameProvider, cellSize);
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTile(
    BuildContext context,
    TileModel tile,
    GameProvider provider,
    double cellSize,
  ) {
    if (tile.isBlocked) {
      return Container(
        margin: const EdgeInsets.all(0.5),
        color: AppTheme.blockedColor,
      );
    }

    Color bgColor = Colors.white;
    if (tile.isLocked && tile.letter != null) bgColor = AppTheme.tileColor;
    if (!tile.isLocked && tile.letter != null) bgColor = const Color(0xFFFFE082);
    // Only highlight empty cells: filled cells already have clear visual
    // feedback from their letter colour, so adding highlight would be confusing.
    if (tile.isHighlighted && tile.letter == null) bgColor = AppTheme.highlightColor;

    final numSize = (cellSize * 0.28).clamp(6.0, 11.0);
    final letterSize = (cellSize * 0.54).clamp(10.0, 20.0);

    return GestureDetector(
      onTap: () => provider.placeLetter(tile.row, tile.col),
      child: Container(
        margin: const EdgeInsets.all(0.5),
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(color: Colors.grey.shade400, width: 0.5),
        ),
        child: Stack(
          children: [
            // Clue number in top-left corner
            if (tile.clueNumber != null)
              Positioned(
                top: 1,
                left: 2,
                child: Text(
                  '${tile.clueNumber}',
                  style: TextStyle(
                    fontSize: numSize,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.bold,
                    height: 1,
                  ),
                ),
              ),
            // Letter in centre
            if (tile.letter != null)
              Center(
                child: Text(
                  tile.letter!,
                  style: TextStyle(
                    fontSize: letterSize,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.tileTextColor,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
