/// Represents a player in a Planning Poker session
class Player {
  final String id;
  final String name;
  final bool isHost;

  const Player({required this.id, required this.name, this.isHost = false});

  Player copyWith({String? id, String? name, bool? isHost}) {
    return Player(
      id: id ?? this.id,
      name: name ?? this.name,
      isHost: isHost ?? this.isHost,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'isHost': isHost};
  }

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id'] as String,
      name: json['name'] as String,
      isHost: json['isHost'] as bool? ?? false,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Player && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Player(id: $id, name: $name, isHost: $isHost)';
}
