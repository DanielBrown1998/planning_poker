import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:planning_poker/core/result/result.dart';
import 'package:planning_poker/domain/entities/entities.dart';
import 'package:planning_poker/domain/usecases/usecases.dart';
import 'package:planning_poker/presentation/commands/home_commands.dart';

import 'home_commands_test.mocks.dart';

@GenerateMocks([CreateSessionUseCase, JoinSessionUseCase])
void main() {
  setUpAll(() {
    // Provide dummy values for Result types
    provideDummy<Result<Session>>(Result.failure('dummy'));
    provideDummy<Result<Session?>>(Result.failure('dummy'));
  });

  group('CreateSessionCommand', () {
    late MockCreateSessionUseCase mockUseCase;

    setUp(() {
      mockUseCase = MockCreateSessionUseCase();
    });

    final testPlayer = Player(id: 'player-1', name: 'Test Host', isHost: true);
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

    test('should execute successfully and return session', () async {
      when(
        mockUseCase.execute(
          sessionName: anyNamed('sessionName'),
          host: anyNamed('host'),
        ),
      ).thenAnswer((_) async => Result.success(testSession));

      final command = CreateSessionCommand(
        useCase: mockUseCase,
        sessionName: 'Test Session',
        host: testPlayer,
      );

      final result = await command.execute();

      expect(result, equals(testSession));
      expect(command.hasError, isFalse);
      expect(command.result, equals(testSession));
    });

    test('should set error when use case returns failure', () async {
      when(
        mockUseCase.execute(
          sessionName: anyNamed('sessionName'),
          host: anyNamed('host'),
        ),
      ).thenAnswer((_) async => Result.failure('Failed to create session'));

      final command = CreateSessionCommand(
        useCase: mockUseCase,
        sessionName: 'Test Session',
        host: testPlayer,
      );

      final result = await command.execute();

      expect(result, isNull);
      expect(command.hasError, isTrue);
      expect(command.error, contains('Failed to create session'));
    });

    test('should expose sessionName and host', () {
      final command = CreateSessionCommand(
        useCase: mockUseCase,
        sessionName: 'My Session',
        host: testPlayer,
      );

      expect(command.sessionName, equals('My Session'));
      expect(command.host, equals(testPlayer));
    });
  });

  group('JoinSessionCommand', () {
    late MockJoinSessionUseCase mockUseCase;

    setUp(() {
      mockUseCase = MockJoinSessionUseCase();
    });

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

    test('should execute successfully and return session', () async {
      when(
        mockUseCase.execute(
          sessionKey: anyNamed('sessionKey'),
          player: anyNamed('player'),
        ),
      ).thenAnswer((_) async => Result.success(testSession));

      final command = JoinSessionCommand(
        useCase: mockUseCase,
        sessionKey: 'ABC123',
        player: testPlayer,
      );

      final result = await command.execute();

      expect(result, equals(testSession));
      expect(command.hasError, isFalse);
    });

    test('should set error when use case returns failure', () async {
      when(
        mockUseCase.execute(
          sessionKey: anyNamed('sessionKey'),
          player: anyNamed('player'),
        ),
      ).thenAnswer((_) async => Result.failure('Session not found'));

      final command = JoinSessionCommand(
        useCase: mockUseCase,
        sessionKey: 'INVALID',
        player: testPlayer,
      );

      final result = await command.execute();

      expect(result, isNull);
      expect(command.hasError, isTrue);
      expect(command.error, contains('Session not found'));
    });

    test('should expose sessionKey and player', () {
      final command = JoinSessionCommand(
        useCase: mockUseCase,
        sessionKey: 'XYZ789',
        player: testPlayer,
      );

      expect(command.sessionKey, equals('XYZ789'));
      expect(command.player, equals(testPlayer));
    });
  });
}
