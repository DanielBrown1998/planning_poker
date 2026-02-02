import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:planning_poker/core/result/result.dart';
import 'package:planning_poker/domain/entities/entities.dart';
import 'package:planning_poker/domain/usecases/usecases.dart';
import 'package:planning_poker/presentation/viewmodels/game_viewmodel.dart';
import 'package:planning_poker/presentation/views/partials/players_panel.dart';
import 'package:provider/provider.dart';

import 'players_panel_test.mocks.dart';

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
  final player3 = Player(id: 'player-3', name: 'Player 3');

  final testSession = Session(
    id: 'session-1',
    sessionKey: 'ABC123',
    hostId: 'player-1',
    name: 'Test Session',
    state: GameState.voting,
    players: [testPlayer, player2, player3],
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

  Widget createWidget({bool isHorizontal = false}) {
    return MaterialApp(
      home: Scaffold(
        body: ChangeNotifierProvider<GameViewModel>.value(
          value: viewModel,
          child: SizedBox(
            width: 400,
            height: 600,
            child: PlayersPanel(isHorizontal: isHorizontal),
          ),
        ),
      ),
    );
  }

  group('PlayersPanel', () {
    group('vertical layout (desktop)', () {
      testWidgets('should display "Jogadores" header', (tester) async {
        await tester.pumpWidget(createWidget(isHorizontal: false));
        await pumpAndWait(tester);

        expect(find.text('Jogadores'), findsOneWidget);
      });

      testWidgets('should display people icon', (tester) async {
        await tester.pumpWidget(createWidget(isHorizontal: false));
        await pumpAndWait(tester);

        expect(find.byIcon(Icons.people_outline_rounded), findsOneWidget);
      });

      testWidgets('should display all players', (tester) async {
        await tester.pumpWidget(createWidget(isHorizontal: false));
        await pumpAndWait(tester);

        expect(find.text('Test Player'), findsOneWidget);
        expect(find.text('Player 2'), findsOneWidget);
        expect(find.text('Player 3'), findsOneWidget);
      });

      testWidgets('should show host badge for host player', (tester) async {
        await tester.pumpWidget(createWidget(isHorizontal: false));
        await pumpAndWait(tester);

        expect(find.byIcon(Icons.star_rounded), findsOneWidget);
      });

      testWidgets('should show waiting status for players without votes', (
        tester,
      ) async {
        await tester.pumpWidget(createWidget(isHorizontal: false));
        await pumpAndWait(tester);

        expect(find.text('Aguardando...'), findsNWidgets(3));
      });

      testWidgets('should show voted status when player votes', (tester) async {
        final sessionWithVote = testSession.copyWith(
          playedCards: {
            'player-2': PlayedCard(
              playerId: 'player-2',
              playerName: 'Player 2',
              cardValue: '5',
              playedAt: DateTime.now(),
            ),
          },
        );

        viewModel.initialize(sessionWithVote, testPlayer);

        await tester.pumpWidget(createWidget(isHorizontal: false));
        await pumpAndWait(tester);

        expect(find.text('Votou'), findsOneWidget);
      });

      testWidgets('should show card value when revealed', (tester) async {
        final revealedSession = testSession.copyWith(
          state: GameState.revealed,
          playedCards: {
            'player-2': PlayedCard(
              playerId: 'player-2',
              playerName: 'Player 2',
              cardValue: '8',
              playedAt: DateTime.now(),
            ),
          },
        );

        viewModel.initialize(revealedSession, testPlayer);

        await tester.pumpWidget(createWidget(isHorizontal: false));
        await pumpAndWait(tester);

        expect(find.text('Votou: 8'), findsOneWidget);
      });

      testWidgets('should use ListView for scrolling', (tester) async {
        await tester.pumpWidget(createWidget(isHorizontal: false));
        await pumpAndWait(tester);

        expect(find.byType(ListView), findsOneWidget);
      });
    });

    group('horizontal layout (mobile)', () {
      testWidgets('should display "Jogadores" header', (tester) async {
        await tester.pumpWidget(createWidget(isHorizontal: true));
        await pumpAndWait(tester);

        expect(find.text('Jogadores'), findsOneWidget);
      });

      testWidgets('should display all players horizontally', (tester) async {
        await tester.pumpWidget(createWidget(isHorizontal: true));
        await pumpAndWait(tester);

        expect(find.text('Test Player'), findsOneWidget);
        expect(find.text('Player 2'), findsOneWidget);
        expect(find.text('Player 3'), findsOneWidget);
      });

      testWidgets('should use horizontal ListView', (tester) async {
        await tester.pumpWidget(createWidget(isHorizontal: true));
        await pumpAndWait(tester);

        final listView = tester.widget<ListView>(find.byType(ListView));
        expect(listView.scrollDirection, equals(Axis.horizontal));
      });

      testWidgets('should show compact player cards', (tester) async {
        await tester.pumpWidget(createWidget(isHorizontal: true));
        await pumpAndWait(tester);

        // Players should be visible in compact mode
        expect(find.text('T'), findsOneWidget); // First letter of Test Player
        expect(
          find.text('P'),
          findsNWidgets(2),
        ); // First letter of Player 2 & 3
      });
    });

    group('player highlighting', () {
      testWidgets('should highlight current player', (tester) async {
        await tester.pumpWidget(createWidget(isHorizontal: false));
        await pumpAndWait(tester);

        // Current player should be displayed
        expect(find.text('Test Player'), findsOneWidget);
      });
    });

    group('vote indicators', () {
      testWidgets('should show check indicator for voted players', (
        tester,
      ) async {
        final sessionWithVotes = testSession.copyWith(
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

        viewModel.initialize(sessionWithVotes, testPlayer);

        await tester.pumpWidget(createWidget(isHorizontal: false));
        await pumpAndWait(tester);

        expect(find.byIcon(Icons.check_rounded), findsNWidgets(2));
      });

      testWidgets('should show hourglass for waiting players', (tester) async {
        await tester.pumpWidget(createWidget(isHorizontal: false));
        await pumpAndWait(tester);

        expect(find.byIcon(Icons.hourglass_empty_rounded), findsNWidgets(3));
      });
    });

    group('many players', () {
      testWidgets('should handle many players with scrolling', (tester) async {
        final manyPlayers = List.generate(
          10,
          (i) => Player(id: 'player-$i', name: 'Player $i'),
        );
        final sessionWithManyPlayers = testSession.copyWith(
          players: manyPlayers,
        );

        viewModel.initialize(sessionWithManyPlayers, manyPlayers.first);

        await tester.pumpWidget(createWidget(isHorizontal: false));
        await pumpAndWait(tester);

        // Should be able to scroll
        final listView = find.byType(ListView);
        await tester.drag(listView, const Offset(0, -200));
        await pumpAndWait(tester);
      });
    });
  });
}
