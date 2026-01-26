import 'package:planning_poker/domain/entities/entities.dart';

/// Estados da tela Home
sealed class HomeState {
  const HomeState();
}

/// Estado inicial - aguardando ação do usuário
class HomeInitial extends HomeState {
  const HomeInitial();
}

/// Estado de carregamento - criando ou entrando em sessão
class HomeLoading extends HomeState {
  const HomeLoading();
}

/// Estado de erro
class HomeError extends HomeState {
  final String message;
  const HomeError(this.message);
}

/// Estado de sucesso - sessão criada ou entrou com sucesso
class HomeSuccess extends HomeState {
  final Session session;
  final Player player;
  const HomeSuccess({required this.session, required this.player});
}
