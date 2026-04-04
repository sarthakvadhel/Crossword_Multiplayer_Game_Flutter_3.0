import 'package:flutter/foundation.dart';
import '../data/repositories/ai_repo.dart';

class AiProvider extends ChangeNotifier {
  final AiRepo _aiRepo = AiRepo();

  AiDifficulty get difficulty => _aiRepo.currentDifficulty;

  void setDifficulty(AiDifficulty difficulty) {
    _aiRepo.setDifficulty(difficulty);
    notifyListeners();
  }
}
