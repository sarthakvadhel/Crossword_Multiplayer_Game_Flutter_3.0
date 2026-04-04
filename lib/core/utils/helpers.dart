import 'dart:math';

class Helpers {
  static final Random _random = Random();

  // Generate random letter with vowel/consonant balance
  static String randomLetter({double vowelChance = 0.4}) {
    const vowels = ['A','E','I','O','U'];
    const consonants = ['B','C','D','F','G','H','J','K','L','M','N','P','R','S','T','W','Y'];
    if (_random.nextDouble() < vowelChance) {
      return vowels[_random.nextInt(vowels.length)];
    }
    return consonants[_random.nextInt(consonants.length)];
  }

  // Generate a hand of n letters
  static List<String> generateHand(int count) {
    return List.generate(count, (_) => randomLetter());
  }

  // Random int between min and max inclusive
  static int randomInt(int min, int max) {
    return min + _random.nextInt(max - min + 1);
  }
}
