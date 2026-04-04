import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/game_provider.dart';
import '../../data/models/word_model.dart';
import '../../core/theme/app_theme.dart';

class WordPopup extends StatelessWidget {
  const WordPopup({Key? key}) : super(key: key);

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<GameProvider>(),
        child: const WordPopup(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, _) {
        final words = gameProvider.words;
        final board = gameProvider.board;

        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: Row(
                  children: [
                    const Icon(Icons.list_alt, color: AppTheme.primaryColor),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Words',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: words.length,
                  itemBuilder: (context, index) {
                    final word = words[index];
                    return _WordCard(word: word, board: board);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _WordCard extends StatelessWidget {
  final WordModel word;
  final List<dynamic> board;

  const _WordCard({required this.word, required this.board});

  @override
  Widget build(BuildContext context) {
    final dirLabel =
        word.direction == WordDirection.across ? 'Across' : 'Down';
    final pattern = board.isNotEmpty ? word.getPattern(board.cast()) : '';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${word.id} $dirLabel',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    word.clue,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    pattern,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
            if (word.isCompleted)
              const Icon(Icons.check_circle, color: AppTheme.accentColor),
          ],
        ),
      ),
    );
  }
}
