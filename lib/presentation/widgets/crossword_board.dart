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
        if (board.isEmpty) return SizedBox.shrink();

        return AspectRatio(
          aspectRatio: board[0].length / board.length,
          child: GridView.builder(
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: board[0].length,
            ),
            itemCount: board.length * board[0].length,
            itemBuilder: (context, index) {
              final row = index ~/ board[0].length;
              final col = index % board[0].length;
              final tile = board[row][col];
              return _buildTile(context, tile, gameProvider);
            },
          ),
        );
      },
    );
  }

  Widget _buildTile(BuildContext context, TileModel tile, GameProvider provider) {
    if (tile.isBlocked) {
      return Container(
        margin: EdgeInsets.all(0.5),
        decoration: BoxDecoration(
          color: AppTheme.blockedColor,
          borderRadius: BorderRadius.circular(2),
        ),
      );
    }

    Color bgColor = Colors.white;
    if (tile.isLocked && tile.letter != null) bgColor = AppTheme.tileColor;
    if (tile.isHighlighted) bgColor = AppTheme.highlightColor;
    if (tile.letter != null && !tile.isLocked) bgColor = Color(0xFFFFE082);

    return GestureDetector(
      onTap: () => provider.placeLetter(tile.row, tile.col),
      child: Container(
        margin: EdgeInsets.all(0.5),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(3),
          border: Border.all(color: Colors.grey.shade400, width: 0.5),
          boxShadow: tile.letter != null
              ? [
                  BoxShadow(
                      color: Colors.black12,
                      blurRadius: 1,
                      offset: Offset(0, 1)),
                ]
              : null,
        ),
        child: Center(
          child: tile.letter != null
              ? Text(
                  tile.letter!,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.tileTextColor,
                  ),
                )
              : (tile.clueNumber != null
                  ? Text(
                      '${tile.clueNumber}',
                      style: TextStyle(fontSize: 8, color: Colors.grey),
                    )
                  : null),
        ),
      ),
    );
  }
}
