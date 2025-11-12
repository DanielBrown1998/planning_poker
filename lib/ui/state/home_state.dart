import 'package:flutter/material.dart';
import 'package:planning_poker/ui/components/card.dart';

class HomeState extends ChangeNotifier {
  String title = 'Planning Poker';
  List<dynamic> valueCards = [
    '🃏',
    1,
    2,
    3,
    5,
    8,
    13,
    21,
    '?',
    '☕',
    '∞',
  ];
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

  List<CardPoker> get cardsPoker {
    return List.generate(valueCards.length, (index) {
      return CardPoker(
        cardValue: valueCards[index],
        colorCard: colorsCards[index],
        symbolCard: symbols[index],
      );
    });
  }

  initialize() {
    choicedTime = 0;
    actualDescriptionCard = descriptionCardsPlanning[choicedTime];
    cardsPoker[choicedTime].isFlipped = false;
    // notifyListeners();
  }

  void reset() {
    // Reset any state variables if needed
    choicedTime = 0;
    actualDescriptionCard = descriptionCardsPlanning[choicedTime];
    notifyListeners();
  }

  void updateBaseTime(dynamic cardValue) {
    choicedTime = valueCards.indexOf(cardValue);
    actualDescriptionCard = descriptionCardsPlanning[choicedTime];
    notifyListeners();
  }

  Color updateColor(dynamic cardValue) {
    choicedTime = valueCards.indexOf(cardValue);
    notifyListeners();
    return colorsCards[choicedTime];
  }

  void flipAllCards() {
    for (var card in cardsPoker) {
      card.isFlipped = !card.isFlipped;
    }
    notifyListeners();
  }

  void flipCardAtIndex(int index) {
    if (index >= 0 && index < cardsPoker.length) {
      cardsPoker[index].controllerFlipCard.toggleCard();
      cardsPoker[index].isFlipped = !cardsPoker[index].isFlipped;
      notifyListeners();
    }
  }
}
