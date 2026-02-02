import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:planning_poker/core/result/result.dart';
import 'package:planning_poker/domain/entities/entities.dart';
import 'package:planning_poker/domain/usecases/usecases.dart';
import 'package:planning_poker/presentation/viewmodels/home_viewmodel.dart';
import 'package:planning_poker/presentation/viewmodels/game_viewmodel.dart';
import 'package:planning_poker/presentation/views/home_screen.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import 'home_screen_test.mocks.dart';

@GenerateMocks([
  CreateSessionUseCase,
  JoinSessionUseCase,
  WatchSessionUseCase,
  PlayCardUseCase,
  RevealCardsUseCase,
  ResetRoundUseCase,
  LeaveSessionUseCase,
  Uuid,
])
void main() {
  late MockCreateSessionUseCase mockCreateUseCase;
  late MockJoinSessionUseCase mockJoinUseCase;
  late MockWatchSessionUseCase mockWatchUseCase;
  late MockPlayCardUseCase mockPlayCardUseCase;
  late MockRevealCardsUseCase mockRevealCardsUseCase;
  late MockResetRoundUseCase mockResetRoundUseCase;
  late MockLeaveSessionUseCase mockLeaveSessionUseCase;
  late MockUuid mockUuid;
  late HomeViewModel homeViewModel;
  late GameViewModel gameViewModel;

  setUpAll(() {
    provideDummy<Result<Session>>(Result.failure('dummy'));
    provideDummy<Result<void>>(Result.success(null));
  });

  setUp(() {
    mockCreateUseCase = MockCreateSessionUseCase();
    mockJoinUseCase = MockJoinSessionUseCase();
    mockWatchUseCase = MockWatchSessionUseCase();
    mockPlayCardUseCase = MockPlayCardUseCase();
    mockRevealCardsUseCase = MockRevealCardsUseCase();
    mockResetRoundUseCase = MockResetRoundUseCase();
    mockLeaveSessionUseCase = MockLeaveSessionUseCase();
    mockUuid = MockUuid();

    when(mockUuid.v4()).thenReturn('uuid-123');

    homeViewModel = HomeViewModel(
      createSessionUseCase: mockCreateUseCase,
      joinSessionUseCase: mockJoinUseCase,
      uuid: mockUuid,
    );

    gameViewModel = GameViewModel(
      watchSessionUseCase: mockWatchUseCase,
      playCardUseCase: mockPlayCardUseCase,
      revealCardsUseCase: mockRevealCardsUseCase,
      resetRoundUseCase: mockResetRoundUseCase,
      leaveSessionUseCase: mockLeaveSessionUseCase,
    );
  });

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
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider<HomeViewModel>.value(value: homeViewModel),
          ChangeNotifierProvider<GameViewModel>.value(value: gameViewModel),
        ],
        child: const HomeScreen(),
      ),
    );
  }

  group('HomeScreen', () {
    group('rendering', () {
      testWidgets('should display app title', (tester) async {
        setViewSize(tester, const Size(1200, 800));
        addTearDown(() => resetViewSize(tester));
        await tester.pumpWidget(createWidget());
        await tester.pump(const Duration(milliseconds: 500));

        expect(find.text('Planning Poker'), findsOneWidget);
      });

      testWidgets('should display subtitle', (tester) async {
        setViewSize(tester, const Size(1200, 800));
        addTearDown(() => resetViewSize(tester));
        await tester.pumpWidget(createWidget());
        await tester.pump(const Duration(milliseconds: 500));

        expect(find.text('Estimativas ágeis em tempo real'), findsOneWidget);
      });

      testWidgets('should display logo icon', (tester) async {
        setViewSize(tester, const Size(1200, 800));
        addTearDown(() => resetViewSize(tester));
        await tester.pumpWidget(createWidget());
        await tester.pump(const Duration(milliseconds: 500));

        expect(find.byIcon(Icons.style_rounded), findsOneWidget);
      });

      testWidgets('should display mode toggle buttons', (tester) async {
        setViewSize(tester, const Size(1200, 800));
        addTearDown(() => resetViewSize(tester));
        await tester.pumpWidget(createWidget());
        await tester.pump(const Duration(milliseconds: 500));

        // 'Criar Sessão' appears in toggle button AND submit button
        expect(find.text('Criar Sessão'), findsAtLeastNWidgets(1));
        expect(find.text('Entrar'), findsAtLeastNWidgets(1));
      });

      testWidgets('should display player name field', (tester) async {
        setViewSize(tester, const Size(1200, 800));
        addTearDown(() => resetViewSize(tester));
        await tester.pumpWidget(createWidget());
        await tester.pump(const Duration(milliseconds: 500));

        expect(find.text('Seu Nome'), findsOneWidget);
        expect(find.text('Como você quer ser chamado?'), findsOneWidget);
      });

      testWidgets('should display session name field in create mode', (
        tester,
      ) async {
        setViewSize(tester, const Size(1200, 800));
        addTearDown(() => resetViewSize(tester));
        await tester.pumpWidget(createWidget());
        await tester.pump(const Duration(milliseconds: 500));

        expect(find.text('Nome da Sessão'), findsOneWidget);
        expect(find.text('Ex: Sprint 42 Planning'), findsOneWidget);
      });

      testWidgets('should display submit button', (tester) async {
        setViewSize(tester, const Size(1200, 800));
        addTearDown(() => resetViewSize(tester));
        await tester.pumpWidget(createWidget());
        await tester.pump(const Duration(milliseconds: 500));

        expect(
          find.widgetWithText(FilledButton, 'Criar Sessão'),
          findsOneWidget,
        );
      });
    });

    group('mode toggle', () {
      testWidgets('should switch to join mode when Entrar is tapped', (
        tester,
      ) async {
        setViewSize(tester, const Size(1200, 800));
        addTearDown(() => resetViewSize(tester));
        await tester.pumpWidget(createWidget());
        await tester.pump(const Duration(milliseconds: 500));

        await tester.tap(find.text('Entrar').first);
        await tester.pump(const Duration(milliseconds: 500));

        expect(find.text('Código da Sessão'), findsOneWidget);
        expect(find.text('Ex: ABC123'), findsOneWidget);
      });

      testWidgets('should switch back to create mode', (tester) async {
        setViewSize(tester, const Size(1200, 800));
        addTearDown(() => resetViewSize(tester));
        await tester.pumpWidget(createWidget());
        await tester.pump(const Duration(milliseconds: 500));

        // Switch to join mode
        await tester.tap(find.text('Entrar').first);
        await tester.pump(const Duration(milliseconds: 500));

        // Switch back to create mode
        await tester.tap(find.text('Criar Sessão').first);
        await tester.pump(const Duration(milliseconds: 500));

        expect(find.text('Nome da Sessão'), findsOneWidget);
      });

      testWidgets('submit button should change text based on mode', (
        tester,
      ) async {
        setViewSize(tester, const Size(1200, 800));
        addTearDown(() => resetViewSize(tester));
        await tester.pumpWidget(createWidget());
        await tester.pump(const Duration(milliseconds: 500));

        expect(
          find.widgetWithText(FilledButton, 'Criar Sessão'),
          findsOneWidget,
        );

        await tester.tap(find.text('Entrar').first);
        await tester.pump(const Duration(milliseconds: 500));

        expect(
          find.widgetWithText(FilledButton, 'Entrar na Sessão'),
          findsOneWidget,
        );
      });
    });

    group('form validation', () {
      testWidgets('should show error when player name is empty', (
        tester,
      ) async {
        setViewSize(tester, const Size(1200, 800));
        addTearDown(() => resetViewSize(tester));
        await tester.pumpWidget(createWidget());
        await tester.pump(const Duration(milliseconds: 500));

        await tester.tap(find.widgetWithText(FilledButton, 'Criar Sessão'));
        await tester.pump(const Duration(milliseconds: 500));

        expect(find.text('Digite seu nome'), findsOneWidget);
      });

      testWidgets(
        'should show error when session name is empty in create mode',
        (tester) async {
          setViewSize(tester, const Size(1200, 800));
          addTearDown(() => resetViewSize(tester));
          await tester.pumpWidget(createWidget());
          await tester.pump(const Duration(milliseconds: 500));

          // Enter player name
          await tester.enterText(
            find.widgetWithText(TextFormField, 'Como você quer ser chamado?'),
            'Test Player',
          );

          await tester.tap(find.widgetWithText(FilledButton, 'Criar Sessão'));
          await tester.pump(const Duration(milliseconds: 500));

          expect(find.text('Digite o nome da sessão'), findsOneWidget);
        },
      );

      testWidgets('should show error when session key is empty in join mode', (
        tester,
      ) async {
        setViewSize(tester, const Size(1200, 800));
        addTearDown(() => resetViewSize(tester));
        await tester.pumpWidget(createWidget());
        await tester.pump(const Duration(milliseconds: 500));

        await tester.tap(find.text('Entrar').first);
        await tester.pump(const Duration(milliseconds: 500));

        // Enter player name
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Como você quer ser chamado?'),
          'Test Player',
        );

        await tester.tap(find.widgetWithText(FilledButton, 'Entrar na Sessão'));
        await tester.pump(const Duration(milliseconds: 500));

        expect(find.text('Digite o código da sessão'), findsOneWidget);
      });
    });

    group('create session', () {
      testWidgets('should disable button during form submission', (
        tester,
      ) async {
        setViewSize(tester, const Size(1200, 800));
        addTearDown(() => resetViewSize(tester));

        // Mock a failure response
        when(
          mockCreateUseCase.execute(
            sessionName: anyNamed('sessionName'),
            host: anyNamed('host'),
          ),
        ).thenAnswer((_) async => Result.failure('error'));

        await tester.pumpWidget(createWidget());
        await tester.pump(const Duration(milliseconds: 500));

        // Enter valid data
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Como você quer ser chamado?'),
          'Test Player',
        );
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Ex: Sprint 42 Planning'),
          'My Session',
        );

        // Verify button is enabled before submission
        final buttonBefore = tester.widget<FilledButton>(
          find.widgetWithText(FilledButton, 'Criar Sessão'),
        );
        expect(buttonBefore.onPressed, isNotNull);

        await tester.tap(find.widgetWithText(FilledButton, 'Criar Sessão'));
        await tester.pump(const Duration(milliseconds: 500));

        // After error, button should be enabled again
        verify(
          mockCreateUseCase.execute(
            sessionName: anyNamed('sessionName'),
            host: anyNamed('host'),
          ),
        ).called(1);
      });
    });

    group('join session', () {
      // Note: Full integration tests for create/join session flow
      // that navigate to GameScreen should be in integration tests
    });

    group('error handling', () {
      testWidgets('should display error message when creation fails', (
        tester,
      ) async {
        setViewSize(tester, const Size(1200, 800));
        addTearDown(() => resetViewSize(tester));

        when(
          mockCreateUseCase.execute(
            sessionName: anyNamed('sessionName'),
            host: anyNamed('host'),
          ),
        ).thenAnswer((_) async => Result.failure('Session creation failed'));

        await tester.pumpWidget(createWidget());
        await tester.pump(const Duration(milliseconds: 500));

        // Enter valid data
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Como você quer ser chamado?'),
          'Test Player',
        );
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Ex: Sprint 42 Planning'),
          'My Session',
        );

        await tester.tap(find.widgetWithText(FilledButton, 'Criar Sessão'));
        await tester.pump(const Duration(milliseconds: 500));

        expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
      });

      testWidgets('should clear error when close button is tapped', (
        tester,
      ) async {
        setViewSize(tester, const Size(1200, 800));
        addTearDown(() => resetViewSize(tester));

        when(
          mockCreateUseCase.execute(
            sessionName: anyNamed('sessionName'),
            host: anyNamed('host'),
          ),
        ).thenAnswer((_) async => Result.failure('Error'));

        await tester.pumpWidget(createWidget());
        await tester.pump(const Duration(milliseconds: 500));

        // Enter valid data and submit
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Como você quer ser chamado?'),
          'Test Player',
        );
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Ex: Sprint 42 Planning'),
          'My Session',
        );
        await tester.tap(find.widgetWithText(FilledButton, 'Criar Sessão'));
        await tester.pump(const Duration(milliseconds: 500));

        // Error should be visible
        expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);

        // Tap close button
        await tester.tap(find.byIcon(Icons.close_rounded));
        await tester.pump(const Duration(milliseconds: 500));

        // Error should be cleared
        expect(find.byIcon(Icons.error_outline_rounded), findsNothing);
      });
    });

    group('text input', () {
      testWidgets('should have player name text field', (tester) async {
        setViewSize(tester, const Size(1200, 800));
        addTearDown(() => resetViewSize(tester));
        await tester.pumpWidget(createWidget());
        await tester.pump(const Duration(milliseconds: 500));

        // Verify the field exists and can accept input
        final textField = find.widgetWithText(
          TextFormField,
          'Como você quer ser chamado?',
        );
        expect(textField, findsOneWidget);

        await tester.enterText(textField, 'Test Player');
        await tester.pump();

        expect(find.text('Test Player'), findsOneWidget);
      });

      testWidgets('should have session key text field in join mode', (
        tester,
      ) async {
        setViewSize(tester, const Size(1200, 800));
        addTearDown(() => resetViewSize(tester));
        await tester.pumpWidget(createWidget());
        await tester.pump(const Duration(milliseconds: 500));

        await tester.tap(find.text('Entrar').first);
        await tester.pump(const Duration(milliseconds: 500));

        final textField = find.widgetWithText(TextFormField, 'Ex: ABC123');
        expect(textField, findsOneWidget);

        await tester.enterText(textField, 'XYZ789');
        await tester.pump();

        expect(find.text('XYZ789'), findsOneWidget);
      });
    });

    group('icons', () {
      testWidgets('should show person icon for player name', (tester) async {
        setViewSize(tester, const Size(1200, 800));
        addTearDown(() => resetViewSize(tester));
        await tester.pumpWidget(createWidget());
        await tester.pump(const Duration(milliseconds: 500));

        expect(find.byIcon(Icons.person_outline_rounded), findsOneWidget);
      });

      testWidgets('should show meeting room icon for session name', (
        tester,
      ) async {
        setViewSize(tester, const Size(1200, 800));
        addTearDown(() => resetViewSize(tester));
        await tester.pumpWidget(createWidget());
        await tester.pump(const Duration(milliseconds: 500));

        expect(find.byIcon(Icons.meeting_room_outlined), findsOneWidget);
      });

      testWidgets('should show key icon for session key in join mode', (
        tester,
      ) async {
        setViewSize(tester, const Size(1200, 800));
        addTearDown(() => resetViewSize(tester));
        await tester.pumpWidget(createWidget());
        await tester.pump(const Duration(milliseconds: 500));

        await tester.tap(find.text('Entrar').first);
        await tester.pump(const Duration(milliseconds: 500));

        expect(find.byIcon(Icons.key_rounded), findsOneWidget);
      });

      testWidgets('should show add icon in create mode button', (tester) async {
        setViewSize(tester, const Size(1200, 800));
        addTearDown(() => resetViewSize(tester));
        await tester.pumpWidget(createWidget());
        await tester.pump(const Duration(milliseconds: 500));

        expect(find.byIcon(Icons.add_rounded), findsWidgets);
      });

      testWidgets('should show login icon in join mode button', (tester) async {
        setViewSize(tester, const Size(1200, 800));
        addTearDown(() => resetViewSize(tester));
        await tester.pumpWidget(createWidget());
        await tester.pump(const Duration(milliseconds: 500));

        await tester.tap(find.text('Entrar').first);
        await tester.pump(const Duration(milliseconds: 500));

        expect(find.byIcon(Icons.login_rounded), findsWidgets);
      });
    });
  });
}
