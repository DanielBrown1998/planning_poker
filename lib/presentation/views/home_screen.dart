import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/home_viewmodel.dart';
import 'game_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _playerNameController = TextEditingController();
  final _sessionNameController = TextEditingController();
  final _sessionKeyController = TextEditingController();

  bool _isCreateMode = true;

  @override
  void dispose() {
    _playerNameController.dispose();
    _sessionNameController.dispose();
    _sessionKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HomeViewModel>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Planning Poker'), centerTitle: true),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo/Icon
                  Icon(
                    Icons.casino,
                    size: 80,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Planning Poker',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Toggle buttons
                  SegmentedButton<bool>(
                    segments: const [
                      ButtonSegment(
                        value: true,
                        label: Text('Criar Sessão'),
                        icon: Icon(Icons.add),
                      ),
                      ButtonSegment(
                        value: false,
                        label: Text('Entrar'),
                        icon: Icon(Icons.login),
                      ),
                    ],
                    selected: {_isCreateMode},
                    onSelectionChanged: (selected) {
                      setState(() {
                        _isCreateMode = selected.first;
                      });
                    },
                  ),
                  const SizedBox(height: 24),

                  // Player name field
                  TextFormField(
                    controller: _playerNameController,
                    decoration: const InputDecoration(
                      labelText: 'Seu Nome',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Digite seu nome';
                      }
                      return null;
                    },
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),

                  // Conditional fields based on mode
                  if (_isCreateMode) ...[
                    TextFormField(
                      controller: _sessionNameController,
                      decoration: const InputDecoration(
                        labelText: 'Nome da Sessão',
                        prefixIcon: Icon(Icons.meeting_room),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Digite o nome da sessão';
                        }
                        return null;
                      },
                      textInputAction: TextInputAction.done,
                    ),
                  ] else ...[
                    TextFormField(
                      controller: _sessionKeyController,
                      decoration: const InputDecoration(
                        labelText: 'Código da Sessão',
                        prefixIcon: Icon(Icons.key),
                        border: OutlineInputBorder(),
                        hintText: 'Ex: ABC123',
                      ),
                      textCapitalization: TextCapitalization.characters,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Digite o código da sessão';
                        }
                        return null;
                      },
                      textInputAction: TextInputAction.done,
                    ),
                  ],
                  const SizedBox(height: 24),

                  // Error message
                  if (viewModel.hasError)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: theme.colorScheme.error,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              viewModel.error!,
                              style: TextStyle(
                                color: theme.colorScheme.onErrorContainer,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: viewModel.clearError,
                            iconSize: 20,
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 16),

                  // Action button
                  FilledButton.icon(
                    onPressed: viewModel.isLoading ? null : _onSubmit,
                    icon: viewModel.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(_isCreateMode ? Icons.add : Icons.login),
                    label: Text(_isCreateMode ? 'Criar Sessão' : 'Entrar'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final viewModel = context.read<HomeViewModel>();
    bool success;

    if (_isCreateMode) {
      success = await viewModel.createSession(
        sessionName: _sessionNameController.text.trim(),
        playerName: _playerNameController.text.trim(),
      );
    } else {
      success = await viewModel.joinSession(
        sessionKey: _sessionKeyController.text.trim(),
        playerName: _playerNameController.text.trim(),
      );
    }

    if (success && mounted) {
      final session = viewModel.currentSession!;
      final player = viewModel.currentPlayer!;

      Navigator.of(context)
          .push(
            MaterialPageRoute(
              builder: (context) =>
                  GameScreen(session: session, player: player),
            ),
          )
          .then((_) {
            // Reset when returning from game screen
            viewModel.reset();
          });
    }
  }
}
