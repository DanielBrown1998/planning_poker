import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:planning_poker/core/result/result.dart';
import 'package:planning_poker/domain/entities/entities.dart';
import 'package:planning_poker/domain/usecases/usecases.dart';
import 'package:planning_poker/presentation/viewmodels/game_viewmodel.dart';
import 'package:planning_poker/presentation/views/partials/table_area.dart';
import 'package:provider/provider.dart';

import 'table_area_test.mocks.dart';

@GenerateMocks([
  WatchSessionUseCase,
  PlayCardUseCase,
  RevealCardsUseCase,
  ResetRoundUseCase,
  LeaveSessionUseCase,
])
void main() {
  late MockWatchSessionUseCase mockWatchUseCase;
  late MockPlayCardUseCase mockPlayCardUseCase;
  late MockRevealCardsUseCase mockRevealCardsUseCase;
  late MockResetRoundUseCase mockResetRoundUseCase;
  late MockLeaveSessionUseCase mockLeaveSessionUseCase;
  late StreamController<Session?> sessionStreamController;
  late GameViewModel viewModel;

  final testPlayer = Player(id: 'player-1', name: 'Test Player', isHost: true);
  final player2 = Player(id: 'player-2', name: 'Player 2');

  final testSession = Session(
    id: 'session-1',
    sessionKey: 'ABC123',
    hostId: 'player-1',
    name: 'Test Session',
    state: GameState.voting,
    players: [testPlayer, player2],
    playedCards: {},
    createdAt: DateTime(2024, 1, 15),
  );

  setUpAll(() {
    provideDummy<Result<void>>(Result.success(null));
  });

  setUp(() {
    mockWatchUseCase = MockWatchSessionUseCase();
    mockPlayCardUseCase = MockPlayCardUseCase();
    mockRevealCardsUseCase = MockRevealCardsUseCase();
    mockResetRoundUseCase = MockResetRoundUseCase();
    mockLeaveSessionUseCase = MockLeaveSessionUseCase();

    sessionStreamController = StreamController<Session?>.broadcast();

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

    viewModel.initialize(testSession, testPlayer);
  });

  tearDown(() async {
    await sessionStreamController.close();
  });

  /// Helper to pump widget and let it settle without using pumpAndSettle
  /// which can cause semantics issues
  Future<void> pumpAndWait(WidgetTester tester, {int frames = 10}) async {
    for (int i = 0; i < frames; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  Widget createWidget() {
    return MaterialApp(
      home: Scaffold(
        body: ChangeNotifierProvider<GameViewModel>.value(
          value: viewModel,
          child: const SizedBox(width: 400, height: 600, child: TableArea()),
        ),
      ),
    );
  }

  group('TableArea', () {
    group('empty state', () {
      testWidgets('should display empty state when no cards played', (
        tester,
      ) async {
        await tester.pumpWidget(createWidget());
        await pumpAndWait(tester);

        expect(find.text('Aguardando votos...'), findsOneWidget);
        expect(
          find.text('Selecione uma carta abaixo para votar'),
          findsOneWidget,
        );
      });

      testWidgets('should display style icon in empty state', (tester) async {
        await tester.pumpWidget(createWidget());
        await pumpAndWait(tester);

        expect(find.byIcon(Icons.style_outlined), findsOneWidget);
      });
    });

    group('cards on table', () {
      testWidgets('should display hidden cards when voting', (tester) async {
        final sessionWithCards = testSession.copyWith(
          playedCards: {
            'player-1': PlayedCard(
              playerId: 'player-1',
              playerName: 'Test Player',
              cardValue: '5',
              playedAt: DateTime.now(),
            ),
            'player-2': PlayedCard(
              playerId: 'player-2',
              playerName: 'Player 2',
              cardValue: '8',
              playedAt: DateTime.now(),
            ),
          },
        );

        viewModel.initialize(sessionWithCards, testPlayer);

        await tester.pumpWidget(createWidget());
        await pumpAndWait(tester);

        // Cards should be hidden (showing question mark)
        expect(find.byIcon(Icons.question_mark_rounded), findsNWidgets(2));
      });

      testWidgets('should display player names below cards', (tester) async {
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

        await tester.pumpWidget(createWidget());
        await pumpAndWait(tester);

        expect(find.text('Test Player'), findsOneWidget);
      });

      testWidgets('should reveal card values when session is revealed', (
        tester,
      ) async {
        final revealedSession = testSession.copyWith(
          state: GameState.revealed,
          playedCards: {
            'player-1': PlayedCard(
              playerId: 'player-1',
              playerName: 'Test Player',
              cardValue: '5',
              playedAt: DateTime.now(),
            ),
            'player-2': PlayedCard(
              playerId: 'player-2',
              playerName: 'Player 2',
              cardValue: '8',
              playedAt: DateTime.now(),
            ),
          },
        );

        viewModel.initialize(revealedSession, testPlayer);

        await tester.pumpWidget(createWidget());
        await pumpAndWait(tester);

        expect(find.text('5'), findsOneWidget);
        expect(find.text('8'), findsOneWidget);
      });

      testWidgets('should not show hidden card icon when revealed', (
        tester,
      ) async {
        final revealedSession = testSession.copyWith(
          state: GameState.revealed,
          playedCards: {
            'player-1': PlayedCard(
              playerId: 'player-1',
              playerName: 'Test Player',
              cardValue: '5',
              playedAt: DateTime.now(),
            ),
          },
        );

        viewModel.initialize(revealedSession, testPlayer);

        await tester.pumpWidget(createWidget());
        await pumpAndWait(tester);

        expect(find.byIcon(Icons.question_mark_rounded), findsNothing);
      });
    });

    group('layout', () {
      testWidgets('should use Wrap for card layout', (tester) async {
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

        await tester.pumpWidget(createWidget());
        await pumpAndWait(tester);

        expect(find.byType(Wrap), findsOneWidget);
      });

      testWidgets('should center cards in the area', (tester) async {
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

        await tester.pumpWidget(createWidget());
        await pumpAndWait(tester);

        expect(find.byType(Center), findsWidgets);
      });
    });

    group('many cards', () {
      testWidgets('should handle many played cards', (tester) async {
        final manyPlayers = List.generate(
          8,
          (i) => Player(id: 'player-$i', name: 'Player $i'),
        );
        final playedCards = {
          for (var p in manyPlayers)
            p.id: PlayedCard(
              playerId: p.id,
              playerName: p.name,
              cardValue: '${(manyPlayers.indexOf(p) + 1) * 2}',
              playedAt: DateTime.now(),
            ),
        };

        final sessionWithManyCards = testSession.copyWith(
          players: manyPlayers,
          playedCards: playedCards,
        );

        viewModel.initialize(sessionWithManyCards, manyPlayers.first);

        await tester.pumpWidget(createWidget());
        await pumpAndWait(tester);

        // All hidden cards should be shown
        expect(find.byIcon(Icons.question_mark_rounded), findsNWidgets(8));
      });
    });

    group('special card values', () {
      testWidgets('should display coffee card when revealed', (tester) async {
        final revealedSession = testSession.copyWith(
          state: GameState.revealed,
          playedCards: {
            'player-1': PlayedCard(
              playerId: 'player-1',
              playerName: 'Test Player',
              cardValue: '☕',
              playedAt: DateTime.now(),
            ),
          },
        );

        viewModel.initialize(revealedSession, testPlayer);

        await tester.pumpWidget(createWidget());
        await pumpAndWait(tester);

        expect(find.text('☕'), findsOneWidget);
      });

      testWidgets('should display question mark card when revealed', (
        tester,
      ) async {
        final revealedSession = testSession.copyWith(
          state: GameState.revealed,
          playedCards: {
            'player-1': PlayedCard(
              playerId: 'player-1',
              playerName: 'Test Player',
              cardValue: '?',
              playedAt: DateTime.now(),
            ),
          },
        );

        viewModel.initialize(revealedSession, testPlayer);

        await tester.pumpWidget(createWidget());
        await pumpAndWait(tester);

        expect(find.text('?'), findsOneWidget);
      });
    });
  });
}
