import 'package:flutter/material.dart';
import 'package:planning_poker/presentation/viewmodels/game_viewmodel.dart';
import 'package:planning_poker/presentation/widgets/poker_card_widget.dart';
import 'package:provider/provider.dart';

class CardSelectionArea extends StatelessWidget {
  const CardSelectionArea({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<GameViewModel>();
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        border: Border(top: BorderSide(color: theme.dividerColor)),
      ),
      child: Column(
        children: [
          Text('Suas Cartas', style: theme.textTheme.titleSmall),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: viewModel.availableCards.map((card) {
                final isSelected = viewModel.selectedCard == card;
                final isMyPlayedCard = viewModel.myPlayedCard == card;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: PokerCardWidget(
                    value: card,
                    isSelected: isSelected || isMyPlayedCard,
                    onTap: viewModel.isRevealed
                        ? null
                        : () => viewModel.selectCard(card),
                    size: const Size(60, 90),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
