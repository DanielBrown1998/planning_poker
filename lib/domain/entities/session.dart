import 'player.dart';
import 'played_card.dart';

/// Represents the current state of a Planning Poker session
enum SessionState {
  waiting, // Waiting for players to join
  voting, // Players are selecting cards
  revealed, // Cards are revealed
}

/// Represents a Planning Poker session
class Session {
  final String id;
  final String sessionKey;
  final String hostId;
  final String name;
  final SessionState state;
  final List<Player> players;
  final Map<String, PlayedCard> playedCards;
  final DateTime createdAt;

  const Session({
    required this.id,
    required this.sessionKey,
    required this.hostId,
    required this.name,
    required this.state,
    required this.players,
    required this.playedCards,
    required this.createdAt,
  });

  bool get allPlayersVoted {
    if (players.isEmpty) return false;
    return players.every((player) => playedCards.containsKey(player.id));
  }

  bool get canReveal => playedCards.isNotEmpty;

  Session copyWith({
    String? id,
    String? sessionKey,
    String? hostId,
    String? name,
    SessionState? state,
    List<Player>? players,
    Map<String, PlayedCard>? playedCards,
    DateTime? createdAt,
  }) {
    return Session(
      id: id ?? this.id,
      sessionKey: sessionKey ?? this.sessionKey,
      hostId: hostId ?? this.hostId,
      name: name ?? this.name,
      state: state ?? this.state,
      players: players ?? this.players,
      playedCards: playedCards ?? this.playedCards,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sessionKey': sessionKey,
      'hostId': hostId,
      'name': name,
      'state': state.name,
      'players': {for (var p in players) p.id: p.toJson()},
      'playedCards': playedCards.map((k, v) => MapEntry(k, v.toJson())),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Session.fromJson(Map<String, dynamic> json) {
    final playersMap = json['players'] as Map<dynamic, dynamic>? ?? {};
    final cardsMap = json['playedCards'] as Map<dynamic, dynamic>? ?? {};

    return Session(
      id: json['id'] as String,
      sessionKey: json['sessionKey'] as String,
      hostId: json['hostId'] as String,
      name: json['name'] as String,
      state: SessionState.values.firstWhere(
        (e) => e.name == json['state'],
        orElse: () => SessionState.waiting,
      ),
      players: playersMap.entries
          .map((e) => Player.fromJson(Map<String, dynamic>.from(e.value)))
          .toList(),
      playedCards: cardsMap.map(
        (k, v) => MapEntry(
          k.toString(),
          PlayedCard.fromJson(Map<String, dynamic>.from(v)),
        ),
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  @override
  String toString() =>
      'Session(id: $id, sessionKey: $sessionKey, name: $name, state: $state, players: ${players.length})';
}
