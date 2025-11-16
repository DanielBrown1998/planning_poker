import 'package:flutter/material.dart';
import 'package:planning_poker/ui/components/card.dart';

class HomeState extends ChangeNotifier {
  String title = 'Planning Poker';
  List<dynamic> valueCards = ['🃏', 1, 2, 3, 5, 8, 13, 21, '?', '☕', '∞'];
  List<String> symbols = [
    "Planning Poker",
    '♠',
    '♥',
    '♦',
    '♣',
    '★',
    '☯',
    '☘',
    '☀',
    '☁',
    '☂',
  ];
  List<Color> colorsCards = [
    Colors.amber,
    Colors.green,
    Colors.blue,
    Colors.orange,
    Colors.purple,
    Colors.red,
    Colors.pink,
    Colors.cyan,
    Colors.grey,
    Colors.brown,
    Colors.teal,
  ];
  late int choicedTime;
  late Color colorBase;
  List<String> descriptionCardsPlanning = [
    'Welcome to Planning Poker, select a card to estimate',
    '30 minutes, this is a small task',
    '1 hours, this is a medium task, requires minimal effort',
    '2 hours, this is a medium task, requires some effort',
    '3 hours, this is a large task, requires effort',
    '5 hours, this is a large task, requires significant effort',
    '8 hours, this is a huge task, requires substantial effort',
    '13 hours, this is a huge task, requires extensive effort',
    'Unknown, need more information',
    'Coffee Break (15 minutes), time for a break',
    'Need more discussion and break the problem down, cannot estimate now',
  ];
  late String actualDescriptionCard;

  late List<CardPoker> cardsPoker;

  HomeState() {
    _initializeCards();
  }

  void _initializeCards() {
    cardsPoker = List.generate(valueCards.length, (index) {
      return CardPoker(
        key: ValueKey<String>('card_${index}_${valueCards[index]}'),
        cardValue: valueCards[index],
        colorCard: colorsCards[index],
        symbolCard: symbols[index],
        isFlipped: false,
      );
    });
    initializeState();
  }

  initializeState() {
    choicedTime = 0;
    actualDescriptionCard = descriptionCardsPlanning[choicedTime];
    cardsPoker[choicedTime].isFlipped = false;
    colorBase = colorsCards[choicedTime];
    // notifyListeners();
  }

  void resetState() {
    // Reset any state variables if needed
    _initializeCards();
    notifyListeners();
  }

  void _updateState(int indexCardPoker) {
    choicedTime = indexCardPoker;
    actualDescriptionCard = descriptionCardsPlanning[choicedTime];
    colorBase = colorsCards[choicedTime];
  }

  // _internalFlip(int index) async {
  //   if (index >= 0 && index < cardsPoker.length) {
  //     await cardsPoker[index].controllerFlipCard.toggleCard();
  //     cardsPoker[index].isFlipped = !cardsPoker[index].isFlipped;
  //   }
  // }

  void flipCardAtIndex(int toIndex, int fromIndex) async {
    if ((toIndex >= 0 && toIndex < cardsPoker.length) &&
        (fromIndex >= 0 && fromIndex < cardsPoker.length)) {
      // debugPrint("$fromIndex -> $toIndex");
      // await _internalFlip(fromIndex);
      // await _internalFlip(toIndex);
      choicedTime = toIndex;
      _updateState(choicedTime);
      notifyListeners();
    }
  }
}
