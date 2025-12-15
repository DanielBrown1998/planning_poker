enum ValueCards {
  joker,
  one,
  two,
  three,
  five,
  eight,
  thirteen,
  twentyOne,
  hundred,
  infinity,
  question,
}

extension ValueCardsExtension on ValueCards {
  // ignore: unused_element
  String get displayValue {
    switch (this) {
      case ValueCards.joker:
        return '🃏';
      case ValueCards.one:
        return '1';
      case ValueCards.two:
        return '2';
      case ValueCards.three:
        return '3';
      case ValueCards.five:
        return '5';
      case ValueCards.eight:
        return '8';
      case ValueCards.thirteen:
        return '13';
      case ValueCards.twentyOne:
        return '21';
      case ValueCards.hundred:
        return '☕';
      case ValueCards.infinity:
        return '∞';
      case ValueCards.question:
        return '?';
    }
  }
}
