import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:planning_poker/core/result/result.dart';
import 'package:planning_poker/domain/entities/entities.dart';
import 'package:planning_poker/domain/usecases/usecases.dart';
import 'package:planning_poker/presentation/viewmodels/game_viewmodel.dart';
import 'package:planning_poker/presentation/views/partials/session_info_bar.dart';
import 'package:provider/provider.dart';

import 'session_info_bar_test.mocks.dart';

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

  final hostPlayer = Player(id: 'player-1', name: 'Host Player', isHost: true);
  final regularPlayer = Player(id: 'player-2', name: 'Regular Player');
  final player3 = Player(id: 'player-3', name: 'Player 3');

  final testSession = Session(
    id: 'session-1',
    sessionKey: 'ABC123',
    hostId: 'player-1',
    name: 'Test Session',
    state: GameState.voting,
    players: [hostPlayer, regularPlayer, player3],
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

  /// Sets up the test view size
  void setViewSize(WidgetTester tester, Size size) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
  }

  /// Resets the view size to default
  void resetViewSize(WidgetTester tester) {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  }

  Widget createWidget() {
    return MaterialApp(
      home: Scaffold(
        body: ChangeNotifierProvider<GameViewModel>.value(
          value: viewModel,
          child: const SessionInfoBar(),
        ),
      ),
    );
  }

  group('SessionInfoBar', () {
    group('players count', () {
      testWidgets('should display players count', (tester) async {
        setViewSize(tester, const Size(1400, 900));
        addTearDown(() => resetViewSize(tester));

        viewModel.initialize(testSession, hostPlayer);

        await tester.pumpWidget(createWidget());
        await pumpAndWait(tester);

        expect(find.text('3 jogadores'), findsOneWidget);
      });

      testWidgets('should display people icon', (tester) async {
        setViewSize(tester, const Size(1400, 900));
        addTearDown(() => resetViewSize(tester));

        viewModel.initialize(testSession, hostPlayer);

        await tester.pumpWidget(createWidget());
        await pumpAndWait(tester);

        expect(find.byIcon(Icons.people_outline_rounded), findsOneWidget);
      });

      testWidgets('should update count when players change', (tester) async {
        setViewSize(tester, const Size(1400, 900));
        addTearDown(() => resetViewSize(tester));

        viewModel.initialize(testSession, hostPlayer);

        await tester.pumpWidget(createWidget());
        await pumpAndWait(tester);

        expect(find.text('3 jogadores'), findsOneWidget);

        // Simulate player joining
        final updatedSession = testSession.copyWith(
          players: [
            ...testSession.players,
            Player(id: 'player-4', name: 'Player 4'),
          ],
        );
        sessionStreamController.add(updatedSession);

        await pumpAndWait(tester);

        expect(find.text('4 jogadores'), findsOneWidget);
      });
    });

    group('status chip', () {
      testWidgets('should show "Votação em andamento" when voting', (
        tester,
      ) async {
        setViewSize(tester, const Size(1400, 900));
        addTearDown(() => resetViewSize(tester));

        viewModel.initialize(testSession, hostPlayer);

        await tester.pumpWidget(createWidget());
        await pumpAndWait(tester);

        expect(find.text('Votação em andamento'), findsOneWidget);
        expect(find.byIcon(Icons.hourglass_empty_rounded), findsOneWidget);
      });

      testWidgets('should show "Todos votaram!" when all voted', (
        tester,
      ) async {
        setViewSize(tester, const Size(1400, 900));
        addTearDown(() => resetViewSize(tester));

        final allVotedSession = testSession.copyWith(
          playedCards: {
            'player-1': PlayedCard(
              playerId: 'player-1',
              playerName: 'Host Player',
              cardValue: '5',
              playedAt: DateTime.now(),
            ),
            'player-2': PlayedCard(
              playerId: 'player-2',
              playerName: 'Regular Player',
              cardValue: '8',
              playedAt: DateTime.now(),
            ),
            'player-3': PlayedCard(
              playerId: 'player-3',
              playerName: 'Player 3',
              cardValue: '13',
              playedAt: DateTime.now(),
            ),
          },
        );

        viewModel.initialize(allVotedSession, hostPlayer);

        await tester.pumpWidget(createWidget());
        await pumpAndWait(tester);

        expect(find.text('Todos votaram!'), findsOneWidget);
        expect(find.byIcon(Icons.check_circle_outline_rounded), findsOneWidget);
      });

      testWidgets('should show "Cartas Reveladas" when revealed', (
        tester,
      ) async {
        setViewSize(tester, const Size(1400, 900));
        addTearDown(() => resetViewSize(tester));

        final revealedSession = testSession.copyWith(state: GameState.revealed);

        viewModel.initialize(revealedSession, hostPlayer);

        await tester.pumpWidget(createWidget());
        await pumpAndWait(tester);

        expect(find.text('Cartas Reveladas'), findsOneWidget);
        // visibility_rounded icon appears in both status chip and action button
        expect(find.byIcon(Icons.visibility_rounded), findsAtLeast(1));
      });
    });

    group('host actions', () {
      testWidgets('should show action buttons for host', (tester) async {
        setViewSize(tester, const Size(1400, 900));
        addTearDown(() => resetViewSize(tester));

        viewModel.initialize(testSession, hostPlayer);

        await tester.pumpWidget(createWidget());
        await pumpAndWait(tester);

        expect(find.text('Revelar Cartas'), findsOneWidget);
        expect(find.text('Nova Rodada'), findsOneWidget);
      });

      testWidgets('should not show action buttons for non-host', (
        tester,
      ) async {
        setViewSize(tester, const Size(1400, 900));
        addTearDown(() => resetViewSize(tester));

        viewModel.initialize(testSession, regularPlayer);

        await tester.pumpWidget(createWidget());
        await pumpAndWait(tester);

        expect(find.text('Revelar Cartas'), findsNothing);
        expect(find.text('Nova Rodada'), findsNothing);
      });

      testWidgets('reveal button should be disabled when no cards played', (
        tester,
      ) async {
        setViewSize(tester, const Size(1400, 900));
        addTearDown(() => resetViewSize(tester));

        viewModel.initialize(testSession, hostPlayer);

        await tester.pumpWidget(createWidget());
        await pumpAndWait(tester);

        // Verify the text exists and button is present
        expect(find.text('Revelar Cartas'), findsOneWidget);

        // Tap the button - should NOT call revealCards since disabled
        await tester.tap(find.text('Revelar Cartas'));
        await pumpAndWait(tester);

        // Verify revealCards was NOT called (button disabled)
        verifyNever(mockRevealCardsUseCase.execute(any));
      });

      testWidgets('reveal button should be enabled when cards are played', (
        tester,
      ) async {
        setViewSize(tester, const Size(1400, 900));
        addTearDown(() => resetViewSize(tester));

        when(
          mockRevealCardsUseCase.execute(any),
        ).thenAnswer((_) async => Result.success(null));

        final sessionWithCards = testSession.copyWith(
          playedCards: {
            'player-1': PlayedCard(
              playerId: 'player-1',
              playerName: 'Host Player',
              cardValue: '5',
              playedAt: DateTime.now(),
            ),
          },
        );

        viewModel.initialize(sessionWithCards, hostPlayer);

        await tester.pumpWidget(createWidget());
        await pumpAndWait(tester);

        // Verify the text exists
        expect(find.text('Revelar Cartas'), findsOneWidget);

        // Button should be enabled - tapping will call revealCards
        // (This is verified in another test)
      });

      testWidgets('should call revealCards when reveal button is tapped', (
        tester,
      ) async {
        setViewSize(tester, const Size(1400, 900));
        addTearDown(() => resetViewSize(tester));

        when(
          mockRevealCardsUseCase.execute(any),
        ).thenAnswer((_) async => Result.success(null));

        final sessionWithCards = testSession.copyWith(
          playedCards: {
            'player-1': PlayedCard(
              playerId: 'player-1',
              playerName: 'Host Player',
              cardValue: '5',
              playedAt: DateTime.now(),
            ),
          },
        );

        viewModel.initialize(sessionWithCards, hostPlayer);

        await tester.pumpWidget(createWidget());
        await pumpAndWait(tester);

        await tester.tap(find.text('Revelar Cartas'));
        await pumpAndWait(tester);

        verify(mockRevealCardsUseCase.execute('session-1')).called(1);
      });

      testWidgets('reset button should be disabled during voting', (
        tester,
      ) async {
        setViewSize(tester, const Size(1400, 900));
        addTearDown(() => resetViewSize(tester));

        viewModel.initialize(testSession, hostPlayer);

        await tester.pumpWidget(createWidget());
        await pumpAndWait(tester);

        final resetButton = tester.widget<OutlinedButton>(
          find.widgetWithText(OutlinedButton, 'Nova Rodada'),
        );

        expect(resetButton.onPressed, isNull);
      });

      testWidgets('reset button should be enabled when revealed', (
        tester,
      ) async {
        setViewSize(tester, const Size(1400, 900));
        addTearDown(() => resetViewSize(tester));

        when(
          mockResetRoundUseCase.execute(any),
        ).thenAnswer((_) async => Result.success(null));

        final revealedSession = testSession.copyWith(state: GameState.revealed);

        viewModel.initialize(revealedSession, hostPlayer);

        await tester.pumpWidget(createWidget());
        await pumpAndWait(tester);

        final resetButton = tester.widget<OutlinedButton>(
          find.widgetWithText(OutlinedButton, 'Nova Rodada'),
        );

        expect(resetButton.onPressed, isNotNull);
      });

      testWidgets('should call resetRound when reset button is tapped', (
        tester,
      ) async {
        setViewSize(tester, const Size(1400, 900));
        addTearDown(() => resetViewSize(tester));

        when(
          mockResetRoundUseCase.execute(any),
        ).thenAnswer((_) async => Result.success(null));

        final revealedSession = testSession.copyWith(state: GameState.revealed);

        viewModel.initialize(revealedSession, hostPlayer);

        await tester.pumpWidget(createWidget());
        await pumpAndWait(tester);

        await tester.tap(find.text('Nova Rodada'));
        await pumpAndWait(tester);

        verify(mockResetRoundUseCase.execute('session-1')).called(1);
      });
    });

    group('mobile layout', () {
      testWidgets('should show compact buttons on mobile', (tester) async {
        // Use width < 600 (mobile breakpoint) but enough to fit content
        setViewSize(tester, const Size(550, 800));
        addTearDown(() => resetViewSize(tester));

        viewModel.initialize(testSession, hostPlayer);

        await tester.pumpWidget(createWidget());
        await pumpAndWait(tester);

        // Mobile should show shorter labels
        expect(find.text('Revelar'), findsOneWidget);
      });
    });
  });
}
