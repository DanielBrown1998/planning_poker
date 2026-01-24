import '../../core/result/result.dart';
import '../repositories/session_repository.dart';

/// Use case for revealing all cards in a session
class RevealCardsUseCase {
  final SessionRepository _repository;

  RevealCardsUseCase(this._repository);

  Future<Result<void>> execute(String sessionId) async {
    try {
      await _repository.revealCards(sessionId);
      return Result.success(null);
    } catch (e) {
      return Result.failure('Falha ao revelar cartas: ${e.toString()}');
    }
  }
}
