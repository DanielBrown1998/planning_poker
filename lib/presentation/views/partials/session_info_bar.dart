import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/theme.dart';
import '../../viewmodels/game_viewmodel.dart';

class SessionInfoBar extends StatelessWidget {
  const SessionInfoBar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isMobile = Responsive.isMobile(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.horizontalPadding(context),
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: colorScheme.outlineVariant, width: 1),
        ),
      ),
      child: isMobile
          ? _buildMobileLayout(context)
          : _buildDesktopLayout(context),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [_PlayersCount(), _StatusChip()],
        ),
        AppSpacing.vSm,
        _HostActions(isCompact: true),
      ],
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      children: [
        _PlayersCount(),
        AppSpacing.hXl,
        _StatusChip(),
        const Spacer(),
        _HostActions(isCompact: false),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
// EXTRACTED LEAF WIDGETS FOR PERFORMANCE
// ══════════════════════════════════════════════════════════════════════════

class _PlayersCount extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final viewModel = context.select<GameViewModel, int>(
      (vm) => vm.players.length,
    );
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: AppRadius.borderRadiusMd,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.people_outline_rounded,
            size: 18,
            color: colorScheme.primary,
          ),
          AppSpacing.hSm,
          Text(
            '$viewModel jogadores',
            style: theme.textTheme.labelLarge?.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<GameViewModel>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final (label, color, icon) = _getStatusConfig(viewModel, colorScheme);

    return AnimatedContainer(
      duration: AppDurations.fast,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: AppRadius.borderRadiusRound,
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          AppSpacing.hXs,
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  (String, Color, IconData) _getStatusConfig(
    GameViewModel viewModel,
    ColorScheme colorScheme,
  ) {
    if (viewModel.isRevealed) {
      return ('Cartas Reveladas', AppTheme.success, Icons.visibility_rounded);
    }
    if (viewModel.allPlayersVoted) {
      return (
        'Todos votaram!',
        AppTheme.warning,
        Icons.check_circle_outline_rounded,
      );
    }
    return (
      'Votação em andamento',
      colorScheme.primary,
      Icons.hourglass_empty_rounded,
    );
  }
}

class _HostActions extends StatelessWidget {
  final bool isCompact;

  const _HostActions({required this.isCompact});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<GameViewModel>();

    if (!viewModel.isHost) {
      return const SizedBox.shrink();
    }

    if (isCompact) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: _ActionButton(
              label: 'Revelar',
              icon: Icons.visibility_rounded,
              onPressed: viewModel.canReveal && !viewModel.isRevealed
                  ? viewModel.revealCards
                  : null,
              isPrimary: true,
            ),
          ),
          AppSpacing.hSm,
          Expanded(
            child: _ActionButton(
              label: 'Nova Rodada',
              icon: Icons.refresh_rounded,
              onPressed: viewModel.isRevealed ? viewModel.resetRound : null,
              isPrimary: false,
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        _ActionButton(
          label: 'Revelar Cartas',
          icon: Icons.visibility_rounded,
          onPressed: viewModel.canReveal && !viewModel.isRevealed
              ? viewModel.revealCards
              : null,
          isPrimary: true,
        ),
        AppSpacing.hSm,
        _ActionButton(
          label: 'Nova Rodada',
          icon: Icons.refresh_rounded,
          onPressed: viewModel.isRevealed ? viewModel.resetRound : null,
          isPrimary: false,
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool isPrimary;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    required this.isPrimary,
  });

  @override
  Widget build(BuildContext context) {
    if (isPrimary) {
      return FilledButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
        ),
      );
    }

    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
      ),
    );
  }
}
