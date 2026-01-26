import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/poker_cards.dart';
import '../../../core/theme/theme.dart';
import '../../viewmodels/game_viewmodel.dart';
import '../../widgets/poker_card_widget.dart';

class TableArea extends StatelessWidget {
  const TableArea({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [colorScheme.surface, colorScheme.surfaceContainerLow],
        ),
      ),
      child: _TableContent(),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
// EXTRACTED WIDGETS FOR PERFORMANCE
// ══════════════════════════════════════════════════════════════════════════

class _TableContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<GameViewModel>();
    final playedCards = viewModel.playedCards;

    if (playedCards.isEmpty) {
      return const _EmptyState();
    }

    return _CardsGrid(isRevealed: viewModel.isRevealed);
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated icon container
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.style_outlined,
                    size: 36,
                    color: colorScheme.primary.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ),
            AppSpacing.vXxl,
            Text(
              'Aguardando votos...',
              style: theme.textTheme.titleLarge?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.8),
                fontWeight: FontWeight.w600,
              ),
            ),
            AppSpacing.vSm,
            Text(
              'Selecione uma carta abaixo para votar',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.5),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _CardsGrid extends StatelessWidget {
  final bool isRevealed;

  const _CardsGrid({required this.isRevealed});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<GameViewModel>();
    final playedCards = viewModel.playedCards;
    final isMobile = Responsive.isMobile(context);
    final cardSize = isMobile ? const Size(70, 100) : const Size(90, 130);

    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(Responsive.horizontalPadding(context)),
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: Responsive.gap(context),
          runSpacing: Responsive.gap(context),
          children: playedCards.entries.map((entry) {
            final card = entry.value;
            return _PlayedCardItem(
              playerName: card.playerName,
              cardValue: isRevealed
                  ? card.cardValue ?? PokerCards.hiddenCard
                  : PokerCards.hiddenCard,
              isRevealed: isRevealed,
              cardSize: cardSize,
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _PlayedCardItem extends StatelessWidget {
  final String playerName;
  final String cardValue;
  final bool isRevealed;
  final Size cardSize;

  const _PlayedCardItem({
    required this.playerName,
    required this.cardValue,
    required this.isRevealed,
    required this.cardSize,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        PokerCardWidget(
          value: cardValue,
          isSelected: false,
          isRevealed: isRevealed,
          size: cardSize,
        ),
        AppSpacing.vSm,
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHigh,
            borderRadius: AppRadius.borderRadiusSm,
          ),
          child: Text(
            playerName,
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.8),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
