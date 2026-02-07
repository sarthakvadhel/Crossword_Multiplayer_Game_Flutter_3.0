import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class LetterTile extends StatelessWidget {
  final String letter;
  final bool isSelected;
  final bool isSwapSelected;
  final VoidCallback onTap;

  const LetterTile({
    Key? key,
    required this.letter,
    required this.isSelected,
    required this.onTap,
    this.isSwapSelected = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        width: 50,
        height: 55,
        margin: EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: isSwapSelected
              ? Colors.red.shade200
              : isSelected
                  ? AppTheme.highlightColor
                  : AppTheme.tileColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.brown.shade300,
            width: isSelected ? 2.5 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppTheme.primaryColor.withOpacity(0.3)
                  : Colors.black26,
              blurRadius: isSelected ? 6 : 3,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            letter,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppTheme.tileTextColor,
            ),
          ),
        ),
      ),
    );
  }
}
