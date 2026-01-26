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
