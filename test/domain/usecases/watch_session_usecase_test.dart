import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:planning_poker/domain/entities/entities.dart';
import 'package:planning_poker/domain/repositories/session_repository.dart';
import 'package:planning_poker/domain/usecases/watch_session_usecase.dart';

import 'watch_session_usecase_test.mocks.dart';

@GenerateMocks([SessionRepository])
void main() {
  late WatchSessionUseCase useCase;
  late MockSessionRepository mockRepository;

  setUp(() {
    mockRepository = MockSessionRepository();
    useCase = WatchSessionUseCase(mockRepository);
  });

  group('WatchSessionUseCase', () {
    final testSession = Session(
      id: 'session-1',
      sessionKey: 'ABC123',
      hostId: 'player-1',
      name: 'Test Session',
      state: GameState.voting,
      players: [Player(id: 'player-1', name: 'Host', isHost: true)],
      playedCards: {},
      createdAt: DateTime(2024, 1, 15),
    );

    test('should return stream from repository', () {
      when(
        mockRepository.watchSession(any),
      ).thenAnswer((_) => Stream.value(testSession));

      final stream = useCase.execute('session-1');

      expect(stream, isA<Stream<Session?>>());
      verify(mockRepository.watchSession('session-1')).called(1);
    });

    test('should emit session updates', () async {
      final updatedSession = testSession.copyWith(state: GameState.revealed);

      when(
        mockRepository.watchSession(any),
      ).thenAnswer((_) => Stream.fromIterable([testSession, updatedSession]));

      final stream = useCase.execute('session-1');
      final sessions = await stream.toList();

      expect(sessions.length, equals(2));
      expect(sessions[0]?.state, equals(GameState.voting));
      expect(sessions[1]?.state, equals(GameState.revealed));
    });

    test('should emit null when session is deleted', () async {
      when(
        mockRepository.watchSession(any),
      ).thenAnswer((_) => Stream.fromIterable([testSession, null]));

      final stream = useCase.execute('session-1');
      final sessions = await stream.toList();

      expect(sessions.length, equals(2));
      expect(sessions[0], isNotNull);
      expect(sessions[1], isNull);
    });

    test('should pass sessionId to repository', () {
      when(
        mockRepository.watchSession(any),
      ).thenAnswer((_) => Stream.value(testSession));

      useCase.execute('my-session-id');

      verify(mockRepository.watchSession('my-session-id')).called(1);
    });

    test('should forward errors from stream', () async {
      when(
        mockRepository.watchSession(any),
      ).thenAnswer((_) => Stream.error(Exception('Connection lost')));

      final stream = useCase.execute('session-1');

      expect(stream, emitsError(isA<Exception>()));
    });
  });
}
