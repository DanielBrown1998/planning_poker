import 'package:flutter/material.dart';

import '../../domain/entities/player.dart';

/// A widget that displays a player's status in the session
class PlayerCardWidget extends StatelessWidget {
  final Player player;
  final bool hasVoted;
  final String? cardValue;
  final bool isCurrentPlayer;

  const PlayerCardWidget({
    super.key,
    required this.player,
    required this.hasVoted,
    this.cardValue,
    this.isCurrentPlayer = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: isCurrentPlayer
          ? theme.colorScheme.primaryContainer.withValues(alpha: 0.5)
          : null,
      child: ListTile(
        dense: true,
        leading: CircleAvatar(
          radius: 16,
          backgroundColor: hasVoted
              ? Colors.green.withValues(alpha: 0.2)
              : theme.colorScheme.surfaceContainerHighest,
          child: hasVoted
              ? const Icon(Icons.check, size: 16, color: Colors.green)
              : Text(
                  player.name.isNotEmpty ? player.name[0].toUpperCase() : '?',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                player.name,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: isCurrentPlayer ? FontWeight.bold : null,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (player.isHost)
              Tooltip(
                message: 'Host',
                child: Icon(Icons.star, size: 16, color: Colors.amber[700]),
              ),
          ],
        ),
        trailing: cardValue != null
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  cardValue!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : hasVoted
            ? Icon(Icons.check_circle, size: 20, color: Colors.green[400])
            : Icon(
                Icons.hourglass_empty,
                size: 20,
                color: theme.colorScheme.outline,
              ),
      ),
    );
  }
}
