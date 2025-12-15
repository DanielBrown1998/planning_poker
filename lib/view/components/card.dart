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
  final String userName;
  bool isFlipped;
  final bool flipOnTouch;
  late final FlipCardController _controllerFlipCard;
  final bool inTable;
  CardPoker({
    super.key,
    required this.cardValue,
    required this.colorCard,
    required this.symbolCard,
    this.userName = "anonymous",
    this.isFlipped = false,
    this.flipOnTouch = false,
    this.inTable = false,
    FlipCardController? controllerFlipCard,
  }) {
    _controllerFlipCard = controllerFlipCard ?? FlipCardController();
  }

  FlipCardController get controllerFlipCard => _controllerFlipCard;

  @override
  State<CardPoker> createState() => _CardPokerState();
}

class _CardPokerState extends State<CardPoker> with WidgetsBindingObserver {
  _flipCard() {
    if (widget.isFlipped) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget._controllerFlipCard.toggleCard();
      });
    }
  }

  late bool isFlipped;
  @override
  void initState() {
    super.initState();
    _flipCard();
    isFlipped = widget.isFlipped;
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didUpdateWidget(covariant CardPoker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isFlipped != widget.isFlipped) {
      isFlipped = widget.isFlipped;
      _flipCard();
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
    required Key key,
    required ThemeData theme,
    required SizeWindow size,
  }) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      key: key,
      child: Text(
        text,
        style: theme.textTheme.headlineLarge!.copyWith(
          color: widget.colorCard,
          fontWeight: FontWeight.bold,
          fontSize: (!widget.inTable)
              ? size == SizeWindow.large
                    ? 20
                    : (size == SizeWindow.medium ? 16 : 12)
              : 10,
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
      constraints: BoxConstraints(maxWidth: 4 * 84, maxHeight: 4 * 150),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FlipCard(
          key: ValueKey('FlipCard_${widget.cardValue}'),
          controller: widget._controllerFlipCard,
          flipOnTouch: widget.flipOnTouch,
          direction: FlipDirection.HORIZONTAL,
          front: Card(
            margin: EdgeInsets.all(0),
            borderOnForeground: false,
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
                (widget.inTable)
                    ? Positioned(
                        left: 8,
                        top: 10,
                        right: 8,
                        child: _textWidget(
                          key: ValueKey('CardUserName_${widget.cardValue}'),
                          widget.userName,
                          size: sizeWindow,
                          theme: theme,
                        ),
                      )
                    : Positioned(
                        top: 8,
                        left: 8,
                        child: _textWidget(
                          key: ValueKey('CardUserName_${widget.cardValue}'),
                          widget.cardValue.toString(),
                          size: sizeWindow,
                          theme: theme,
                        ),
                      ),
                Positioned(
                  left: 8,
                  bottom: 8,
                  child: _textWidget(
                    key: ValueKey('CardValue_${widget.cardValue}_1'),
                    widget.cardValue.toString(),
                    size: sizeWindow,
                    theme: theme,
                  ),
                ),
                (!widget.inTable)
                    ? Positioned(
                        right: 8,
                        top: 8,
                        child: _textWidget(
                          key: ValueKey('CardValue_${widget.cardValue}_2'),
                          widget.cardValue.toString(),
                          size: sizeWindow,
                          theme: theme,
                        ),
                      )
                    : SizedBox.shrink(),
                Positioned(
                  right: 8,
                  bottom: 8,
                  child: _textWidget(
                    key: ValueKey('CardValue_${widget.cardValue}_3'),
                    widget.cardValue.toString(),
                    size: sizeWindow,
                    theme: theme,
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: AlignmentGeometry.center,
                    child: Text(
                      '${widget.cardValue}',
                      style: theme.textTheme.headlineMedium!.copyWith(
                        color: widget.colorCard,
                        fontWeight: FontWeight.bold,
                        fontFamily: GoogleFonts.playfairDisplay().fontFamily,
                        fontSize: (widget.inTable)
                            ? size.width * 0.1
                            : size.height * 0.1,
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
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  widget.symbolCard,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineLarge!.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontFamily: GoogleFonts.playfairDisplay().fontFamily,
                    fontSize: (widget.inTable)
                        ? size.width * .25
                        : size.height * 0.15,
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
