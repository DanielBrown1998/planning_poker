// session.dart

import 'player.dart';
import 'played_card.dart';

/// Represents the current state of a Planning Poker session
enum GameState {
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
  final GameState state;
  final List<Player> players;
  final Map<String, PlayedCard> playedCards;
  final DateTime createdAt;
  final String? errorMessage; // Para armazenar mensagens de erro

  const Session({
    required this.id,
    required this.sessionKey,
    required this.hostId,
    required this.name,
    required this.state,
    required this.players,
    required this.playedCards,
    required this.createdAt,
    this.errorMessage,
  });

  bool get allPlayersVoted {
    if (players.isEmpty) return false;
    return players.every((player) => playedCards.containsKey(player.id));
  }

  bool get canReveal => playedCards.isNotEmpty;

  factory Session.fromJson(Map<String, dynamic> json) {
    // Firebase retorna players como Map<playerId, playerData>, não como List
    final playersData = json['players'];
    List<Player> playersList = [];
    if (playersData != null) {
      final playersMap = Map<String, dynamic>.from(playersData as Map);
      playersList = playersMap.values
          .map((e) => Player.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    }

    // playedCards pode ser null se ninguém jogou ainda
    final playedCardsData = json['playedCards'];
    Map<String, PlayedCard> playedCardsMap = {};
    if (playedCardsData != null) {
      final cardsMap = Map<String, dynamic>.from(playedCardsData as Map);
      playedCardsMap = cardsMap.map(
        (key, value) => MapEntry(
          key,
          PlayedCard.fromJson(Map<String, dynamic>.from(value as Map)),
        ),
      );
    }

    return Session(
      id: json['id'] as String,
      sessionKey: json['sessionKey'] as String,
      hostId: json['hostId'] as String,
      name: json['name'] as String,
      state: GameState.values.firstWhere(
        (e) => e.name == json['state'],
        orElse: () => GameState.waiting,
      ),
      players: playersList,
      playedCards: playedCardsMap,
      createdAt: DateTime.parse(json['createdAt'] as String),
      errorMessage: json['errorMessage'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sessionKey': sessionKey,
      'hostId': hostId,
      'name': name,
      'state': state.name,
      // Salva players como Map<playerId, playerData> para consistência com Firebase
      'players': {for (var p in players) p.id: p.toJson()},
      'playedCards': playedCards.map(
        (key, value) => MapEntry(key, value.toJson()),
      ),
      'createdAt': createdAt.toIso8601String(),
      if (errorMessage != null) 'errorMessage': errorMessage,
    };
  }

  Session copyWith({
    String? id,
    String? sessionKey,
    String? hostId,
    String? name,
    GameState? state,
    List<Player>? players,
    Map<String, PlayedCard>? playedCards,
    DateTime? createdAt,
    String? errorMessage,
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
      errorMessage: errorMessage,
    );
  }

  // ... resto do toJson/fromJson
}
