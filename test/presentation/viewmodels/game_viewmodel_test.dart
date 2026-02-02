import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:planning_poker/core/result/result.dart';
import 'package:planning_poker/domain/entities/entities.dart';
import 'package:planning_poker/domain/usecases/usecases.dart';
import 'package:planning_poker/presentation/viewmodels/game_viewmodel.dart';

import 'game_viewmodel_test.mocks.dart';

@GenerateMocks([
  WatchSessionUseCase,
  PlayCardUseCase,
  RevealCardsUseCase,
  ResetRoundUseCase,
  LeaveSessionUseCase,
])
void main() {
  late GameViewModel viewModel;
  late MockWatchSessionUseCase mockWatchUseCase;
  late MockPlayCardUseCase mockPlayCardUseCase;
  late MockRevealCardsUseCase mockRevealCardsUseCase;
  late MockResetRoundUseCase mockResetRoundUseCase;
  late MockLeaveSessionUseCase mockLeaveSessionUseCase;
  late StreamController<Session?> sessionStreamController;

  final testPlayer = Player(id: 'player-1', name: 'Test Player', isHost: true);
  final testPlayer2 = Player(id: 'player-2', name: 'Player 2');
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

  setUpAll(() {
    // Provide dummy values for Result types
    provideDummy<Result<void>>(Result.success(null));
  });

  setUp(() {
    mockWatchUseCase = MockWatchSessionUseCase();
    mockPlayCardUseCase = MockPlayCardUseCase();
    mockRevealCardsUseCase = MockRevealCardsUseCase();
    mockResetRoundUseCase = MockResetRoundUseCase();
    mockLeaveSessionUseCase = MockLeaveSessionUseCase();

    sessionStreamController = StreamController<Session?>.broadcast();

    // Setup watch use case to return the stream - must use thenAnswer for Stream
    when(
      mockWatchUseCase.execute(any),
    ).thenAnswer((_) => sessionStreamController.stream);

    viewModel = GameViewModel(
      watchSessionUseCase: mockWatchUseCase,
      playCardUseCase: mockPlayCardUseCase,
      revealCardsUseCase: mockRevealCardsUseCase,
      resetRoundUseCase: mockResetRoundUseCase,
      leaveSessionUseCase: mockLeaveSessionUseCase,
    );
  });

  tearDown(() {
    sessionStreamController.close();
  });

  group('GameViewModel', () {
    group('initial state', () {
      test('should have null initial state', () {
        expect(viewModel.session, isNull);
        expect(viewModel.currentPlayer, isNull);
        expect(viewModel.selectedCard, isNull);
        expect(viewModel.error, isNull);
        expect(viewModel.hasError, isFalse);
      });

      test('should return availableCards from PokerCards', () {
        expect(viewModel.availableCards, isNotEmpty);
        expect(viewModel.availableCards, contains('5'));
        expect(viewModel.availableCards, contains('?'));
      });
    });

    group('initialize', () {
      test('should set session and player', () {
        viewModel.initialize(testSession, testPlayer);

        expect(viewModel.session, equals(testSession));
        expect(viewModel.currentPlayer, equals(testPlayer));
      });

      test('should start watching session', () {
        viewModel.initialize(testSession, testPlayer);

        verify(mockWatchUseCase.execute(testSession.id)).called(1);
      });

      test('should update session when stream emits', () async {
        viewModel.initialize(testSession, testPlayer);

        final updatedSession = testSession.copyWith(state: GameState.revealed);
        sessionStreamController.add(updatedSession);

        await Future.delayed(const Duration(milliseconds: 10));

        expect(viewModel.session?.state, equals(GameState.revealed));
      });

      test(
        'should set error when stream emits null (session deleted)',
        () async {
          viewModel.initialize(testSession, testPlayer);
          sessionStreamController.add(null);

          await Future.delayed(const Duration(milliseconds: 10));

          expect(viewModel.error, equals('A sessão foi encerrada'));
          expect(viewModel.hasError, isTrue);
        },
      );
    });

    group('computed properties', () {
      test('isHost should return true when current player is host', () {
        viewModel.initialize(testSession, testPlayer);

        expect(viewModel.isHost, isTrue);
      });

      test('isHost should return false when current player is not host', () {
        viewModel.initialize(testSession, testPlayer2);

        expect(viewModel.isHost, isFalse);
      });

      test('isRevealed should return true when state is revealed', () {
        final revealedSession = testSession.copyWith(state: GameState.revealed);
        viewModel.initialize(revealedSession, testPlayer);

        expect(viewModel.isRevealed, isTrue);
      });

      test('isRevealed should return false when state is voting', () {
        viewModel.initialize(testSession, testPlayer);

        expect(viewModel.isRevealed, isFalse);
      });

      test('canReveal should return false when no cards played', () {
        viewModel.initialize(testSession, testPlayer);

        expect(viewModel.canReveal, isFalse);
      });

      test('canReveal should return true when cards are played', () {
        final sessionWithCards = testSession.copyWith(
          playedCards: {
            'player-1': PlayedCard(
              playerId: 'player-1',
              playerName: 'Test Player',
              cardValue: '5',
              playedAt: DateTime.now(),
            ),
          },
        );
        viewModel.initialize(sessionWithCards, testPlayer);

        expect(viewModel.canReveal, isTrue);
      });

      test('allPlayersVoted should return true when all voted', () {
        final sessionWithAllVotes = testSession.copyWith(
          players: [testPlayer],
          playedCards: {
            'player-1': PlayedCard(
              playerId: 'player-1',
              playerName: 'Test Player',
              cardValue: '5',
              playedAt: DateTime.now(),
            ),
          },
        );
        viewModel.initialize(sessionWithAllVotes, testPlayer);

        expect(viewModel.allPlayersVoted, isTrue);
      });

      test('myPlayedCard should return null when not played', () {
        viewModel.initialize(testSession, testPlayer);

        expect(viewModel.myPlayedCard, isNull);
      });

      test('myPlayedCard should return card value when played', () {
        final sessionWithMyCard = testSession.copyWith(
          playedCards: {
            'player-1': PlayedCard(
              playerId: 'player-1',
              playerName: 'Test Player',
              cardValue: '8',
              playedAt: DateTime.now(),
            ),
          },
        );
        viewModel.initialize(sessionWithMyCard, testPlayer);

        expect(viewModel.myPlayedCard, equals('8'));
      });

      test('players should return session players', () {
        final sessionWithPlayers = testSession.copyWith(
          players: [testPlayer, testPlayer2],
        );
        viewModel.initialize(sessionWithPlayers, testPlayer);

        expect(viewModel.players.length, equals(2));
      });

      test('playedCards should return session playedCards', () {
        final card = PlayedCard(
          playerId: 'player-1',
          playerName: 'Test Player',
          cardValue: '5',
          playedAt: DateTime.now(),
        );
        final sessionWithCards = testSession.copyWith(
          playedCards: {'player-1': card},
        );
        viewModel.initialize(sessionWithCards, testPlayer);

        expect(viewModel.playedCards.length, equals(1));
        expect(viewModel.playedCards['player-1']?.cardValue, equals('5'));
      });
    });

    group('selectCard', () {
      test('should set selected card and play it', () async {
        when(
          mockPlayCardUseCase.execute(
            sessionId: anyNamed('sessionId'),
            playerId: anyNamed('playerId'),
            playerName: anyNamed('playerName'),
            cardValue: anyNamed('cardValue'),
          ),
        ).thenAnswer((_) async => Result.success(null));

        viewModel.initialize(testSession, testPlayer);
        viewModel.selectCard('5');

        await Future.delayed(const Duration(milliseconds: 10));

        expect(viewModel.selectedCard, equals('5'));
        verify(
          mockPlayCardUseCase.execute(
            sessionId: 'session-1',
            playerId: 'player-1',
            playerName: 'Test Player',
            cardValue: '5',
          ),
        ).called(1);
      });
    });

    group('playSelectedCard', () {
      test('should do nothing when selectedCard is null', () async {
        viewModel.initialize(testSession, testPlayer);
        await viewModel.playSelectedCard();

        verifyNever(
          mockPlayCardUseCase.execute(
            sessionId: anyNamed('sessionId'),
            playerId: anyNamed('playerId'),
            playerName: anyNamed('playerName'),
            cardValue: anyNamed('cardValue'),
          ),
        );
      });

      test('should call use case when card is selected', () async {
        when(
          mockPlayCardUseCase.execute(
            sessionId: anyNamed('sessionId'),
            playerId: anyNamed('playerId'),
            playerName: anyNamed('playerName'),
            cardValue: anyNamed('cardValue'),
          ),
        ).thenAnswer((_) async => Result.success(null));

        viewModel.initialize(testSession, testPlayer);
        viewModel.selectCard('13');

        await Future.delayed(const Duration(milliseconds: 10));

        verify(
          mockPlayCardUseCase.execute(
            sessionId: 'session-1',
            playerId: 'player-1',
            playerName: 'Test Player',
            cardValue: '13',
          ),
        ).called(1);
      });
    });

    group('revealCards', () {
      test('should not reveal if not host', () async {
        viewModel.initialize(testSession, testPlayer2);
        await viewModel.revealCards();

        verifyNever(mockRevealCardsUseCase.execute(any));
      });

      test('should reveal cards when host', () async {
        when(
          mockRevealCardsUseCase.execute(any),
        ).thenAnswer((_) async => Result.success(null));

        viewModel.initialize(testSession, testPlayer);
        await viewModel.revealCards();

        verify(mockRevealCardsUseCase.execute('session-1')).called(1);
      });

      test('should set error on failure', () async {
        when(
          mockRevealCardsUseCase.execute(any),
        ).thenAnswer((_) async => Result.failure('Failed'));

        viewModel.initialize(testSession, testPlayer);
        await viewModel.revealCards();

        expect(viewModel.hasError, isTrue);
      });
    });

    group('resetRound', () {
      test('should not reset if not host', () async {
        viewModel.initialize(testSession, testPlayer2);
        await viewModel.resetRound();

        verifyNever(mockResetRoundUseCase.execute(any));
      });

      test('should reset round when host', () async {
        when(
          mockResetRoundUseCase.execute(any),
        ).thenAnswer((_) async => Result.success(null));

        viewModel.initialize(testSession, testPlayer);
        await viewModel.resetRound();

        verify(mockResetRoundUseCase.execute('session-1')).called(1);
      });
    });

    group('leaveSession', () {
      test('should call leave use case', () async {
        when(
          mockLeaveSessionUseCase.execute(
            sessionId: anyNamed('sessionId'),
            playerId: anyNamed('playerId'),
          ),
        ).thenAnswer((_) async => Result.success(null));

        viewModel.initialize(testSession, testPlayer);
        await viewModel.leaveSession();

        verify(
          mockLeaveSessionUseCase.execute(
            sessionId: 'session-1',
            playerId: 'player-1',
          ),
        ).called(1);
      });
    });

    group('clearError', () {
      test('should clear error', () async {
        when(
          mockRevealCardsUseCase.execute(any),
        ).thenAnswer((_) async => Result.failure('Error'));

        viewModel.initialize(testSession, testPlayer);
        await viewModel.revealCards();
        expect(viewModel.hasError, isTrue);

        viewModel.clearError();

        expect(viewModel.hasError, isFalse);
        expect(viewModel.error, isNull);
      });
    });
  });
}
