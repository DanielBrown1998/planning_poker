import 'package:flutter/material.dart';
import 'package:planning_poker/presentation/viewmodels/game_viewmodel.dart';
import 'package:provider/provider.dart';

class SessionInfoBar extends StatelessWidget {
  const SessionInfoBar({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<GameViewModel>();
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: theme.colorScheme.surfaceContainerHighest,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Players count
          Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.people, size: 20),
                  const SizedBox(width: 8),
                  Text('${viewModel.players.length} jogadores'),
                ],
              ),

              // Status
              Chip(
                label: Text(
                  viewModel.isRevealed
                      ? 'Cartas Reveladas'
                      : viewModel.allPlayersVoted
                      ? 'Todos votaram!'
                      : 'Votação em andamento',
                ),
                backgroundColor: viewModel.isRevealed
                    ? Colors.green.withValues(alpha: 0.2)
                    : viewModel.allPlayersVoted
                    ? Colors.orange.withValues(alpha: 0.2)
                    : theme.colorScheme.primaryContainer,
              ),
            ],
          ),
          // Host actions
          if (viewModel.isHost)
            Column(
              children: [
                FilledButton.tonal(
                  onPressed: viewModel.canReveal && !viewModel.isRevealed
                      ? viewModel.revealCards
                      : null,
                  child: const Text('Revelar'),
                ),
                const SizedBox(width: 8),
                FilledButton.tonal(
                  onPressed: viewModel.isRevealed ? viewModel.resetRound : null,
                  child: const Text('Nova Rodada'),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
