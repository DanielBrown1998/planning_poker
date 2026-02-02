import 'package:flutter_test/flutter_test.dart';
import 'package:planning_poker/domain/entities/player.dart';

void main() {
  group('Player', () {
    group('constructor', () {
      test('should create player with required fields', () {
        final player = Player(id: '123', name: 'John');

        expect(player.id, equals('123'));
        expect(player.name, equals('John'));
        expect(player.isHost, isFalse);
      });

      test('should create player with isHost true', () {
        final player = Player(id: '123', name: 'John', isHost: true);

        expect(player.isHost, isTrue);
      });

      test('should create const player', () {
        const player = Player(id: '123', name: 'John', isHost: true);

        expect(player.id, equals('123'));
      });
    });

    group('copyWith', () {
      test('should copy with new id', () {
        final player = Player(id: '123', name: 'John', isHost: true);
        final copied = player.copyWith(id: '456');

        expect(copied.id, equals('456'));
        expect(copied.name, equals('John'));
        expect(copied.isHost, isTrue);
      });

      test('should copy with new name', () {
        final player = Player(id: '123', name: 'John');
        final copied = player.copyWith(name: 'Jane');

        expect(copied.id, equals('123'));
        expect(copied.name, equals('Jane'));
      });

      test('should copy with new isHost', () {
        final player = Player(id: '123', name: 'John', isHost: false);
        final copied = player.copyWith(isHost: true);

        expect(copied.isHost, isTrue);
      });

      test('should copy without changes when no params provided', () {
        final player = Player(id: '123', name: 'John', isHost: true);
        final copied = player.copyWith();

        expect(copied.id, equals(player.id));
        expect(copied.name, equals(player.name));
        expect(copied.isHost, equals(player.isHost));
      });
    });

    group('toJson', () {
      test('should convert player to JSON map', () {
        final player = Player(id: '123', name: 'John', isHost: true);
        final json = player.toJson();

        expect(json['id'], equals('123'));
        expect(json['name'], equals('John'));
        expect(json['isHost'], isTrue);
      });

      test('should convert non-host player to JSON', () {
        final player = Player(id: '456', name: 'Jane', isHost: false);
        final json = player.toJson();

        expect(json['isHost'], isFalse);
      });
    });

    group('fromJson', () {
      test('should create player from JSON map', () {
        final json = {'id': '123', 'name': 'John', 'isHost': true};
        final player = Player.fromJson(json);

        expect(player.id, equals('123'));
        expect(player.name, equals('John'));
        expect(player.isHost, isTrue);
      });

      test('should default isHost to false when not provided', () {
        final json = {'id': '123', 'name': 'John'};
        final player = Player.fromJson(json);

        expect(player.isHost, isFalse);
      });

      test('should handle null isHost', () {
        final json = {'id': '123', 'name': 'John', 'isHost': null};
        final player = Player.fromJson(json);

        expect(player.isHost, isFalse);
      });
    });

    group('equality', () {
      test('should be equal when ids match', () {
        final player1 = Player(id: '123', name: 'John');
        final player2 = Player(id: '123', name: 'Jane');

        expect(player1 == player2, isTrue);
      });

      test('should not be equal when ids differ', () {
        final player1 = Player(id: '123', name: 'John');
        final player2 = Player(id: '456', name: 'John');

        expect(player1 == player2, isFalse);
      });

      test('should be identical to itself', () {
        final player = Player(id: '123', name: 'John');

        expect(identical(player, player), isTrue);
        expect(player == player, isTrue);
      });
    });

    group('hashCode', () {
      test('should return same hashCode for equal players', () {
        final player1 = Player(id: '123', name: 'John');
        final player2 = Player(id: '123', name: 'Jane');

        expect(player1.hashCode, equals(player2.hashCode));
      });

      test('should be based on id', () {
        final player = Player(id: '123', name: 'John');

        expect(player.hashCode, equals('123'.hashCode));
      });
    });

    group('toString', () {
      test('should return formatted string', () {
        final player = Player(id: '123', name: 'John', isHost: true);

        expect(
          player.toString(),
          equals('Player(id: 123, name: John, isHost: true)'),
        );
      });
    });

    group('serialization roundtrip', () {
      test('should preserve data through toJson/fromJson', () {
        final original = Player(id: '123', name: 'John', isHost: true);
        final json = original.toJson();
        final restored = Player.fromJson(json);

        expect(restored.id, equals(original.id));
        expect(restored.name, equals(original.name));
        expect(restored.isHost, equals(original.isHost));
      });
    });
  });
}
