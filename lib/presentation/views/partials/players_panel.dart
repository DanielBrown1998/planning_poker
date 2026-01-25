import 'package:flutter/material.dart';
import 'package:planning_poker/presentation/viewmodels/game_viewmodel.dart';
import 'package:planning_poker/presentation/widgets/player_card_widget.dart';
import 'package:provider/provider.dart';

class PlayersPanel extends StatelessWidget {
  const PlayersPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<GameViewModel>();
    final theme = Theme.of(context);
    return Container(
      width: 200,
      decoration: BoxDecoration(
        border: Border(right: BorderSide(color: theme.dividerColor)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Jogadores',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: viewModel.players.length,
              itemBuilder: (context, index) {
                final player = viewModel.players[index];
                final hasVoted = viewModel.playedCards.containsKey(player.id);
                final playedCard = viewModel.playedCards[player.id];
                final isCurrentPlayer =
                    player.id == viewModel.currentPlayer?.id;
                return PlayerCardWidget(
                  player: player,
                  hasVoted: hasVoted,
                  cardValue: viewModel.isRevealed
                      ? playedCard?.cardValue
                      : null,
                  isCurrentPlayer: isCurrentPlayer,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
