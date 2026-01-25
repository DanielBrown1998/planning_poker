import 'package:planning_poker/domain/entities/session.dart';

sealed class SessionState {}

class SessionInitial extends SessionState {}

class SessionWaiting extends SessionState {}

class SessionLoading extends SessionState {}

class SessionError extends SessionState {
  final String message;
  SessionError(this.message);
}

class SessionVoting extends SessionState {}

class SessionRevealed extends SessionState {}

class SessionActive extends SessionState {
  final Session session;
  SessionActive(this.session);
}
