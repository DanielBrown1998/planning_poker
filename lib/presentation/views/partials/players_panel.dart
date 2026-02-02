import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/theme.dart';
import '../../../domain/entities/player.dart';
import '../../viewmodels/game_viewmodel.dart';
import '../../widgets/player_card_widget.dart';

class PlayersPanel extends StatelessWidget {
  final bool isHorizontal;

  const PlayersPanel({super.key, this.isHorizontal = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (isHorizontal) {
      return _buildHorizontalPanel(context, theme, colorScheme);
    }

    return _buildVerticalPanel(context, theme, colorScheme);
  }

  Widget _buildHorizontalPanel(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        border: Border(
          bottom: BorderSide(color: colorScheme.outlineVariant, width: 1),
        ),
      ),
      constraints: BoxConstraints(minHeight: 80, minWidth: 240),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: AppSpacing.lg,
              top: AppSpacing.md,
              bottom: AppSpacing.sm,
            ),
            child: Text(
              'Jogadores',
              style: theme.textTheme.labelMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(child: _PlayersList(isHorizontal: true)),
        ],
      ),
    );
  }

  Widget _buildVerticalPanel(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Container(
      width: 240,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        border: Border(
          right: BorderSide(color: colorScheme.outlineVariant, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: AppRadius.borderRadiusSm,
                  ),
                  child: Icon(
                    Icons.people_outline_rounded,
                    size: 18,
                    color: colorScheme.primary,
                  ),
                ),
                AppSpacing.hMd,
                Text(
                  'Jogadores',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: colorScheme.outlineVariant),
          Expanded(child: _PlayersList(isHorizontal: false)),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
// EXTRACTED WIDGETS FOR PERFORMANCE
// ══════════════════════════════════════════════════════════════════════════

class _PlayersList extends StatelessWidget {
  final bool isHorizontal;

  const _PlayersList({required this.isHorizontal});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<GameViewModel>();
    final players = viewModel.players;

    if (isHorizontal) {
      return ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        itemCount: players.length,
        itemBuilder: (context, index) {
          return _PlayerListItem(player: players[index], isHorizontal: true);
        },
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: players.length,
      itemBuilder: (context, index) {
        return _PlayerListItem(player: players[index], isHorizontal: false);
      },
    );
  }
}

class _PlayerListItem extends StatelessWidget {
  final Player player;
  final bool isHorizontal;

  const _PlayerListItem({required this.player, required this.isHorizontal});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<GameViewModel>();
    final hasVoted = viewModel.playedCards.containsKey(player.id);
    final playedCard = viewModel.playedCards[player.id];
    final isCurrentPlayer = player.id == viewModel.currentPlayer?.id;

    if (isHorizontal) {
      return Padding(
        padding: const EdgeInsets.only(right: AppSpacing.sm),
        child: PlayerCardWidget(
          player: player,
          hasVoted: hasVoted,
          cardValue: viewModel.isRevealed ? playedCard?.cardValue : null,
          isCurrentPlayer: isCurrentPlayer,
          isCompact: true,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: PlayerCardWidget(
        player: player,
        hasVoted: hasVoted,
        cardValue: viewModel.isRevealed ? playedCard?.cardValue : null,
        isCurrentPlayer: isCurrentPlayer,
        isCompact: false,
      ),
    );
  }
}
