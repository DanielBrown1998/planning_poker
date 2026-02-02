import 'package:flutter_test/flutter_test.dart';
import 'package:planning_poker/presentation/state/game_state.dart';
import 'package:planning_poker/domain/entities/entities.dart';

void main() {
  group('GameScreenState', () {
    final testTime = DateTime(2024, 1, 15);
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
      createdAt: testTime,
    );

    group('GameScreenLoading', () {
      test('should create instance', () {
        const state = GameScreenLoading();
        expect(state, isA<GameScreenState>());
        expect(state, isA<GameScreenLoading>());
      });

      test('should be const constructible', () {
        const state1 = GameScreenLoading();
        const state2 = GameScreenLoading();
        expect(identical(state1, state2), isTrue);
      });
    });

    group('GameScreenActive', () {
      test('should create instance with required fields', () {
        final state = GameScreenActive(
          session: testSession,
          currentPlayer: testPlayer,
        );

        expect(state, isA<GameScreenState>());
        expect(state, isA<GameScreenActive>());
        expect(state.session, equals(testSession));
        expect(state.currentPlayer, equals(testPlayer));
        expect(state.selectedCard, isNull);
      });

      test('should create instance with selectedCard', () {
        final state = GameScreenActive(
          session: testSession,
          currentPlayer: testPlayer,
          selectedCard: '5',
        );

        expect(state.selectedCard, equals('5'));
      });

      test('should support copyWith for session', () {
        final state = GameScreenActive(
          session: testSession,
          currentPlayer: testPlayer,
          selectedCard: '5',
        );

        final newSession = testSession.copyWith(state: GameState.revealed);
        final newState = state.copyWith(session: newSession);

        expect(newState.session.state, equals(GameState.revealed));
        expect(newState.currentPlayer, equals(testPlayer));
        expect(newState.selectedCard, equals('5'));
      });

      test('should support copyWith for currentPlayer', () {
        final state = GameScreenActive(
          session: testSession,
          currentPlayer: testPlayer,
        );

        final newPlayer = testPlayer.copyWith(name: 'New Name');
        final newState = state.copyWith(currentPlayer: newPlayer);

        expect(newState.currentPlayer.name, equals('New Name'));
        expect(newState.session, equals(testSession));
      });

      test('should support copyWith for selectedCard', () {
        final state = GameScreenActive(
          session: testSession,
          currentPlayer: testPlayer,
          selectedCard: '5',
        );

        final newState = state.copyWith(selectedCard: '13');

        expect(newState.selectedCard, equals('13'));
        expect(newState.session, equals(testSession));
        expect(newState.currentPlayer, equals(testPlayer));
      });

      test('should preserve all fields with empty copyWith', () {
        final state = GameScreenActive(
          session: testSession,
          currentPlayer: testPlayer,
          selectedCard: '5',
        );

        final newState = state.copyWith();

        expect(newState.session, equals(state.session));
        expect(newState.currentPlayer, equals(state.currentPlayer));
        expect(newState.selectedCard, equals(state.selectedCard));
      });
    });

    group('GameScreenError', () {
      test('should create instance with message', () {
        const state = GameScreenError(message: 'Test error');

        expect(state, isA<GameScreenState>());
        expect(state, isA<GameScreenError>());
        expect(state.message, equals('Test error'));
        expect(state.lastSession, isNull);
        expect(state.currentPlayer, isNull);
      });

      test('should create instance with lastSession', () {
        final state = GameScreenError(
          message: 'Error',
          lastSession: testSession,
        );

        expect(state.lastSession, equals(testSession));
      });

      test('should create instance with currentPlayer', () {
        final state = GameScreenError(
          message: 'Error',
          currentPlayer: testPlayer,
        );

        expect(state.currentPlayer, equals(testPlayer));
      });

      test('should create instance with all fields', () {
        final state = GameScreenError(
          message: 'Session disconnected',
          lastSession: testSession,
          currentPlayer: testPlayer,
        );

        expect(state.message, equals('Session disconnected'));
        expect(state.lastSession, equals(testSession));
        expect(state.currentPlayer, equals(testPlayer));
      });
    });

    group('GameScreenSessionEnded', () {
      test('should create instance', () {
        const state = GameScreenSessionEnded();
        expect(state, isA<GameScreenState>());
        expect(state, isA<GameScreenSessionEnded>());
      });

      test('should be const constructible', () {
        const state1 = GameScreenSessionEnded();
        const state2 = GameScreenSessionEnded();
        expect(identical(state1, state2), isTrue);
      });
    });

    group('pattern matching', () {
      test('should support switch expressions', () {
        GameScreenState state = const GameScreenLoading();
        expect(_getStateName(state), equals('loading'));

        state = GameScreenActive(
          session: testSession,
          currentPlayer: testPlayer,
        );
        expect(_getStateName(state), equals('active'));

        state = const GameScreenError(message: 'Error');
        expect(_getStateName(state), equals('error'));

        state = const GameScreenSessionEnded();
        expect(_getStateName(state), equals('ended'));
      });
    });
  });
}

String _getStateName(GameScreenState state) {
  return switch (state) {
    GameScreenLoading() => 'loading',
    GameScreenActive() => 'active',
    GameScreenError() => 'error',
    GameScreenSessionEnded() => 'ended',
  };
}
