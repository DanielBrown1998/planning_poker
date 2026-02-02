import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:planning_poker/data/datasources/firebase_session_datasource.dart';
import 'package:planning_poker/data/repositories/firebase_session_repository.dart';
import 'package:planning_poker/domain/entities/entities.dart';
import 'package:uuid/uuid.dart';

import 'firebase_session_repository_test.mocks.dart';

@GenerateMocks([FirebaseSessionDataSource, Uuid])
void main() {
  late FirebaseSessionRepository repository;
  late MockFirebaseSessionDataSource mockDataSource;
  late MockUuid mockUuid;

  setUp(() {
    mockDataSource = MockFirebaseSessionDataSource();
    mockUuid = MockUuid();
    repository = FirebaseSessionRepository(
      dataSource: mockDataSource,
      uuid: mockUuid,
    );
  });

  group('FirebaseSessionRepository', () {
    final testPlayer = Player(
      id: 'player-1',
      name: 'Test Player',
      isHost: true,
    );
    final testSession = Session(
      id: 'session-1',
      sessionKey: 'ABC123',
      hostId: 'player-1',
      name: 'Test Session',
      state: GameState.voting,
      players: [testPlayer],
      playedCards: {},
      createdAt: DateTime(2024, 1, 15),
    );

    group('createSession', () {
      test('should create session with generated id and key', () async {
        when(mockUuid.v4()).thenReturn('generated-uuid');
        when(mockDataSource.createSession(any)).thenAnswer((_) async {});

        final result = await repository.createSession(
          name: 'Test Session',
          host: testPlayer,
        );

        expect(result.id, equals('generated-uuid'));
        expect(result.name, equals('Test Session'));
        expect(result.hostId, equals('player-1'));
        expect(result.state, equals(GameState.voting));
        expect(result.players.first.isHost, isTrue);
        expect(result.sessionKey.length, equals(6));
      });

      test('should call datasource createSession', () async {
        when(mockUuid.v4()).thenReturn('generated-uuid');
        when(mockDataSource.createSession(any)).thenAnswer((_) async {});

        await repository.createSession(name: 'Test Session', host: testPlayer);

        verify(mockDataSource.createSession(any)).called(1);
      });
    });

    group('joinSession', () {
      final joiningPlayer = Player(id: 'player-2', name: 'Joining Player');

      test('should return null when session not found by key', () async {
        when(
          mockDataSource.getSessionIdByKey(any),
        ).thenAnswer((_) async => null);

        final result = await repository.joinSession(
          sessionKey: 'INVALID',
          player: joiningPlayer,
        );

        expect(result, isNull);
      });

      test('should return null when session not found by id', () async {
        when(
          mockDataSource.getSessionIdByKey(any),
        ).thenAnswer((_) async => 'session-id');
        when(mockDataSource.getSession(any)).thenAnswer((_) async => null);

        final result = await repository.joinSession(
          sessionKey: 'ABC123',
          player: joiningPlayer,
        );

        expect(result, isNull);
      });

      test('should add player and return session', () async {
        when(
          mockDataSource.getSessionIdByKey(any),
        ).thenAnswer((_) async => 'session-1');
        when(
          mockDataSource.getSession(any),
        ).thenAnswer((_) async => testSession);
        when(mockDataSource.addPlayer(any, any)).thenAnswer((_) async {});

        final result = await repository.joinSession(
          sessionKey: 'ABC123',
          player: joiningPlayer,
        );

        expect(result, isNotNull);
        verify(mockDataSource.addPlayer('session-1', joiningPlayer)).called(1);
      });

      test('should not add player if already in session', () async {
        final sessionWithPlayer = testSession.copyWith(
          players: [testPlayer, joiningPlayer],
        );

        when(
          mockDataSource.getSessionIdByKey(any),
        ).thenAnswer((_) async => 'session-1');
        when(
          mockDataSource.getSession(any),
        ).thenAnswer((_) async => sessionWithPlayer);

        await repository.joinSession(
          sessionKey: 'ABC123',
          player: joiningPlayer,
        );

        verifyNever(mockDataSource.addPlayer(any, any));
      });

      test('should convert session key to uppercase', () async {
        when(
          mockDataSource.getSessionIdByKey(any),
        ).thenAnswer((_) async => null);

        await repository.joinSession(
          sessionKey: 'abc123',
          player: joiningPlayer,
        );

        verify(mockDataSource.getSessionIdByKey('ABC123')).called(1);
      });
    });

    group('leaveSession', () {
      test('should remove player from session', () async {
        when(
          mockDataSource.getSession(any),
        ).thenAnswer((_) async => testSession);
        when(mockDataSource.removePlayer(any, any)).thenAnswer((_) async {});

        await repository.leaveSession(
          sessionId: 'session-1',
          playerId: 'player-2',
        );

        verify(mockDataSource.removePlayer('session-1', 'player-2')).called(1);
      });

      test('should delete session when host leaves', () async {
        when(
          mockDataSource.getSession(any),
        ).thenAnswer((_) async => testSession);
        when(mockDataSource.removePlayer(any, any)).thenAnswer((_) async {});
        when(mockDataSource.deleteSession(any, any)).thenAnswer((_) async {});

        await repository.leaveSession(
          sessionId: 'session-1',
          playerId: 'player-1', // host
        );

        verify(mockDataSource.deleteSession('session-1', 'ABC123')).called(1);
      });

      test('should do nothing when session not found', () async {
        when(mockDataSource.getSession(any)).thenAnswer((_) async => null);

        await repository.leaveSession(
          sessionId: 'session-1',
          playerId: 'player-1',
        );

        verifyNever(mockDataSource.removePlayer(any, any));
      });
    });

    group('watchSession', () {
      test('should delegate to datasource', () {
        when(
          mockDataSource.watchSession(any),
        ).thenAnswer((_) => Stream.value(testSession));

        final stream = repository.watchSession('session-1');

        expect(stream, isA<Stream<Session?>>());
        verify(mockDataSource.watchSession('session-1')).called(1);
      });
    });

    group('getSessionByKey', () {
      test('should return null when session key not found', () async {
        when(
          mockDataSource.getSessionIdByKey(any),
        ).thenAnswer((_) async => null);

        final result = await repository.getSessionByKey('INVALID');

        expect(result, isNull);
      });

      test('should return session when found', () async {
        when(
          mockDataSource.getSessionIdByKey(any),
        ).thenAnswer((_) async => 'session-1');
        when(
          mockDataSource.getSession(any),
        ).thenAnswer((_) async => testSession);

        final result = await repository.getSessionByKey('ABC123');

        expect(result, equals(testSession));
      });

      test('should convert key to uppercase', () async {
        when(
          mockDataSource.getSessionIdByKey(any),
        ).thenAnswer((_) async => null);

        await repository.getSessionByKey('abc123');

        verify(mockDataSource.getSessionIdByKey('ABC123')).called(1);
      });
    });

    group('playCard', () {
      test('should create PlayedCard and call datasource', () async {
        when(mockDataSource.playCard(any, any)).thenAnswer((_) async {});

        await repository.playCard(
          sessionId: 'session-1',
          playerId: 'player-1',
          playerName: 'Test Player',
          cardValue: '5',
        );

        verify(
          mockDataSource.playCard(
            'session-1',
            argThat(
              isA<PlayedCard>()
                  .having((c) => c.playerId, 'playerId', 'player-1')
                  .having((c) => c.playerName, 'playerName', 'Test Player')
                  .having((c) => c.cardValue, 'cardValue', '5'),
            ),
          ),
        ).called(1);
      });
    });

    group('revealCards', () {
      test('should update session state to revealed', () async {
        when(
          mockDataSource.updateSessionState(any, any),
        ).thenAnswer((_) async {});

        await repository.revealCards('session-1');

        verify(
          mockDataSource.updateSessionState('session-1', GameState.revealed),
        ).called(1);
      });
    });

    group('resetRound', () {
      test('should clear played cards', () async {
        when(mockDataSource.clearPlayedCards(any)).thenAnswer((_) async {});

        await repository.resetRound('session-1');

        verify(mockDataSource.clearPlayedCards('session-1')).called(1);
      });
    });

    group('deleteSession', () {
      test('should delete session when found', () async {
        when(
          mockDataSource.getSession(any),
        ).thenAnswer((_) async => testSession);
        when(mockDataSource.deleteSession(any, any)).thenAnswer((_) async {});

        await repository.deleteSession('session-1');

        verify(mockDataSource.deleteSession('session-1', 'ABC123')).called(1);
      });

      test('should do nothing when session not found', () async {
        when(mockDataSource.getSession(any)).thenAnswer((_) async => null);

        await repository.deleteSession('session-1');

        verifyNever(mockDataSource.deleteSession(any, any));
      });
    });
  });
}
