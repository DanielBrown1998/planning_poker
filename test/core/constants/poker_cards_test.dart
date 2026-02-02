import 'package:flutter_test/flutter_test.dart';
import 'package:planning_poker/core/constants/poker_cards.dart';

void main() {
  group('PokerCards', () {
    test('values should contain Fibonacci sequence', () {
      expect(PokerCards.values, contains('0'));
      expect(PokerCards.values, contains('1'));
      expect(PokerCards.values, contains('2'));
      expect(PokerCards.values, contains('3'));
      expect(PokerCards.values, contains('5'));
      expect(PokerCards.values, contains('8'));
      expect(PokerCards.values, contains('13'));
      expect(PokerCards.values, contains('21'));
      expect(PokerCards.values, contains('34'));
      expect(PokerCards.values, contains('55'));
      expect(PokerCards.values, contains('89'));
    });

    test('values should contain special cards', () {
      expect(PokerCards.values, contains('?'));
      expect(PokerCards.values, contains('☕'));
    });

    test('values should have correct length', () {
      expect(PokerCards.values.length, equals(13));
    });

    test('hiddenCard should be the card back symbol', () {
      expect(PokerCards.hiddenCard, equals('🂠'));
    });

    test('values should be immutable list', () {
      expect(PokerCards.values, isA<List<String>>());
    });
  });
}
