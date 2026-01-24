import '../../core/result/result.dart';
import '../repositories/session_repository.dart';

/// Use case for playing a card in a session
class PlayCardUseCase {
  final SessionRepository _repository;

  PlayCardUseCase(this._repository);

  Future<Result<void>> execute({
    required String sessionId,
    required String playerId,
    required String playerName,
    required String cardValue,
  }) async {
    try {
      await _repository.playCard(
        sessionId: sessionId,
        playerId: playerId,
        playerName: playerName,
        cardValue: cardValue,
      );
      return Result.success(null);
    } catch (e) {
      return Result.failure('Falha ao jogar carta: ${e.toString()}');
    }
  }
}
