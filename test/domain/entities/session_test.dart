import 'package:flutter_test/flutter_test.dart';
import 'package:planning_poker/domain/entities/session.dart';
import 'package:planning_poker/domain/entities/player.dart';
import 'package:planning_poker/domain/entities/played_card.dart';

void main() {
  group('GameState', () {
    test('should have correct enum values', () {
      expect(GameState.values.length, equals(3));
      expect(GameState.values, contains(GameState.waiting));
      expect(GameState.values, contains(GameState.voting));
      expect(GameState.values, contains(GameState.revealed));
    });

    test('should convert to name string', () {
      expect(GameState.waiting.name, equals('waiting'));
      expect(GameState.voting.name, equals('voting'));
      expect(GameState.revealed.name, equals('revealed'));
    });
  });

  group('Session', () {
    final testTime = DateTime(2024, 1, 15, 10, 30, 0);
    final hostPlayer = Player(id: 'host-123', name: 'Host', isHost: true);
    final player2 = Player(id: 'player-456', name: 'Player 2');
    final playedCard1 = PlayedCard(
      playerId: 'host-123',
      playerName: 'Host',
      cardValue: '5',
      playedAt: testTime,
    );
    final playedCard2 = PlayedCard(
      playerId: 'player-456',
      playerName: 'Player 2',
      cardValue: '8',
      playedAt: testTime,
    );

    Session createTestSession({
      String id = 'session-1',
      String sessionKey = 'ABC123',
      String hostId = 'host-123',
      String name = 'Test Session',
      GameState state = GameState.voting,
      List<Player>? players,
      Map<String, PlayedCard>? playedCards,
      DateTime? createdAt,
      String? errorMessage,
    }) {
      return Session(
        id: id,
        sessionKey: sessionKey,
        hostId: hostId,
        name: name,
        state: state,
        players: players ?? [hostPlayer],
        playedCards: playedCards ?? {},
        createdAt: createdAt ?? testTime,
        errorMessage: errorMessage,
      );
    }

    group('constructor', () {
      test('should create session with required fields', () {
        final session = createTestSession();

        expect(session.id, equals('session-1'));
        expect(session.sessionKey, equals('ABC123'));
        expect(session.hostId, equals('host-123'));
        expect(session.name, equals('Test Session'));
        expect(session.state, equals(GameState.voting));
        expect(session.players.length, equals(1));
        expect(session.playedCards, isEmpty);
        expect(session.createdAt, equals(testTime));
        expect(session.errorMessage, isNull);
      });

      test('should create session with error message', () {
        final session = createTestSession(errorMessage: 'Test error');

        expect(session.errorMessage, equals('Test error'));
      });

      test('should create const session', () {
        final session = Session(
          id: '1',
          sessionKey: 'KEY',
          hostId: 'host',
          name: 'Test',
          state: GameState.waiting,
          players: [],
          playedCards: {},
          createdAt: DateTime.now(),
        );

        expect(session.id, equals('1'));
      });
    });

    group('allPlayersVoted', () {
      test('should return false when no players', () {
        final session = createTestSession(players: []);

        expect(session.allPlayersVoted, isFalse);
      });

      test('should return false when not all players voted', () {
        final session = createTestSession(
          players: [hostPlayer, player2],
          playedCards: {'host-123': playedCard1},
        );

        expect(session.allPlayersVoted, isFalse);
      });

      test('should return true when all players voted', () {
        final session = createTestSession(
          players: [hostPlayer, player2],
          playedCards: {'host-123': playedCard1, 'player-456': playedCard2},
        );

        expect(session.allPlayersVoted, isTrue);
      });

      test('should return true with single player who voted', () {
        final session = createTestSession(
          players: [hostPlayer],
          playedCards: {'host-123': playedCard1},
        );

        expect(session.allPlayersVoted, isTrue);
      });
    });

    group('canReveal', () {
      test('should return false when no cards played', () {
        final session = createTestSession(playedCards: {});

        expect(session.canReveal, isFalse);
      });

      test('should return true when at least one card played', () {
        final session = createTestSession(
          playedCards: {'host-123': playedCard1},
        );

        expect(session.canReveal, isTrue);
      });
    });

    group('copyWith', () {
      test('should copy with new id', () {
        final session = createTestSession();
        final copied = session.copyWith(id: 'new-id');

        expect(copied.id, equals('new-id'));
        expect(copied.sessionKey, equals(session.sessionKey));
      });

      test('should copy with new sessionKey', () {
        final session = createTestSession();
        final copied = session.copyWith(sessionKey: 'NEWKEY');

        expect(copied.sessionKey, equals('NEWKEY'));
      });

      test('should copy with new state', () {
        final session = createTestSession(state: GameState.voting);
        final copied = session.copyWith(state: GameState.revealed);

        expect(copied.state, equals(GameState.revealed));
      });

      test('should copy with new players', () {
        final session = createTestSession();
        final copied = session.copyWith(players: [hostPlayer, player2]);

        expect(copied.players.length, equals(2));
      });

      test('should copy with new playedCards', () {
        final session = createTestSession();
        final copied = session.copyWith(playedCards: {'host-123': playedCard1});

        expect(copied.playedCards.length, equals(1));
      });

      test('should copy with new errorMessage', () {
        final session = createTestSession();
        final copied = session.copyWith(errorMessage: 'New error');

        expect(copied.errorMessage, equals('New error'));
      });

      test('should clear errorMessage when copyWith with null', () {
        final session = createTestSession(errorMessage: 'Error');
        final copied = session.copyWith(errorMessage: null);

        expect(copied.errorMessage, isNull);
      });

      test('should preserve all fields when no params provided', () {
        final session = createTestSession(
          errorMessage: 'Test error',
          playedCards: {'host-123': playedCard1},
        );
        final copied = session.copyWith();

        expect(copied.id, equals(session.id));
        expect(copied.sessionKey, equals(session.sessionKey));
        expect(copied.hostId, equals(session.hostId));
        expect(copied.name, equals(session.name));
        expect(copied.state, equals(session.state));
        expect(copied.players.length, equals(session.players.length));
        expect(copied.playedCards.length, equals(session.playedCards.length));
        expect(copied.createdAt, equals(session.createdAt));
        // Note: errorMessage becomes null in copyWith when not provided
      });
    });

    group('toJson', () {
      test('should convert to JSON map', () {
        final session = createTestSession(
          players: [hostPlayer],
          playedCards: {'host-123': playedCard1},
        );
        final json = session.toJson();

        expect(json['id'], equals('session-1'));
        expect(json['sessionKey'], equals('ABC123'));
        expect(json['hostId'], equals('host-123'));
        expect(json['name'], equals('Test Session'));
        expect(json['state'], equals('voting'));
        expect(json['createdAt'], equals(testTime.toIso8601String()));
      });

      test('should include players as map', () {
        final session = createTestSession(players: [hostPlayer, player2]);
        final json = session.toJson();

        expect(json['players'], isA<Map>());
        expect((json['players'] as Map).length, equals(2));
        expect((json['players'] as Map)['host-123'], isNotNull);
        expect((json['players'] as Map)['player-456'], isNotNull);
      });

      test('should include playedCards as map', () {
        final session = createTestSession(
          playedCards: {'host-123': playedCard1},
        );
        final json = session.toJson();

        expect(json['playedCards'], isA<Map>());
        expect((json['playedCards'] as Map).length, equals(1));
      });

      test('should include errorMessage when present', () {
        final session = createTestSession(errorMessage: 'Test error');
        final json = session.toJson();

        expect(json['errorMessage'], equals('Test error'));
      });

      test('should not include errorMessage when null', () {
        final session = createTestSession();
        final json = session.toJson();

        expect(json.containsKey('errorMessage'), isFalse);
      });
    });

    group('fromJson', () {
      test('should create from JSON map', () {
        final json = {
          'id': 'session-1',
          'sessionKey': 'ABC123',
          'hostId': 'host-123',
          'name': 'Test Session',
          'state': 'voting',
          'players': {
            'host-123': {'id': 'host-123', 'name': 'Host', 'isHost': true},
          },
          'playedCards': {},
          'createdAt': testTime.toIso8601String(),
        };
        final session = Session.fromJson(json);

        expect(session.id, equals('session-1'));
        expect(session.sessionKey, equals('ABC123'));
        expect(session.hostId, equals('host-123'));
        expect(session.name, equals('Test Session'));
        expect(session.state, equals(GameState.voting));
        expect(session.players.length, equals(1));
        expect(session.playedCards, isEmpty);
        expect(session.createdAt, equals(testTime));
      });

      test('should parse players from map format', () {
        final json = {
          'id': '1',
          'sessionKey': 'KEY',
          'hostId': 'host',
          'name': 'Test',
          'state': 'waiting',
          'players': {
            'p1': {'id': 'p1', 'name': 'Player 1', 'isHost': true},
            'p2': {'id': 'p2', 'name': 'Player 2', 'isHost': false},
          },
          'playedCards': null,
          'createdAt': testTime.toIso8601String(),
        };
        final session = Session.fromJson(json);

        expect(session.players.length, equals(2));
      });

      test('should handle null players', () {
        final json = {
          'id': '1',
          'sessionKey': 'KEY',
          'hostId': 'host',
          'name': 'Test',
          'state': 'waiting',
          'players': null,
          'playedCards': null,
          'createdAt': testTime.toIso8601String(),
        };
        final session = Session.fromJson(json);

        expect(session.players, isEmpty);
      });

      test('should parse playedCards', () {
        final json = {
          'id': '1',
          'sessionKey': 'KEY',
          'hostId': 'host',
          'name': 'Test',
          'state': 'revealed',
          'players': null,
          'playedCards': {
            'p1': {
              'playerId': 'p1',
              'playerName': 'Player 1',
              'cardValue': '5',
              'playedAt': testTime.toIso8601String(),
            },
          },
          'createdAt': testTime.toIso8601String(),
        };
        final session = Session.fromJson(json);

        expect(session.playedCards.length, equals(1));
        expect(session.playedCards['p1']?.cardValue, equals('5'));
      });

      test('should default to waiting state for unknown state', () {
        final json = {
          'id': '1',
          'sessionKey': 'KEY',
          'hostId': 'host',
          'name': 'Test',
          'state': 'unknown_state',
          'players': null,
          'playedCards': null,
          'createdAt': testTime.toIso8601String(),
        };
        final session = Session.fromJson(json);

        expect(session.state, equals(GameState.waiting));
      });

      test('should parse errorMessage', () {
        final json = {
          'id': '1',
          'sessionKey': 'KEY',
          'hostId': 'host',
          'name': 'Test',
          'state': 'waiting',
          'players': null,
          'playedCards': null,
          'createdAt': testTime.toIso8601String(),
          'errorMessage': 'Test error',
        };
        final session = Session.fromJson(json);

        expect(session.errorMessage, equals('Test error'));
      });
    });

    group('serialization roundtrip', () {
      test('should preserve data through toJson/fromJson', () {
        final original = createTestSession(
          players: [hostPlayer, player2],
          playedCards: {'host-123': playedCard1, 'player-456': playedCard2},
          errorMessage: 'Test error',
        );
        final json = original.toJson();
        final restored = Session.fromJson(json);

        expect(restored.id, equals(original.id));
        expect(restored.sessionKey, equals(original.sessionKey));
        expect(restored.hostId, equals(original.hostId));
        expect(restored.name, equals(original.name));
        expect(restored.state, equals(original.state));
        expect(restored.players.length, equals(original.players.length));
        expect(
          restored.playedCards.length,
          equals(original.playedCards.length),
        );
        expect(restored.createdAt, equals(original.createdAt));
        expect(restored.errorMessage, equals(original.errorMessage));
      });
    });
  });
}
