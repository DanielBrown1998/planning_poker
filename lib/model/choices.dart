// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class ChoiceAndUser {
  String symbol;
  String value;
  String nome;
  ChoiceAndUser({
    required this.symbol,
    required this.value,
    required this.nome,
  });

  ChoiceAndUser copyWith({String? symbol, String? value, String? nome}) {
    return ChoiceAndUser(
      symbol: symbol ?? this.symbol,
      value: value ?? this.value,
      nome: nome ?? this.nome,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'symbol': symbol, 'value': value, 'nome': nome};
  }

  factory ChoiceAndUser.fromMap(Map<String, dynamic> map) {
    return ChoiceAndUser(
      symbol: map['symbol'] as String,
      value: map['value'] as String,
      nome: map['nome'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory ChoiceAndUser.fromJson(String source) =>
      ChoiceAndUser.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'ChoiceAndUser(symbol: $symbol, value: $value, nome: $nome)';

  @override
  bool operator ==(covariant ChoiceAndUser other) {
    if (identical(this, other)) return true;

    return other.symbol == symbol && other.value == value && other.nome == nome;
  }

  @override
  int get hashCode => symbol.hashCode ^ value.hashCode ^ nome.hashCode;
}
