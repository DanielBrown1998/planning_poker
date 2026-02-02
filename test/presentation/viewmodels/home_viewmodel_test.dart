import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:planning_poker/core/result/result.dart';
import 'package:planning_poker/domain/entities/entities.dart';
import 'package:planning_poker/domain/usecases/usecases.dart';
import 'package:planning_poker/presentation/state/home_state.dart';
import 'package:planning_poker/presentation/viewmodels/home_viewmodel.dart';
import 'package:uuid/uuid.dart';

import 'home_viewmodel_test.mocks.dart';

@GenerateMocks([CreateSessionUseCase, JoinSessionUseCase, Uuid])
void main() {
  late HomeViewModel viewModel;
  late MockCreateSessionUseCase mockCreateUseCase;
  late MockJoinSessionUseCase mockJoinUseCase;
  late MockUuid mockUuid;

  setUpAll(() {
    // Provide dummy values for Result types
    provideDummy<Result<Session>>(Result.failure('dummy'));
  });

  setUp(() {
    mockCreateUseCase = MockCreateSessionUseCase();
    mockJoinUseCase = MockJoinSessionUseCase();
    mockUuid = MockUuid();

    when(mockUuid.v4()).thenReturn('uuid-123');

    viewModel = HomeViewModel(
      createSessionUseCase: mockCreateUseCase,
      joinSessionUseCase: mockJoinUseCase,
      uuid: mockUuid,
    );
  });

  group('HomeViewModel', () {
    group('initial state', () {
      test('should have initial state', () {
        expect(viewModel.state, isA<HomeInitial>());
        expect(viewModel.isLoading, isFalse);
        expect(viewModel.hasError, isFalse);
        expect(viewModel.error, isNull);
        expect(viewModel.hasSuccess, isFalse);
        expect(viewModel.session, isNull);
        expect(viewModel.currentPlayer, isNull);
      });
    });

    group('createSession', () {
      final testSession = Session(
        id: 'session-1',
        sessionKey: 'ABC123',
        hostId: 'uuid-123',
        name: 'Test Session',
        state: GameState.voting,
        players: [Player(id: 'uuid-123', name: 'Test Host', isHost: true)],
        playedCards: {},
        createdAt: DateTime(2024, 1, 15),
      );

      test('should set loading state when creating session', () async {
        when(
          mockCreateUseCase.execute(
            sessionName: anyNamed('sessionName'),
            host: anyNamed('host'),
          ),
        ).thenAnswer((_) async {
          await Future.delayed(const Duration(milliseconds: 10));
          return Result.success(testSession);
        });

        var wasLoading = false;
        viewModel.addListener(() {
          if (viewModel.state is HomeLoading) {
            wasLoading = true;
          }
        });

        await viewModel.createSession(
          sessionName: 'Test Session',
          playerName: 'Test Host',
        );

        expect(wasLoading, isTrue);
      });

      test('should return true and set success state on success', () async {
        when(
          mockCreateUseCase.execute(
            sessionName: anyNamed('sessionName'),
            host: anyNamed('host'),
          ),
        ).thenAnswer((_) async => Result.success(testSession));

        final result = await viewModel.createSession(
          sessionName: 'Test Session',
          playerName: 'Test Host',
        );

        expect(result, isTrue);
        expect(viewModel.state, isA<HomeSuccess>());
        expect(viewModel.hasSuccess, isTrue);
        expect(viewModel.session?.id, equals('session-1'));
        expect(viewModel.currentPlayer?.name, equals('Test Host'));
        expect(viewModel.currentPlayer?.isHost, isTrue);
      });

      test(
        'should return false and set error state when command returns failure',
        () async {
          when(
            mockCreateUseCase.execute(
              sessionName: anyNamed('sessionName'),
              host: anyNamed('host'),
            ),
          ).thenAnswer((_) async => Result.failure('Failed'));

          final result = await viewModel.createSession(
            sessionName: 'Test Session',
            playerName: 'Test Host',
          );

          expect(result, isFalse);
          expect(viewModel.state, isA<HomeError>());
          expect(viewModel.hasError, isTrue);
        },
      );

      test('should set error state on exception', () async {
        when(
          mockCreateUseCase.execute(
            sessionName: anyNamed('sessionName'),
            host: anyNamed('host'),
          ),
        ).thenThrow(Exception('Network error'));

        final result = await viewModel.createSession(
          sessionName: 'Test Session',
          playerName: 'Test Host',
        );

        expect(result, isFalse);
        expect(viewModel.state, isA<HomeError>());
        expect(viewModel.error, isNotNull);
      });
    });

    group('joinSession', () {
      final testSession = Session(
        id: 'session-1',
        sessionKey: 'ABC123',
        hostId: 'host-id',
        name: 'Test Session',
        state: GameState.voting,
        players: [
          Player(id: 'host-id', name: 'Host', isHost: true),
          Player(id: 'uuid-123', name: 'Joining Player'),
        ],
        playedCards: {},
        createdAt: DateTime(2024, 1, 15),
      );

      test('should set loading state when joining session', () async {
        when(
          mockJoinUseCase.execute(
            sessionKey: anyNamed('sessionKey'),
            player: anyNamed('player'),
          ),
        ).thenAnswer((_) async {
          await Future.delayed(const Duration(milliseconds: 10));
          return Result.success(testSession);
        });

        var wasLoading = false;
        viewModel.addListener(() {
          if (viewModel.state is HomeLoading) {
            wasLoading = true;
          }
        });

        await viewModel.joinSession(
          sessionKey: 'ABC123',
          playerName: 'Joining Player',
        );

        expect(wasLoading, isTrue);
      });

      test('should return true and set success state on success', () async {
        when(
          mockJoinUseCase.execute(
            sessionKey: anyNamed('sessionKey'),
            player: anyNamed('player'),
          ),
        ).thenAnswer((_) async => Result.success(testSession));

        final result = await viewModel.joinSession(
          sessionKey: 'ABC123',
          playerName: 'Joining Player',
        );

        expect(result, isTrue);
        expect(viewModel.state, isA<HomeSuccess>());
        expect(viewModel.session?.sessionKey, equals('ABC123'));
        expect(viewModel.currentPlayer?.name, equals('Joining Player'));
        expect(viewModel.currentPlayer?.isHost, isFalse);
      });

      test(
        'should return false and set error state when session not found',
        () async {
          when(
            mockJoinUseCase.execute(
              sessionKey: anyNamed('sessionKey'),
              player: anyNamed('player'),
            ),
          ).thenAnswer((_) async => Result.failure('Session not found'));

          final result = await viewModel.joinSession(
            sessionKey: 'INVALID',
            playerName: 'Test Player',
          );

          expect(result, isFalse);
          expect(viewModel.state, isA<HomeError>());
        },
      );

      test('should set error state on exception', () async {
        when(
          mockJoinUseCase.execute(
            sessionKey: anyNamed('sessionKey'),
            player: anyNamed('player'),
          ),
        ).thenThrow(Exception('Connection failed'));

        final result = await viewModel.joinSession(
          sessionKey: 'ABC123',
          playerName: 'Test Player',
        );

        expect(result, isFalse);
        expect(viewModel.state, isA<HomeError>());
        expect(viewModel.error, isNotNull);
      });
    });

    group('clearError', () {
      test('should clear error and return to initial state', () async {
        when(
          mockCreateUseCase.execute(
            sessionName: anyNamed('sessionName'),
            host: anyNamed('host'),
          ),
        ).thenAnswer((_) async => Result.failure('Error'));

        await viewModel.createSession(
          sessionName: 'Test',
          playerName: 'Player',
        );
        expect(viewModel.state, isA<HomeError>());

        viewModel.clearError();

        expect(viewModel.state, isA<HomeInitial>());
        expect(viewModel.hasError, isFalse);
      });

      test('should not change state if not in error state', () async {
        when(
          mockCreateUseCase.execute(
            sessionName: anyNamed('sessionName'),
            host: anyNamed('host'),
          ),
        ).thenAnswer(
          (_) async => Result.success(
            Session(
              id: 'session-1',
              sessionKey: 'ABC123',
              hostId: 'uuid-123',
              name: 'Test',
              state: GameState.voting,
              players: [],
              playedCards: {},
              createdAt: DateTime.now(),
            ),
          ),
        );

        await viewModel.createSession(
          sessionName: 'Test',
          playerName: 'Player',
        );
        expect(viewModel.state, isA<HomeSuccess>());

        viewModel.clearError();

        expect(viewModel.state, isA<HomeSuccess>());
      });
    });

    group('reset', () {
      test('should return to initial state', () async {
        when(
          mockCreateUseCase.execute(
            sessionName: anyNamed('sessionName'),
            host: anyNamed('host'),
          ),
        ).thenAnswer(
          (_) async => Result.success(
            Session(
              id: 'session-1',
              sessionKey: 'ABC123',
              hostId: 'uuid-123',
              name: 'Test',
              state: GameState.voting,
              players: [],
              playedCards: {},
              createdAt: DateTime.now(),
            ),
          ),
        );

        await viewModel.createSession(
          sessionName: 'Test',
          playerName: 'Player',
        );
        expect(viewModel.state, isA<HomeSuccess>());

        viewModel.reset();

        expect(viewModel.state, isA<HomeInitial>());
        expect(viewModel.session, isNull);
        expect(viewModel.currentPlayer, isNull);
      });
    });

    group('notifications', () {
      test('should notify listeners on state changes', () async {
        when(
          mockCreateUseCase.execute(
            sessionName: anyNamed('sessionName'),
            host: anyNamed('host'),
          ),
        ).thenAnswer(
          (_) async => Result.success(
            Session(
              id: 'session-1',
              sessionKey: 'ABC123',
              hostId: 'uuid-123',
              name: 'Test',
              state: GameState.voting,
              players: [],
              playedCards: {},
              createdAt: DateTime.now(),
            ),
          ),
        );

        var notificationCount = 0;
        viewModel.addListener(() {
          notificationCount++;
        });

        await viewModel.createSession(
          sessionName: 'Test',
          playerName: 'Player',
        );

        expect(notificationCount, greaterThan(0));
      });
    });
  });
}
