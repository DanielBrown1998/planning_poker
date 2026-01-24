import '../../core/result/result.dart';
import '../repositories/session_repository.dart';

/// Use case for leaving a session
class LeaveSessionUseCase {
  final SessionRepository _repository;

  LeaveSessionUseCase(this._repository);

  Future<Result<void>> execute({
    required String sessionId,
    required String playerId,
  }) async {
    try {
      await _repository.leaveSession(sessionId: sessionId, playerId: playerId);
      return Result.success(null);
    } catch (e) {
      return Result.failure('Falha ao sair da sessão: ${e.toString()}');
    }
  }
}
