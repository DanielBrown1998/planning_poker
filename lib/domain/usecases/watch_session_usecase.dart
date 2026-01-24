import '../entities/session.dart';
import '../repositories/session_repository.dart';

/// Use case for watching session updates in real-time
class WatchSessionUseCase {
  final SessionRepository _repository;

  WatchSessionUseCase(this._repository);

  Stream<Session?> execute(String sessionId) {
    return _repository.watchSession(sessionId);
  }
}
