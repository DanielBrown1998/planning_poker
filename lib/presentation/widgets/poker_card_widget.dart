import 'package:flutter/material.dart';

import '../../core/constants/poker_cards.dart';

/// A widget that displays a Planning Poker card
class PokerCardWidget extends StatelessWidget {
  final String value;
  final bool isSelected;
  final bool isRevealed;
  final VoidCallback? onTap;
  final Size size;

  const PokerCardWidget({
    super.key,
    required this.value,
    this.isSelected = false,
    this.isRevealed = true,
    this.onTap,
    this.size = const Size(70, 100),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isHidden = value == PokerCards.hiddenCard;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: size.width,
        height: size.height,
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primaryContainer
              : isHidden
              ? theme.colorScheme.surfaceContainerHighest
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline,
            width: isSelected ? 3 : 1,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: theme.colorScheme.primary.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              )
            else
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Center(
          child: isHidden
              ? Icon(
                  Icons.question_mark,
                  size: size.width * 0.5,
                  color: theme.colorScheme.outline,
                )
              : Text(
                  value,
                  style: TextStyle(
                    fontSize: size.width * 0.4,
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? theme.colorScheme.onPrimaryContainer
                        : theme.colorScheme.onSurface,
                  ),
                ),
        ),
      ),
    );
  }
}
