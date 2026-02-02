import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:planning_poker/core/result/result.dart';
import 'package:planning_poker/domain/repositories/session_repository.dart';
import 'package:planning_poker/domain/usecases/reveal_cards_usecase.dart';

import 'reveal_cards_usecase_test.mocks.dart';

@GenerateMocks([SessionRepository])
void main() {
  late RevealCardsUseCase useCase;
  late MockSessionRepository mockRepository;

  setUp(() {
    mockRepository = MockSessionRepository();
    useCase = RevealCardsUseCase(mockRepository);
  });

  group('RevealCardsUseCase', () {
    test('should return success when repository succeeds', () async {
      when(mockRepository.revealCards(any)).thenAnswer((_) async {});

      final result = await useCase.execute('session-1');

      expect(result, isA<Success<void>>());

      verify(mockRepository.revealCards('session-1')).called(1);
    });

    test('should return failure when repository throws exception', () async {
      when(
        mockRepository.revealCards(any),
      ).thenThrow(Exception('Database error'));

      final result = await useCase.execute('session-1');

      expect(result, isA<Failure<void>>());
      result.when(
        success: (_) => fail('Should not succeed'),
        failure: (message) {
          expect(message, contains('Falha ao revelar cartas'));
        },
      );
    });

    test('should pass sessionId to repository', () async {
      when(mockRepository.revealCards(any)).thenAnswer((_) async {});

      await useCase.execute('my-session-id');

      verify(mockRepository.revealCards('my-session-id')).called(1);
    });
  });
}
