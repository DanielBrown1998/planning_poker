import 'package:flutter/material.dart';
import 'package:planning_poker/core/constants/poker_cards.dart';
import 'package:planning_poker/presentation/viewmodels/game_viewmodel.dart';
import 'package:planning_poker/presentation/widgets/poker_card_widget.dart';
import 'package:provider/provider.dart';

class TableArea extends StatelessWidget {
  const TableArea({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<GameViewModel>();
    final playedCards = viewModel.playedCards;
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            theme.colorScheme.surfaceContainerLow,
            theme.colorScheme.surfaceContainerLowest,
          ],
        ),
      ),
      child: Center(
        child: playedCards.isEmpty
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.style, size: 64, color: theme.colorScheme.outline),
                  const SizedBox(height: 16),
                  Text(
                    'Aguardando votos...',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Selecione uma carta abaixo para votar',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              )
            : Wrap(
                alignment: WrapAlignment.center,
                spacing: 16,
                runSpacing: 16,
                children: playedCards.entries.map((entry) {
                  final card = entry.value;
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      PokerCardWidget(
                        value: viewModel.isRevealed
                            ? card.cardValue ?? PokerCards.hiddenCard
                            : PokerCards.hiddenCard,
                        isSelected: false,
                        isRevealed: viewModel.isRevealed,
                        size: const Size(80, 120),
                      ),
                      const SizedBox(height: 8),
                      Text(card.playerName, style: theme.textTheme.bodySmall),
                    ],
                  );
                }).toList(),
              ),
      ),
    );
  }
}
