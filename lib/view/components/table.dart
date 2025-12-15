import 'package:flutter/material.dart';
import 'package:planning_poker/view/components/card.dart';

class TablePoker extends StatefulWidget {
  final List<CardPoker> cards;
  const TablePoker({super.key, required this.cards});

  @override
  State<TablePoker> createState() => _TablePokerState();
}

class _TablePokerState extends State<TablePoker> {
  CardPoker card = CardPoker(
    cardValue: '🃏',
    colorCard: Colors.amber,
    symbolCard: 'Planning Poker',
  );

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return DragTarget<CardPoker>(
      builder: (context, candidateData, rejectedData) {
        return Container(
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 3, 113, 6).withAlpha(200),
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Stack(
            children: [
              Positioned(
                top: 10,
                bottom: .5,
                left: 10,
                right: 10,
                child: Row(
                  children: [
                    Expanded(
                      child: GridView.count(
                        childAspectRatio:
                            (size.width * 1.1) / (size.height * .7),
                        crossAxisCount: widget.cards.length > 8 ? 6 : 4,
                        children: List<Widget>.generate(
                          widget.cards.length,
                          (index) => SizedBox(
                            height: size.width * .3,
                            width: size.width * .225,
                            child: widget.cards[index],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  height: size.width * .3,
                  width: size.width * .225,
                  child: card,
                ),
              ),
            ],
          ),
        );
      },
      onAcceptWithDetails: (details) {
        setState(() {
          card = details.data;
        });
      },
    );
  }
}
