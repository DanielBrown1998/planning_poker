import 'package:uuid/uuid.dart';

import '../../core/utils/session_key_generator.dart';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/session_repository.dart';
import '../datasources/firebase_session_datasource.dart';

/// Implementation of SessionRepository using Firebase
class FirebaseSessionRepository implements SessionRepository {
  final FirebaseSessionDataSource _dataSource;
  final Uuid _uuid;

  FirebaseSessionRepository({
    required FirebaseSessionDataSource dataSource,
    Uuid? uuid,
  }) : _dataSource = dataSource,
       _uuid = uuid ?? const Uuid();

  @override
  Future<Session> createSession({
    required String name,
    required Player host,
  }) async {
    final sessionId = _uuid.v4();
    final sessionKey = SessionKeyGenerator.generate();

    final session = Session(
      id: sessionId,
      sessionKey: sessionKey,
      hostId: host.id,
      name: name,
      state: SessionState.voting,
      players: [host.copyWith(isHost: true)],
      playedCards: {},
      createdAt: DateTime.now(),
    );

    await _dataSource.createSession(session);
    return session;
  }

  @override
  Future<Session?> joinSession({
    required String sessionKey,
    required Player player,
  }) async {
    final sessionId = await _dataSource.getSessionIdByKey(
      sessionKey.toUpperCase(),
    );
    if (sessionId == null) {
      return null;
    }

    final session = await _dataSource.getSession(sessionId);
    if (session == null) {
      return null;
    }

    // Check if player already in session
    final existingPlayer = session.players.any((p) => p.id == player.id);
    if (!existingPlayer) {
      await _dataSource.addPlayer(sessionId, player);
    }

    return await _dataSource.getSession(sessionId);
  }

  @override
  Future<void> leaveSession({
    required String sessionId,
    required String playerId,
  }) async {
    final session = await _dataSource.getSession(sessionId);
    if (session == null) return;

    await _dataSource.removePlayer(sessionId, playerId);

    // If host leaves, delete the session
    if (session.hostId == playerId) {
      await _dataSource.deleteSession(sessionId, session.sessionKey);
    }
  }

  @override
  Stream<Session?> watchSession(String sessionId) {
    return _dataSource.watchSession(sessionId);
  }

  @override
  Future<Session?> getSessionByKey(String sessionKey) async {
    final sessionId = await _dataSource.getSessionIdByKey(
      sessionKey.toUpperCase(),
    );
    if (sessionId == null) return null;
    return await _dataSource.getSession(sessionId);
  }

  @override
  Future<void> playCard({
    required String sessionId,
    required String playerId,
    required String playerName,
    required String cardValue,
  }) async {
    final card = PlayedCard(
      playerId: playerId,
      playerName: playerName,
      cardValue: cardValue,
      playedAt: DateTime.now(),
    );
    await _dataSource.playCard(sessionId, card);
  }

  @override
  Future<void> revealCards(String sessionId) async {
    await _dataSource.updateSessionState(sessionId, SessionState.revealed);
  }

  @override
  Future<void> resetRound(String sessionId) async {
    await _dataSource.clearPlayedCards(sessionId);
  }

  @override
  Future<void> deleteSession(String sessionId) async {
    final session = await _dataSource.getSession(sessionId);
    if (session != null) {
      await _dataSource.deleteSession(sessionId, session.sessionKey);
    }
  }
}
