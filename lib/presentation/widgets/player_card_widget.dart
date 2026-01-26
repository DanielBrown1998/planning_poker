import 'package:flutter/material.dart';

import '../../core/theme/theme.dart';
import '../../domain/entities/player.dart';

/// A widget that displays a player's status in the session
///
/// Optimized with:
/// - Leaf widget pattern (no unnecessary rebuilds)
/// - Const constructors where possible
/// - RepaintBoundary for complex decorations
class PlayerCardWidget extends StatelessWidget {
  final Player player;
  final bool hasVoted;
  final String? cardValue;
  final bool isCurrentPlayer;
  final bool isCompact;

  const PlayerCardWidget({
    super.key,
    required this.player,
    required this.hasVoted,
    this.cardValue,
    this.isCurrentPlayer = false,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isCompact) {
      return _CompactPlayerCard(
        player: player,
        hasVoted: hasVoted,
        cardValue: cardValue,
        isCurrentPlayer: isCurrentPlayer,
      );
    }

    return _FullPlayerCard(
      player: player,
      hasVoted: hasVoted,
      cardValue: cardValue,
      isCurrentPlayer: isCurrentPlayer,
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
// COMPACT CARD (FOR MOBILE HORIZONTAL LIST)
// ══════════════════════════════════════════════════════════════════════════

class _CompactPlayerCard extends StatelessWidget {
  final Player player;
  final bool hasVoted;
  final String? cardValue;
  final bool isCurrentPlayer;

  const _CompactPlayerCard({
    required this.player,
    required this.hasVoted,
    this.cardValue,
    required this.isCurrentPlayer,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SizedBox(
      width: 70,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Avatar with status
          Stack(
            children: [
              _PlayerAvatar(
                name: player.name,
                hasVoted: hasVoted,
                isCurrentPlayer: isCurrentPlayer,
                size: 44,
              ),
              if (player.isHost)
                Positioned(right: 0, bottom: 0, child: _HostBadge(size: 16)),
              if (hasVoted && cardValue == null)
                Positioned(right: 0, top: 0, child: _VotedIndicator(size: 14)),
            ],
          ),
          AppSpacing.vXs,
          // Name
          Text(
            player.name,
            style: theme.textTheme.labelSmall?.copyWith(
              color: isCurrentPlayer
                  ? colorScheme.primary
                  : colorScheme.onSurface.withValues(alpha: 0.8),
              fontWeight: isCurrentPlayer ? FontWeight.w600 : FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            textAlign: TextAlign.center,
          ),
          // Card value or status
          if (cardValue != null)
            Container(
              margin: const EdgeInsets.only(top: 2),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: AppRadius.borderRadiusSm,
              ),
              child: Text(
                cardValue!,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
// FULL CARD (FOR DESKTOP SIDEBAR)
// ══════════════════════════════════════════════════════════════════════════

class _FullPlayerCard extends StatelessWidget {
  final Player player;
  final bool hasVoted;
  final String? cardValue;
  final bool isCurrentPlayer;

  const _FullPlayerCard({
    required this.player,
    required this.hasVoted,
    this.cardValue,
    required this.isCurrentPlayer,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnimatedContainer(
      duration: AppDurations.fast,
      curve: AppCurves.defaultCurve,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isCurrentPlayer
            ? colorScheme.primaryContainer.withValues(alpha: 0.3)
            : colorScheme.surface,
        borderRadius: AppRadius.borderRadiusMd,
        border: Border.all(
          color: isCurrentPlayer
              ? colorScheme.primary.withValues(alpha: 0.3)
              : colorScheme.outlineVariant,
          width: isCurrentPlayer ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          // Avatar
          _PlayerAvatar(
            name: player.name,
            hasVoted: hasVoted,
            isCurrentPlayer: isCurrentPlayer,
            size: 40,
          ),
          AppSpacing.hMd,
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        player.name,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: isCurrentPlayer
                              ? FontWeight.w600
                              : FontWeight.w500,
                          color: colorScheme.onSurface,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (player.isHost) ...[
                      AppSpacing.hXs,
                      _HostBadge(size: 18),
                    ],
                  ],
                ),
                AppSpacing.vXxs,
                _StatusText(hasVoted: hasVoted, cardValue: cardValue),
              ],
            ),
          ),
          // Card value or status icon
          _TrailingWidget(hasVoted: hasVoted, cardValue: cardValue),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
// SHARED COMPONENTS
// ══════════════════════════════════════════════════════════════════════════

class _PlayerAvatar extends StatelessWidget {
  final String name;
  final bool hasVoted;
  final bool isCurrentPlayer;
  final double size;

  const _PlayerAvatar({
    required this.name,
    required this.hasVoted,
    required this.isCurrentPlayer,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: hasVoted
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.success,
                  AppTheme.success.withValues(alpha: 0.8),
                ],
              )
            : isCurrentPlayer
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colorScheme.primary,
                  colorScheme.primary.withValues(alpha: 0.8),
                ],
              )
            : null,
        color: hasVoted || isCurrentPlayer
            ? null
            : colorScheme.surfaceContainerHigh,
        shape: BoxShape.circle,
        border: Border.all(
          color: hasVoted
              ? AppTheme.success.withValues(alpha: 0.3)
              : isCurrentPlayer
              ? colorScheme.primary.withValues(alpha: 0.3)
              : colorScheme.outlineVariant,
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          initial,
          style: TextStyle(
            fontSize: size * 0.4,
            fontWeight: FontWeight.w600,
            color: hasVoted || isCurrentPlayer
                ? Colors.white
                : colorScheme.onSurface.withValues(alpha: 0.8),
          ),
        ),
      ),
    );
  }
}

class _HostBadge extends StatelessWidget {
  final double size;

  const _HostBadge({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD700).withValues(alpha: 0.3),
            blurRadius: 4,
          ),
        ],
      ),
      child: Icon(Icons.star_rounded, size: size * 0.7, color: Colors.white),
    );
  }
}

class _VotedIndicator extends StatelessWidget {
  final double size;

  const _VotedIndicator({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppTheme.success,
        shape: BoxShape.circle,
        border: Border.all(
          color: Theme.of(context).colorScheme.surface,
          width: 2,
        ),
      ),
      child: Icon(Icons.check, size: size * 0.65, color: Colors.white),
    );
  }
}

class _StatusText extends StatelessWidget {
  final bool hasVoted;
  final String? cardValue;

  const _StatusText({required this.hasVoted, this.cardValue});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    String text;
    Color color;

    if (cardValue != null) {
      text = 'Votou: $cardValue';
      color = AppTheme.success;
    } else if (hasVoted) {
      text = 'Votou';
      color = AppTheme.success;
    } else {
      text = 'Aguardando...';
      color = colorScheme.onSurface.withValues(alpha: 0.5);
    }

    return Text(
      text,
      style: theme.textTheme.labelSmall?.copyWith(
        color: color,
        fontWeight: hasVoted ? FontWeight.w500 : FontWeight.w400,
      ),
    );
  }
}

class _TrailingWidget extends StatelessWidget {
  final bool hasVoted;
  final String? cardValue;

  const _TrailingWidget({required this.hasVoted, this.cardValue});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (cardValue != null) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.primary,
              colorScheme.primary.withValues(alpha: 0.8),
            ],
          ),
          borderRadius: AppRadius.borderRadiusSm,
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withValues(alpha: 0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          cardValue!,
          style: theme.textTheme.titleSmall?.copyWith(
            color: colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    if (hasVoted) {
      return Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: AppTheme.success.withValues(alpha: 0.15),
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.check_rounded, size: 18, color: AppTheme.success),
      );
    }

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.hourglass_empty_rounded,
        size: 18,
        color: colorScheme.onSurface.withValues(alpha: 0.4),
      ),
    );
  }
}
