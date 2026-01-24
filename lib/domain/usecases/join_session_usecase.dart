import '../../core/result/result.dart';
import '../entities/session.dart';
import '../entities/player.dart';
import '../repositories/session_repository.dart';

/// Use case for joining an existing planning poker session
class JoinSessionUseCase {
  final SessionRepository _repository;

  JoinSessionUseCase(this._repository);

  Future<Result<Session>> execute({
    required String sessionKey,
    required Player player,
  }) async {
    try {
      final session = await _repository.joinSession(
        sessionKey: sessionKey,
        player: player,
      );

      if (session == null) {
        return Result.failure('Sessão não encontrada com a chave: $sessionKey');
      }

      return Result.success(session);
    } catch (e) {
      return Result.failure('Falha ao entrar na sessão: ${e.toString()}');
    }
  }
}
