import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:planning_poker/core/result/result.dart';
import 'package:planning_poker/domain/entities/entities.dart';
import 'package:planning_poker/domain/usecases/usecases.dart';
import 'package:planning_poker/presentation/viewmodels/game_viewmodel.dart';
import 'package:planning_poker/presentation/views/game_screen.dart';
import 'package:provider/provider.dart';

import 'game_screen_test.mocks.dart';

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

  final testSession = Session(
    id: 'session-1',
    sessionKey: 'ABC123',
    hostId: 'player-1',
    name: 'Test Session',
    state: GameState.voting,
    players: [hostPlayer, regularPlayer],
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

  void setViewSize(WidgetTester tester, Size size) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
  }

  void resetViewSize(WidgetTester tester) {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  }

  Widget createWidget({Session? session, Player? player}) {
    return MaterialApp(
      home: ChangeNotifierProvider<GameViewModel>.value(
        value: viewModel,
        child: GameScreen(
          session: session ?? testSession,
          player: player ?? hostPlayer,
        ),
      ),
    );
  }

  const desktopSize = Size(1200, 800);

  // NOTA: Testes de Loading foram removidos porque o GameScreen.initState()
  // sempre chama viewModel.initialize() automaticamente via addPostFrameCallback.
  // O estado de loading é efêmero e não pode ser testado de forma confiável.

  group('GameScreen - Estado Active (session != null)', () {
    setUp(() {
      viewModel.initialize(testSession, hostPlayer);
      sessionStreamController.add(testSession);
    });

    testWidgets('exibe nome da sessão', (tester) async {
      setViewSize(tester, desktopSize);
      addTearDown(() => resetViewSize(tester));

      await tester.pumpWidget(createWidget());
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Test Session'), findsOneWidget);
    });

    testWidgets('exibe código da sessão', (tester) async {
      setViewSize(tester, desktopSize);
      addTearDown(() => resetViewSize(tester));

      await tester.pumpWidget(createWidget());
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('ABC123'), findsOneWidget);
    });

    testWidgets('exibe contagem de jogadores', (tester) async {
      setViewSize(tester, desktopSize);
      addTearDown(() => resetViewSize(tester));

      await tester.pumpWidget(createWidget());
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('2 jogadores'), findsOneWidget);
    });

    testWidgets('exibe painel de jogadores', (tester) async {
      setViewSize(tester, desktopSize);
      addTearDown(() => resetViewSize(tester));

      await tester.pumpWidget(createWidget());
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Jogadores'), findsOneWidget);
    });

    testWidgets('exibe área de seleção de cartas', (tester) async {
      setViewSize(tester, desktopSize);
      addTearDown(() => resetViewSize(tester));

      await tester.pumpWidget(createWidget());
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Suas Cartas'), findsOneWidget);
    });

    testWidgets('exibe mesa de votação', (tester) async {
      setViewSize(tester, desktopSize);
      addTearDown(() => resetViewSize(tester));

      await tester.pumpWidget(createWidget());
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Aguardando votos...'), findsOneWidget);
    });
  });

  group('GameScreen - Host vs Não-Host', () {
    testWidgets('host vê botões de controle', (tester) async {
      setViewSize(tester, desktopSize);
      addTearDown(() => resetViewSize(tester));

      viewModel.initialize(testSession, hostPlayer);
      sessionStreamController.add(testSession);

      await tester.pumpWidget(createWidget(player: hostPlayer));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Revelar Cartas'), findsOneWidget);
      expect(find.text('Nova Rodada'), findsOneWidget);
    });

    testWidgets('não-host não vê botões de controle', (tester) async {
      setViewSize(tester, desktopSize);
      addTearDown(() => resetViewSize(tester));

      viewModel.initialize(testSession, regularPlayer);
      sessionStreamController.add(testSession);

      await tester.pumpWidget(createWidget(player: regularPlayer));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Revelar Cartas'), findsNothing);
      expect(find.text('Nova Rodada'), findsNothing);
    });
  });

  group('GameScreen - Estado de Votação', () {
    testWidgets('exibe carta escondida durante votação', (tester) async {
      setViewSize(tester, desktopSize);
      addTearDown(() => resetViewSize(tester));

      final sessionWithVote = testSession.copyWith(
        state: GameState.voting,
        playedCards: {
          'player-1': PlayedCard(
            playerId: 'player-1',
            playerName: 'Host Player',
            cardValue: '5',
            playedAt: DateTime.now(),
          ),
        },
      );

      viewModel.initialize(sessionWithVote, hostPlayer);
      sessionStreamController.add(sessionWithVote);

      await tester.pumpWidget(createWidget(session: sessionWithVote));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byIcon(Icons.question_mark_rounded), findsOneWidget);
    });

    testWidgets('exibe valor da carta quando revelado', (tester) async {
      setViewSize(tester, desktopSize);
      addTearDown(() => resetViewSize(tester));

      final revealedSession = testSession.copyWith(
        state: GameState.revealed,
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
        },
      );

      viewModel.initialize(revealedSession, hostPlayer);
      sessionStreamController.add(revealedSession);

      await tester.pumpWidget(createWidget(session: revealedSession));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('5'), findsWidgets);
      expect(find.text('8'), findsWidgets);
    });
  });

  group('GameScreen - Estado Error', () {
    testWidgets('exibe dialog quando sessão é encerrada', (tester) async {
      setViewSize(tester, desktopSize);
      addTearDown(() => resetViewSize(tester));

      viewModel.initialize(testSession, hostPlayer);
      sessionStreamController.add(testSession);

      await tester.pumpWidget(createWidget());
      await tester.pump(const Duration(milliseconds: 300));

      // Simula a sessão sendo encerrada pelo host
      sessionStreamController.add(null);
      // Processa o notifyListeners e o rebuild do widget
      await tester.pump();
      // Processa o addPostFrameCallback que mostra o dialog
      await tester.pump();
      // Processa a animação do dialog
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Sessão Encerrada'), findsOneWidget);
    });
  });

  group('GameScreen - Interações', () {
    testWidgets('tap em carta chama selectCard', (tester) async {
      setViewSize(tester, desktopSize);
      addTearDown(() => resetViewSize(tester));

      when(
        mockPlayCardUseCase.execute(
          sessionId: anyNamed('sessionId'),
          playerId: anyNamed('playerId'),
          playerName: anyNamed('playerName'),
          cardValue: anyNamed('cardValue'),
        ),
      ).thenAnswer((_) async => Result.success(null));

      viewModel.initialize(testSession, hostPlayer);
      sessionStreamController.add(testSession);

      await tester.pumpWidget(createWidget());
      await tester.pump(const Duration(milliseconds: 300));

      await tester.tap(find.text('5').first);
      await tester.pump();

      verify(
        mockPlayCardUseCase.execute(
          sessionId: 'session-1',
          playerId: 'player-1',
          playerName: 'Host Player',
          cardValue: '5',
        ),
      ).called(1);
    });

    testWidgets('tap em voltar abre dialog de confirmação', (tester) async {
      setViewSize(tester, desktopSize);
      addTearDown(() => resetViewSize(tester));

      viewModel.initialize(testSession, hostPlayer);
      sessionStreamController.add(testSession);

      await tester.pumpWidget(createWidget());
      await tester.pump(const Duration(milliseconds: 300));

      await tester.tap(find.byIcon(Icons.arrow_back_rounded));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Sair da Sessão'), findsOneWidget);
    });

    testWidgets('copiar código mostra snackbar', (tester) async {
      setViewSize(tester, desktopSize);
      addTearDown(() => resetViewSize(tester));

      viewModel.initialize(testSession, hostPlayer);
      sessionStreamController.add(testSession);

      await tester.pumpWidget(createWidget());
      await tester.pump(const Duration(milliseconds: 300));

      await tester.tap(find.text('ABC123'));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Código copiado: ABC123'), findsOneWidget);
    });

    testWidgets('confirmar sair chama leaveSession', (tester) async {
      setViewSize(tester, desktopSize);
      addTearDown(() => resetViewSize(tester));

      when(
        mockLeaveSessionUseCase.execute(
          sessionId: anyNamed('sessionId'),
          playerId: anyNamed('playerId'),
        ),
      ).thenAnswer((_) async => Result.success(null));

      viewModel.initialize(testSession, hostPlayer);
      sessionStreamController.add(testSession);

      await tester.pumpWidget(createWidget());
      await tester.pump(const Duration(milliseconds: 300));

      await tester.tap(find.byIcon(Icons.arrow_back_rounded));
      await tester.pump(const Duration(milliseconds: 300));

      await tester.tap(find.widgetWithText(FilledButton, 'Sair'));
      await tester.pump(const Duration(milliseconds: 300));

      verify(
        mockLeaveSessionUseCase.execute(
          sessionId: 'session-1',
          playerId: 'player-1',
        ),
      ).called(1);
    });
  });

  group('GameScreen - Stream Updates', () {
    testWidgets('atualiza quando novo jogador entra', (tester) async {
      setViewSize(tester, desktopSize);
      addTearDown(() => resetViewSize(tester));

      viewModel.initialize(testSession, hostPlayer);
      sessionStreamController.add(testSession);

      await tester.pumpWidget(createWidget());
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('2 jogadores'), findsOneWidget);

      final updatedSession = testSession.copyWith(
        players: [
          ...testSession.players,
          Player(id: 'p3', name: 'Player 3'),
        ],
      );
      sessionStreamController.add(updatedSession);
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('3 jogadores'), findsOneWidget);
    });
  });
}
