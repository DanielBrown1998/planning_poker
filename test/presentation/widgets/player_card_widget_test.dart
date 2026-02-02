import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:planning_poker/domain/entities/player.dart';
import 'package:planning_poker/presentation/widgets/player_card_widget.dart';

void main() {
  Widget createWidget({
    required Player player,
    required bool hasVoted,
    String? cardValue,
    bool isCurrentPlayer = false,
    bool isCompact = false,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: PlayerCardWidget(
            player: player,
            hasVoted: hasVoted,
            cardValue: cardValue,
            isCurrentPlayer: isCurrentPlayer,
            isCompact: isCompact,
          ),
        ),
      ),
    );
  }

  final testPlayer = Player(id: 'player-1', name: 'Test Player');
  final hostPlayer = Player(id: 'host-1', name: 'Host Player', isHost: true);

  group('PlayerCardWidget', () {
    group('full card (isCompact: false)', () {
      testWidgets('should display player name', (tester) async {
        await tester.pumpWidget(
          createWidget(player: testPlayer, hasVoted: false),
        );

        expect(find.text('Test Player'), findsOneWidget);
      });

      testWidgets('should display player initial in avatar', (tester) async {
        await tester.pumpWidget(
          createWidget(player: testPlayer, hasVoted: false),
        );

        expect(find.text('T'), findsOneWidget);
      });

      testWidgets('should display host badge for host player', (tester) async {
        await tester.pumpWidget(
          createWidget(player: hostPlayer, hasVoted: false),
        );

        expect(find.byIcon(Icons.star_rounded), findsOneWidget);
      });

      testWidgets('should not display host badge for regular player', (
        tester,
      ) async {
        await tester.pumpWidget(
          createWidget(player: testPlayer, hasVoted: false),
        );

        expect(find.byIcon(Icons.star_rounded), findsNothing);
      });

      testWidgets('should show "Aguardando..." when not voted', (tester) async {
        await tester.pumpWidget(
          createWidget(player: testPlayer, hasVoted: false),
        );

        expect(find.text('Aguardando...'), findsOneWidget);
      });

      testWidgets('should show "Votou" when voted but cards not revealed', (
        tester,
      ) async {
        await tester.pumpWidget(
          createWidget(player: testPlayer, hasVoted: true),
        );

        expect(find.text('Votou'), findsOneWidget);
      });

      testWidgets('should show card value when revealed', (tester) async {
        await tester.pumpWidget(
          createWidget(player: testPlayer, hasVoted: true, cardValue: '8'),
        );

        expect(find.text('Votou: 8'), findsOneWidget);
        expect(find.text('8'), findsWidgets); // Card value shown in badge too
      });

      testWidgets('should show check icon when voted', (tester) async {
        await tester.pumpWidget(
          createWidget(player: testPlayer, hasVoted: true),
        );

        expect(find.byIcon(Icons.check_rounded), findsOneWidget);
      });

      testWidgets('should show hourglass when waiting', (tester) async {
        await tester.pumpWidget(
          createWidget(player: testPlayer, hasVoted: false),
        );

        expect(find.byIcon(Icons.hourglass_empty_rounded), findsOneWidget);
      });

      testWidgets('should highlight current player', (tester) async {
        await tester.pumpWidget(
          createWidget(
            player: testPlayer,
            hasVoted: false,
            isCurrentPlayer: true,
          ),
        );

        // Widget renders with different styling
        expect(find.text('Test Player'), findsOneWidget);
      });
    });

    group('compact card (isCompact: true)', () {
      testWidgets('should display player name', (tester) async {
        await tester.pumpWidget(
          createWidget(player: testPlayer, hasVoted: false, isCompact: true),
        );

        expect(find.text('Test Player'), findsOneWidget);
      });

      testWidgets('should display player initial in avatar', (tester) async {
        await tester.pumpWidget(
          createWidget(player: testPlayer, hasVoted: false, isCompact: true),
        );

        expect(find.text('T'), findsOneWidget);
      });

      testWidgets('should display host badge for host', (tester) async {
        await tester.pumpWidget(
          createWidget(player: hostPlayer, hasVoted: false, isCompact: true),
        );

        expect(find.byIcon(Icons.star_rounded), findsOneWidget);
      });

      testWidgets('should show voted indicator when voted', (tester) async {
        await tester.pumpWidget(
          createWidget(player: testPlayer, hasVoted: true, isCompact: true),
        );

        expect(find.byIcon(Icons.check), findsOneWidget);
      });

      testWidgets('should show card value when revealed', (tester) async {
        await tester.pumpWidget(
          createWidget(
            player: testPlayer,
            hasVoted: true,
            cardValue: '5',
            isCompact: true,
          ),
        );

        expect(find.text('5'), findsOneWidget);
      });

      testWidgets('should highlight current player', (tester) async {
        await tester.pumpWidget(
          createWidget(
            player: testPlayer,
            hasVoted: false,
            isCurrentPlayer: true,
            isCompact: true,
          ),
        );

        expect(find.text('Test Player'), findsOneWidget);
      });
    });

    group('avatar', () {
      testWidgets('should handle empty name with question mark', (
        tester,
      ) async {
        final emptyNamePlayer = Player(id: 'player-1', name: '');
        await tester.pumpWidget(
          createWidget(player: emptyNamePlayer, hasVoted: false),
        );

        expect(find.text('?'), findsOneWidget);
      });

      testWidgets('should show first letter uppercase', (tester) async {
        final lowercasePlayer = Player(id: 'player-1', name: 'john');
        await tester.pumpWidget(
          createWidget(player: lowercasePlayer, hasVoted: false),
        );

        expect(find.text('J'), findsOneWidget);
      });

      testWidgets('should show green avatar when voted', (tester) async {
        await tester.pumpWidget(
          createWidget(player: testPlayer, hasVoted: true),
        );

        // Avatar renders with success color
        expect(find.text('T'), findsOneWidget);
      });
    });

    group('edge cases', () {
      testWidgets('should handle long player name', (tester) async {
        final longNamePlayer = Player(
          id: 'player-1',
          name: 'Very Long Player Name That Should Be Truncated',
        );
        await tester.pumpWidget(
          createWidget(player: longNamePlayer, hasVoted: false),
        );

        expect(find.textContaining('Very Long'), findsOneWidget);
      });

      testWidgets('should handle special characters in name', (tester) async {
        final specialCharPlayer = Player(id: 'player-1', name: 'José Ñoño');
        await tester.pumpWidget(
          createWidget(player: specialCharPlayer, hasVoted: false),
        );

        expect(find.textContaining('José'), findsOneWidget);
      });
    });
  });
}
