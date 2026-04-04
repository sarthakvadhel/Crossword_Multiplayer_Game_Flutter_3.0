/// A single game result record.
class ScoreRecord {
  final int puzzleId;
  final int playerScore;
  final int computerScore;
  final DateTime date;
  final String? longestWord;

  ScoreRecord({
    required this.puzzleId,
    required this.playerScore,
    required this.computerScore,
    required this.date,
    this.longestWord,
  });

  Map<String, dynamic> toJson() => {
        'puzzleId': puzzleId,
        'playerScore': playerScore,
        'computerScore': computerScore,
        'date': date.toIso8601String(),
        'longestWord': longestWord,
      };

  factory ScoreRecord.fromJson(Map<String, dynamic> json) => ScoreRecord(
        puzzleId: json['puzzleId'] as int,
        playerScore: json['playerScore'] as int,
        computerScore: json['computerScore'] as int,
        date: DateTime.parse(json['date'] as String),
        longestWord: json['longestWord'] as String?,
      );
}

/// Repository for tracking high scores and game statistics.
class ScoreRepo {
  final List<ScoreRecord> _records = [];

  void addRecord(ScoreRecord record) => _records.add(record);

  List<ScoreRecord> get records => List.unmodifiable(_records);

  int get totalGamesPlayed => _records.length;

  int get totalWins =>
      _records.where((r) => r.playerScore > r.computerScore).length;

  int get bestScore =>
      _records.fold(0, (max, r) => r.playerScore > max ? r.playerScore : max);

  void loadFromJson(List<dynamic> jsonList) {
    _records.clear();
    _records.addAll(
      jsonList.map((e) => ScoreRecord.fromJson(e as Map<String, dynamic>)),
    );
  }

  List<Map<String, dynamic>> toJsonList() =>
      _records.map((r) => r.toJson()).toList();
}
