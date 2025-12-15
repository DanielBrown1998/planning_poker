enum Symbols {
  planningPoker,
  spade,
  heart,
  diamond,
  club,
  star,
  yingYang,
  trevo,
  sun,
  cloud,
  umbrella,
}

extension SymbolsExtension on Symbols {
  String get displayValue {
    switch (this) {
      case Symbols.planningPoker:
        return 'Planning Poker';
      case Symbols.spade:
        return '♠';
      case Symbols.heart:
        return '♥';
      case Symbols.diamond:
        return '♦';
      case Symbols.club:
        return '♣';
      case Symbols.star:
        return '★';
      case Symbols.yingYang:
        return '☯';
      case Symbols.trevo:
        return '☘';
      case Symbols.sun:
        return '☀';
      case Symbols.cloud:
        return '☁';
      case Symbols.umbrella:
        return '☂';
    }
  }
}
