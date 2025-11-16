import 'package:flutter_test/flutter_test.dart';
import 'package:planning_poker/ui/state/home_state.dart';
import 'package:flutter/material.dart';

void main() {
  group('HomeState', () {
    late HomeState homeState;

    setUp(() {
      homeState = HomeState();
    });

    test('initial values are correct', () {
      homeState.initializeState();
      expect(homeState.title, 'Planning Poker');
      expect(homeState.valueCards, [
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
      ]);
      expect(homeState.choicedTime, 0);
      expect(
        homeState.actualDescriptionCard,
        homeState.descriptionCardsPlanning[0],
      );
    });

    test('initialize sets correct values', () {
      homeState.initializeState();
      expect(homeState.choicedTime, 0);
      expect(
        homeState.actualDescriptionCard,
        homeState.descriptionCardsPlanning[0],
      );
      expect(homeState.cardsPoker[0].isFlipped, isFalse);
    });

    test('reset sets correct values', () {
      homeState.initializeState();
      homeState.choicedTime = 5;
      homeState.actualDescriptionCard = 'Test Description';
      homeState.resetState();
      expect(homeState.choicedTime, 0);
      expect(
        homeState.actualDescriptionCard,
        homeState.descriptionCardsPlanning[0],
      );
    });

    test('updateBaseTime updates choicedTime and actualDescriptionCard', () {
      homeState.initializeState();
      homeState.updateState(5);
      expect(homeState.choicedTime, 4);
      expect(
        homeState.actualDescriptionCard,
        homeState.descriptionCardsPlanning[4],
      );
    });

    test('updateColor updates choicedTime and returns correct color', () {
      homeState.initializeState();
      Color color = homeState.updateColor(8);
      expect(homeState.choicedTime, 5);
      expect(color, homeState.colorsCards[5]);
    });

    test('flipCardAtIndex toggles isFlipped for the specified card', () {
      homeState.initializeState();
      homeState.flipCardAtIndex(2);
      expect(homeState.cardsPoker[2].isFlipped, isFalse);
    });
  });
}
