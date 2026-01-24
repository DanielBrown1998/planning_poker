import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/entities.dart';
import '../../domain/usecases/usecases.dart';

/// ViewModel for the Home screen
class HomeViewModel extends ChangeNotifier {
  final CreateSessionUseCase _createSessionUseCase;
  final JoinSessionUseCase _joinSessionUseCase;
  final Uuid _uuid;

  bool _isLoading = false;
  String? _error;
  Session? _currentSession;
  Player? _currentPlayer;

  HomeViewModel({
    required CreateSessionUseCase createSessionUseCase,
    required JoinSessionUseCase joinSessionUseCase,
    Uuid? uuid,
  }) : _createSessionUseCase = createSessionUseCase,
       _joinSessionUseCase = joinSessionUseCase,
       _uuid = uuid ?? const Uuid();

  bool get isLoading => _isLoading;
  String? get error => _error;
  Session? get currentSession => _currentSession;
  Player? get currentPlayer => _currentPlayer;
  bool get hasError => _error != null;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Creates a new session
  Future<bool> createSession({
    required String sessionName,
    required String playerName,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final player = Player(id: _uuid.v4(), name: playerName, isHost: true);

      final result = await _createSessionUseCase.execute(
        sessionName: sessionName,
        host: player,
      );

      return result.when(
        success: (session) {
          _currentSession = session;
          _currentPlayer = player;
          _setLoading(false);
          return true;
        },
        failure: (message) {
          _setError(message);
          _setLoading(false);
          return false;
        },
      );
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Joins an existing session
  Future<bool> joinSession({
    required String sessionKey,
    required String playerName,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final player = Player(id: _uuid.v4(), name: playerName, isHost: false);

      final result = await _joinSessionUseCase.execute(
        sessionKey: sessionKey.toUpperCase(),
        player: player,
      );

      return result.when(
        success: (session) {
          _currentSession = session;
          _currentPlayer = player;
          _setLoading(false);
          return true;
        },
        failure: (message) {
          _setError(message);
          _setLoading(false);
          return false;
        },
      );
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  void reset() {
    _currentSession = null;
    _currentPlayer = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}
