import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/constants/poker_cards.dart';
import '../../domain/entities/entities.dart';
import '../viewmodels/game_viewmodel.dart';
import '../widgets/poker_card_widget.dart';
import '../widgets/player_card_widget.dart';

class GameScreen extends StatefulWidget {
  final Session session;
  final Player player;

  const GameScreen({super.key, required this.session, required this.player});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GameViewModel>().initialize(widget.session, widget.player);
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<GameViewModel>();
    final theme = Theme.of(context);

    // Handle session ended
    if (viewModel.session == null && viewModel.error != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showSessionEndedDialog();
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(viewModel.session?.name ?? 'Planning Poker'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => _showLeaveConfirmation(context, viewModel),
        ),
        actions: [
          // Session key button
          if (viewModel.session != null)
            TextButton.icon(
              onPressed: () => _copySessionKey(viewModel.session!.sessionKey),
              icon: const Icon(Icons.key),
              label: Text(viewModel.session!.sessionKey),
            ),
        ],
      ),
      body: viewModel.session == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Session info bar
                _buildSessionInfoBar(viewModel, theme),

                // Main content
                Expanded(
                  child: Row(
                    children: [
                      // Players panel
                      _buildPlayersPanel(viewModel, theme),

                      // Table/Board area
                      Expanded(child: _buildTableArea(viewModel, theme)),
                    ],
                  ),
                ),

                // Card selection area
                _buildCardSelectionArea(viewModel, theme),
              ],
            ),
    );
  }

  Widget _buildSessionInfoBar(GameViewModel viewModel, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: theme.colorScheme.surfaceContainerHighest,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Players count
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

          // Host actions
          if (viewModel.isHost)
            Row(
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

  Widget _buildPlayersPanel(GameViewModel viewModel, ThemeData theme) {
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

  Widget _buildTableArea(GameViewModel viewModel, ThemeData theme) {
    final playedCards = viewModel.playedCards;

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

  Widget _buildCardSelectionArea(GameViewModel viewModel, ThemeData theme) {
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
                  padding: const EdgeInsets.symmetric(horizontal: 4),
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

  void _copySessionKey(String key) {
    Clipboard.setData(ClipboardData(text: key));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Código copiado: $key'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showLeaveConfirmation(BuildContext context, GameViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sair da Sessão'),
        content: Text(
          viewModel.isHost
              ? 'Você é o host. Se sair, a sessão será encerrada para todos. Deseja continuar?'
              : 'Deseja sair desta sessão?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              await viewModel.leaveSession();
              if (mounted) {
                Navigator.pop(this.context);
              }
            },
            child: const Text('Sair'),
          ),
        ],
      ),
    );
  }

  void _showSessionEndedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Sessão Encerrada'),
        content: const Text('A sessão foi encerrada pelo host.'),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(this.context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
