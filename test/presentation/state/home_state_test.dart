import 'package:flutter_test/flutter_test.dart';
import 'package:planning_poker/presentation/state/home_state.dart';
import 'package:planning_poker/domain/entities/entities.dart';

void main() {
  group('HomeState', () {
    group('HomeInitial', () {
      test('should create instance', () {
        const state = HomeInitial();
        expect(state, isA<HomeState>());
        expect(state, isA<HomeInitial>());
      });

      test('should be const constructible', () {
        const state1 = HomeInitial();
        const state2 = HomeInitial();
        expect(identical(state1, state2), isTrue);
      });
    });

    group('HomeLoading', () {
      test('should create instance', () {
        const state = HomeLoading();
        expect(state, isA<HomeState>());
        expect(state, isA<HomeLoading>());
      });

      test('should be const constructible', () {
        const state1 = HomeLoading();
        const state2 = HomeLoading();
        expect(identical(state1, state2), isTrue);
      });
    });

    group('HomeError', () {
      test('should create instance with message', () {
        const state = HomeError('Test error message');
        expect(state, isA<HomeState>());
        expect(state, isA<HomeError>());
        expect(state.message, equals('Test error message'));
      });

      test('should store error message', () {
        const state = HomeError('Something went wrong');
        expect(state.message, equals('Something went wrong'));
      });

      test('should handle empty message', () {
        const state = HomeError('');
        expect(state.message, isEmpty);
      });
    });

    group('HomeSuccess', () {
      final testSession = Session(
        id: 'session-1',
        sessionKey: 'ABC123',
        hostId: 'player-1',
        name: 'Test Session',
        state: GameState.voting,
        players: [],
        playedCards: {},
        createdAt: DateTime(2024, 1, 15),
      );
      final testPlayer = Player(
        id: 'player-1',
        name: 'Test Player',
        isHost: true,
      );

      test('should create instance with session and player', () {
        final state = HomeSuccess(session: testSession, player: testPlayer);
        expect(state, isA<HomeState>());
        expect(state, isA<HomeSuccess>());
      });

      test('should expose session', () {
        final state = HomeSuccess(session: testSession, player: testPlayer);
        expect(state.session, equals(testSession));
        expect(state.session.id, equals('session-1'));
      });

      test('should expose player', () {
        final state = HomeSuccess(session: testSession, player: testPlayer);
        expect(state.player, equals(testPlayer));
        expect(state.player.name, equals('Test Player'));
      });
    });

    group('pattern matching', () {
      test('should support switch expressions', () {
        final testSession = Session(
          id: '1',
          sessionKey: 'KEY',
          hostId: 'host',
          name: 'Test',
          state: GameState.waiting,
          players: [],
          playedCards: {},
          createdAt: DateTime.now(),
        );
        final testPlayer = Player(id: 'host', name: 'Host');

        HomeState state = const HomeInitial();
        expect(_getStateName(state), equals('initial'));

        state = const HomeLoading();
        expect(_getStateName(state), equals('loading'));

        state = const HomeError('Error');
        expect(_getStateName(state), equals('error'));

        state = HomeSuccess(session: testSession, player: testPlayer);
        expect(_getStateName(state), equals('success'));
      });
    });
  });
}

String _getStateName(HomeState state) {
  return switch (state) {
    HomeInitial() => 'initial',
    HomeLoading() => 'loading',
    HomeError() => 'error',
    HomeSuccess() => 'success',
  };
}
