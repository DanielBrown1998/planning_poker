import '../../domain/usecases/usecases.dart';
import 'command.dart';

/// Command for playing a card
class PlayCardCommand extends ObservableCommand<void> {
  final String sessionId;
  final String playerId;
  final String playerName;
  final String cardValue;

  PlayCardCommand({
    required PlayCardUseCase useCase,
    required this.sessionId,
    required this.playerId,
    required this.playerName,
    required this.cardValue,
  }) : super(() async {
         final result = await useCase.execute(
           sessionId: sessionId,
           playerId: playerId,
           playerName: playerName,
           cardValue: cardValue,
         );
         return result.when(
           success: (_) {},
           failure: (message) => throw Exception(message),
         );
       });
}

/// Command for revealing cards
class RevealCardsCommand extends ObservableCommand<void> {
  final String sessionId;

  RevealCardsCommand({
    required RevealCardsUseCase useCase,
    required this.sessionId,
  }) : super(() async {
         final result = await useCase.execute(sessionId);
         return result.when(
           success: (_) {},
           failure: (message) => throw Exception(message),
         );
       });
}

/// Command for resetting a round
class ResetRoundCommand extends ObservableCommand<void> {
  final String sessionId;

  ResetRoundCommand({
    required ResetRoundUseCase useCase,
    required this.sessionId,
  }) : super(() async {
         final result = await useCase.execute(sessionId);
         return result.when(
           success: (_) {},
           failure: (message) => throw Exception(message),
         );
       });
}

/// Command for leaving a session
class LeaveSessionCommand extends ObservableCommand<void> {
  final String sessionId;
  final String playerId;

  LeaveSessionCommand({
    required LeaveSessionUseCase useCase,
    required this.sessionId,
    required this.playerId,
  }) : super(() async {
         final result = await useCase.execute(
           sessionId: sessionId,
           playerId: playerId,
         );
         return result.when(
           success: (_) {},
           failure: (message) => throw Exception(message),
         );
       });
}
