import '../../core/result/result.dart';
import '../repositories/session_repository.dart';

/// Use case for resetting a round (clearing all played cards)
class ResetRoundUseCase {
  final SessionRepository _repository;

  ResetRoundUseCase(this._repository);

  Future<Result<void>> execute(String sessionId) async {
    try {
      await _repository.resetRound(sessionId);
      return Result.success(null);
    } catch (e) {
      return Result.failure('Falha ao resetar rodada: ${e.toString()}');
    }
  }
}
