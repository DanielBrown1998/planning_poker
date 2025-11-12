import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flip_card/flip_card_controller.dart';
import 'package:google_fonts/google_fonts.dart';

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
    this.isFlipped = true,
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
  _flipCard() {
    if (widget.isFlipped) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget._controllerFlipCard.toggleCard();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _flipCard();
  }

  @override
  void didUpdateWidget(covariant CardPoker oldWidget) {
    super.didUpdateWidget(oldWidget);
    _flipCard();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      setState(() {
        widget.isFlipped = false;
      });
      _flipCard();
    } else if (state == AppLifecycleState.hidden) {
      setState(() {
        widget.isFlipped = true;
      });
      _flipCard();
    } else if (state == AppLifecycleState.inactive) {
      setState(() {
        widget.isFlipped = true;
      });
      _flipCard();
    } else if (state == AppLifecycleState.paused) {
      setState(() {
        widget.isFlipped = true;
      });
      _flipCard();
    }
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: FlipCard(
        controller: widget._controllerFlipCard,
        flipOnTouch: widget.flipOnTouch,
        direction: FlipDirection.HORIZONTAL,
        front: Card(
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
                child: Text(
                  widget.cardValue.toString(),
                  style: theme.textTheme.headlineLarge!.copyWith(
                    color: widget.colorCard,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
              ),
              Positioned(
                left: 8,
                bottom: 8,
                child: Text(
                  widget.cardValue.toString(),
                  style: theme.textTheme.headlineLarge!.copyWith(
                    color: widget.colorCard,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Text(
                  widget.cardValue.toString(),
                  style: theme.textTheme.headlineLarge!.copyWith(
                    color: widget.colorCard,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
              ),
              Positioned(
                right: 8,
                bottom: 8,
                child: Text(
                  widget.cardValue.toString(),
                  style: theme.textTheme.headlineLarge!.copyWith(
                    color: widget.colorCard,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: Text(
                  '${widget.cardValue}',
                  style: theme.textTheme.headlineLarge!.copyWith(
                    color: widget.colorCard,
                    fontWeight: FontWeight.bold,
                    fontSize: size.height * 0.2,
                  ),
                ),
              ),
            ],
          ),
        ),
        back: Card(
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
    );
  }
}
