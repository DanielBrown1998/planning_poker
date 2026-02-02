import 'package:flutter_test/flutter_test.dart';
import 'package:planning_poker/domain/entities/played_card.dart';

void main() {
  group('PlayedCard', () {
    final testTime = DateTime(2024, 1, 15, 10, 30, 0);

    group('constructor', () {
      test('should create played card with required fields', () {
        final card = PlayedCard(
          playerId: '123',
          playerName: 'John',
          cardValue: '5',
          playedAt: testTime,
        );

        expect(card.playerId, equals('123'));
        expect(card.playerName, equals('John'));
        expect(card.cardValue, equals('5'));
        expect(card.playedAt, equals(testTime));
      });

      test('should create played card with null cardValue', () {
        final card = PlayedCard(
          playerId: '123',
          playerName: 'John',
          cardValue: null,
          playedAt: testTime,
        );

        expect(card.cardValue, isNull);
      });

      test('should create const played card', () {
        final card = PlayedCard(
          playerId: '123',
          playerName: 'John',
          cardValue: '8',
          playedAt: DateTime.now(),
        );

        expect(card.playerId, equals('123'));
      });
    });

    group('hasPlayed', () {
      test('should return true when cardValue is not null', () {
        final card = PlayedCard(
          playerId: '123',
          playerName: 'John',
          cardValue: '5',
          playedAt: testTime,
        );

        expect(card.hasPlayed, isTrue);
      });

      test('should return false when cardValue is null', () {
        final card = PlayedCard(
          playerId: '123',
          playerName: 'John',
          cardValue: null,
          playedAt: testTime,
        );

        expect(card.hasPlayed, isFalse);
      });
    });

    group('copyWith', () {
      test('should copy with new playerId', () {
        final card = PlayedCard(
          playerId: '123',
          playerName: 'John',
          cardValue: '5',
          playedAt: testTime,
        );
        final copied = card.copyWith(playerId: '456');

        expect(copied.playerId, equals('456'));
        expect(copied.playerName, equals('John'));
        expect(copied.cardValue, equals('5'));
        expect(copied.playedAt, equals(testTime));
      });

      test('should copy with new playerName', () {
        final card = PlayedCard(
          playerId: '123',
          playerName: 'John',
          cardValue: '5',
          playedAt: testTime,
        );
        final copied = card.copyWith(playerName: 'Jane');

        expect(copied.playerName, equals('Jane'));
      });

      test('should copy with new cardValue', () {
        final card = PlayedCard(
          playerId: '123',
          playerName: 'John',
          cardValue: '5',
          playedAt: testTime,
        );
        final copied = card.copyWith(cardValue: '13');

        expect(copied.cardValue, equals('13'));
      });

      test('should copy with new playedAt', () {
        final card = PlayedCard(
          playerId: '123',
          playerName: 'John',
          cardValue: '5',
          playedAt: testTime,
        );
        final newTime = DateTime(2024, 2, 1);
        final copied = card.copyWith(playedAt: newTime);

        expect(copied.playedAt, equals(newTime));
      });

      test('should copy without changes when no params provided', () {
        final card = PlayedCard(
          playerId: '123',
          playerName: 'John',
          cardValue: '5',
          playedAt: testTime,
        );
        final copied = card.copyWith();

        expect(copied.playerId, equals(card.playerId));
        expect(copied.playerName, equals(card.playerName));
        expect(copied.cardValue, equals(card.cardValue));
        expect(copied.playedAt, equals(card.playedAt));
      });
    });

    group('toJson', () {
      test('should convert to JSON map', () {
        final card = PlayedCard(
          playerId: '123',
          playerName: 'John',
          cardValue: '5',
          playedAt: testTime,
        );
        final json = card.toJson();

        expect(json['playerId'], equals('123'));
        expect(json['playerName'], equals('John'));
        expect(json['cardValue'], equals('5'));
        expect(json['playedAt'], equals(testTime.toIso8601String()));
      });

      test('should include null cardValue', () {
        final card = PlayedCard(
          playerId: '123',
          playerName: 'John',
          cardValue: null,
          playedAt: testTime,
        );
        final json = card.toJson();

        expect(json['cardValue'], isNull);
      });
    });

    group('fromJson', () {
      test('should create from JSON map', () {
        final json = {
          'playerId': '123',
          'playerName': 'John',
          'cardValue': '5',
          'playedAt': testTime.toIso8601String(),
        };
        final card = PlayedCard.fromJson(json);

        expect(card.playerId, equals('123'));
        expect(card.playerName, equals('John'));
        expect(card.cardValue, equals('5'));
        expect(card.playedAt, equals(testTime));
      });

      test('should handle null cardValue in JSON', () {
        final json = {
          'playerId': '123',
          'playerName': 'John',
          'cardValue': null,
          'playedAt': testTime.toIso8601String(),
        };
        final card = PlayedCard.fromJson(json);

        expect(card.cardValue, isNull);
      });
    });

    group('toString', () {
      test('should return formatted string', () {
        final card = PlayedCard(
          playerId: '123',
          playerName: 'John',
          cardValue: '5',
          playedAt: testTime,
        );

        expect(
          card.toString(),
          equals('PlayedCard(playerId: 123, playerName: John, cardValue: 5)'),
        );
      });

      test('should include null cardValue in string', () {
        final card = PlayedCard(
          playerId: '123',
          playerName: 'John',
          cardValue: null,
          playedAt: testTime,
        );

        expect(
          card.toString(),
          equals(
            'PlayedCard(playerId: 123, playerName: John, cardValue: null)',
          ),
        );
      });
    });

    group('serialization roundtrip', () {
      test('should preserve data through toJson/fromJson', () {
        final original = PlayedCard(
          playerId: '123',
          playerName: 'John',
          cardValue: '5',
          playedAt: testTime,
        );
        final json = original.toJson();
        final restored = PlayedCard.fromJson(json);

        expect(restored.playerId, equals(original.playerId));
        expect(restored.playerName, equals(original.playerName));
        expect(restored.cardValue, equals(original.cardValue));
        expect(restored.playedAt, equals(original.playedAt));
      });
    });
  });
}
