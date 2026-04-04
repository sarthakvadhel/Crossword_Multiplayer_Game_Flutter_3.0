class GameConstants {
  static const int handSize = 5;
  static const int correctLetterPoints = 1;
  static const int emptyHandBonus = 5;
  static const int longestWordBonus = 6;
  static const double vowelRatio = 0.4;
  static const int aiMinDelay = 1000; // ms
  static const int aiMaxDelay = 2000; // ms
  static const List<String> vowels = ['A', 'E', 'I', 'O', 'U'];
  static const List<String> consonants = ['B','C','D','F','G','H','J','K','L','M','N','P','Q','R','S','T','V','W','X','Y','Z'];
  static const List<String> bannerMessages = [
    'Yey!! You formed the longest word!',
    'Amazing!',
    'Excellent!',
    'Cool Move!',
    'Empty Hand Master!',
    '3x Strike!',
    '5x Strike!',
  ];
}
