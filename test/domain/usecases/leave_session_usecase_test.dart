import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:planning_poker/core/result/result.dart';
import 'package:planning_poker/domain/repositories/session_repository.dart';
import 'package:planning_poker/domain/usecases/leave_session_usecase.dart';

import 'leave_session_usecase_test.mocks.dart';

@GenerateMocks([SessionRepository])
void main() {
  late LeaveSessionUseCase useCase;
  late MockSessionRepository mockRepository;

  setUp(() {
    mockRepository = MockSessionRepository();
    useCase = LeaveSessionUseCase(mockRepository);
  });

  group('LeaveSessionUseCase', () {
    test('should return success when repository succeeds', () async {
      when(
        mockRepository.leaveSession(
          sessionId: anyNamed('sessionId'),
          playerId: anyNamed('playerId'),
        ),
      ).thenAnswer((_) async {});

      final result = await useCase.execute(
        sessionId: 'session-1',
        playerId: 'player-1',
      );

      expect(result, isA<Success<void>>());

      verify(
        mockRepository.leaveSession(
          sessionId: 'session-1',
          playerId: 'player-1',
        ),
      ).called(1);
    });

    test('should return failure when repository throws exception', () async {
      when(
        mockRepository.leaveSession(
          sessionId: anyNamed('sessionId'),
          playerId: anyNamed('playerId'),
        ),
      ).thenThrow(Exception('Database error'));

      final result = await useCase.execute(
        sessionId: 'session-1',
        playerId: 'player-1',
      );

      expect(result, isA<Failure<void>>());
      result.when(
        success: (_) => fail('Should not succeed'),
        failure: (message) {
          expect(message, contains('Falha ao sair da sessão'));
        },
      );
    });

    test('should pass correct parameters to repository', () async {
      when(
        mockRepository.leaveSession(
          sessionId: anyNamed('sessionId'),
          playerId: anyNamed('playerId'),
        ),
      ).thenAnswer((_) async {});

      await useCase.execute(sessionId: 'my-session', playerId: 'my-player');

      verify(
        mockRepository.leaveSession(
          sessionId: 'my-session',
          playerId: 'my-player',
        ),
      ).called(1);
    });
  });
}
