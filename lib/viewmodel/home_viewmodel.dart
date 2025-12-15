import 'dart:async';

import 'package:flutter/material.dart';
import 'package:planning_poker/model/choices.dart';
import 'package:planning_poker/repository/partners_choices_repository.dart';
import 'package:planning_poker/view/components/card.dart';
import 'package:planning_poker/view/components/get_all_cards.dart';

class HomeViewModel extends ChangeNotifier {
  String title = 'Planning Poker';

  late int choicedTime;

  late String actualDescriptionCard;
  late int numberOfPartners;
  late List<CardPoker> optionsCardsPoker;
  List<CardPoker> cardsFromPartners = [];
  List<CardPoker> myChoice = [];
  final PartnersChoicesRepository partnersChoicesRepository;
  HomeViewModel({required this.partnersChoicesRepository}) {
    _initializeCards();
  }

  //Mocked function to simulate getting choices from partners
  Stream<ChoiceAndUser> getChoicesByPartners(int numChoices) =>
      partnersChoicesRepository.getChoicesByPartners(numChoices);

  StreamController<List<ChoiceAndUser>> get partnersChoicesStreamController =>
      partnersChoicesRepository.partnersChoicesStreamController;

  void insertChoiceInCardsFromPartners(List<ChoiceAndUser> choiceAndUser) {
    final cardsFromPartners = <CardPoker>[];
    for (var choice in choiceAndUser) {
      CardPoker cardPoker = cardsFromPartners.firstWhere(
        (card) {
          final isUser = card.userName == choice.nome;
          final isValue = card.cardValue == choice.value;
          return isUser && isValue;
        },
        orElse: () => CardPoker(
          cardValue: choice.value,
          colorCard: Colors.blueGrey,
          symbolCard: choice.symbol,
          flipOnTouch: true,
          inTable: true,
          userName: choice.nome,
        ),
      );

      cardsFromPartners.add(cardPoker);
      this.cardsFromPartners = cardsFromPartners;
    }
    numberOfPartners = cardsFromPartners.length;
    // notifyListeners();
  }

  void _initializeCards() {
    optionsCardsPoker = GetAllCards.getAllCards();
    initializeState();
  }

  initializeState() {
    choicedTime = 0;
    optionsCardsPoker[choicedTime].isFlipped = false;
    // notifyListeners();
    numberOfPartners = 0;
  }

  void resetState() {
    // Reset any state variables if needed
    _initializeCards();
    notifyListeners();
  }

  void _updateState(int indexCardPoker) {
    choicedTime = indexCardPoker;
  }

  // _internalFlip(int index) async {
  //   if (index >= 0 && index < optionsCardsPoker.length) {
  //     await optionsCardsPoker[index].controllerFlipCard.toggleCard();
  //     optionsCardsPoker[index].isFlipped = !optionsCardsPoker[index].isFlipped;
  //   }
  // }

  void flipCardAtIndex(int toIndex, int fromIndex) async {
    if ((toIndex >= 0 && toIndex < optionsCardsPoker.length) &&
        (fromIndex >= 0 && fromIndex < optionsCardsPoker.length)) {
      // debugPrint("$fromIndex -> $toIndex");
      // await _internalFlip(fromIndex);
      // await _internalFlip(toIndex);
      choicedTime = toIndex;
      _updateState(choicedTime);
      notifyListeners();
    }
  }
}
