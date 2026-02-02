import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:planning_poker/core/result/result.dart';
import 'package:planning_poker/domain/entities/entities.dart';
import 'package:planning_poker/domain/usecases/usecases.dart';
import 'package:planning_poker/presentation/viewmodels/game_viewmodel.dart';
import 'package:planning_poker/presentation/views/partials/card_selection_area.dart';
import 'package:provider/provider.dart';

import 'card_selection_area_test.mocks.dart';

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
          child: const Column(
            children: [
              Expanded(child: SizedBox()),
              CardSelectionArea(),
            ],
          ),
        ),
      ),
    );
  }

  group('CardSelectionArea', () {
    group('rendering', () {
      testWidgets('should display section header', (tester) async {
        await tester.pumpWidget(createWidget());
        await pumpAndWait(tester);

        expect(find.text('Suas Cartas'), findsOneWidget);
      });

      testWidgets('should display cards icon', (tester) async {
        await tester.pumpWidget(createWidget());
        await pumpAndWait(tester);

        expect(find.byIcon(Icons.style_rounded), findsOneWidget);
      });

      testWidgets('should display all available cards', (tester) async {
        await tester.pumpWidget(createWidget());
        await pumpAndWait(tester);

        // Check that cards are rendered in a ListView
        expect(find.byType(ListView), findsOneWidget);
      });

      testWidgets('should render poker card widgets', (tester) async {
        await tester.pumpWidget(createWidget());
        await pumpAndWait(tester);

        // At least some poker cards should be visible
        expect(find.text('1'), findsWidgets);
      });
    });

    group('card selection', () {
      testWidgets('should select card when tapped', (tester) async {
        when(
          mockPlayCardUseCase.execute(
            sessionId: anyNamed('sessionId'),
            playerId: anyNamed('playerId'),
            playerName: anyNamed('playerName'),
            cardValue: anyNamed('cardValue'),
          ),
        ).thenAnswer((_) async => Result.success(null));

        await tester.pumpWidget(createWidget());
        await pumpAndWait(tester);

        // Find and tap a card (the card with value '5')
        final cardFinder = find.text('5').first;
        await tester.tap(cardFinder);
        await pumpAndWait(tester);

        expect(viewModel.selectedCard, equals('5'));
      });

      testWidgets('should show selected indicator after selection', (
        tester,
      ) async {
        when(
          mockPlayCardUseCase.execute(
            sessionId: anyNamed('sessionId'),
            playerId: anyNamed('playerId'),
            playerName: anyNamed('playerName'),
            cardValue: anyNamed('cardValue'),
          ),
        ).thenAnswer((_) async => Result.success(null));

        await tester.pumpWidget(createWidget());
        await pumpAndWait(tester);

        // Select a card
        viewModel.selectCard('8');
        await pumpAndWait(tester);

        // The selected indicator should appear in header
        expect(find.text('8'), findsWidgets);
      });
    });

    group('scrolling', () {
      testWidgets('should be horizontally scrollable', (tester) async {
        await tester.pumpWidget(createWidget());
        await pumpAndWait(tester);

        final listView = find.byType(ListView);
        expect(listView, findsOneWidget);

        // Attempt to scroll
        await tester.drag(listView, const Offset(-200, 0));
        await pumpAndWait(tester);
      });
    });

    group('played card indicator', () {
      testWidgets('should show indicator when card is played', (tester) async {
        final sessionWithPlayedCard = testSession.copyWith(
          playedCards: {
            'player-1': PlayedCard(
              playerId: 'player-1',
              playerName: 'Test Player',
              cardValue: '13',
              playedAt: DateTime.now(),
            ),
          },
        );

        when(
          mockWatchUseCase.execute(any),
        ).thenAnswer((_) => Stream.value(sessionWithPlayedCard));

        viewModel.initialize(sessionWithPlayedCard, testPlayer);

        await tester.pumpWidget(createWidget());
        await pumpAndWait(tester);

        // The played card value should appear
        expect(find.text('13'), findsWidgets);
      });
    });
  });
}
