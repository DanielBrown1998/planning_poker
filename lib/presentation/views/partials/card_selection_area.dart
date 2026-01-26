import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/theme.dart';
import '../../viewmodels/game_viewmodel.dart';
import '../../widgets/poker_card_widget.dart';

class CardSelectionArea extends StatelessWidget {
  const CardSelectionArea({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(color: colorScheme.outlineVariant, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: Responsive.horizontalPadding(context),
            vertical: AppSpacing.md,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [_SectionHeader(), AppSpacing.vMd, _CardsCarousel()],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
// EXTRACTED WIDGETS FOR PERFORMANCE
// ══════════════════════════════════════════════════════════════════════════

class _SectionHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final viewModel = context.watch<GameViewModel>();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: colorScheme.secondaryContainer.withValues(alpha: 0.5),
            borderRadius: AppRadius.borderRadiusSm,
          ),
          child: Icon(
            Icons.style_rounded,
            size: 16,
            color: colorScheme.secondary,
          ),
        ),
        AppSpacing.hSm,
        Text(
          'Suas Cartas',
          style: theme.textTheme.labelLarge?.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.8),
            fontWeight: FontWeight.w600,
          ),
        ),
        if (viewModel.selectedCard != null ||
            viewModel.myPlayedCard != null) ...[
          AppSpacing.hMd,
          _SelectedIndicator(
            cardValue: viewModel.myPlayedCard ?? viewModel.selectedCard,
          ),
        ],
      ],
    );
  }
}

class _SelectedIndicator extends StatelessWidget {
  final String? cardValue;

  const _SelectedIndicator({this.cardValue});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (cardValue == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
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
    );
  }
}

class _CardsCarousel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<GameViewModel>();
    final isMobile = Responsive.isMobile(context);
    final cardSize = isMobile ? const Size(55, 80) : const Size(65, 95);

    return SizedBox(
      height: cardSize.height + AppSpacing.lg,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
        itemCount: viewModel.availableCards.length,
        itemBuilder: (context, index) {
          final card = viewModel.availableCards[index];
          final isSelected = viewModel.selectedCard == card;
          final isMyPlayedCard = viewModel.myPlayedCard == card;

          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xs,
              vertical: AppSpacing.xs,
            ),
            child: PokerCardWidget(
              value: card,
              isSelected: isSelected || isMyPlayedCard,
              onTap: viewModel.isRevealed
                  ? null
                  : () => viewModel.selectCard(card),
              size: cardSize,
              isSmall: true,
            ),
          );
        },
      ),
    );
  }
}
