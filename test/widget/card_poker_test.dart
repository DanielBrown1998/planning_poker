import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:planning_poker/view/components/card.dart';

void main() {
  testWidgets('CardPoker displays correctly and flips', (
    WidgetTester tester,
  ) async {
    final cardValue = 5;
    final colorCard = Colors.blue;
    final symbolCard = '♠';

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CardPoker(
            cardValue: cardValue,
            colorCard: colorCard,
            symbolCard: symbolCard,
            isFlipped: false,
            flipOnTouch: true,
          ),
        ),
      ),
    );

    // Initially, the back of the card should be shown
    expect(find.text(symbolCard), findsOneWidget);
    // expect(find.text(cardValue.toString()), findsNothing);

    // Tap to flip the card
    await tester.tap(find.byType(FlipCard));
    await tester.pumpAndSettle();

    // After flipping, the front of the card should be shown
    expect(find.text(cardValue.toString()), findsNWidgets(5));
    // expect(find.text(symbolCard), findsNothing);
  });
}
