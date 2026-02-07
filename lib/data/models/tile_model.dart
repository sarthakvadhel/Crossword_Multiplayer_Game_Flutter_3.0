const _sentinel = Object();

class TileModel {
  String? letter;
  final int row;
  final int col;
  bool isLocked;
  bool isHighlighted;
  bool isClueCell;
  int? clueNumber;
  bool isBlocked;

  TileModel({
    this.letter,
    required this.row,
    required this.col,
    this.isLocked = false,
    this.isHighlighted = false,
    this.isClueCell = false,
    this.clueNumber,
    this.isBlocked = false,
  });

  TileModel copyWith({
    Object? letter = _sentinel,
    int? row,
    int? col,
    bool? isLocked,
    bool? isHighlighted,
    bool? isClueCell,
    Object? clueNumber = _sentinel,
    bool? isBlocked,
  }) {
    return TileModel(
      letter: letter == _sentinel ? this.letter : letter as String?,
      row: row ?? this.row,
      col: col ?? this.col,
      isLocked: isLocked ?? this.isLocked,
      isHighlighted: isHighlighted ?? this.isHighlighted,
      isClueCell: isClueCell ?? this.isClueCell,
      clueNumber:
          clueNumber == _sentinel ? this.clueNumber : clueNumber as int?,
      isBlocked: isBlocked ?? this.isBlocked,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'letter': letter,
      'row': row,
      'col': col,
      'isLocked': isLocked,
      'isHighlighted': isHighlighted,
      'isClueCell': isClueCell,
      'clueNumber': clueNumber,
      'isBlocked': isBlocked,
    };
  }

  factory TileModel.fromJson(Map<String, dynamic> json) {
    return TileModel(
      letter: json['letter'] as String?,
      row: json['row'] as int,
      col: json['col'] as int,
      isLocked: json['isLocked'] as bool? ?? false,
      isHighlighted: json['isHighlighted'] as bool? ?? false,
      isClueCell: json['isClueCell'] as bool? ?? false,
      clueNumber: json['clueNumber'] as int?,
      isBlocked: json['isBlocked'] as bool? ?? false,
    );
  }
}
