import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/entities.dart';

/// Data source for Firebase Realtime Database operations
class FirebaseSessionDataSource {
  final FirebaseDatabase _database;

  FirebaseSessionDataSource({FirebaseDatabase? database})
    : _database = database ?? FirebaseDatabase.instance;

  DatabaseReference get _sessionsRef => _database.ref('sessions');
  DatabaseReference get _sessionKeysRef => _database.ref('sessionKeys');

  /// Creates a new session in Firebase
  Future<void> createSession(Session session) async {
    // Save session data
    await _sessionsRef.child(session.id).set(session.toJson());

    // Create session key mapping for quick lookup
    await _sessionKeysRef.child(session.sessionKey).set(session.id);
  }

  /// Gets a session by ID
  Future<Session?> getSession(String sessionId) async {
    final snapshot = await _sessionsRef.child(sessionId).get();
    if (!snapshot.exists || snapshot.value == null) {
      return null;
    }
    return Session.fromJson(Map<String, dynamic>.from(snapshot.value as Map));
  }

  /// Gets a session ID by session key
  Future<String?> getSessionIdByKey(String sessionKey) async {
    final snapshot = await _sessionKeysRef.child(sessionKey).get();
    if (!snapshot.exists || snapshot.value == null) {
      return null;
    }
    return snapshot.value as String;
  }

  /// Adds a player to a session
  Future<void> addPlayer(String sessionId, Player player) async {
    await _sessionsRef
        .child(sessionId)
        .child('players')
        .child(player.id)
        .set(player.toJson());
  }

  /// Removes a player from a session
  Future<void> removePlayer(String sessionId, String playerId) async {
    await _sessionsRef
        .child(sessionId)
        .child('players')
        .child(playerId)
        .remove();

    // Also remove their played card
    await _sessionsRef
        .child(sessionId)
        .child('playedCards')
        .child(playerId)
        .remove();
  }

  /// Plays a card
  Future<void> playCard(String sessionId, PlayedCard card) async {
    await _sessionsRef
        .child(sessionId)
        .child('playedCards')
        .child(card.playerId)
        .set(card.toJson());
  }

  /// Updates session state
  Future<void> updateSessionState(String sessionId, GameState state) async {
    await _sessionsRef.child(sessionId).child('state').set(state.name);
  }

  /// Clears all played cards (reset round)
  Future<void> clearPlayedCards(String sessionId) async {
    await _sessionsRef.child(sessionId).child('playedCards').remove();

    await updateSessionState(sessionId, GameState.voting);
  }

  /// Deletes a session
  Future<void> deleteSession(String sessionId, String sessionKey) async {
    await _sessionsRef.child(sessionId).remove();
    await _sessionKeysRef.child(sessionKey).remove();
  }

  /// Watches a session for real-time updates
  Stream<Session?> watchSession(String sessionId) {
    debugPrint('🔥 Firebase watchSession chamado para: $sessionId');
    return _sessionsRef.child(sessionId).onValue.map((event) {
      debugPrint(
        '🔥 Firebase onValue recebeu evento - exists: ${event.snapshot.exists}',
      );
      if (!event.snapshot.exists || event.snapshot.value == null) {
        return null;
      }
      return Session.fromJson(
        Map<String, dynamic>.from(event.snapshot.value as Map),
      );
    });
  }
}
