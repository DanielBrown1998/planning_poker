import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:planning_poker/core/result/result.dart';
import 'package:planning_poker/domain/repositories/session_repository.dart';
import 'package:planning_poker/domain/usecases/reset_round_usecase.dart';

import 'reset_round_usecase_test.mocks.dart';

@GenerateMocks([SessionRepository])
void main() {
  late ResetRoundUseCase useCase;
  late MockSessionRepository mockRepository;

  setUp(() {
    mockRepository = MockSessionRepository();
    useCase = ResetRoundUseCase(mockRepository);
  });

  group('ResetRoundUseCase', () {
    test('should return success when repository succeeds', () async {
      when(mockRepository.resetRound(any)).thenAnswer((_) async {});

      final result = await useCase.execute('session-1');

      expect(result, isA<Success<void>>());

      verify(mockRepository.resetRound('session-1')).called(1);
    });

    test('should return failure when repository throws exception', () async {
      when(
        mockRepository.resetRound(any),
      ).thenThrow(Exception('Database error'));

      final result = await useCase.execute('session-1');

      expect(result, isA<Failure<void>>());
      result.when(
        success: (_) => fail('Should not succeed'),
        failure: (message) {
          expect(message, contains('Falha ao resetar rodada'));
        },
      );
    });

    test('should pass sessionId to repository', () async {
      when(mockRepository.resetRound(any)).thenAnswer((_) async {});

      await useCase.execute('my-session-id');

      verify(mockRepository.resetRound('my-session-id')).called(1);
    });
  });
}
