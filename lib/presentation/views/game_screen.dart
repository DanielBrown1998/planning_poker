import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/theme/theme.dart';
import '../../domain/entities/entities.dart';
import '../viewmodels/game_viewmodel.dart';
import 'partials/card_selection_area.dart';
import 'partials/players_panel.dart';
import 'partials/session_info_bar.dart';
import 'partials/table_area.dart';

class GameScreen extends StatefulWidget {
  final Session session;
  final Player player;

  const GameScreen({super.key, required this.session, required this.player});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  bool _dialogShown = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppDurations.normal,
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: AppCurves.defaultCurve,
    );
    _animationController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GameViewModel>().initialize(widget.session, widget.player);
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<GameViewModel>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isMobile = Responsive.isMobile(context);

    // Handle session ended
    if (viewModel.session == null && viewModel.error != null && !_dialogShown) {
      _dialogShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showSessionEndedDialog();
      });
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: _buildAppBar(viewModel, theme, colorScheme),
      body: viewModel.session == null
          ? _buildLoadingState(colorScheme)
          : FadeTransition(
              opacity: _fadeAnimation,
              child: isMobile
                  ? _buildMobileLayout(viewModel)
                  : _buildDesktopLayout(viewModel),
            ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    GameViewModel viewModel,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return AppBar(
      backgroundColor: colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      title: viewModel.session != null
          ? Column(
              children: [
                Text(
                  viewModel.session!.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            )
          : null,
      centerTitle: true,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHigh,
            borderRadius: AppRadius.borderRadiusSm,
          ),
          child: Icon(
            Icons.arrow_back_rounded,
            size: 20,
            color: colorScheme.onSurface,
          ),
        ),
        onPressed: () => _showLeaveConfirmation(context, viewModel),
      ),
      actions: [
        if (viewModel.session != null) ...[
          _SessionKeyChip(
            sessionKey: viewModel.session!.sessionKey,
            onTap: () => _copySessionKey(viewModel.session!.sessionKey),
          ),
          AppSpacing.hMd,
        ],
      ],
    );
  }

  Widget _buildLoadingState(ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: colorScheme.primary,
            ),
          ),
          AppSpacing.vXl,
          Text(
            'Carregando sessão...',
            style: TextStyle(
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(GameViewModel viewModel) {
    return Column(
      children: [
        const SessionInfoBar(),
        Expanded(
          child: Column(
            children: [
              // Players as horizontal list at top
              SizedBox(height: 150, child: PlayersPanel(isHorizontal: true)),
              // Table area takes remaining space
              const Expanded(child: TableArea()),
            ],
          ),
        ),
        const CardSelectionArea(),
      ],
    );
  }

  Widget _buildDesktopLayout(GameViewModel viewModel) {
    return Column(
      children: [
        const SessionInfoBar(),
        Expanded(
          child: Row(
            children: [
              const PlayersPanel(),
              const Expanded(child: TableArea()),
            ],
          ),
        ),
        const CardSelectionArea(),
      ],
    );
  }

  void _copySessionKey(String key) {
    Clipboard.setData(ClipboardData(text: key));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.check_circle_rounded,
              color: Theme.of(context).colorScheme.onInverseSurface,
              size: 20,
            ),
            AppSpacing.hSm,
            Text('Código copiado: $key'),
          ],
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(AppSpacing.lg),
      ),
    );
  }

  void _showLeaveConfirmation(BuildContext context, GameViewModel viewModel) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.borderRadiusXxl),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: colorScheme.errorContainer.withValues(alpha: 0.3),
                borderRadius: AppRadius.borderRadiusMd,
              ),
              child: Icon(
                Icons.logout_rounded,
                color: colorScheme.error,
                size: 24,
              ),
            ),
            AppSpacing.hMd,
            const Text('Sair da Sessão'),
          ],
        ),
        content: Text(
          viewModel.isHost
              ? 'Você é o host. Se sair, a sessão será encerrada para todos os participantes. Tem certeza?'
              : 'Tem certeza que deseja sair desta sessão?',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.8),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Cancelar',
              style: TextStyle(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await viewModel.leaveSession();
              if (mounted) {
                Navigator.pop(this.context);
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.error,
              foregroundColor: colorScheme.onError,
            ),
            child: const Text('Sair'),
          ),
        ],
      ),
    );
  }

  void _showSessionEndedDialog() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.borderRadiusXxl),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: AppRadius.borderRadiusMd,
              ),
              child: Icon(
                Icons.info_outline_rounded,
                color: colorScheme.primary,
                size: 24,
              ),
            ),
            AppSpacing.hMd,
            const Text('Sessão Encerrada'),
          ],
        ),
        content: Text(
          'A sessão foi encerrada pelo host.',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.8),
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
// EXTRACTED WIDGETS FOR PERFORMANCE
// ══════════════════════════════════════════════════════════════════════════

class _SessionKeyChip extends StatelessWidget {
  final String sessionKey;
  final VoidCallback onTap;

  const _SessionKeyChip({required this.sessionKey, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.borderRadiusMd,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer.withValues(alpha: 0.3),
            borderRadius: AppRadius.borderRadiusMd,
            border: Border.all(
              color: colorScheme.primary.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.key_rounded, size: 16, color: colorScheme.primary),
              AppSpacing.hXs,
              Text(
                sessionKey,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                ),
              ),
              AppSpacing.hXs,
              Icon(
                Icons.copy_rounded,
                size: 14,
                color: colorScheme.primary.withValues(alpha: 0.7),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
