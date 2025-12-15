import 'package:flutter/material.dart';
import 'package:planning_poker/utils/helpers/symbols.dart';
import 'package:planning_poker/utils/helpers/value_cards.dart';
import 'package:planning_poker/view/components/card.dart';

class GetAllCards {
  static List<CardPoker> getAllCards() {
    return List.generate(ValueCards.values.length, (index) {
      return CardPoker(
        key: ValueKey<String>(
          'card_${index}_${ValueCards.values[index].displayValue}',
        ),
        cardValue: ValueCards.values[index].displayValue,
        colorCard: Colors.primaries[index % Colors.primaries.length],
        symbolCard: Symbols.values[index].displayValue,
        isFlipped: false,
      );
    });
  }
}
