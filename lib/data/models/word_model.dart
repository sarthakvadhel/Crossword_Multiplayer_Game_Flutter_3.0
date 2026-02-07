import 'tile_model.dart';

enum WordDirection { across, down }

class WordModel {
  final int id;
  final String clue;
  final String answer;
  final List<List<int>> positions;
  final WordDirection direction;
  bool isCompleted;
  final String? imageAsset;

  WordModel({
    required this.id,
    required this.clue,
    required this.answer,
    required this.positions,
    required this.direction,
    this.isCompleted = false,
    this.imageAsset,
  });

  int getFilledCount(List<List<TileModel>> board) {
    int count = 0;
    for (final pos in positions) {
      final tile = board[pos[0]][pos[1]];
      if (tile.letter != null && tile.letter!.isNotEmpty) {
        count++;
      }
    }
    return count;
  }

  String getPattern(List<List<TileModel>> board) {
    final buffer = StringBuffer();
    for (int i = 0; i < positions.length; i++) {
      if (i > 0) buffer.write(' ');
      final tile = board[positions[i][0]][positions[i][1]];
      buffer.write(
        (tile.letter != null && tile.letter!.isNotEmpty) ? tile.letter : '_',
      );
    }
    return buffer.toString();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clue': clue,
      'answer': answer,
      'positions': positions.map((p) => p.toList()).toList(),
      'direction': direction.name,
      'isCompleted': isCompleted,
      'imageAsset': imageAsset,
    };
  }

  factory WordModel.fromJson(Map<String, dynamic> json) {
    return WordModel(
      id: json['id'] as int,
      clue: json['clue'] as String,
      answer: json['answer'] as String,
      positions: (json['positions'] as List)
          .map((p) => (p as List).map((e) => e as int).toList())
          .toList(),
      direction: WordDirection.values.byName(json['direction'] as String),
      isCompleted: json['isCompleted'] as bool? ?? false,
      imageAsset: json['imageAsset'] as String?,
    );
  }
}
