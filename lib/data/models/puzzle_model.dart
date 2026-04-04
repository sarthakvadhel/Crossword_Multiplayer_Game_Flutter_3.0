import 'word_model.dart';

class PuzzleModel {
  final int id;
  final String name;
  final int rows;
  final int cols;
  final List<WordModel> words;
  final List<List<bool>> blockedCells;

  PuzzleModel({
    required this.id,
    required this.name,
    required this.rows,
    required this.cols,
    required this.words,
    required this.blockedCells,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'rows': rows,
      'cols': cols,
      'words': words.map((w) => w.toJson()).toList(),
      'blockedCells':
          blockedCells.map((row) => row.toList()).toList(),
    };
  }

  factory PuzzleModel.fromJson(Map<String, dynamic> json) {
    return PuzzleModel(
      id: json['id'] as int,
      name: json['name'] as String,
      rows: json['rows'] as int,
      cols: json['cols'] as int,
      words: (json['words'] as List)
          .map((w) => WordModel.fromJson(w as Map<String, dynamic>))
          .toList(),
      blockedCells: (json['blockedCells'] as List)
          .map((row) => (row as List).map((e) => e as bool).toList())
          .toList(),
    );
  }
}
