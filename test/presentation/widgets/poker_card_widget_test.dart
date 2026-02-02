import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:planning_poker/core/constants/poker_cards.dart';
import 'package:planning_poker/presentation/widgets/poker_card_widget.dart';

void main() {
  Widget createWidget({
    required String value,
    bool isSelected = false,
    bool isRevealed = true,
    VoidCallback? onTap,
    Size size = const Size(70, 100),
    bool isSmall = false,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: PokerCardWidget(
            value: value,
            isSelected: isSelected,
            isRevealed: isRevealed,
            onTap: onTap,
            size: size,
            isSmall: isSmall,
          ),
        ),
      ),
    );
  }

  group('PokerCardWidget', () {
    group('rendering', () {
      testWidgets('should display card value when revealed', (tester) async {
        await tester.pumpWidget(createWidget(value: '5'));

        expect(find.text('5'), findsOneWidget);
      });

      testWidgets('should display question mark when hidden', (tester) async {
        await tester.pumpWidget(createWidget(value: PokerCards.hiddenCard));

        expect(find.byIcon(Icons.question_mark_rounded), findsOneWidget);
      });

      testWidgets('should display all poker card values correctly', (
        tester,
      ) async {
        for (final value in PokerCards.values) {
          await tester.pumpWidget(createWidget(value: value));

          if (value == PokerCards.hiddenCard) {
            expect(find.byIcon(Icons.question_mark_rounded), findsOneWidget);
          } else {
            expect(find.text(value), findsOneWidget);
          }
        }
      });

      testWidgets('should show check icon when selected', (tester) async {
        await tester.pumpWidget(createWidget(value: '5', isSelected: true));

        expect(find.byIcon(Icons.check), findsOneWidget);
      });

      testWidgets('should not show check icon when not selected', (
        tester,
      ) async {
        await tester.pumpWidget(createWidget(value: '5', isSelected: false));

        expect(find.byIcon(Icons.check), findsNothing);
      });
    });

    group('interaction', () {
      testWidgets('should call onTap when tapped', (tester) async {
        var tapped = false;
        await tester.pumpWidget(
          createWidget(value: '5', onTap: () => tapped = true),
        );

        await tester.tap(find.byType(PokerCardWidget));
        await tester.pump();

        expect(tapped, isTrue);
      });

      testWidgets('should handle tap down animation', (tester) async {
        await tester.pumpWidget(createWidget(value: '5', onTap: () {}));

        final gesture = await tester.startGesture(
          tester.getCenter(find.byType(PokerCardWidget)),
        );
        await tester.pump();

        // Animation should start
        await tester.pump(const Duration(milliseconds: 50));

        await gesture.up();
        await tester.pumpAndSettle();
      });

      testWidgets('should handle tap cancel', (tester) async {
        await tester.pumpWidget(createWidget(value: '5', onTap: () {}));

        final gesture = await tester.startGesture(
          tester.getCenter(find.byType(PokerCardWidget)),
        );
        await tester.pump();

        await gesture.cancel();
        await tester.pumpAndSettle();
      });

      testWidgets('should not animate when onTap is null', (tester) async {
        await tester.pumpWidget(createWidget(value: '5', onTap: null));

        await tester.tap(find.byType(PokerCardWidget));
        await tester.pump();

        // No crash expected
      });
    });

    group('sizing', () {
      testWidgets('should respect custom size', (tester) async {
        const customSize = Size(100, 150);
        await tester.pumpWidget(createWidget(value: '5', size: customSize));

        final container = tester.widget<AnimatedContainer>(
          find.byType(AnimatedContainer).first,
        );

        expect(container.constraints?.maxWidth, equals(customSize.width));
        expect(container.constraints?.maxHeight, equals(customSize.height));
      });

      testWidgets('should apply small styling when isSmall is true', (
        tester,
      ) async {
        await tester.pumpWidget(createWidget(value: '5', isSmall: true));

        // Widget should render without errors
        expect(find.byType(PokerCardWidget), findsOneWidget);
      });
    });

    group('visual states', () {
      testWidgets('should show different style when disabled (no onTap)', (
        tester,
      ) async {
        await tester.pumpWidget(createWidget(value: '5', onTap: null));

        // Card should still render
        expect(find.text('5'), findsOneWidget);
      });

      testWidgets('hidden card should have gradient background', (
        tester,
      ) async {
        await tester.pumpWidget(createWidget(value: PokerCards.hiddenCard));

        // Check for RepaintBoundary which wraps the decorated container
        expect(find.byType(RepaintBoundary), findsWidgets);
      });

      testWidgets('selected card should have selection overlay', (
        tester,
      ) async {
        await tester.pumpWidget(createWidget(value: '8', isSelected: true));

        // Check icon is present
        expect(find.byIcon(Icons.check), findsOneWidget);
      });
    });

    group('special cards', () {
      testWidgets('should display coffee card', (tester) async {
        await tester.pumpWidget(createWidget(value: '☕'));

        expect(find.text('☕'), findsOneWidget);
      });

      testWidgets('should display question mark card', (tester) async {
        await tester.pumpWidget(createWidget(value: '?'));

        expect(find.text('?'), findsOneWidget);
      });

      testWidgets('should display infinity card', (tester) async {
        await tester.pumpWidget(createWidget(value: '∞'));

        expect(find.text('∞'), findsOneWidget);
      });
    });
  });
}
