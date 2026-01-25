// home_viewmodel.dart

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:planning_poker/presentation/commands/session_commands.dart';
import 'package:planning_poker/presentation/state/session_state.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/entities.dart';
import '../../domain/usecases/usecases.dart';

/// ViewModel for the Home screen
class HomeViewModel extends ChangeNotifier {
  final CreateSessionUseCase _createSessionUseCase;
  final JoinSessionUseCase _joinSessionUseCase;
  final Uuid _uuid;

  late SessionState _state;
  Player? _currentPlayer;
  HomeViewModel({
    required CreateSessionUseCase createSessionUseCase,
    required JoinSessionUseCase joinSessionUseCase,
    Uuid? uuid,
  }) : _createSessionUseCase = createSessionUseCase,
       _joinSessionUseCase = joinSessionUseCase,
       _uuid = uuid ?? const Uuid(),
       _state = SessionInitial();

  // Expõe o estado da session
  Player? get currentPlayer => _currentPlayer;
  SessionState get state => _state;
  // Getters delegados para facilitar uso na UI
  bool get isLoading => _state is SessionWaiting;
  bool get hasError => _state is SessionError;
  String? get error =>
      _state is SessionError ? (_state as SessionError).message : null;
  bool get hasActiveSession => _state is SessionActive;

  void clearError() {
    if (_state is SessionError) {
      emit(SessionInitial());
    }
  }

  void emit(SessionState state) {
    _state = state;
    notifyListeners();
  }

  /// Creates a new session
  Future<bool> createSession({
    required String sessionName,
    required String playerName,
  }) async {
    emit(SessionWaiting());

    try {
      final player = Player(id: _uuid.v4(), name: playerName, isHost: true);
      final result = await CreateSessionCommand(
        useCase: _createSessionUseCase,
        sessionName: sessionName,
        host: player,
      ).execute();

      if (result != null) {
        _currentPlayer = player;
        emit(SessionActive(result));
        return true;
      } else {
        emit(SessionError('Failed to create session'));
        return false;
      }
    } catch (e) {
      emit(SessionError(e.toString()));
      return false;
    }
  }

  /// Joins an existing session
  Future<bool> joinSession({
    required String sessionKey,
    required String playerName,
  }) async {
    emit(SessionWaiting());

    try {
      final player = Player(id: _uuid.v4(), name: playerName, isHost: false);

      final result = await JoinSessionCommand(
        useCase: _joinSessionUseCase,
        sessionKey: sessionKey,
        player: player,
      ).execute();

      if (result != null) {
        _currentPlayer = player;
        emit(SessionActive(result));
        return true;
      } else {
        emit(SessionError('Failed to join session'));
        return false;
      }
    } catch (e) {
      emit(SessionError(e.toString()));
      return false;
    }
  }

  void reset() {
    _currentPlayer = null;
    emit(SessionInitial());
  }
}
