import '../../domain/entities/entities.dart';
import '../../domain/usecases/usecases.dart';
import 'command.dart';

/// Command for creating a new session
class CreateSessionCommand extends ObservableCommand<Session?> {
  final String sessionName;
  final Player host;

  CreateSessionCommand({
    required CreateSessionUseCase useCase,
    required this.sessionName,
    required this.host,
  }) : super(() async {
         final result = await useCase.execute(
           sessionName: sessionName,
           host: host,
         );
         return result.when(
           success: (session) => session,
           failure: (message) => throw Exception(message),
         );
       });
}

/// Command for joining an existing session
class JoinSessionCommand extends ObservableCommand<Session?> {
  final String sessionKey;
  final Player player;

  JoinSessionCommand({
    required JoinSessionUseCase useCase,
    required this.sessionKey,
    required this.player,
  }) : super(() async {
         final result = await useCase.execute(
           sessionKey: sessionKey,
           player: player,
         );
         return result.when(
           success: (session) => session,
           failure: (message) => throw Exception(message),
         );
       });
}

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
