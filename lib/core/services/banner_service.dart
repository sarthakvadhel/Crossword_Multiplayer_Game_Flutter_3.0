class BannerService {
  // Determine which banner to show based on game event
  static String? getBanner({
    required bool wordCompleted,
    required bool emptyHand,
    required bool longestWord,
    required int streak,
    required int score,
  }) {
    if (longestWord) return 'Yey!! You formed the longest word!';
    if (emptyHand) return 'Empty Hand Master!';
    if (streak >= 5) return '5x Strike!';
    if (streak >= 3) return '3x Strike!';
    if (wordCompleted) return 'Excellent!';
    if (score >= 5) return 'Amazing!';
    if (score >= 1) return 'Cool Move!';
    return null;
  }
}
