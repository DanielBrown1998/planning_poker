import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LottieCard extends StatefulWidget {
  final AnimationController controller;
  const LottieCard({super.key, required this.controller});

  @override
  State<LottieCard> createState() => _LottieCardState();
}

class _LottieCardState extends State<LottieCard>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      'assets/animations/cards.json',
      width: 40,
      height: 40,
      fit: BoxFit.cover,
      frameBuilder: (context, child, composition) {
        if (composition == null) {
          return const SizedBox.shrink();
        }
        return child;
      },
      onLoaded: (composition) {
        widget.controller.duration = composition.duration;
        widget.controller.forward();
        widget.controller.addStatusListener((status) {
          if (status == AnimationStatus.completed) {
            widget.controller.repeat();
          }
        });
      },
      errorBuilder: (context, error, stackTrace) =>
          const Icon(Icons.error, color: Colors.red),
      controller: widget.controller,
      filterQuality: FilterQuality.high,
    );
  }
}
