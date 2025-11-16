import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flip_card/flip_card_controller.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:planning_poker/utils/helpers/sizes_window.dart';

// ignore: must_be_immutable
class CardPoker extends StatefulWidget {
  final dynamic cardValue;
  final Color colorCard;
  final String symbolCard;
  bool isFlipped;
  final bool flipOnTouch;
  late final FlipCardController _controllerFlipCard;
  CardPoker({
    super.key,
    required this.cardValue,
    required this.colorCard,
    required this.symbolCard,
    this.isFlipped = false,
    this.flipOnTouch = false,
    FlipCardController? controllerFlipCard,
  }) {
    _controllerFlipCard = controllerFlipCard ?? FlipCardController();
  }

  FlipCardController get controllerFlipCard => _controllerFlipCard;

  @override
  State<CardPoker> createState() => _CardPokerState();
}

class _CardPokerState extends State<CardPoker> with WidgetsBindingObserver {
  // _flipCard() {
  //   if (widget.isFlipped) {
  //     WidgetsBinding.instance.addPostFrameCallback((_) {
  //       widget._controllerFlipCard.toggleCard();
  //     });
  //   }
  // }

  late bool isFlipped;
  @override
  void initState() {
    super.initState();
    // _flipCard();
    isFlipped = widget.isFlipped;
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didUpdateWidget(covariant CardPoker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isFlipped != widget.isFlipped) {
      isFlipped = widget.isFlipped;
      // _flipCard();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // setState(() {
      //   widget.isFlipped = false;
      // });
      // _flipCard();
    } else if (state == AppLifecycleState.hidden) {
      // setState(() {
      //   widget.isFlipped = true;
      // });
      // _flipCard();`
    } else if (state == AppLifecycleState.inactive) {
      // setState(() {
      //   widget.isFlipped = true;
      // });
      // _flipCard();
    } else if (state == AppLifecycleState.paused) {
      // setState(() {
      //   widget.isFlipped = true;
      // });
      // _flipCard();
    }
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  Widget _textWidget(
    String text, {
    required ThemeData theme,
    required SizeWindow size,
  }) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      key: ValueKey<String>('text_$text'),
      child: Text(
        text,
        style: theme.textTheme.headlineLarge!.copyWith(
          color: widget.colorCard,
          fontWeight: FontWeight.bold,
          fontSize: size == SizeWindow.large
              ? 24
              : (size == SizeWindow.medium ? 20 : 16),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final sizeWindow = getSizeWindow(size.width);
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: 4 * 84,
        maxHeight: 4 * 150,
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FlipCard(
          controller: widget._controllerFlipCard,
          flipOnTouch: widget.flipOnTouch,
          direction: FlipDirection.HORIZONTAL,
          front: Card(
            key: ValueKey('CardFront_${widget.cardValue}'),
            color: Colors.white54.withAlpha(230),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
              side: BorderSide(
                color: widget.colorCard,
                width: 2,
                style: BorderStyle.solid,
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  left: 8,
                  top: 8,
                  child: _textWidget(
                    widget.cardValue.toString(),
                    size: sizeWindow,
                    theme: theme,
                  ),
                ),
                Positioned(
                  left: 8,
                  bottom: 8,
                  child: _textWidget(
                    widget.cardValue.toString(),
                    size: sizeWindow,
                    theme: theme,
                  ),
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: _textWidget(
                    widget.cardValue.toString(),
                    size: sizeWindow,
                    theme: theme,
                  ),
                ),
                Positioned(
                  right: 8,
                  bottom: 8,
                  child: _textWidget(
                    widget.cardValue.toString(),
                    size: sizeWindow,
                    theme: theme,
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: FittedBox(
                    fit: BoxFit.fill,
                    child: Text(
                      '${widget.cardValue}',
                      style: theme.textTheme.headlineMedium!.copyWith(
                        color: widget.colorCard,
                        fontWeight: FontWeight.bold,
                        fontFamily:
                            GoogleFonts.playfairDisplay().fontFamily,
                        fontSize: size.height * 0.1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          back: Card(
            key: ValueKey('CardBack_${widget.cardValue}'),
            color: widget.colorCard,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
              side: BorderSide(
                color: widget.colorCard,
                width: 2,
                style: BorderStyle.solid,
              ),
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    widget.symbolCard,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineLarge!.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontFamily: GoogleFonts.playfairDisplay().fontFamily,
                      fontSize: size.height * 0.05,
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
}
