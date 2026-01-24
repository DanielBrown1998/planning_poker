/// Represents a card played by a player
class PlayedCard {
  final String playerId;
  final String playerName;
  final String? cardValue;
  final DateTime playedAt;

  const PlayedCard({
    required this.playerId,
    required this.playerName,
    this.cardValue,
    required this.playedAt,
  });

  bool get hasPlayed => cardValue != null;

  PlayedCard copyWith({
    String? playerId,
    String? playerName,
    String? cardValue,
    DateTime? playedAt,
  }) {
    return PlayedCard(
      playerId: playerId ?? this.playerId,
      playerName: playerName ?? this.playerName,
      cardValue: cardValue ?? this.cardValue,
      playedAt: playedAt ?? this.playedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'playerId': playerId,
      'playerName': playerName,
      'cardValue': cardValue,
      'playedAt': playedAt.toIso8601String(),
    };
  }

  factory PlayedCard.fromJson(Map<String, dynamic> json) {
    return PlayedCard(
      playerId: json['playerId'] as String,
      playerName: json['playerName'] as String,
      cardValue: json['cardValue'] as String?,
      playedAt: DateTime.parse(json['playedAt'] as String),
    );
  }

  @override
  String toString() =>
      'PlayedCard(playerId: $playerId, playerName: $playerName, cardValue: $cardValue)';
}
