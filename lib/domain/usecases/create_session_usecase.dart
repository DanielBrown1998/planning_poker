import '../../core/result/result.dart';
import '../entities/session.dart';
import '../entities/player.dart';
import '../repositories/session_repository.dart';

/// Use case for creating a new planning poker session
class CreateSessionUseCase {
  final SessionRepository _repository;

  CreateSessionUseCase(this._repository);

  Future<Result<Session>> execute({
    required String sessionName,
    required Player host,
  }) async {
    try {
      final session = await _repository.createSession(
        name: sessionName,
        host: host,
      );
      return Result.success(session);
    } catch (e) {
      return Result.failure('Falha ao criar sessão: ${e.toString()}');
    }
  }
}
