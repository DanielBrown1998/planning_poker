import 'package:planning_poker/domain/entities/entities.dart';

/// Estados da tela de Jogo
sealed class GameScreenState {
  const GameScreenState();
}

/// Estado inicial - carregando dados da sessão
class GameScreenLoading extends GameScreenState {
  const GameScreenLoading();
}

/// Estado ativo - jogando
class GameScreenActive extends GameScreenState {
  final Session session;
  final Player currentPlayer;
  final String? selectedCard;

  const GameScreenActive({
    required this.session,
    required this.currentPlayer,
    this.selectedCard,
  });

  /// Cria uma cópia com novos valores
  GameScreenActive copyWith({
    Session? session,
    Player? currentPlayer,
    String? selectedCard,
  }) {
    return GameScreenActive(
      session: session ?? this.session,
      currentPlayer: currentPlayer ?? this.currentPlayer,
      selectedCard: selectedCard ?? this.selectedCard,
    );
  }
}

/// Estado de erro
class GameScreenError extends GameScreenState {
  final String message;
  final Session? lastSession;
  final Player? currentPlayer;

  const GameScreenError({
    required this.message,
    this.lastSession,
    this.currentPlayer,
  });
}

/// Estado de sessão encerrada
class GameScreenSessionEnded extends GameScreenState {
  const GameScreenSessionEnded();
}
