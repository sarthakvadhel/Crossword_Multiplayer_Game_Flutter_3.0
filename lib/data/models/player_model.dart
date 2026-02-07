enum PlayerType { human, computer }

class PlayerModel {
  final String name;
  final PlayerType type;
  int score;
  List<String> hand;
  int streak;
  String? longestWord;
  int totalWordsCompleted;
  String? profileImageUrl;

  PlayerModel({
    required this.name,
    required this.type,
    this.score = 0,
    List<String>? hand,
    this.streak = 0,
    this.longestWord,
    this.totalWordsCompleted = 0,
    this.profileImageUrl,
  }) : hand = hand ?? [];

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type.name,
      'score': score,
      'hand': hand,
      'streak': streak,
      'longestWord': longestWord,
      'totalWordsCompleted': totalWordsCompleted,
      'profileImageUrl': profileImageUrl,
    };
  }

  factory PlayerModel.fromJson(Map<String, dynamic> json) {
    return PlayerModel(
      name: json['name'] as String,
      type: PlayerType.values.byName(json['type'] as String),
      score: json['score'] as int? ?? 0,
      hand: (json['hand'] as List?)?.map((e) => e as String).toList() ?? [],
      streak: json['streak'] as int? ?? 0,
      longestWord: json['longestWord'] as String?,
      totalWordsCompleted: json['totalWordsCompleted'] as int? ?? 0,
      profileImageUrl: json['profileImageUrl'] as String?,
    );
  }
}
