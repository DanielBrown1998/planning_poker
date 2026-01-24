import '../entities/session.dart';
import '../entities/player.dart';

/// Repository interface for session operations
abstract class SessionRepository {
  /// Creates a new session and returns the session
  Future<Session> createSession({required String name, required Player host});

  /// Joins an existing session by session key
  Future<Session?> joinSession({
    required String sessionKey,
    required Player player,
  });

  /// Leaves a session
  Future<void> leaveSession({
    required String sessionId,
    required String playerId,
  });

  /// Gets a stream of session updates
  Stream<Session?> watchSession(String sessionId);

  /// Gets a session by its key
  Future<Session?> getSessionByKey(String sessionKey);

  /// Plays a card in the session
  Future<void> playCard({
    required String sessionId,
    required String playerId,
    required String playerName,
    required String cardValue,
  });

  /// Reveals all cards in the session
  Future<void> revealCards(String sessionId);

  /// Resets the round (clears all played cards)
  Future<void> resetRound(String sessionId);

  /// Deletes a session
  Future<void> deleteSession(String sessionId);
}
