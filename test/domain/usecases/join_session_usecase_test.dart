import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:planning_poker/core/result/result.dart';
import 'package:planning_poker/domain/entities/entities.dart';
import 'package:planning_poker/domain/repositories/session_repository.dart';
import 'package:planning_poker/domain/usecases/join_session_usecase.dart';

import 'join_session_usecase_test.mocks.dart';

@GenerateMocks([SessionRepository])
void main() {
  late JoinSessionUseCase useCase;
  late MockSessionRepository mockRepository;

  setUp(() {
    mockRepository = MockSessionRepository();
    useCase = JoinSessionUseCase(mockRepository);
  });

  group('JoinSessionUseCase', () {
    final testPlayer = Player(id: 'player-2', name: 'Joining Player');
    final testSession = Session(
      id: 'session-1',
      sessionKey: 'ABC123',
      hostId: 'player-1',
      name: 'Test Session',
      state: GameState.voting,
      players: [
        Player(id: 'player-1', name: 'Host', isHost: true),
        testPlayer,
      ],
      playedCards: {},
      createdAt: DateTime(2024, 1, 15),
    );

    test('should return success with session when found', () async {
      when(
        mockRepository.joinSession(
          sessionKey: anyNamed('sessionKey'),
          player: anyNamed('player'),
        ),
      ).thenAnswer((_) async => testSession);

      final result = await useCase.execute(
        sessionKey: 'ABC123',
        player: testPlayer,
      );

      expect(result, isA<Success<Session>>());
      result.when(
        success: (session) {
          expect(session.sessionKey, equals('ABC123'));
          expect(session.players.length, equals(2));
        },
        failure: (_) => fail('Should not fail'),
      );
    });

    test('should return failure when session not found', () async {
      when(
        mockRepository.joinSession(
          sessionKey: anyNamed('sessionKey'),
          player: anyNamed('player'),
        ),
      ).thenAnswer((_) async => null);

      final result = await useCase.execute(
        sessionKey: 'INVALID',
        player: testPlayer,
      );

      expect(result, isA<Failure<Session>>());
      result.when(
        success: (_) => fail('Should not succeed'),
        failure: (message) {
          expect(message, contains('Sessão não encontrada'));
          expect(message, contains('INVALID'));
        },
      );
    });

    test('should return failure when repository throws exception', () async {
      when(
        mockRepository.joinSession(
          sessionKey: anyNamed('sessionKey'),
          player: anyNamed('player'),
        ),
      ).thenThrow(Exception('Network error'));

      final result = await useCase.execute(
        sessionKey: 'ABC123',
        player: testPlayer,
      );

      expect(result, isA<Failure<Session>>());
      result.when(
        success: (_) => fail('Should not succeed'),
        failure: (message) {
          expect(message, contains('Falha ao entrar na sessão'));
        },
      );
    });

    test('should pass correct parameters to repository', () async {
      when(
        mockRepository.joinSession(
          sessionKey: anyNamed('sessionKey'),
          player: anyNamed('player'),
        ),
      ).thenAnswer((_) async => testSession);

      await useCase.execute(sessionKey: 'XYZ789', player: testPlayer);

      verify(
        mockRepository.joinSession(sessionKey: 'XYZ789', player: testPlayer),
      ).called(1);
    });
  });
}
