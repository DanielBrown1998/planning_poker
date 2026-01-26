import 'package:flutter/material.dart';

import '../../core/constants/poker_cards.dart';
import '../../core/theme/theme.dart';

/// A widget that displays a Planning Poker card
///
/// Optimized for performance with:
/// - RepaintBoundary for complex decorations
/// - Cached decorations where possible
/// - Efficient animations
class PokerCardWidget extends StatefulWidget {
  final String value;
  final bool isSelected;
  final bool isRevealed;
  final VoidCallback? onTap;
  final Size size;
  final bool isSmall;

  const PokerCardWidget({
    super.key,
    required this.value,
    this.isSelected = false,
    this.isRevealed = true,
    this.onTap,
    this.size = const Size(70, 100),
    this.isSmall = false,
  });

  @override
  State<PokerCardWidget> createState() => _PokerCardWidgetState();
}

class _PokerCardWidgetState extends State<PokerCardWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: AppDurations.fast, vsync: this);
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onTap != null) {
      _controller.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onTap != null) {
      _controller.reverse();
    }
  }

  void _handleTapCancel() {
    if (widget.onTap != null) {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isHidden = widget.value == PokerCards.hiddenCard;
    final isDisabled = widget.onTap == null;

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(scale: _scaleAnimation.value, child: child);
        },
        child: _CardBody(
          value: widget.value,
          size: widget.size,
          isSelected: widget.isSelected,
          isHidden: isHidden,
          isDisabled: isDisabled,
          isSmall: widget.isSmall,
          colorScheme: colorScheme,
          theme: theme,
        ),
      ),
    );
  }
}

class _CardBody extends StatelessWidget {
  final String value;
  final Size size;
  final bool isSelected;
  final bool isHidden;
  final bool isDisabled;
  final bool isSmall;
  final ColorScheme colorScheme;
  final ThemeData theme;

  const _CardBody({
    required this.value,
    required this.size,
    required this.isSelected,
    required this.isHidden,
    required this.isDisabled,
    required this.isSmall,
    required this.colorScheme,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedContainer(
        duration: AppDurations.fast,
        curve: AppCurves.defaultCurve,
        width: size.width,
        height: size.height,
        decoration: _buildDecoration(),
        child: Stack(
          children: [
            // Pattern overlay for hidden cards
            if (isHidden) _buildHiddenPattern(),
            // Card content
            Center(child: _buildContent()),
            // Selection indicator
            if (isSelected) _buildSelectionOverlay(),
          ],
        ),
      ),
    );
  }

  BoxDecoration _buildDecoration() {
    if (isHidden) {
      return BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary,
            colorScheme.primary.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(isSmall ? 8 : 12),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      );
    }

    return BoxDecoration(
      color: isSelected ? colorScheme.primaryContainer : colorScheme.surface,
      borderRadius: BorderRadius.circular(isSmall ? 8 : 12),
      border: Border.all(
        color: isSelected ? colorScheme.primary : colorScheme.outlineVariant,
        width: isSelected ? 2.5 : 1.5,
      ),
      boxShadow: [
        if (isSelected)
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        else
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
      ],
    );
  }

  Widget _buildHiddenPattern() {
    return Positioned.fill(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(isSmall ? 8 : 12),
        child: CustomPaint(
          painter: _DiamondPatternPainter(
            color: Colors.white.withValues(alpha: 0.1),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (isHidden) {
      return Icon(
        Icons.question_mark_rounded,
        size: size.width * 0.4,
        color: Colors.white.withValues(alpha: 0.9),
      );
    }

    return Text(
      value,
      style: TextStyle(
        fontSize: isSmall ? size.width * 0.38 : size.width * 0.4,
        fontWeight: FontWeight.bold,
        color: isSelected
            ? colorScheme.primary
            : isDisabled
            ? colorScheme.onSurface.withValues(alpha: 0.4)
            : colorScheme.onSurface,
        height: 1,
      ),
    );
  }

  Widget _buildSelectionOverlay() {
    return Positioned(
      top: 4,
      right: 4,
      child: Container(
        width: isSmall ? 14 : 18,
        height: isSmall ? 14 : 18,
        decoration: BoxDecoration(
          color: colorScheme.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withValues(alpha: 0.3),
              blurRadius: 4,
            ),
          ],
        ),
        child: Icon(
          Icons.check,
          size: isSmall ? 10 : 12,
          color: colorScheme.onPrimary,
        ),
      ),
    );
  }
}

/// Custom painter for diamond pattern on hidden cards
class _DiamondPatternPainter extends CustomPainter {
  final Color color;

  _DiamondPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    const spacing = 12.0;
    const diamondSize = 4.0;

    for (double y = 0; y < size.height; y += spacing) {
      for (
        double x = (y ~/ spacing).isEven ? 0 : spacing / 2;
        x < size.width;
        x += spacing
      ) {
        final path = Path()
          ..moveTo(x, y - diamondSize)
          ..lineTo(x + diamondSize, y)
          ..lineTo(x, y + diamondSize)
          ..lineTo(x - diamondSize, y)
          ..close();
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DiamondPatternPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
