import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:planning_poker/presentation/views/partials/card_selection_area.dart';
import 'package:planning_poker/presentation/views/partials/players_panel.dart';
import 'package:planning_poker/presentation/views/partials/session_info_bar.dart';
import 'package:planning_poker/presentation/views/partials/table_area.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/entities.dart';
import '../viewmodels/game_viewmodel.dart';

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
                SessionInfoBar(),
                Expanded(
                  child: Row(
                    children: [
                      PlayersPanel(),
                      Expanded(child: TableArea()),
                    ],
                  ),
                ),
                CardSelectionArea(),
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
