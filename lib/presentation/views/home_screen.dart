import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/theme.dart';
import '../state/home_state.dart';
import '../viewmodels/home_viewmodel.dart';
import 'game_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _playerNameController = TextEditingController();
  final _sessionNameController = TextEditingController();
  final _sessionKeyController = TextEditingController();

  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  bool _isCreateMode = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppDurations.slow,
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: AppCurves.defaultCurve,
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: AppCurves.defaultCurve,
          ),
        );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _playerNameController.dispose();
    _sessionNameController.dispose();
    _sessionKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final size = MediaQuery.sizeOf(context);
    final isDesktop = Responsive.isDesktop(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [colorScheme.surface, colorScheme.surfaceContainerLow],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: Responsive.padding(context),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: isDesktop ? 480 : 400,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildHeader(theme, size),
                        AppSpacing.vXxxl,
                        _buildCard(theme, colorScheme),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, Size size) {
    final isSmall = size.width < 400;

    return Column(
      children: [
        // Animated Logo
        Container(
          width: isSmall ? 80 : 100,
          height: isSmall ? 80 : 100,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.primary,
                theme.colorScheme.primary.withValues(alpha: 0.8),
              ],
            ),
            borderRadius: AppRadius.borderRadiusXxl,
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Icon(
            Icons.style_rounded,
            size: isSmall ? 40 : 50,
            color: theme.colorScheme.onPrimary,
          ),
        ),
        AppSpacing.vXl,
        Text(
          'Planning Poker',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        AppSpacing.vSm,
        Text(
          'Estimativas ágeis em tempo real',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildCard(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: AppRadius.borderRadiusXxl,
        border: Border.all(color: colorScheme.outlineVariant, width: 1),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildModeToggle(theme, colorScheme),
              AppSpacing.vXxl,
              _buildPlayerNameField(theme),
              AppSpacing.vLg,
              _buildConditionalField(theme),
              AppSpacing.vXxl,
              _buildErrorMessage(theme, colorScheme),
              _buildSubmitButton(theme, colorScheme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeToggle(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: AppRadius.borderRadiusMd,
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: _ModeButton(
              label: 'Criar Sessão',
              icon: Icons.add_rounded,
              isSelected: _isCreateMode,
              onTap: () => setState(() => _isCreateMode = true),
            ),
          ),
          Expanded(
            child: _ModeButton(
              label: 'Entrar',
              icon: Icons.login_rounded,
              isSelected: !_isCreateMode,
              onTap: () => setState(() => _isCreateMode = false),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerNameField(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Seu Nome',
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
          ),
        ),
        AppSpacing.vSm,
        TextFormField(
          controller: _playerNameController,
          decoration: const InputDecoration(
            hintText: 'Como você quer ser chamado?',
            prefixIcon: Icon(Icons.person_outline_rounded),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Digite seu nome';
            }
            return null;
          },
          textInputAction: TextInputAction.next,
          textCapitalization: TextCapitalization.words,
        ),
      ],
    );
  }

  Widget _buildConditionalField(ThemeData theme) {
    return AnimatedSwitcher(
      duration: AppDurations.normal,
      switchInCurve: AppCurves.defaultCurve,
      switchOutCurve: AppCurves.defaultCurve,
      child: _isCreateMode
          ? _buildSessionNameField(theme)
          : _buildSessionKeyField(theme),
    );
  }

  Widget _buildSessionNameField(ThemeData theme) {
    return Column(
      key: const ValueKey('session_name'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nome da Sessão',
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
          ),
        ),
        AppSpacing.vSm,
        TextFormField(
          controller: _sessionNameController,
          decoration: const InputDecoration(
            hintText: 'Ex: Sprint 42 Planning',
            prefixIcon: Icon(Icons.meeting_room_outlined),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Digite o nome da sessão';
            }
            return null;
          },
          textInputAction: TextInputAction.done,
          textCapitalization: TextCapitalization.sentences,
          onFieldSubmitted: (_) => _onSubmit(),
        ),
      ],
    );
  }

  Widget _buildSessionKeyField(ThemeData theme) {
    return Column(
      key: const ValueKey('session_key'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Código da Sessão',
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
          ),
        ),
        AppSpacing.vSm,
        TextFormField(
          controller: _sessionKeyController,
          decoration: const InputDecoration(
            hintText: 'Ex: ABC123',
            prefixIcon: Icon(Icons.key_rounded),
          ),
          textCapitalization: TextCapitalization.characters,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Digite o código da sessão';
            }
            return null;
          },
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _onSubmit(),
        ),
      ],
    );
  }

  Widget _buildErrorMessage(ThemeData theme, ColorScheme colorScheme) {
    final viewModel = context.watch<HomeViewModel>();

    if (viewModel.state is! HomeError) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: colorScheme.errorContainer.withValues(alpha: 0.3),
          borderRadius: AppRadius.borderRadiusMd,
          border: Border.all(color: colorScheme.error.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: colorScheme.error,
              size: 20,
            ),
            AppSpacing.hSm,
            Expanded(
              child: Text(
                viewModel.error ?? 'Ocorreu um erro',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.error,
                ),
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.close_rounded,
                size: 18,
                color: colorScheme.error,
              ),
              onPressed: viewModel.clearError,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton(ThemeData theme, ColorScheme colorScheme) {
    final viewModel = context.watch<HomeViewModel>();

    return FilledButton(
      onPressed: viewModel.isLoading ? null : _onSubmit,
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 18),
        backgroundColor: colorScheme.primary,
        disabledBackgroundColor: colorScheme.primary.withValues(alpha: 0.5),
      ),
      child: AnimatedSwitcher(
        duration: AppDurations.fast,
        child: viewModel.isLoading
            ? SizedBox(
                key: const ValueKey('loading'),
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: colorScheme.onPrimary,
                ),
              )
            : Row(
                key: const ValueKey('content'),
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _isCreateMode ? Icons.add_rounded : Icons.login_rounded,
                    size: 20,
                  ),
                  AppSpacing.hSm,
                  Text(_isCreateMode ? 'Criar Sessão' : 'Entrar na Sessão'),
                ],
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
      if (viewModel.state is! HomeSuccess) return;
      final successState = viewModel.state as HomeSuccess;
      final session = successState.session;
      final player = successState.player;

      Navigator.of(context)
          .push(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  GameScreen(session: session, player: player),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                    return FadeTransition(opacity: animation, child: child);
                  },
              transitionDuration: AppDurations.normal,
            ),
          )
          .then((_) {
            viewModel.reset();
          });
    }
  }
}

// ══════════════════════════════════════════════════════════════════════════
// EXTRACTED WIDGETS FOR PERFORMANCE
// ══════════════════════════════════════════════════════════════════════════

class _ModeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModeButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppDurations.fast,
        curve: AppCurves.defaultCurve,
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.md,
          horizontal: AppSpacing.lg,
        ),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primary : Colors.transparent,
          borderRadius: AppRadius.borderRadiusSm,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected
                  ? colorScheme.onPrimary
                  : colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            AppSpacing.hXs,
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: isSelected
                    ? colorScheme.onPrimary
                    : colorScheme.onSurface.withValues(alpha: 0.7),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
