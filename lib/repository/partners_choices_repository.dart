import 'dart:async';
import 'dart:math';

import 'package:planning_poker/model/choices.dart';
import 'package:planning_poker/view/components/get_all_cards.dart';

class PartnersChoicesRepository {
  PartnersChoicesRepository();

  //from realtime database by firebase at future
  StreamController<List<ChoiceAndUser>> partnersChoicesStreamController =
      StreamController<List<ChoiceAndUser>>.broadcast();

  //Mocked function to simulate getting choices from partners
  Stream<ChoiceAndUser> getChoicesByPartners(int numChoices) async* {
    final cards = GetAllCards.getAllCards();
    final max = cards.length;

    for (int i = 0; i < numChoices; i++) {
      Random random = Random();
      int choiceRandom = random.nextInt(max);
      final choice = ChoiceAndUser(
        value: cards[choiceRandom].cardValue,
        symbol: cards[choiceRandom].symbolCard,
        nome: 'Partner_${i + 1}',
      );
      await Future.delayed(const Duration(seconds: 3));
      yield choice;
    }
  }
}
