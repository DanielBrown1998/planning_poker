import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:planning_poker/core/result/result.dart';
import 'package:planning_poker/domain/entities/entities.dart';
import 'package:planning_poker/domain/repositories/session_repository.dart';
import 'package:planning_poker/domain/usecases/create_session_usecase.dart';

import 'create_session_usecase_test.mocks.dart';

@GenerateMocks([SessionRepository])
void main() {
  late CreateSessionUseCase useCase;
  late MockSessionRepository mockRepository;

  setUp(() {
    mockRepository = MockSessionRepository();
    useCase = CreateSessionUseCase(mockRepository);
  });

  group('CreateSessionUseCase', () {
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

    test(
      'should return success with session when repository succeeds',
      () async {
        when(
          mockRepository.createSession(
            name: anyNamed('name'),
            host: anyNamed('host'),
          ),
        ).thenAnswer((_) async => testSession);

        final result = await useCase.execute(
          sessionName: 'Test Session',
          host: testPlayer,
        );

        expect(result, isA<Success<Session>>());
        result.when(
          success: (session) {
            expect(session.id, equals('session-1'));
            expect(session.name, equals('Test Session'));
          },
          failure: (_) => fail('Should not fail'),
        );

        verify(
          mockRepository.createSession(name: 'Test Session', host: testPlayer),
        ).called(1);
      },
    );

    test('should return failure when repository throws exception', () async {
      when(
        mockRepository.createSession(
          name: anyNamed('name'),
          host: anyNamed('host'),
        ),
      ).thenThrow(Exception('Database error'));

      final result = await useCase.execute(
        sessionName: 'Test Session',
        host: testPlayer,
      );

      expect(result, isA<Failure<Session>>());
      result.when(
        success: (_) => fail('Should not succeed'),
        failure: (message) {
          expect(message, contains('Falha ao criar sessão'));
        },
      );
    });

    test('should pass correct parameters to repository', () async {
      when(
        mockRepository.createSession(
          name: anyNamed('name'),
          host: anyNamed('host'),
        ),
      ).thenAnswer((_) async => testSession);

      await useCase.execute(sessionName: 'My Session', host: testPlayer);

      verify(
        mockRepository.createSession(name: 'My Session', host: testPlayer),
      ).called(1);
    });
  });
}
