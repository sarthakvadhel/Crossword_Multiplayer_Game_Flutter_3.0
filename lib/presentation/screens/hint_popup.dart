import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class HintPopup extends StatelessWidget {
  const HintPopup({Key? key}) : super(key: key);

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (_) => const HintPopup(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: const [
          Icon(Icons.lightbulb_outline, color: AppTheme.bannerColor),
          SizedBox(width: 8),
          Text('Hint'),
        ],
      ),
      content: const Text(
        'Highlighted cells show where you can place letters. '
        'Select a letter from your hand, then tap a highlighted cell to place it.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('OK'),
        ),
      ],
    );
  }
}
