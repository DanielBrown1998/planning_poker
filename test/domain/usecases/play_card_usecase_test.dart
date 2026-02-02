import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:planning_poker/core/result/result.dart';
import 'package:planning_poker/domain/repositories/session_repository.dart';
import 'package:planning_poker/domain/usecases/play_card_usecase.dart';

import 'play_card_usecase_test.mocks.dart';

@GenerateMocks([SessionRepository])
void main() {
  late PlayCardUseCase useCase;
  late MockSessionRepository mockRepository;

  setUp(() {
    mockRepository = MockSessionRepository();
    useCase = PlayCardUseCase(mockRepository);
  });

  group('PlayCardUseCase', () {
    test('should return success when repository succeeds', () async {
      when(
        mockRepository.playCard(
          sessionId: anyNamed('sessionId'),
          playerId: anyNamed('playerId'),
          playerName: anyNamed('playerName'),
          cardValue: anyNamed('cardValue'),
        ),
      ).thenAnswer((_) async {});

      final result = await useCase.execute(
        sessionId: 'session-1',
        playerId: 'player-1',
        playerName: 'Test Player',
        cardValue: '5',
      );

      expect(result, isA<Success<void>>());

      verify(
        mockRepository.playCard(
          sessionId: 'session-1',
          playerId: 'player-1',
          playerName: 'Test Player',
          cardValue: '5',
        ),
      ).called(1);
    });

    test('should return failure when repository throws exception', () async {
      when(
        mockRepository.playCard(
          sessionId: anyNamed('sessionId'),
          playerId: anyNamed('playerId'),
          playerName: anyNamed('playerName'),
          cardValue: anyNamed('cardValue'),
        ),
      ).thenThrow(Exception('Database error'));

      final result = await useCase.execute(
        sessionId: 'session-1',
        playerId: 'player-1',
        playerName: 'Test Player',
        cardValue: '5',
      );

      expect(result, isA<Failure<void>>());
      result.when(
        success: (_) => fail('Should not succeed'),
        failure: (message) {
          expect(message, contains('Falha ao jogar carta'));
        },
      );
    });

    test('should pass all parameters correctly to repository', () async {
      when(
        mockRepository.playCard(
          sessionId: anyNamed('sessionId'),
          playerId: anyNamed('playerId'),
          playerName: anyNamed('playerName'),
          cardValue: anyNamed('cardValue'),
        ),
      ).thenAnswer((_) async {});

      await useCase.execute(
        sessionId: 'my-session',
        playerId: 'my-player',
        playerName: 'John Doe',
        cardValue: '13',
      );

      verify(
        mockRepository.playCard(
          sessionId: 'my-session',
          playerId: 'my-player',
          playerName: 'John Doe',
          cardValue: '13',
        ),
      ).called(1);
    });

    test('should handle special card values', () async {
      when(
        mockRepository.playCard(
          sessionId: anyNamed('sessionId'),
          playerId: anyNamed('playerId'),
          playerName: anyNamed('playerName'),
          cardValue: anyNamed('cardValue'),
        ),
      ).thenAnswer((_) async {});

      final result = await useCase.execute(
        sessionId: 'session-1',
        playerId: 'player-1',
        playerName: 'Test Player',
        cardValue: '☕',
      );

      expect(result, isA<Success<void>>());

      verify(
        mockRepository.playCard(
          sessionId: anyNamed('sessionId'),
          playerId: anyNamed('playerId'),
          playerName: anyNamed('playerName'),
          cardValue: '☕',
        ),
      ).called(1);
    });
  });
}
