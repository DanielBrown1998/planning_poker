import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:planning_poker/core/result/result.dart';
import 'package:planning_poker/domain/usecases/usecases.dart';
import 'package:planning_poker/presentation/commands/game_commands.dart';

import 'game_commands_test.mocks.dart';

@GenerateMocks([
  PlayCardUseCase,
  RevealCardsUseCase,
  ResetRoundUseCase,
  LeaveSessionUseCase,
])
void main() {
  setUpAll(() {
    // Provide dummy values for Result types
    provideDummy<Result<void>>(Result.success(null));
  });

  group('PlayCardCommand', () {
    late MockPlayCardUseCase mockUseCase;

    setUp(() {
      mockUseCase = MockPlayCardUseCase();
    });

    test('should execute successfully', () async {
      when(
        mockUseCase.execute(
          sessionId: anyNamed('sessionId'),
          playerId: anyNamed('playerId'),
          playerName: anyNamed('playerName'),
          cardValue: anyNamed('cardValue'),
        ),
      ).thenAnswer((_) async => Result.success(null));

      final command = PlayCardCommand(
        useCase: mockUseCase,
        sessionId: 'session-1',
        playerId: 'player-1',
        playerName: 'Test Player',
        cardValue: '5',
      );

      await command.execute();

      expect(command.hasError, isFalse);
      verify(
        mockUseCase.execute(
          sessionId: 'session-1',
          playerId: 'player-1',
          playerName: 'Test Player',
          cardValue: '5',
        ),
      ).called(1);
    });

    test('should set error when use case returns failure', () async {
      when(
        mockUseCase.execute(
          sessionId: anyNamed('sessionId'),
          playerId: anyNamed('playerId'),
          playerName: anyNamed('playerName'),
          cardValue: anyNamed('cardValue'),
        ),
      ).thenAnswer((_) async => Result.failure('Failed to play card'));

      final command = PlayCardCommand(
        useCase: mockUseCase,
        sessionId: 'session-1',
        playerId: 'player-1',
        playerName: 'Test Player',
        cardValue: '5',
      );

      await command.execute();

      expect(command.hasError, isTrue);
      expect(command.error, contains('Failed to play card'));
    });

    test('should expose command parameters', () {
      final command = PlayCardCommand(
        useCase: mockUseCase,
        sessionId: 'session-1',
        playerId: 'player-1',
        playerName: 'Test Player',
        cardValue: '13',
      );

      expect(command.sessionId, equals('session-1'));
      expect(command.playerId, equals('player-1'));
      expect(command.playerName, equals('Test Player'));
      expect(command.cardValue, equals('13'));
    });
  });

  group('RevealCardsCommand', () {
    late MockRevealCardsUseCase mockUseCase;

    setUp(() {
      mockUseCase = MockRevealCardsUseCase();
    });

    test('should execute successfully', () async {
      when(
        mockUseCase.execute(any),
      ).thenAnswer((_) async => Result.success(null));

      final command = RevealCardsCommand(
        useCase: mockUseCase,
        sessionId: 'session-1',
      );

      await command.execute();

      expect(command.hasError, isFalse);
      verify(mockUseCase.execute('session-1')).called(1);
    });

    test('should set error when use case returns failure', () async {
      when(
        mockUseCase.execute(any),
      ).thenAnswer((_) async => Result.failure('Failed to reveal cards'));

      final command = RevealCardsCommand(
        useCase: mockUseCase,
        sessionId: 'session-1',
      );

      await command.execute();

      expect(command.hasError, isTrue);
      expect(command.error, contains('Failed to reveal cards'));
    });

    test('should expose sessionId', () {
      final command = RevealCardsCommand(
        useCase: mockUseCase,
        sessionId: 'my-session',
      );

      expect(command.sessionId, equals('my-session'));
    });
  });

  group('ResetRoundCommand', () {
    late MockResetRoundUseCase mockUseCase;

    setUp(() {
      mockUseCase = MockResetRoundUseCase();
    });

    test('should execute successfully', () async {
      when(
        mockUseCase.execute(any),
      ).thenAnswer((_) async => Result.success(null));

      final command = ResetRoundCommand(
        useCase: mockUseCase,
        sessionId: 'session-1',
      );

      await command.execute();

      expect(command.hasError, isFalse);
      verify(mockUseCase.execute('session-1')).called(1);
    });

    test('should set error when use case returns failure', () async {
      when(
        mockUseCase.execute(any),
      ).thenAnswer((_) async => Result.failure('Failed to reset round'));

      final command = ResetRoundCommand(
        useCase: mockUseCase,
        sessionId: 'session-1',
      );

      await command.execute();

      expect(command.hasError, isTrue);
      expect(command.error, contains('Failed to reset round'));
    });

    test('should expose sessionId', () {
      final command = ResetRoundCommand(
        useCase: mockUseCase,
        sessionId: 'my-session',
      );

      expect(command.sessionId, equals('my-session'));
    });
  });

  group('LeaveSessionCommand', () {
    late MockLeaveSessionUseCase mockUseCase;

    setUp(() {
      mockUseCase = MockLeaveSessionUseCase();
    });

    test('should execute successfully', () async {
      when(
        mockUseCase.execute(
          sessionId: anyNamed('sessionId'),
          playerId: anyNamed('playerId'),
        ),
      ).thenAnswer((_) async => Result.success(null));

      final command = LeaveSessionCommand(
        useCase: mockUseCase,
        sessionId: 'session-1',
        playerId: 'player-1',
      );

      await command.execute();

      expect(command.hasError, isFalse);
      verify(
        mockUseCase.execute(sessionId: 'session-1', playerId: 'player-1'),
      ).called(1);
    });

    test('should set error when use case returns failure', () async {
      when(
        mockUseCase.execute(
          sessionId: anyNamed('sessionId'),
          playerId: anyNamed('playerId'),
        ),
      ).thenAnswer((_) async => Result.failure('Failed to leave session'));

      final command = LeaveSessionCommand(
        useCase: mockUseCase,
        sessionId: 'session-1',
        playerId: 'player-1',
      );

      await command.execute();

      expect(command.hasError, isTrue);
      expect(command.error, contains('Failed to leave session'));
    });

    test('should expose sessionId and playerId', () {
      final command = LeaveSessionCommand(
        useCase: mockUseCase,
        sessionId: 'my-session',
        playerId: 'my-player',
      );

      expect(command.sessionId, equals('my-session'));
      expect(command.playerId, equals('my-player'));
    });
  });
}
